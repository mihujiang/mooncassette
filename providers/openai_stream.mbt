// mooncassette/providers —— OpenAI 流式响应聚合。
//
// 目标：把一串 `chat.completion.chunk` 增量帧还原成一个**与非流式
// `chat.completion` 同形**的对象。这样做的意义在于——匹配、漂移检测、
// 成本核算、以及应用代码都不必区分「流式」与「非流式」两种形态。
//
// 帧本身仍然完整保留在 `Response.stream` 里，供需要逐帧重放的回放场景使用。

///|
/// 累积中的一个 tool call。
///
/// `arguments` 是**分片发送**的：每一帧给一小段 JSON 文本。因此这里只做
/// 字符串拼接，直到最后一帧才是一个完整可解析的 JSON——中途解析必然失败。
priv struct ToolCallAcc {
  index : Int
  mut call_id : String?
  mut kind : String?
  mut name : String?
  mut arguments : String
}

///|
/// 累积中的一个 choice。
priv struct ChoiceAcc {
  index : Int
  mut role : String?
  mut content : String
  /// 是否出现过 `content` 增量。
  ///
  /// 用于区分「内容确实是空字符串」与「服务端压根没发 content」——后者
  /// （例如纯 tool call 的响应）按 OpenAI 的约定应当写成 `null`。
  mut saw_content : Bool
  mut refusal : String
  mut saw_refusal : Bool
  mut finish_reason : String?
  calls : Array[ToolCallAcc]
}

///|
/// 聚合过程中的累积状态。
priv struct OpenAiStream {
  /// `id` / `model` / `created` / `system_fingerprint` 等元信息，取首次出现值。
  meta : Map[String, Json]
  choices : Array[ChoiceAcc]
  /// 最后一个携带 `usage` 的 chunk 里那个**原始** usage 对象。
  ///
  /// 保留原始对象而不是只留派生出来的两个整数，是为了让聚合体与非流式响应体
  /// 真正同形——非流式的 `body.usage` 里还有 `total_tokens` 等字段。
  mut usage : Json?
  /// 若流中出现了错误体（没有 `choices` 的帧），原样作为最终结果。
  mut error_body : Json?
}

///|
/// 解码 OpenAI 流式响应。
///
/// 输入是**完整**的 SSE 文本（即 `HttpResponse.body`）。之所以能这样做，
/// 是因为录制阶段已经把所有帧都拿到了；「真正逐块消费网络流」属于调用方的
/// HTTP 客户端职责，本项目只关心「这段字节流的内容是什么」。
pub fn decode_openai_stream_response(response : HttpResponse) -> @core.Response {
  let acc : OpenAiStream = {
    meta: Map([]),
    choices: [],
    usage: None,
    error_body: None,
  }
  let frames = @stream.parse(response.body)
  for frame in frames {
    absorb_openai(acc, frame)
  }
  {
    status: response.status,
    body: openai_stream_body(acc),
    usage: openai_usage(acc),
    stream: Some(frames),
  }
}

///|
/// 从累积到的原始 usage 对象里抽出统一模型使用的用量。
///
/// 两侧都有才给出：`Usage` 是「输入 + 输出」两个整数，缺一半时补 0 会把
/// 「没上报」写成「上报了 0」，那是错误信息而不是缺失信息。
fn openai_usage(acc : OpenAiStream) -> @core.Usage? {
  let fields = match acc.usage {
    Some(value) => as_object(value)
    None => None
  }
  match fields {
    Some(usage) =>
      match
        (
          int_field(usage, "prompt_tokens"),
          int_field(usage, "completion_tokens"),
        ) {
        (Some(input), Some(output)) => Some(@core.Usage::new(input, output))
        _ => None
      }
    None => None
  }
}

///|
/// 吸收一帧。
fn absorb_openai(acc : OpenAiStream, frame : @core.StreamFrame) -> Unit {
  let payload = match frame_payload(frame) {
    Some(value) => value
    None => return
  }
  let fields = match as_object(payload) {
    Some(value) => value
    None => return
  }
  if fields.get("choices") is None {
    // 没有 `choices` 的对象只可能是错误体，直接作为最终结果保留。
    match fields.get("error") {
      Some(_) => acc.error_body = Some(payload)
      None => ()
    }
    return
  }
  // 元信息取首次出现值：后续 chunk 里这些字段通常缺席，或原样重复。
  for key in ["id", "model", "created", "system_fingerprint"] {
    if acc.meta.get(key) is None {
      match fields.get(key) {
        Some(value) => acc.meta.set(key, value)
        None => ()
      }
    }
  }
  // 只有最后一帧（且请求里显式要求 include_usage）才带 usage，
  // 其余帧里它是 `null`；`as_object(null)` 返回 `None`，因此不会被覆盖掉。
  match fields.get("usage") {
    Some(value) =>
      match as_object(value) {
        Some(_) => acc.usage = Some(value)
        None => ()
      }
    None => ()
  }
  match fields.get("choices") {
    Some(Array(items)) =>
      for item in items {
        absorb_choice(acc.choices, item)
      }
    _ => ()
  }
}

