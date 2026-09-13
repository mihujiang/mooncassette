// mooncassette/providers —— 脚本化发送器的应答序列。
//
// 序列能力的存在理由是「重试后成功」这类场景：只有能按顺序给出 429 与 200，
// 重试路径本身才可能被离线回归。这里把取值规则钉死。

///|
fn scripted_request() -> HttpRequest {
  HttpRequest::new("POST", "https://example.test/v1/chat/completions", [], "{}")
}

///|
fn status_of(sender : ScriptedHttpSender, request : HttpRequest) -> Int {
  let response = sender.send(request) catch {
    _ => return -1
  }
  response.status
}

///|
test "a single scripted response repeats for every call" {
  // 同一个请求被反复调用是常态，用完就报错会把正常用法变成障碍。
  let sender = ScriptedHttpSender::new()
  let request = scripted_request()
  sender.on(request, HttpResponse::new(200, "ok"))
  assert_eq(status_of(sender, request), 200)
  assert_eq(status_of(sender, request), 200)
  assert_eq(status_of(sender, request), 200)
  assert_eq(sender.call_count(), 3)
}

///|
test "a scripted sequence is handed out in order" {
  let sender = ScriptedHttpSender::new()
  let request = scripted_request()
  sender.on_sequence(request, [
    HttpResponse::new(429, "{\"error\":{\"code\":\"rate_limit_exceeded\"}}"),
    HttpResponse::new(200, "ok"),
  ])
  assert_eq(status_of(sender, request), 429)
  assert_eq(status_of(sender, request), 200)
  // 序列用完之后重复最后一个。
  assert_eq(status_of(sender, request), 200)
}

///|
test "registering twice appends instead of overwriting" {
  // 覆盖语义会在「我只想再补一条」时悄悄丢掉先前那条，正是重试序列最容易踩的坑。
  let sender = ScriptedHttpSender::new()
  let request = scripted_request()
  sender.on(request, HttpResponse::new(429, "first"))
  sender.on(request, HttpResponse::new(200, "second"))
  assert_eq(status_of(sender, request), 429)
  assert_eq(status_of(sender, request), 200)
}

///|
test "a sequence can be appended to after construction" {
  let sender = ScriptedHttpSender::new()
  let request = scripted_request()
  sender.on_sequence(request, [HttpResponse::new(429, "first")])
  sender.on_sequence(request, [HttpResponse::new(200, "second")])
  assert_eq(status_of(sender, request), 429)
  assert_eq(status_of(sender, request), 200)
}

///|
test "an unscripted request still fails loudly" {
  // 「本不该发生的真实调用」必须在测试里立刻可见，而不是静默通过。
  let sender = ScriptedHttpSender::new()
  let response = sender.send(scripted_request()) catch {
    _ => return fail("unexpected error")
  }
  assert_eq(response.status, 500)
  assert_true(response.body.contains("no scripted http response"))
}
