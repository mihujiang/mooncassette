// mooncassette/providers —— HTTP 报文的最小表示与执行器抽象。
//
// 这里刻意定义**自己的** HttpRequest / HttpResponse，而不是复用某个
// HTTP 库的类型。原因：一旦复用，本包就绑定了那个库的版本与目标平台，
// 也就失去了「纯计算、全后端可编译」这一性质。

///|
/// 一个待发送的 HTTP 请求。
///
/// `body` 是已经序列化好的字符串而不是 `Json`：编码阶段就固定下来，
/// 可以避免「同一次调用在录制与回放时序列化出不同字节」。
pub(all) struct HttpRequest {
  /// 请求方法（`GET` / `POST` …）。
  ///
  /// 字段名不用 `method`：该词在 MoonBit 中被保留，留给未来可能的语法。
  http_method : String
  url : String
  headers : Array[(String, String)]
  body : String
} derive(Eq)

///|
/// 构造一个 HTTP 请求。
pub fn HttpRequest::new(
  http_method : String,
  url : String,
  headers : Array[(String, String)],
  body : String,
) -> HttpRequest {
  { http_method, url, headers, body }
}

///|
/// 请求方法。
pub fn HttpRequest::method_name(self : HttpRequest) -> String {
  self.http_method
}

///|
/// 用于脚本化发送器索引的键。
///
/// 刻意只包含方法、URL 与请求体，**不含请求头**：鉴权头之类的字段
/// 每次可能不同，若参与索引会导致脚本匹配不上。
pub fn HttpRequest::to_key(self : HttpRequest) -> String {
  self.http_method + "\n" + self.url + "\n" + self.body
}

///|
/// 一个已收到的 HTTP 响应。
///
/// 只保留状态码与响应体：协议解码需要的全部信息都在这两项里，
/// 头信息对统一响应模型没有贡献。
pub(all) struct HttpResponse {
  status : Int
  body : String
  /// 响应体的**原始字节**；`None` 表示 `body` 就是权威内容
  /// （即 `HttpResponse::new` 的既有语义）。
  ///
  /// 只有 `HttpResponse::from_bytes` 会填 `Some`：JSON 字符串表示不了任意字节，
  /// 光留 `body` 的话，非 UTF-8 的响应到解码端只剩一串替换字符，
  /// 「录下来的响应」与「真发出去的响应」不再逐字节相等 —— 回放随即失去意义。
  /// `Some` 时一切判别以本字段为准，`body` 只是它的可读视图。
  raw : Bytes?
} derive(Eq)

///|
/// 构造一个 HTTP 响应。
pub fn HttpResponse::new(status : Int, body : String) -> HttpResponse {
  { status, body, raw: None }
}

///|
/// 用**原始字节**构造响应。
///
/// 二进制响应（图片、音频、序列化后的 protobuf……）在 `String` 里放不下：
/// JSON 载不了任意字节。因此这里把原字节一并保留，由 `parse_response_body`
/// 按内容决定存成 `{"raw_body": …}` 还是载荷信封；`body` 则给出可读视图
/// （能无损解码时是原文本，否则是规范 base64）。
pub fn HttpResponse::from_bytes(status : Int, bytes : Bytes) -> HttpResponse {
  { status, body: @payload.text_view(bytes), raw: Some(bytes) }
}

///|
/// 把 HTTP 请求真正发出去的能力。
///
/// 实现方只需把自家 HTTP 客户端接进来；协议映射与录制逻辑都在别处，
/// 因此适配层可以非常薄。
pub(open) trait HttpSender {
  fn send(Self, HttpRequest) -> HttpResponse raise @core.CassetteError
}

///|
/// 脚本化的假发送器，用于测试与示例。
///
/// 未登记的请求返回 500，使「本不该发生的真实调用」在测试中立刻
/// 表现为可断言的失败，而不是静默通过。
///
/// 同一请求可以登记**多个**响应：按登记顺序依次给出，用完重复最后一个
/// （取值策略见 `@core.ScriptedReplies`）。这让「先 429、重试后 200」这类
/// 序列可以被离线回归，而不只是测到「最终成功」。
pub struct ScriptedHttpSender {
  scripted : Map[String, @core.ScriptedReplies[HttpResponse]]
  mut calls : Int
}

///|
/// 构造一个空的脚本化发送器。
pub fn ScriptedHttpSender::new() -> ScriptedHttpSender {
  { scripted: Map([]), calls: 0 }
}

///|
/// 为某个 HTTP 请求登记一个响应。
///
/// 对同一请求重复调用会**追加**到该请求的应答序列末尾，而不是覆盖。
pub fn ScriptedHttpSender::on(
  self : ScriptedHttpSender,
  request : HttpRequest,
  response : HttpResponse,
) -> Unit {
  self.sequence_for(request).push(response)
}

///|
/// 为某个 HTTP 请求登记一串响应，按顺序依次给出。
///
/// 用于「重试后成功」这类序列，例如 `[429, 200]`。
pub fn ScriptedHttpSender::on_sequence(
  self : ScriptedHttpSender,
  request : HttpRequest,
  responses : Array[HttpResponse],
) -> Unit {
  let sequence = self.sequence_for(request)
  for response in responses {
    sequence.push(response)
  }
}

///|
/// 取（必要时新建）某个请求的应答序列。
fn ScriptedHttpSender::sequence_for(
  self : ScriptedHttpSender,
  request : HttpRequest,
) -> @core.ScriptedReplies[HttpResponse] {
  let key = request.to_key()
  match self.scripted.get(key) {
    Some(sequence) => sequence
    None => {
      let fresh : @core.ScriptedReplies[HttpResponse] = @core.ScriptedReplies::new([],
      )
      self.scripted.set(key, fresh)
      fresh
    }
  }
}

///|
/// 实际被调用的次数。
pub fn ScriptedHttpSender::call_count(self : ScriptedHttpSender) -> Int {
  self.calls
}

///|
pub impl HttpSender for ScriptedHttpSender with fn send(self, request) {
  self.calls = self.calls + 1
  let key = request.to_key()
  let played = match self.scripted.get(key) {
    Some(sequence) => sequence.take()
    None => None
  }
  match played {
    Some(response) => response
    None =>
      HttpResponse::new(
        500,
        "{\"error\":{\"message\":\"no scripted http response for " +
        key.replace(old="\n", new=" ") +
        "\"}}",
      )
  }
}

///|
/// 用普通函数实现 `HttpSender`，省去为接线专门定义一个 struct。
///
/// 例如接入一个同步 HTTP 客户端：
///
/// ```text
/// let sender = @providers.FunctionSender::new(fn(request) {
///   MyClient::call(request)   // (HttpRequest) -> HttpResponse raise CassetteError
/// })
/// ```
///
/// 注意闭包必须是**同步**的。若客户端是异步的（例如 `mizchi/x/http`
/// 的 `async fn post`），则无法在这里被调用 —— MoonBit 没有从同步上下文
/// 启动异步任务的入口。这类客户端需要在 async 上下文里完成发送，
/// 详见 README 的「接入真实 HTTP 客户端」一节。
pub struct FunctionSender {
  f : (HttpRequest) -> HttpResponse raise @core.CassetteError
}

///|
/// 包装一个同步的发送函数。
pub fn FunctionSender::new(
  f : (HttpRequest) -> HttpResponse raise @core.CassetteError,
) -> FunctionSender {
  { f, }
}

///|
pub impl HttpSender for FunctionSender with fn send(self, request) {
  (self.f)(request)
}
