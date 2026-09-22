///|
/// 请求/响应的互转层：`mizchi/llm` 的数据结构与 mooncassette 的记录之间。
///
/// 这一层是纯函数 —— 不碰网络、不碰会话、不抛错。适配层所有「会出事」的部分
/// （回放、录制、匹配失败）都在 `adapter.mbt` 里，这里是它的地基。
///
/// 一个必须守住的约束：**请求体的形状要与 `mizchi/llm` 自己发出去的一模一样**。
/// 指纹是从请求体算出来的，差一个字段就命中不了用它录下来的磁带。
/// 所以 `openai_body` 是 `mizchi/llm/openai` 里 `build_openai_body` 的等价复刻 ——
/// 字段顺序无关紧要（走的是规范化后的 JSON），字段集合与取值必须一致。
///
/// 这里没有直接复用 `mizchi/llm/openai` 的 `build_openai_body`，是因为那个包
/// 引出了 `mizchi/x/http` 与 `moonbitlang/async` 的 socket 实现。适配层只骑在
/// `mizchi/llm` 的顶层包上，编译期不需要异步运行时。

///|
/// 复刻 `mizchi/llm/openai` 的请求体形状：始终流式，并索取用量。
///
/// `stream_options.include_usage` 是精确计的来源 —— 少了它，OpenAI 兼容端点
/// 不会在流尾回报用量，我们就只能回去猜。
pub fn openai_body(
  model : String,
  max_tokens : Int,
  system_prompt : String,
  messages : Array[@llm.Message],
  tools : Array[@llm.ToolDef],
) -> Json {
  let body : Map[String, Json] = Map([])
  body["model"] = model.to_json()
  body["max_tokens"] = Json::number(max_tokens.to_double())
  body["stream"] = Json::boolean(true)
  let stream_options : Map[String, Json] = Map([])
  stream_options["include_usage"] = Json::boolean(true)
  body["stream_options"] = Json::object(stream_options)
  let msgs : Array[Json] = []
  if !system_prompt.is_empty() {
    msgs.push(@llm.Message::system(system_prompt).to_openai_json())
  }
  for msg in messages {
    msgs.push(msg.to_openai_json())
  }
  body["messages"] = Json::array(msgs)
  if !tools.is_empty() {
    body["tools"] = Json::array(tools.map(@llm.ToolDef::to_openai_json))
  }
  Json::object(body)
}

///|
/// `Array[Message]` → mooncassette 请求。
///
/// 配套的 `reported_usage` 拿同一个请求去磁带里查用量，两者必须用同一份
/// 请求，否则查不到。
pub fn request_of_messages(
  provider : String,
  model : String,
  messages : Array[@llm.Message],
  tools? : Array[@llm.ToolDef],
  max_tokens? : Int = 1024,
  system_prompt? : String = "",
) -> @core.Request {
  @core.Request::new(
    provider,
    model,
    openai_body(model, max_tokens, system_prompt, messages, tools.unwrap_or([])),
  )
}

///|
/// 从请求体把消息读回来。用于诊断：磁带对不上时，先看看这一轮到底发了什么。
pub fn messages_of_request(request : @core.Request) -> Array[@llm.Message] {
  let out : Array[@llm.Message] = []
  let msgs = match @llm.json_get_array(request.body, "messages") {
    Some(arr) => arr
    None => return out
  }
  for msg in msgs {
    let role = match @llm.json_get_string(msg, "role") {
      Some(r) => @llm.Role::from_string(r)
      None => continue
    }
    let content = match @llm.json_get_string(msg, "content") {
      Some(c) => c
      None => ""
    }
    out.push(@llm.Message::text(role, content))
  }
  out
}

///|
/// mooncassette 用量 → `mizchi/llm` 用量。
pub fn to_llm_usage(usage : @core.Usage) -> @llm.Usage {
  { input_tokens: usage.input_tokens, output_tokens: usage.output_tokens }
}

///|
/// `mizchi/llm` 用量 → mooncassette 用量。
pub fn to_core_usage(usage : @llm.Usage) -> @core.Usage {
  @core.Usage::new(usage.input_tokens, usage.output_tokens)
}

