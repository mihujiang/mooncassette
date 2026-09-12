// mooncassette/providers —— Anthropic 流式响应聚合。
//
// Anthropic 的流是**带类型的命名事件**（`message_start`、`content_block_delta`、
// `message_delta` ……），不同于 OpenAI 的「一串同形 chunk」。因此这里的聚合
// 是按事件类型分别累积，最后拼成一个与非流式 `message` 同形的对象。
//
// 帧本身完整保留在 `Response.stream` 里。

///|
/// 累积中的一个 content block。
///
/// 一个 block 在流里是「start → 若干 delta → stop」三段，因此这里按类型
/// 分别累积，而不是试图在每帧上就地合并。
priv struct BlockAcc {
  index : Int
  /// `text` / `tool_use` / `thinking`。
  mut kind : String?
  mut text : String
  mut thinking : String
  mut signature : String
  mut tool_id : String?
  mut tool_name : String?
  /// `input_json_delta` 的 `partial_json` 拼接结果。
  mut partial_json : String
}

///|
/// 聚合过程中的累积状态。
priv struct AnthropicStream {
  /// `message_start` 里的 `message` 对象（只取一次）。
  mut message : Map[String, Json]
  blocks : Array[BlockAcc]
  mut stop_reason : String?
  mut stop_sequence : String?
  mut input_tokens : Int?
  /// `message_delta` 里的 `output_tokens` 是**累计值**，取最后一次即可。
  mut output_tokens : Int?
  mut error_body : Json?
}

///|
/// 解码 Anthropic 流式响应。
pub fn decode_anthropic_stream_response(
  response : HttpResponse,
) -> @core.Response {
  let acc : AnthropicStream = {
    message: Map([]),
    blocks: [],
    stop_reason: None,
    stop_sequence: None,
    input_tokens: None,
    output_tokens: None,
    error_body: None,
  }
  let frames = @stream.parse(response.body)
  for frame in frames {
    absorb_anthropic(acc, frame)
  }
  {
    status: response.status,
    body: anthropic_stream_body(acc),
    usage: anthropic_stream_usage(acc),
    stream: Some(frames),
  }
}

///|
/// 吸收一帧，按 `type` 分派。
fn absorb_anthropic(acc : AnthropicStream, frame : @core.StreamFrame) -> Unit {
  let payload = match frame_payload(frame) {
    Some(value) => value
    None => return
  }
  let fields = match as_object(payload) {
    Some(value) => value
    None => return
  }
  let kind = match string_field(fields, "type") {
    Some(value) => value
    None => return
  }
  if kind == "message_start" {
    match nested_object(fields, "message") {
      Some(message) => {
        acc.message = message
        match nested_object(message, "usage") {
          Some(usage) => acc.input_tokens = int_field(usage, "input_tokens")
          None => ()
        }
      }
      None => ()
    }
    return
  }
  if kind == "content_block_start" {
    let block = block_for(acc.blocks, int_field_or(fields, "index", 0))
    match nested_object(fields, "content_block") {
      Some(content) => absorb_block_start(block, content)
      None => ()
    }
    return
  }
  if kind == "content_block_delta" {
    let block = block_for(acc.blocks, int_field_or(fields, "index", 0))
    match nested_object(fields, "delta") {
      Some(delta) => absorb_block_delta(block, delta)
      None => ()
    }
    return
  }
  if kind == "message_delta" {
    match nested_object(fields, "delta") {
      Some(delta) => {
        match string_field(delta, "stop_reason") {
          Some(reason) => acc.stop_reason = Some(reason)
          None => ()
        }
        match string_field(delta, "stop_sequence") {
          Some(sequence) => acc.stop_sequence = Some(sequence)
          None => ()
        }
      }
      None => ()
    }
    match nested_object(fields, "usage") {
      Some(usage) =>
        match int_field(usage, "output_tokens") {
          Some(value) => acc.output_tokens = Some(value)
          None => ()
        }
      None => ()
    }
    return
  }
  if kind == "error" {
    // Anthropic 的错误事件本身就是标准错误体 `{"type":"error","error":{…}}`，
    // 与非流式失败时的响应体同形，因此原样作为最终结果。
    match fields.get("error") {
      Some(_) => acc.error_body = Some(payload)
      None => ()
    }
    return
  }
  // `ping` / `content_block_stop` / `message_stop` 无需累积：
  // 它们只承担同步语义，信息量为零。
}

///|
/// 吸收 `content_block_start`。
fn absorb_block_start(block : BlockAcc, content : Map[String, Json]) -> Unit {
  match string_field(content, "type") {
    Some(value) => block.kind = Some(value)
    None => ()
  }
  match string_field(content, "text") {
    Some(value) => block.text = block.text + value
    None => ()
  }
  match string_field(content, "thinking") {
    Some(value) => block.thinking = block.thinking + value
    None => ()
  }
  match string_field(content, "id") {
    Some(value) => block.tool_id = Some(value)
    None => ()
  }
  match string_field(content, "name") {
    Some(value) => block.tool_name = Some(value)
    None => ()
  }
}

