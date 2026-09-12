// mooncassette/recorder —— 会话引擎契约测试。
//
// 核心承诺：回放模式**绝不**发起真实调用；录制内容**必定**经过脱敏；
// 自动模式在未命中时回落真实调用并把结果并入 cassette。

///|
fn request_of(model : String, body : Json) -> @core.Request {
  @core.Request::new("openai", model, body)
}

///|
/// 把 `send` 的抛错行为转成 `Result`，便于断言错误种类。
fn send_result(
  session : @recorder.Session,
  request : @core.Request,
) -> Result[@core.Response, @core.CassetteError] {
  let response = session.send(request) catch { error => return Err(error) }
  Ok(response)
}

///|
/// 记录型 Transport：把收到的请求体留存下来，供断言检查。
///
/// 用于验证「发给 provider 的请求保留密钥」这一条：如果实现里
/// 顺手把 live 请求也脱敏了，真实鉴权就会失败，而单看落盘内容
/// 是发现不了这个问题的。
struct SpyTransport {
  mut last_body : Json
  mut calls : Int
}

///|
fn SpyTransport::new() -> SpyTransport {
  { last_body: Json::null(), calls: 0 }
}

///|
pub impl @recorder.Transport for SpyTransport with fn send(self, request) {
  self.calls = self.calls + 1
  self.last_body = request.body
  @core.Response::ok(Json::string("ok"))
}

///|
test "the live request keeps its secret while the stored one is redacted" {
  let spy = SpyTransport::new()
  let request = request_of(
    "gpt-4o",
    @json.parse("{\"api_key\":\"sk-abcdefgh12345678\"}"),
  )
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=spy,
  )
  let _ = send_result(session, request).unwrap()
  // 真实调用必须原样带上密钥，否则鉴权会失败。
  assert_eq(spy.last_body, @json.parse("{\"api_key\":\"sk-abcdefgh12345678\"}"))
  // 落盘必须已脱敏。
  assert_eq(
    session.cassette().interactions[0].request.body,
    @json.parse("{\"api_key\":\"***REDACTED***\"}"),
  )
}

///|
test "a secret-bearing request is replayable right after being recorded" {
  // 回归测试：早期版本在录制时存储脱敏请求、却在回放时拿未脱敏请求
  // 去比对指纹，导致「录得进去、回放不出来」。
  let mock = @recorder.MockTransport::new()
  let request = request_of(
    "gpt-4o",
    @json.parse("{\"api_key\":\"sk-abcdefgh12345678\"}"),
  )
  mock.on(request, @core.Response::ok(Json::string("live")))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  session.set_mode(@recorder.Mode::Playback)
  let replayed = send_result(session, request).unwrap()
  assert_eq(replayed.body, Json::string("live"))
  assert_eq(mock.call_count(), 1)
}

///|
test "record mode calls the transport, appends and returns the live response" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  mock.on(request, @core.Response::ok(Json::string("live")))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let response = send_result(session, request).unwrap()
  assert_eq(response.body, Json::string("live"))
  assert_eq(mock.call_count(), 1)
  assert_eq(session.cassette().length(), 1)
  assert_eq(session.stats().recorded, 1)
}

///|
test "record mode keeps recording even when the same request repeats" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  mock.on(request, @core.Response::ok(Json::string("live")))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  let _ = send_result(session, request).unwrap()
  assert_eq(session.cassette().length(), 2)
  assert_eq(mock.call_count(), 2)
}

///|
test "record mode redacts secrets before they ever reach the cassette" {
  let mock = @recorder.MockTransport::new()
  let request = request_of(
    "gpt-4o",
    @json.parse("{\"api_key\":\"sk-abcdefgh12345678\"}"),
  )
  mock.on(request, @core.Response::ok(@json.parse("{\"access_token\":\"t\"}")))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  let recorded = session.cassette().interactions[0]
  assert_eq(
    recorded.request.body,
    @json.parse("{\"api_key\":\"***REDACTED***\"}"),
  )
  assert_eq(
    recorded.response.body,
    @json.parse("{\"access_token\":\"***REDACTED***\"}"),
  )
}

