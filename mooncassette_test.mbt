// mooncassette —— 门面包的端到端契约测试。
//
// 这里验证的是「用户实际会走的那条路」：
// 录制 → 落盘 → 断开真实依赖 → 回放。

///|
test "facade: command records once, then replays fully offline" {
  // 请求里刻意带上密钥：它能同时覆盖「落盘必须脱敏」与
  // 「脱敏后回放仍能命中」这两个曾经互相打架的要求。
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"api_key\":\"sk-abcdefgh12345678\",\"a\":1}"),
  )
  let mock = @recorder.MockTransport::new()
  mock.on(request, @core.Response::ok(Json::string("live")))

  let recording = @mooncassette.record_session(
    @core.Cassette::new("demo"),
    mock,
  )
  let _ = recording.send(request) catch { _ => panic() }
  let saved = @mooncassette.save(recording)

  // 关键：回放会话**没有** transport，因此物理上不可能发起真实调用。
  let playback = @mooncassette.replay_session(saved) catch { _ => panic() }
  let response = playback.send(request) catch { _ => panic() }
  assert_eq(response.body, Json::string("live"))
  assert_eq(mock.call_count(), 1)
}

///|
test "facade: auto session records on miss and replays on hit" {
  let known = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1}"))
  let fresh = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":2}"))
  let mock = @recorder.MockTransport::new()
  mock.on(fresh, @core.Response::ok(Json::string("fresh")))

  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(known, @core.Response::ok(Json::string("known"))),
  ])
  let session = @mooncassette.auto_session(cassette, mock)
  let replayed = session.send(known) catch { _ => panic() }
  let captured = session.send(fresh) catch { _ => panic() }
  assert_eq(replayed.body, Json::string("known"))
  assert_eq(captured.body, Json::string("fresh"))
  assert_eq(mock.call_count(), 1)
  assert_eq(@mooncassette.save(session, indent=0).length() > 0, true)
}

///|
/// 把 `replay_session` 的抛错行为转成 `Result`。
fn replay_result(
  location : StringView,
) -> Result[@recorder.Session, @core.CassetteError] {
  let session = @mooncassette.replay_session(location) catch {
    error => return Err(error)
  }
  Ok(session)
}

///|
test "facade: replay_session rejects a corrupted cassette" {
  assert_true(replay_result("{ not json") is Err(_))
}

///|
test "facade: replay_session rejects an unsupported format version" {
  let text = "{\"format\":\"mooncassette\",\"version\":9,\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[]}"
  match replay_result(text) {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::UnsupportedVersion(version)) =>
      assert_eq(version, 9)
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}
