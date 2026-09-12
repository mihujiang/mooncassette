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
test "sequential playback reports exhaustion instead of no-match" {
  // 回归测试：早期实现无论什么原因都报 NoMatch，把「录制条数不够」
  // 说成「请求对不上」，会把用户引向错误的方向排查。
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(request, @core.Response::ok(Json::string("only"))),
  ])
  let session = @recorder.Session::new(
    cassette,
    policy=@matcher.MatchPolicy::Sequential,
  )
  // 第一条正常消费。
  let first = send_result(session, request).unwrap()
  assert_eq(first.body, Json::string("only"))
  // 第二条：录制已耗尽。
  match send_result(session, request) {
    Ok(_) => fail("expected an Exhausted failure")
    Err(@core.CassetteError::Exhausted(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "an empty cassette is a no-match, not an exhaustion" {
  // 两种失败的可操作含义不同：空 cassette 要先去录，耗尽要补录制条数。
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    policy=@matcher.MatchPolicy::Sequential,
  )
  match send_result(session, request_of("gpt-4o", Json::null())) {
    Ok(_) => fail("expected a NoMatch failure")
    Err(@core.CassetteError::NoMatch(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "a no-match error explains which field differs" {
  // 只报一个指纹，用户无法判断该补录制、改请求还是换策略。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"prompt\":\"hi\"}")),
      @core.Response::ok(Json::string("recorded")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  match
    send_result(
      session,
      request_of("gpt-4o", @json.parse("{\"prompt\":\"bye\"}")),
    ) {
    Ok(_) => fail("expected a NoMatch failure")
    Err(@core.CassetteError::NoMatch(detail)) => {
      assert_true(detail.contains("1 interaction(s)"))
      assert_true(detail.contains("$.body.prompt"))
    }
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "a miss reports an empty cassette plainly" {
  let session = @recorder.Session::new(@core.Cassette::new("demo"))
  match send_result(session, request_of("gpt-4o", Json::null())) {
    Ok(_) => fail("expected a NoMatch failure")
    Err(@core.CassetteError::NoMatch(detail)) =>
      assert_true(detail.contains("contains no interactions"))
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "diagnose can be called without raising" {
  // 供 CLI 与自定义断言使用：先看清楚原因，再决定是补录制还是改请求。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"prompt\":\"hi\"}")),
      @core.Response::ok(Json::string("recorded")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  let diagnosis = session.diagnose(
    request_of("gpt-4o", @json.parse("{\"prompt\":\"bye\"}")),
  )
  assert_eq(diagnosis.total, 1)
  assert_eq(diagnosis.candidates[0].differing_paths, ["$.body.prompt"])
}

///|
test "diagnose prepares the request the same way matching does" {
  // 若诊断不先规范化，易变字段会被报成差异，噪声盖住真正的原因。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"prompt\":\"hi\"}")),
      @core.Response::ok(Json::string("recorded")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  let diagnosis = session.diagnose(
    request_of(
      "gpt-4o",
      @json.parse("{\"prompt\":\"bye\",\"request_id\":\"volatile\"}"),
    ),
  )
  assert_eq(diagnosis.candidates[0].differing_paths, ["$.body.prompt"])
}

///|
test "manual recording stores the sanitized request and replays it" {
  // 手动录入是异步客户端唯一的接入路径，因此它必须与自动录制走
  // 完全相同的派生链，否则「录得进去、回放不出来」会在这里复现。
  let session = @recorder.Session::new(@core.Cassette::new("demo"))
  let request = request_of(
    "gpt-4o",
    @json.parse("{\"api_key\":\"sk-abcdefgh12345678\",\"a\":1}"),
  )
  let _ = session.record(
    request,
    @core.Response::ok(Json::string("from-async")),
  )
  assert_eq(
    session.cassette().interactions[0].request.body,
    @json.parse("{\"api_key\":\"***REDACTED***\",\"a\":1}"),
  )
  // 立刻回放必须命中：这条断言就是过去那个缺陷的守卫。
  session.set_mode(@recorder.Mode::Playback)
  let replayed = send_result(session, request).unwrap()
  assert_eq(replayed.body, Json::string("from-async"))
}

///|
test "manual recording returns the sanitized response to stay deterministic" {
  // 回放返回的是 cassette 里存的那一份；若录制时返回未脱敏的原文，
  // 同一段代码在首次运行与后续运行就会看到不同的值。
  let session = @recorder.Session::new(@core.Cassette::new("demo"))
  let request = request_of("gpt-4o", Json::null())
  let returned = session.record(
    request,
    @core.Response::ok(@json.parse("{\"access_token\":\"secret-value\"}")),
  )
  assert_eq(returned.body, @json.parse("{\"access_token\":\"***REDACTED***\"}"))
  // 与落盘内容一致。
  assert_eq(returned.body, session.cassette().interactions[0].response.body)
}

///|
test "manual recording advances the cursor and the counters" {
  let session = @recorder.Session::new(@core.Cassette::new("demo"))
  let _ = session.record(
    request_of("gpt-4o", @json.parse("{\"a\":1}")),
    @core.Response::ok(Json::string("one")),
  )
  let _ = session.record(
    request_of("gpt-4o", @json.parse("{\"a\":2}")),
    @core.Response::ok(Json::string("two")),
  )
  assert_eq(session.cassette().length(), 2)
  assert_eq(session.cursor(), 2)
  assert_eq(session.stats().recorded, 2)
  // 游标已推进，回放从开头回卷。
  session.set_mode(@recorder.Mode::Playback)
  let replayed = send_result(
    session,
    request_of("gpt-4o", @json.parse("{\"a\":1}")),
  ).unwrap()
  assert_eq(replayed.body, Json::string("one"))
}

///|
test "manual recording never touches the transport" {
  // 这是异步接入路径的前提：只有 `await` 那一步会碰到网络，
  // 引擎侧不得有任何隐式调用。
  let mock = @recorder.MockTransport::new()
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    transport=mock,
  )
  let _ = session.record(
    request_of("gpt-4o", Json::null()),
    @core.Response::ok(Json::string("out-of-band")),
  )
  assert_eq(mock.call_count(), 0)
}

///|
test "streamed frames are sanitized before they reach the cassette" {
  // 帧里装的是同一份模型输出。若只脱敏聚合体，流式路径就成了绕过
  // 「落盘内容一定经过脱敏」这条承诺的后门。
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  let payload = "{\"delta\":{\"access_token\":\"leak-me\"}}"
  mock.on(
    request,
    @core.Response::ok(@json.parse(payload), stream=[
      @core.StreamFrame::new(payload),
    ]),
  )
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  let _ = send_result(session, request).unwrap()
  let recorded = session.cassette().interactions[0].response.stream.unwrap()
  assert_eq(recorded.length(), 1)
  assert_false(recorded[0].data.contains("leak-me"))
  assert_true(recorded[0].data.contains("***REDACTED***"))
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