///|
/// 把一条流式帧解析成 `mizchi/llm` 的流事件。
///
/// 形状与 `mizchi/llm/openai` 的 `parse_openai_event` 对齐（同为 OpenAI 兼容
/// 协议），但只依赖顶层包的 `json_get_*`，不引网络子包。
///
/// 用量帧（`choices` 为空、只带 `usage`）解析为 `MessageEnd`：这是协议里
/// 「说完了，这是账」的那一帧。
pub fn parse_frame(data : String) -> @llm.StreamEvent? {
  let json = @json.parse(data) catch { _ => return None }
  match @llm.json_get_object(json, "error") {
    Some(err) => {
      let msg = match @llm.json_get_string(err, "message") {
        Some(m) => m
        None => "Unknown error"
      }
      return Some(@llm.StreamEvent::Error(msg))
    }
    None => ()
  }
  let usage_of = fn(json : Json) -> @llm.Usage? {
    match @llm.json_get_object(json, "usage") {
      Some(u) => {
        let inp = field_int(u, "prompt_tokens")
        let out = field_int(u, "completion_tokens")
        if inp == 0 && out == 0 {
          None
        } else {
          Some({ input_tokens: inp, output_tokens: out })
        }
      }
      None => None
    }
  }
  let choices = match @llm.json_get_array(json, "choices") {
    Some(arr) => arr
    None =>
      match usage_of(json) {
        Some(usage) =>
          return Some(
            @llm.StreamEvent::MessageEnd(
              finish_reason=@llm.FinishReason::Stop,
              usage=Some(usage),
            ),
          )
        None => return None
      }
  }
  if choices.is_empty() {
    match usage_of(json) {
      Some(usage) =>
        return Some(
          @llm.StreamEvent::MessageEnd(
            finish_reason=@llm.FinishReason::Stop,
            usage=Some(usage),
          ),
        )
      None => return None
    }
  }
  let choice = choices[0]
  match @llm.json_get_string(choice, "finish_reason") {
    Some(reason) =>
      return Some(
        @llm.StreamEvent::MessageEnd(
          finish_reason=@llm.FinishReason::from_string(reason),
          usage=usage_of(json),
        ),
      )
    None => ()
  }
  let delta = match @llm.json_get_object(choice, "delta") {
    Some(d) => d
    None => return None
  }
  match @llm.json_get_string(delta, "content") {
    Some(text) =>
      if !text.is_empty() {
        return Some(@llm.StreamEvent::TextDelta(text))
      }
    None => ()
  }
  match @llm.json_get_array(delta, "tool_calls") {
    Some(tool_calls) =>
      for tc in tool_calls {
        let index = field_int(tc, "index")
        let name = match @llm.json_get_object(tc, "function") {
          Some(func) =>
            match @llm.json_get_string(func, "name") {
              Some(n) => n
              None => ""
            }
          None => ""
        }
        if !name.is_empty() {
          return Some(
            @llm.StreamEvent::ToolCallStart(id=index.to_string(), name~),
          )
        }
        let args = match @llm.json_get_object(tc, "function") {
          Some(func) =>
            match @llm.json_get_string(func, "arguments") {
              Some(a) => a
              None => ""
            }
          None => ""
        }
        if !args.is_empty() {
          return Some(
            @llm.StreamEvent::ToolCallDelta(
              id=index.to_string(),
              input_delta=args,
            ),
          )
        }
      }
    None => ()
  }
  None
}

///|
fn field_int(json : Json, field : String) -> Int {
  match @llm.json_get_int(json, field) {
    Some(n) => n
    None => 0
  }
}

