// mooncassette/recorder —— 应答序列与重试路径的端到端回归。
//
// 把 examples/rate_limit_retry 里的场景固化成测试：429 → 200 的重试路径
// 可以离线复现，而「调用次数多于录制条数」在顺序策略下必须如实报出。

///|
test "a retry sequence replays offline in the same order" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  mock.on_sequence(request, [
    @core.Response::new(429, Json::string("rate limited")),
    @core.Response::ok(Json::string("done")),
  ])
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  // 录制阶段：先被限流，重试后成功。
  assert_eq(send_result(session, request).unwrap().status, 429)
  assert_eq(send_result(session, request).unwrap().status, 200)
  assert_eq(session.cassette().length(), 2)
  assert_eq(mock.call_count(), 2)

  // 回放阶段：同样的两次调用给出同样的顺序，且不再触碰 Transport。
  let playback = @recorder.Session::new(
    session.cassette(),
    mode=@recorder.Mode::Playback,
    policy=@matcher.MatchPolicy::Sequential,
  )
  assert_eq(send_result(playback, request).unwrap().status, 429)
  assert_eq(send_result(playback, request).unwrap().status, 200)
  assert_eq(mock.call_count(), 2)
}

///|
test "ring policy reuses the earliest recording when calls exceed them" {
  // 环形策略的取舍：调用次数多于录制条数时复用最早的一条，而不是失败。
  // 这在「稳态场景下次数本就不固定」时有用，代价是掩盖了「录制不足」。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"a\":1}")),
      @core.Response::new(429, Json::string("rate limited")),
    ),
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"a\":1}")),
      @core.Response::ok(Json::string("done")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  assert_eq(send_result(session, request).unwrap().status, 429)
  assert_eq(send_result(session, request).unwrap().status, 200)
  // 第三次回卷，又拿到最早那条。
  assert_eq(send_result(session, request).unwrap().status, 429)
}

///|
test "sequential policy reports exhaustion instead of wrapping" {
  // 与上一条形成对照：顺序策略不做回卷，「录制不够」必须被报出来，
  // 因为它的修法是补录制，而不是继续复用旧记录。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"a\":1}")),
      @core.Response::new(429, Json::string("rate limited")),
    ),
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"a\":1}")),
      @core.Response::ok(Json::string("done")),
    ),
  ])
  let session = @recorder.Session::new(
    cassette,
    policy=@matcher.MatchPolicy::Sequential,
  )
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  assert_eq(send_result(session, request).unwrap().status, 429)
  assert_eq(send_result(session, request).unwrap().status, 200)
  match send_result(session, request) {
    Ok(_) => fail("expected exhaustion")
    Err(@core.CassetteError::Exhausted(message)) => {
      // 消息本身要能指导下一步：条数与「多调了一次」。
      assert_true(message.contains("2"))
      assert_true(message.contains("one call more"))
    }
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "the scripted mock appends rather than overwriting" {
  let mock = @recorder.MockTransport::new()
  let request = request_of("gpt-4o", @json.parse("{\"a\":1}"))
  mock.on(request, @core.Response::new(429, Json::string("first")))
  mock.on(request, @core.Response::ok(Json::string("second")))
  let first = mock.send(request) catch {
    error => return fail("unexpected error: " + error.to_string())
  }
  assert_eq(first.status, 429)
  let second = mock.send(request) catch {
    error => return fail("unexpected error: " + error.to_string())
  }
  assert_eq(second.status, 200)
}

///|
test "an unscripted mock request still fails loudly" {
  let mock = @recorder.MockTransport::new()
  let response = mock.send(request_of("gpt-4o", Json::null())) catch {
    error => return fail("unexpected error: " + error.to_string())
  }
  assert_eq(response.status, 500)
}