///|
test "record mode normalizes the request before storing it" {
  let mock = @recorder.MockTransport::new()
  let request = request_of(
    "gpt-4o",
    @json.parse("{\"a\":1,\"request_id\":\"xyz\"}"),
  )
  mock.on(request, @core.Response::ok(Json::null()))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  assert_eq(
    session.cassette().interactions[0].request.body,
    @json.parse("{\"a\":1}"),
  )
}

///|
test "playback mode never touches the transport" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request,
      @core.Response::ok(Json::string("replayed")),
    ),
  ])
  let session = @recorder.Session::new(cassette, transport=mock)
  let response = send_result(session, request).unwrap()
  assert_eq(response.body, Json::string("replayed"))
  assert_eq(mock.call_count(), 0)
  assert_eq(session.stats().hits, 1)
}

///|
test "playback defaults to Exact and tolerates key order differences" {
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"b\":2,\"a\":1}")),
      @core.Response::ok(Json::string("hit")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  let response = send_result(
    session,
    request_of("gpt-4o", @json.parse("{\"a\":1,\"b\":2}")),
  ).unwrap()
  assert_eq(response.body, Json::string("hit"))
}

///|
test "playback reports NoMatch and does not call the transport" {
  let mock = @recorder.MockTransport::new()
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    transport=mock,
  )
  match send_result(session, request_of("gpt-4o", Json::null())) {
    Ok(_) => fail("expected a NoMatch failure")
    Err(@core.CassetteError::NoMatch(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
  assert_eq(mock.call_count(), 0)
  assert_eq(session.stats().misses, 1)
}

///|
test "playback replays repeated identical calls in recording order" {
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(request, @core.Response::ok(Json::string("one"))),
    @core.Interaction::new(request, @core.Response::ok(Json::string("two"))),
  ])
  let session = @recorder.Session::new(cassette)
  let first = send_result(session, request).unwrap()
  let second = send_result(session, request).unwrap()
  assert_eq(first.body, Json::string("one"))
  assert_eq(second.body, Json::string("two"))
  assert_eq(session.cursor(), 2)
}

///|
test "auto mode replays when possible and records otherwise" {
  let mock = @recorder.MockTransport::new()
  let known = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  let fresh = request_of("gpt-4o", @json.parse("{\"a\":2}"))
  mock.on(fresh, @core.Response::ok(Json::string("fresh")))
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(known, @core.Response::ok(Json::string("known"))),
  ])
  let session = @recorder.Session::new(
    cassette,
    mode=@recorder.Mode::Auto,
    transport=mock,
  )
  let replayed = send_result(session, known).unwrap()
  let captured = send_result(session, fresh).unwrap()
  assert_eq(replayed.body, Json::string("known"))
  assert_eq(captured.body, Json::string("fresh"))
  assert_eq(mock.call_count(), 1)
  assert_eq(session.stats().hits, 1)
  assert_eq(session.stats().recorded, 1)
  assert_eq(session.cassette().length(), 2)
}

///|
test "record mode without a transport fails loudly" {
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
  )
  match send_result(session, request_of("gpt-4o", Json::null())) {
    Ok(_) => fail("expected a MissingTransport failure")
    Err(@core.CassetteError::MissingTransport(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "mode can be switched at runtime" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  mock.on(request, @core.Response::ok(Json::string("live")))
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  session.set_mode(@recorder.Mode::Playback)
  let replayed = send_result(session, request).unwrap()
  assert_eq(replayed.body, Json::string("live"))
  assert_eq(mock.call_count(), 1)
}

///|
test "unscripted mock responses surface as an explicit 500" {
  let mock = @recorder.MockTransport::new()
  let response = @recorder.MockTransport::call_count(mock) // 仅确认访问器可用
  assert_eq(response, 0)
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let response = send_result(session, request_of("gpt-4o", Json::null())).unwrap()
  assert_eq(response.status, 500)
}
