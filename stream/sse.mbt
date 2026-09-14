// mooncassette/stream —— SSE 帧解析与渲染。
//
// 流式响应在线上就是一段 SSE 文本。录制时把它切成帧，好处有三：
// 回放能逐帧重放、diff 读得懂、以及「帧」这个粒度本身就能被断言。
//
// 全部按**字符**处理，不碰字节/码元偏移：`StringView::at` 走的是 UTF-16 码元
// 下标，而字段值里可能是中文或 emoji，混用两套下标极易产生隐蔽的错位。

///|
/// 解析过程中的累积状态。
priv struct SseState {
  /// 当前帧的 `event:` 值。
  mut event : String?
  /// 当前帧已累积的 `data:` 行。
  mut data : Array[String]
}

///|
/// 判断一段响应体是否是 SSE 事件流。
///
/// 判据：第一个非空行以 `data:`、`event:`、`id:`、`retry:` 或 `:`（注释行）开头。
/// JSON 响应体以 `{` 或 `[` 开头，HTML 错误页以 `<` 开头，都不会误判。
///
/// `id:` / `retry:` 也列入判据：它们是规范允许的起始字段（虽然 OpenAI 与 Anthropic
/// 都不用），漏掉它们会让一条流被当成非流式响应、只能按原始文本录下来 —— 帧就丢了，
/// 而丢帧不会报错。
///
/// 之所以要按下议内容判断，是因为 `HttpResponse` 只带状态码与响应体、
/// 没有响应头，无法从 `Content-Type` 区分流式与非流式。
pub fn looks_like_event_stream(text : StringView) -> Bool {
  let chars = text.to_array()
  let start = skip_blanks(chars, 0)
  if start >= chars.length() {
    return false
  }
  chars[start] == ':' ||
  starts_with_at(chars, start, "data:") ||
  starts_with_at(chars, start, "event:") ||
  starts_with_at(chars, start, "id:") ||
  starts_with_at(chars, start, "retry:")
}

///|
/// 解析 SSE 文本为帧序列。
///
/// 严格遵循 WHATWG HTML 中 Server-Sent Events 的规则：
///
/// - 行终止符可以是 `\r\n`、`\n` 或 `\r`；
/// - 行内第一个冒号之前是字段名；冒号后的**一个**前导空格被去掉，其余原样保留；
/// - 没有冒号的行视为「字段名 = 整行、值为空串」；
/// - 同一帧内的多个 `data:` 行以 `\n` 连接；
/// - 空行表示「派发当前帧」；**没有任何 `data:` 行**时不派发；
///
/// 与规范的唯一偏离：规范规定「数据缓冲区为空字符串时不派发」，因此 `data:` 行存在、
/// 内容却是空串时它不会派发，而本实现会派发出一个 `data: ""` 帧。这样选择有两个理由：
/// 一是录制方的职责是如实记录服务端发出的内容（空数据事件是合法的，常被用作心跳），
/// 二是它保住了 `parse(render(frames)) == frames` 这条往返性质 —— 若在此丢弃，
/// 渲染侧就再也无法表示「一个空数据帧」。
/// - 以 `:` 开头的是注释，忽略；
/// - `id` / `retry` 与未知字段一律忽略（它们是重连元数据，不是模型输出）；
/// - **末尾没有空行时，仍在缓冲的帧按规范丢弃**。
///
/// 最后一条是刻意选择：与其猜「大概只是漏了个终止空行」，不如严格照规范来。
/// 若服务端少了终止空行，我们会少一帧并因此让聚合结果对不上，而不是把一份
/// 可能已被截断的流当作完整流录下来。
pub fn parse(text : StringView) -> Array[@core.StreamFrame] {
  let chars = text.to_array()
  let frames : Array[@core.StreamFrame] = []
  let state : SseState = { event: None, data: [] }
  let mut i = skip_bom(chars)
  let mut line_start = i
  while i < chars.length() {
    let ch = chars[i]
    if ch == '\n' || ch == '\r' {
      dispatch_line(state, chars, line_start, i, frames)
      i = i + 1
      // `\r\n` 是一个终止符，不是一个空行加一个终止符。
      if ch == '\r' && i < chars.length() && chars[i] == '\n' {
        i = i + 1
      }
      line_start = i
    } else {
      i = i + 1
    }
  }
  // 流结束时仍在缓冲的帧按规范丢弃，因此这里刻意不处理 `[line_start, i)`。
  frames
}

