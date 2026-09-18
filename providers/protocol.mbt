// mooncassette/providers —— 协议抽象与 Transport 桥接。

///|
/// 一个 provider 协议的编解码器。
///
/// 分工：
/// - `encode` 负责「统一请求 → HTTP 请求」。它必须只依赖请求内容，
///   不得引入时间戳、随机数等非确定输入，否则指纹会漂移。
/// - `decode` 负责「HTTP 响应 → 统一响应」。**即使状态码是错误码也要
///   正常返回**：失败响应同样需要被录制下来，否则我们无法为「429 限流」
///   这类分支写回归测试。
pub(open) trait Protocol {
  /// 协议标识，写入 cassette 的 `provider` 字段便于人工识别。
  fn name(Self) -> String
  fn encode(Self, @core.Request) -> HttpRequest raise @core.CassetteError
  fn decode(Self, HttpResponse) -> @core.Response raise @core.CassetteError
}

///|
/// 把「协议 + HTTP 执行器」组合成一个 recorder 可用的 `Transport`。
///
/// 这一层刻意做得很薄：录制、匹配、脱敏全部由 `@recorder.Session` 负责，
/// 本类型只完成「协议映射 + 发送」两件事。
pub struct ProviderTransport {
  protocol : &Protocol
  sender : &HttpSender
}

///|
/// 组合一个 ProviderTransport。
pub fn ProviderTransport::new(
  protocol : &Protocol,
  sender : &HttpSender,
) -> ProviderTransport {
  { protocol, sender }
}

///|
/// 底层协议的名字。
pub fn ProviderTransport::protocol_name(self : ProviderTransport) -> String {
  self.protocol.name()
}

///|
/// 把统一请求编码为 HTTP 请求，发送，再解码为统一响应。
///
/// 注意这里**不做脱敏**：脱敏是 `@recorder.Session` 的职责，
/// 且必须发生在「落盘」而不是「发送」这一步，否则真实鉴权会失败。
pub impl @recorder.Transport for ProviderTransport with fn send(self, request) {
  let http_request = self.protocol.encode(request)
  let http_response = self.sender.send(http_request)
  self.protocol.decode(http_response)
}

// ---------------------------------------------------------------------------
// JSON 取值辅助
//
// 协议解码要面对的是**外部输入**，任何字段都可能缺失或类型不符。
// 因此这里全部返回 `Option`，由调用方决定「缺字段」时是降级还是报错，
// 而不是让解析过程直接崩掉。

///|
/// 取 JSON 对象字段表；非对象返回 `None`。
pub fn as_object(value : Json) -> Map[String, Json]? {
  match value {
    Object(fields) => Some(fields)
    _ => None
  }
}

///|
/// 取整数字段。
///
/// 只有「确实是整数」才接受：`3.5` 会被拒绝，避免把浮点噪声悄悄取整。
pub fn int_field(fields : Map[String, Json], key : String) -> Int? {
  match fields.get(key) {
    Some(Number(value, ..)) => {
      let rounded = value.to_int()
      if rounded.to_double() == value {
        Some(rounded)
      } else {
        None
      }
    }
    _ => None
  }
}

///|
/// 按 `key` 读取一个嵌套对象字段。
fn nested_object(
  fields : Map[String, Json],
  key : String,
) -> Map[String, Json]? {
  match fields.get(key) {
    Some(value) => as_object(value)
    None => None
  }
}

///|
/// 从嵌套对象里同时取两个整数字段；任一缺失即返回 `None`。
pub fn usage_of(
  fields : Map[String, Json],
  usage_key : String,
  input_key : String,
  output_key : String,
) -> @core.Usage? {
  match nested_object(fields, usage_key) {
    Some(usage) =>
      match (int_field(usage, input_key), int_field(usage, output_key)) {
        (Some(input), Some(output)) => Some(@core.Usage::new(input, output))
        _ => None
      }
    None => None
  }
}

///|
/// 「大报文」内联承载的阈值：超过它的原始字节不再按文本存，直接进载荷信封。
///
/// 64 KiB 是刻意选的：小到让 JSON 字符串里的转义、折行与页面渲染都还受得住，
/// 大到不会把常见的文本响应（HTML 错误页、纯文本提示）误伤成 base64。
/// 需要别的口径时用 `parse_response_body` 的 `limit` 参数覆盖。
pub let inline_limit_bytes : Int = 65536

///|
/// 按**内容**决定响应体怎么承载：
///
/// - 能解析成 JSON 对象 / 数组 → 原样（`json`，与历史文件同形）；
/// - 其余文本 → `{"raw_body": …}`（`raw`，与历史文件同形）；
/// - 无法用文本无损承载、或超过阈值的原始字节 → 载荷信封（`base64`）。
///
/// 前两种就是 `HttpResponse::new` 的既有行为，一字未改；只有
/// `HttpResponse::from_bytes` 带上原始字节时才可能走到第三种 ——
/// 因此「既有文件的字节不发生变化」。
pub fn parse_response_body(response : HttpResponse, limit? : Int) -> Json {
  let bytes = match response.raw {
    None => return parse_body_or_raw(response.body)
    Some(bytes) => bytes
  }
  let cap = match limit {
    Some(value) => value
    None => inline_limit_bytes
  }
  // 阈值以内、且确实能用文本无损承载，才值得按文本存；
  // 否则一律进信封 —— 宁可多占 33%，也不让字节在转义与解析里被改掉。
  if @payload.is_text(bytes) && bytes.length() <= cap {
    parse_body_or_raw(response.body)
  } else {
    @payload.pack_bytes(bytes)
  }
}

///|
/// 把响应体文本解析为 JSON。
///
/// 解析失败时**不报错**，而是包装成 `{"raw_body": "..."}`。
/// 理由：错误响应体经常是 HTML 或纯文本（例如网关返回 502 页面），
/// 这些内容同样有录制价值，丢掉它们会让排查变得困难。
pub fn parse_body_or_raw(text : String) -> Json {
  let parsed = @json.parse(text) catch { _ => return raw_body_wrapper(text) }
  match parsed {
    Object(_) | Array(_) => parsed
    // 顶层是标量（例如字符串 "ok"）时也包一层：统一响应模型里
    // body 一律是对象或数组，避免下游出现两套取值路径。
    _ => raw_body_wrapper(text)
  }
}

///|
fn raw_body_wrapper(text : String) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("raw_body", Json::string(text))
  Json::object(fields)
}

///|
/// 校验请求体里若显式写了 `model`，必须与 `Request.model` 一致。
///
/// 这是一类很容易犯且很难查的错：调用方在 `body` 里写了 `gpt-4o-mini`，
/// 而 `Request.model` 还是 `gpt-4o`。两者会分别进入指纹与 URL/计费口径，
/// 静默不一致会让排查极其痛苦，因此这里直接报错。
pub fn check_model_consistency(
  request : @core.Request,
) -> Unit raise @core.CassetteError {
  match as_object(request.body) {
    Some(fields) =>
      match fields.get("model") {
        Some(String(declared)) =>
          if declared != request.model {
            raise @core.CassetteError::SchemaViolation(
              "request body declares model \"" +
              declared +
              "\" but Request.model is \"" +
              request.model +
              "\"",
            )
          }
        Some(_) =>
          raise @core.CassetteError::SchemaViolation(
            "request body field \"model\" must be a string",
          )
        None => ()
      }
    None => ()
  }
}
