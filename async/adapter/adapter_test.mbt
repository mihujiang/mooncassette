// 异步适配层的契约测试。
//
// 这里只钉一条，但它是最容易悄悄分叉的一条：**发到网上的请求必须是规范化过的**。
// 同步路径（`Session::send`）一直如此，异步路径若漏掉这一步，两个入口发出的字节就
// 不再相同，而「两条链路共用同一条派生链」这句话也就落空了 —— 这类不一致不会报错，
// 只会在某天以「异步录的 cassette 同步回放不出来（或反过来）」的形式出现。

///|
/// 发出去的报文正文。
///
/// 记在模块级而不是闭包里：异步函数无法捕获外层局部变量，因此这里用一个模块级
/// 容器来观察副作用。
let sent_bodies : Array[String] = []

///|
/// 一个带**易变字段**的请求：`request_id` 属于 `default_drop_keys`，
/// 规范化时会被剔除。
fn volatile_request() -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("request_id", Json::string("volatile-123"))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
/// 假发送器：记下正文，回一个能解码的 200。
async fn capture_outgoing(
  outgoing : @providers.HttpRequest,
) -> @providers.HttpResponse raise @core.CassetteError {
  sent_bodies.push(outgoing.body)
  @providers.HttpResponse::new(200, "{\"ok\":true}")
}

///|
async test "the outgoing request is normalised, exactly like the sync path" {
  let session = @recorder.Session::new(@core.Cassette::new("normalise-check"))
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let _ = replay_or_record(
    session,
    volatile_request(),
    protocol,
    capture_outgoing,
  ) catch {
    error => return fail("unexpected error: " + error.to_string())
  }
  assert_eq(sent_bodies.length(), 1)
  // 报文里只剩 `model`：`request_id` 已被规范化剔除，键按规范文本排序。
  // 若规范化漏做，这里收到的会是 `{"model":"gpt-4o","request_id":"volatile-123"}`。
  assert_eq(sent_bodies[0], "{\"model\":\"gpt-4o\"}")
}