///|
/// 把帧序列渲染回 SSE 文本。
///
/// 与 `parse` 构成一对：`parse(render(frames)) == frames`。
/// 用于调试输出，以及让「帧」这一形态可以直接被人阅读与粘贴。
pub fn render(frames : ArrayView[@core.StreamFrame]) -> String {
  let sb = StringBuilder::new()
  for frame in frames {
    match frame.event {
      Some(name) => {
        sb.write_string("event: ")
        sb.write_string(name)
        sb.write_string("\n")
      }
      None => ()
    }
    // 多行数据必须拆回多个 `data:` 行，否则解析回来就会变成一帧里的换行。
    for line in frame.data.split("\n") {
      sb.write_string("data: ")
      sb.write_string(line.to_owned())
      sb.write_string("\n")
    }
    sb.write_string("\n")
  }
  sb.to_string()
}

///|
/// 处理一整行（`chars[start, end)`）。
fn dispatch_line(
  state : SseState,
  chars : Array[Char],
  start : Int,
  end : Int,
  frames : Array[@core.StreamFrame],
) -> Unit {
  if start >= end {
    flush(state, frames)
    return
  }
  if chars[start] == ':' {
    // 注释行：规范规定忽略。
    return
  }
  let (field, value) = split_field(chars, start, end)
  if field == "data" {
    state.data.push(value)
  } else if field == "event" {
    state.event = Some(value)
  }
  // `id` / `retry` 与未知字段一律忽略。
}

///|
/// 空行：把当前累积的帧派发出去；数据为空时不派发（规范如此）。
fn flush(state : SseState, frames : Array[@core.StreamFrame]) -> Unit {
  if state.data.length() == 0 {
    state.event = None
    return
  }
  let sb = StringBuilder::new()
  for i = 0; i < state.data.length(); i = i + 1 {
    if i > 0 {
      sb.write_string("\n")
    }
    sb.write_string(state.data[i])
  }
  frames.push({ event: state.event, data: sb.to_string() })
  state.data = []
  state.event = None
}

///|
/// 把一行拆成字段名与字段值。
///
/// 冒号后的一个前导空格被去掉；其余空格属于值本身。
fn split_field(chars : Array[Char], start : Int, end : Int) -> (String, String) {
  let mut colon = -1
  for i = start; i < end; i = i + 1 {
    if chars[i] == ':' {
      colon = i
      break
    }
  }
  if colon < 0 {
    // 没有冒号：整行是字段名，值为空串。
    return (chars_to_string(chars[start:end]), "")
  }
  let mut value_start = colon + 1
  if value_start < end && chars[value_start] == ' ' {
    value_start = value_start + 1
  }
  (chars_to_string(chars[start:colon]), chars_to_string(chars[value_start:end]))
}

///|
fn chars_to_string(chars : ArrayView[Char]) -> String {
  StringView::from_array(chars).to_owned()
}

///|
/// 跳过起始处的 UTF-8 BOM（若有）。
fn skip_bom(chars : Array[Char]) -> Int {
  if chars.length() > 0 && chars[0] == '\u{FEFF}' {
    1
  } else {
    0
  }
}

///|
/// 跳过空白与 BOM——仅用于「像不像事件流」的判断。
fn skip_blanks(chars : Array[Char], from : Int) -> Int {
  let mut i = from
  while i < chars.length() {
    let ch = chars[i]
    if ch == '\n' || ch == '\r' || ch == ' ' || ch == '\t' || ch == '\u{FEFF}' {
      i = i + 1
    } else {
      break
    }
  }
  i
}

///|
fn starts_with_at(
  chars : Array[Char],
  start : Int,
  prefix : StringView,
) -> Bool {
  let wanted = prefix.to_array()
  if start + wanted.length() > chars.length() {
    return false
  }
  for i = 0; i < wanted.length(); i = i + 1 {
    if chars[start + i] != wanted[i] {
      return false
    }
  }
  true
}