///|
/// 吸收一个 choice。
fn absorb_choice(choices : Array[ChoiceAcc], value : Json) -> Unit {
  let fields = match as_object(value) {
    Some(value) => value
    None => return
  }
  let choice = choice_for(choices, int_field_or(fields, "index", 0))
  match nested_object(fields, "delta") {
    Some(delta) => {
      match string_field(delta, "role") {
        Some(role) => choice.role = Some(role)
        None => ()
      }
      match delta.get("content") {
        Some(String(text)) => {
          choice.content = choice.content + text
          choice.saw_content = true
        }
        _ => ()
      }
      match delta.get("refusal") {
        Some(String(text)) => {
          choice.refusal = choice.refusal + text
          choice.saw_refusal = true
        }
        _ => ()
      }
      match delta.get("tool_calls") {
        Some(Array(items)) =>
          for item in items {
            absorb_tool_call(choice.calls, item)
          }
        _ => ()
      }
    }
    None => ()
  }
  match string_field(fields, "finish_reason") {
    Some(reason) => choice.finish_reason = Some(reason)
    None => ()
  }
}

///|
/// 吸收一段 tool call 增量。
fn absorb_tool_call(calls : Array[ToolCallAcc], value : Json) -> Unit {
  let fields = match as_object(value) {
    Some(value) => value
    None => return
  }
  let call = tool_call_for(calls, int_field_or(fields, "index", 0))
  match string_field(fields, "id") {
    Some(value) => call.call_id = Some(value)
    None => ()
  }
  match string_field(fields, "type") {
    Some(value) => call.kind = Some(value)
    None => ()
  }
  match nested_object(fields, "function") {
    Some(function_fields) => {
      match string_field(function_fields, "name") {
        Some(value) => call.name = Some(value)
        None => ()
      }
      match string_field(function_fields, "arguments") {
        Some(value) => call.arguments = call.arguments + value
        None => ()
      }
    }
    None => ()
  }
}

///|
/// 取（必要时新建）指定下标的 choice 累积器。
fn choice_for(choices : Array[ChoiceAcc], index : Int) -> ChoiceAcc {
  for choice in choices {
    if choice.index == index {
      return choice
    }
  }
  let fresh : ChoiceAcc = {
    index,
    role: None,
    content: "",
    saw_content: false,
    refusal: "",
    saw_refusal: false,
    finish_reason: None,
    calls: [],
  }
  choices.push(fresh)
  fresh
}

///|
/// 取（必要时新建）指定下标的 tool call 累积器。
fn tool_call_for(calls : Array[ToolCallAcc], index : Int) -> ToolCallAcc {
  for call in calls {
    if call.index == index {
      return call
    }
  }
  let fresh : ToolCallAcc = {
    index,
    call_id: None,
    kind: None,
    name: None,
    arguments: "",
  }
  calls.push(fresh)
  fresh
}

///|
/// 组装最终的响应体。
fn openai_stream_body(acc : OpenAiStream) -> Json {
  match acc.error_body {
    Some(error) => return error
    None => ()
  }
  sort_choices(acc.choices)
  let out : Map[String, Json] = Map([])
  for key in acc.meta.keys() {
    match acc.meta.get(key) {
      Some(value) => out.set(key, value)
      None => ()
    }
  }
  out.set("object", Json::string("chat.completion"))
  let items : Array[Json] = []
  for choice in acc.choices {
    items.push(choice_json(choice))
  }
  out.set("choices", Json::array(items))
  // 非流式响应体里 `usage` 就在 body 内，聚合体保持同形，
  // 因此 `body.usage` 与 `Response.usage` 同时存在、互为一致。
  match acc.usage {
    Some(value) => out.set("usage", value)
    None => ()
  }
  Json::object(out)
}

///|
fn choice_json(choice : ChoiceAcc) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("index", json_int(choice.index))
  let message : Map[String, Json] = Map([])
  message.set(
    "role",
    Json::string(
      match choice.role {
        Some(role) => role
        None => "assistant"
      },
    ),
  )
  message.set(
    "content",
    if choice.saw_content {
      Json::string(choice.content)
    } else {
      Json::null()
    },
  )
  if choice.saw_refusal {
    message.set("refusal", Json::string(choice.refusal))
  }
  if choice.calls.length() > 0 {
    let calls : Array[Json] = []
    for call in choice.calls {
      calls.push(tool_call_json(call))
    }
    message.set("tool_calls", Json::array(calls))
  }
  fields.set("message", Json::object(message))
  fields.set(
    "finish_reason",
    match choice.finish_reason {
      Some(reason) => Json::string(reason)
      None => Json::null()
    },
  )
  Json::object(fields)
}

///|
fn tool_call_json(call : ToolCallAcc) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("index", json_int(call.index))
  match call.call_id {
    Some(value) => fields.set("id", Json::string(value))
    None => ()
  }
  fields.set(
    "type",
    Json::string(
      match call.kind {
        Some(value) => value
        None => "function"
      },
    ),
  )
  let function_fields : Map[String, Json] = Map([])
  function_fields.set(
    "name",
    Json::string(
      match call.name {
        Some(value) => value
        None => ""
      },
    ),
  )
  function_fields.set("arguments", Json::string(call.arguments))
  fields.set("function", Json::object(function_fields))
  Json::object(fields)
}

///|
/// 按下标升序排列 choice。
///
/// 自实现插入排序而不依赖库的排序：要求**稳定**，且 `Map` / 数组的默认顺序
/// 不保证跨运行一致，而聚合结果必须能被测试逐字断言。
fn sort_choices(choices : Array[ChoiceAcc]) -> Unit {
  for i = 1; i < choices.length(); i = i + 1 {
    let value = choices[i]
    let mut j = i - 1
    while j >= 0 && choices[j].index > value.index {
      choices[j + 1] = choices[j]
      j = j - 1
    }
    choices[j + 1] = value
  }
}