///|
/// 会话历史累积的文本：把一次流式响应里的所有 `TextDelta` 拼起来。
pub fn text_of_frames(frames : Array[@core.StreamFrame]) -> String {
  let buf = StringBuilder::new()
  for frame in frames {
    match parse_frame(frame.data) {
      Some(@llm.StreamEvent::TextDelta(text)) => buf.write_string(text)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// 汇总一次流式响应：文本、结束原因、真实用量。
///
/// 结束原因取**最后**一帧说了算：OpenAI 兼容端点在正常结束时先发一帧
/// 带 `finish_reason=stop` 的增量，再补一帧只带 `usage` 的账目帧 ——
/// 后者把前者覆盖成 `Stop` 是错的，所以只认显式给了 `finish_reason` 的那帧。
pub fn summarize_frames(
  frames : Array[@core.StreamFrame],
) -> (@llm.FinishReason, @llm.Usage?) {
  let mut finish : @llm.FinishReason = @llm.FinishReason::Stop
  let mut reported : @llm.Usage? = None
  for frame in frames {
    match parse_frame(frame.data) {
      Some(@llm.StreamEvent::MessageEnd(finish_reason~, usage~)) => {
        match finish_reason {
          @llm.FinishReason::Stop =>
            // 账目帧报的也可能是 Stop，但它没带 finish_reason，
            // 分辨不了，只好都不动 —— 见上面注释。
            ()
          _ => finish = finish_reason
        }
        match usage {
          Some(u) => reported = Some(u)
          None => ()
        }
      }
      _ => ()
    }
  }
  (finish, reported)
}

///|
/// 响应 → `mizchi/llm` 的 `CollectResult`。
///
/// 流式与非流式（录制时可能两种都有）走同一个出口，下游拿到的形态一致。
pub fn collect_result_of_response(
  response : @core.Response,
) -> @llm.CollectResult {
  match response.stream {
    Some(frames) => {
      let text = text_of_frames(frames)
      let (finish, usage) = summarize_frames(frames)
      let reported = match usage {
        Some(u) => Some(to_core_usage(u))
        None => response.usage
      }
      {
        text,
        tool_calls: [],
        finish_reason: finish,
        usage: match reported {
          Some(u) => Some(to_llm_usage(u))
          None => None
        },
      }
    }
    None => {
      let text = body_text(response.body)
      let finish = match @llm.json_get_array(response.body, "choices") {
        Some(choices) =>
          if choices.is_empty() {
            @llm.FinishReason::Stop
          } else {
            match @llm.json_get_string(choices[0], "finish_reason") {
              Some(r) => @llm.FinishReason::from_string(r)
              None => @llm.FinishReason::Stop
            }
          }
        None => @llm.FinishReason::Stop
      }
      {
        text,
        tool_calls: [],
        finish_reason: finish,
        usage: match response.usage {
          Some(u) => Some(to_llm_usage(u))
          None => None
        },
      }
    }
  }
}

///|
/// 非流式响应体里 `choices[0].message.content`。
fn body_text(body : Json) -> String {
  let choices = match @llm.json_get_array(body, "choices") {
    Some(arr) => arr
    None => return ""
  }
  if choices.is_empty() {
    return ""
  }
  let message = match @llm.json_get_object(choices[0], "message") {
    Some(m) => m
    None => return ""
  }
  match @llm.json_get_string(message, "content") {
    Some(c) => c
    None => ""
  }
}

///|
/// **精确的 token 用量**：从磁带里读 provider 真正上报过的数字。
///
/// 与之相对，`mizchi/llm` 的 `Message::estimate_tokens` 是 `(字符数 + 3) / 4`
/// 的猜测 —— 它在没有记录时是合理的退路，但不该是默认答案。同一个会话，
/// 猜出来的数字和账单上的数字能差出几十个百分点，而按量计费、按量限额、
/// 按量告警这三件事全都建立在这个数字上。
///
/// 找不到匹配记录时返回 `None` —— 不猜。调用方要退路自己接估算。
pub fn reported_usage(
  cassette : @core.Cassette,
  request : @core.Request,
) -> @core.Usage? {
  for interaction in cassette.interactions {
    if interaction.request.provider == request.provider &&
      interaction.request.model == request.model &&
      interaction.request.body == request.body {
      // 流式记录里用量藏在帧里，先看显式字段，再退回帧汇总。
      match interaction.response.usage {
        Some(u) => return Some(u)
        None =>
          match interaction.response.stream {
            Some(frames) =>
              match summarize_frames(frames) {
                (_, Some(u)) => return Some(to_core_usage(u))
                _ => ()
              }
            None => ()
          }
      }
    }
  }
  None
}

///|
/// 估算与上报摆在一起：返回 `(估算, 上报)`。
///
/// 这是给人看的 —— 页面上、日志里并排显示两个数字，差多少一眼可见。
/// 适配层的存在意义有一半在这个差值上。
pub fn token_drift(
  messages : Array[@llm.Message],
  reported : @core.Usage,
) -> (Int, Int) {
  let mut estimated = 0
  for message in messages {
    estimated = estimated + message.estimate_tokens()
  }
  (estimated, reported.input_tokens)
}
