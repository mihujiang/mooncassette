// mooncassette/recorder —— 索引在会话里的端到端行为。
//
// 会话在首次匹配时建立索引，并在每次追加录制时同步追加。这里验证的就是
// 这条链：「录制期间建立的索引」与「回放时的查询」必须始终对齐。

///|
test "replay stays correct while the index grows during recording" {
  // 若索引在录制期间同步写错，回放会取回**别人的**响应 —— 不报错，只出错。
  let mock = @recorder.MockTransport::new()
  let session = @recorder.Session::new(
    @core.Cassette::new("demo"),
    mode=@recorder.Mode::Record,
    transport=mock,
  )
  for i = 1; i <= 3; i = i + 1 {
    let request = request_of("gpt-4o", @json.parse("{\"n\":" + i.to_string() + "}"))
    mock.on(request, @core.Response::ok(Json::string("answer-" + i.to_string())))
    let sent = send_result(session, request).unwrap()
    assert_eq(sent.body, Json::string("answer-" + i.to_string()))
  }
  assert_eq(session.cassette().length(), 3)

  // 回放：每条请求都必须取回自己那份响应。
  session.set_mode(@recorder.Mode::Playback)
  for i = 1; i <= 3; i = i + 1 {
    let request = request_of("gpt-4o", @json.parse("{\"n\":" + i.to_string() + "}"))
    let replayed = send_result(session, request).unwrap()
    assert_eq(replayed.body, Json::string("answer-" + i.to_string()))
  }
}

///|
test "an indexed session reports a miss as a miss" {
  // 索引只加速查找，不该把「找不到」变成「找到」。
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      request_of("gpt-4o", @json.parse("{\"n\":1}")),
      @core.Response::ok(Json::string("one")),
    ),
  ])
  let session = @recorder.Session::new(cassette)
  // 先查一次命中，索引就此建立。
  let _ = send_result(session, request_of("gpt-4o", @json.parse("{\"n\":1}"))).unwrap()
  match send_result(session, request_of("gpt-4o", @json.parse("{\"n\":2}"))) {
    Ok(_) => fail("expected a NoMatch failure")
    Err(@core.CassetteError::NoMatch(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "an indexed session matches the same way on a long cassette" {
  // 长 cassette 上索引带来的差别最大，因此在这里也验一遍命中位置。
  let interactions : Array[@core.Interaction] = []
  for i = 0; i < 50; i = i + 1 {
    interactions.push(
      @core.Interaction::new(
        request_of("gpt-4o", @json.parse("{\"n\":" + i.to_string() + "}")),
        @core.Response::ok(Json::string("answer-" + i.to_string())),
      ),
    )
  }
  let session = @recorder.Session::new(
    @core.Cassette::new("demo", interactions~),
  )
  for i = 0; i < 50; i = i + 1 {
    let request = request_of("gpt-4o", @json.parse("{\"n\":" + i.to_string() + "}"))
    let replayed = send_result(session, request).unwrap()
    assert_eq(replayed.body, Json::string("answer-" + i.to_string()))
  }
}