///|
/// 吸收 `content_block_delta`。
///
/// 四种增量都按「拼接」处理：`text_delta` / `input_json_delta` /
/// `thinking_delta` / `signature_delta`。它们共用一个累积器是因为一个 block
/// 只会出现其中一种，而分开四套累积器只会让状态翻倍。
fn absorb_block_delta(block : BlockAcc, delta : Map[String, Json]) -> Unit {
  match string_field(delta, "type") {
    Some(kind) =>
      if block.kind is None {
        // `content_block_start` 理论上总会先到；缺失时用增量类型兜底，
        // 至少让 block 的 `type` 不至于丢失。
        block.kind = Some(kind)
      }
    None => ()
  }
  match string_field(delta, "text") {
    Some(value) => block.text = block.text + value
    None => ()
  }
  match string_field(delta, "thinking") {
    Some(value) => block.thinking = block.thinking + value
    None => ()
  }
  match string_field(delta, "signature") {
    Some(value) => block.signature = block.signature + value
    None => ()
  }
  match string_field(delta, "partial_json") {
    Some(value) => block.partial_json = block.partial_json + value
    None => ()
  }
}

///|
/// 取（必要时新建）指定下标的 block 累积器。
fn block_for(blocks : Array[BlockAcc], index : Int) -> BlockAcc {
  for block in blocks {
    if block.index == index {
      return block
    }
  }
  let fresh : BlockAcc = {
    index,
    kind: None,
    text: "",
    thinking: "",
    signature: "",
    tool_id: None,
    tool_name: None,
    partial_json: "",
  }
  blocks.push(fresh)
  fresh
}

///|
/// 从累积状态里抽出统一模型使用的用量。
///
/// 两侧都有才给出用量：统一模型的 `Usage` 是「输入 + 输出」两个整数，
/// 缺一半时补 0 会把「没上报」写成「上报了 0」，那是错误信息而不是缺失信息。
/// 流被截断时（`message_delta` 没到）宁可留空——原始帧仍在
/// `Response.stream` 里，需要真实数值时可以自己去取。
fn anthropic_stream_usage(acc : AnthropicStream) -> @core.Usage? {
  match (acc.input_tokens, acc.output_tokens) {
    (Some(input), Some(output)) => Some(@core.Usage::new(input, output))
    _ => None
  }
}

///|
/// 组装最终的响应体。
fn anthropic_stream_body(acc : AnthropicStream) -> Json {
  match acc.error_body {
    Some(error) => return error
    None => ()
  }
  sort_blocks(acc.blocks)
  let out : Map[String, Json] = Map([])
  for key in acc.message.keys() {
    match acc.message.get(key) {
      Some(value) => out.set(key, value)
      None => ()
    }
  }
  // `message_start` 里的 `content` 通常是空数组，必须用累积结果覆盖；
  // `usage` 同理（那里的 `output_tokens` 只是个占位值）。
  out.set("type", Json::string("message"))
  let content : Array[Json] = []
  for block in acc.blocks {
    content.push(block_json(block))
  }
  out.set("content", Json::array(content))
  out.set(
    "stop_reason",
    match acc.stop_reason {
      Some(reason) => Json::string(reason)
      None => Json::null()
    },
  )
  match acc.stop_sequence {
    Some(sequence) => out.set("stop_sequence", Json::string(sequence))
    None => ()
  }
  let usage : Map[String, Json] = Map([])
  usage.set(
    "input_tokens",
    json_int(
      match acc.input_tokens {
        Some(value) => value
        None => 0
      },
    ),
  )
  usage.set(
    "output_tokens",
    json_int(
      match acc.output_tokens {
        Some(value) => value
        None => 0
      },
    ),
  )
  out.set("usage", Json::object(usage))
  Json::object(out)
}

///|
fn block_json(block : BlockAcc) -> Json {
  let fields : Map[String, Json] = Map([])
  let kind = match block.kind {
    Some(value) => value
    None => "text"
  }
  fields.set("type", Json::string(kind))
  if kind == "tool_use" {
    fields.set(
      "id",
      Json::string(
        match block.tool_id {
          Some(value) => value
          None => ""
        },
      ),
    )
    fields.set(
      "name",
      Json::string(
        match block.tool_name {
          Some(value) => value
          None => ""
        },
      ),
    )
    // 参数是分片到达的，只有全部到齐才是一个可解析的 JSON。
    fields.set("input", parse_partial_json(block.partial_json))
  } else if kind == "thinking" {
    fields.set("thinking", Json::string(block.thinking))
    if block.signature != "" {
      fields.set("signature", Json::string(block.signature))
    }
  } else {
    fields.set("text", Json::string(block.text))
  }
  Json::object(fields)
}

///|
/// 按下标升序排列 block，保证输出可被断言。
fn sort_blocks(blocks : Array[BlockAcc]) -> Unit {
  for i = 1; i < blocks.length(); i = i + 1 {
    let value = blocks[i]
    let mut j = i - 1
    while j >= 0 && blocks[j].index > value.index {
      blocks[j + 1] = blocks[j]
      j = j - 1
    }
    blocks[j + 1] = value
  }
}
