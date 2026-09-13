// mooncassette 异步适配层。
//
// 为什么需要它：`Transport::send` 是同步的，而生态里的 HTTP 客户端都是 async 的
// （`mizchi/x/http`、以及 `moonbitlang/async` 自带的 `@http`）。MoonBit 没有
// 「从同步上下文启动异步任务」的入口 —— 有 `spawn`，但没有 `block_on` 式的桥接 ——
// 因此这类客户端**无法**实现 `Transport`。
//
// 好在整条链路里只有「把报文发出去」这一步是异步的：编码、解码、规范化、脱敏
// 全是纯计算。于是接入方式就是在异步上下文里走三步，本包把它封装成一个函数。

///|
/// 在异步上下文里完成一次调用：命中就回放，未命中就真实发一次并录下来。
///
/// 与同步路径 `Session::send` 共用同一条派生链，也共用同一个录入入口
/// （`Session::record`），因此异步录下的记录与同步录下的记录在 cassette 里形态一致，
/// 可以互相回放。换句话说：这条路径绕开了 `Transport`，但没有绕开任何不变量。
///
/// `send_http` 只负责把报文发出去 —— 它是整条链路上唯一必须异步的一步，
/// 也是本函数唯一需要调用方提供的东西。
///
/// 会话本身不需要持有 `Transport`：回放走 `try_replay`，录入走 `record`，
/// 两者都不接触外部资源。
pub async fn replay_or_record(
  session : @recorder.Session,
  request : @core.Request,
  protocol : &@providers.Protocol,
  send_http : async (@providers.HttpRequest) -> @providers.HttpResponse raise @core.CassetteError,
) -> @core.Response raise @core.CassetteError {
  match session.try_replay(request) {
    Some(response) => response
    None => {
      let outgoing = protocol.encode(request)
      let incoming = send_http(outgoing)
      let response = protocol.decode(incoming)
      // 交给 Session 落盘：它会施加与自动录制完全相同的脱敏与规范化。
      // 手工在这里拼一条 Interaction 也能跑，但那条路径迟早会与自动录制分叉。
      session.record(request, response)
    }
  }
}

///|
/// 用 `moonbitlang/async` 自带的 HTTP 客户端实现 `send_http`。
///
/// 方法、URL、请求体全部取自已经编码好的报文，因此这一层不需要知道任何 provider
/// 细节。放在包里而不是留给每个使用者自己写：它很薄，但「网络层的错误怎么折叠成
/// `CassetteError`」这件事每个人都会写一遍，而且容易写得各不相同 ——
/// 那种差异会让错误处理在两次调用之间不一致。
pub async fn send_with_async_http(
  request : @providers.HttpRequest,
) -> @providers.HttpResponse raise @core.CassetteError {
  let headers : Map[@http.CaseInsensitiveString, String] = Map([])
  for entry in request.headers {
    let (name, value) = entry
    headers.set(@http.CaseInsensitiveString(name), value)
  }
  let (response, body) = @http.request(
    request.url,
    method_of(request.http_method),
    headers,
    request.body,
  ) catch {
    // 网络层错误折叠成 `TransportFailure`：它是「调用没成功」这一大类，
    // 与「回放找不到记录」（`NoMatch`）是两回事，不能混。
    error => raise @core.CassetteError::TransportFailure(error.to_string())
  }
  let text = body.text() catch {
    error => raise @core.CassetteError::TransportFailure(error.to_string())
  }
  @providers.HttpResponse::new(response.code, text)
}

///|
/// 把报文里的方法名映射成异步库的方法枚举。
///
/// 未知方法按 `GET` 处理：本函数只在**真实发送**时被调用，方法猜错的结果是服务端
/// 回一个 405，而不是静默的错误结果。报文的形状本身由 `providers` 保证。
fn method_of(name : String) -> @http.RequestMethod {
  match name {
    "GET" => @http.RequestMethod::Get
    "HEAD" => @http.RequestMethod::Head
    "POST" => @http.RequestMethod::Post
    "PUT" => @http.RequestMethod::Put
    "DELETE" => @http.RequestMethod::Delete
    "OPTIONS" => @http.RequestMethod::Options
    "PATCH" => @http.RequestMethod::Patch
    _ => @http.RequestMethod::Get
  }
}
