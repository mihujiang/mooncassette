///|
/// 适配层的测试全程离线：磁带是手工搭的，一个字节都不出网。
///
/// 这不是为了快 —— 是为了证明这层的东西真的不依赖网络。一个「离线适配层」
/// 如果只能靠联网来测，那它就不是离线的。

///|
/// 一段 OpenAI 兼容端点的流式响应，按线上真正会出现的字节写。
///
/// 手写 JSON 字符串而不是用 `Json::object` 拼，是有意的：适配层解析的是
/// 真实协议里的形状，测试就该喂它真实的形状。用结构体拼出来的东西是
/// 「我以为的形状」，那正是这类适配层最容易错的地方。
///
/// 四帧的顺序也是真的：内容增量、结束原因、最后才是只带账目的那帧 ——
/// 账目永远晚一步到，这正是「精确用量」这件事的麻烦所在。
fn openai_stream_frames() -> Array[@core.StreamFrame] {
  [
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{\"content\":\"你好\"},\"index\":0,\"finish_reason\":null}]}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{\"content\":\"，世界\"},\"index\":0,\"finish_reason\":null}]}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{},\"index\":0,\"finish_reason\":\"stop\"}],\"usage\":null}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[],\"usage\":{\"prompt_tokens\":31,\"completion_tokens\":7,\"total_tokens\":38}}",
    ),
  ]
}

///|
/// 搭一条只有一个交互的磁带，请求用适配层自己的构造函数生成 ——
/// 这样「录制方」与「回放方」共用同一份请求，测的是回放路径而不是手感。
fn cassette_with_stream(
  messages : Array[@llm.Message],
  frames : Array[@core.StreamFrame],
) -> @core.Cassette {
  let request = request_of_messages("openai", "gpt-4o-mini", messages)
  let response = @core.Response::ok(
    Json::object(Map([])),
    usage=@core.Usage::new(31, 7),
    stream=frames,
  )
  @core.Cassette::new("llm-replay", interactions=[
    @core.Interaction::new(request, response),
  ])
}

///|
/// `@core.Usage` 与 `@llm.Usage` 都没派生 `Debug`/`Eq`（它们是别人的类型，
/// 改不了），所以用量只能拆开比。
fn assert_usage(actual : @core.Usage?, input : Int, output : Int) -> Unit raise {
  match actual {
    Some(u) => {
      assert_eq(u.input_tokens, input)
      assert_eq(u.output_tokens, output)
    }
    None => fail("期望有用量记录，实际是 None")
  }
}

///|
fn collect_events(
  provider : CassetteProvider,
  messages : Array[@llm.Message],
) -> Array[@llm.StreamEvent] {
  let events : Array[@llm.StreamEvent] = []
  let handler = @llm.StreamHandler::{
    on_event: fn(event) { events.push(event) },
  }
  provider.stream(messages, [], handler)
  events
}

///|
test "从磁带回放：事件序列是 MessageStart / 增量 / 恰好一个 MessageEnd" {
  let messages = [@llm.Message::user("你好")]
  let cassette = cassette_with_stream(messages, openai_stream_frames())
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = CassetteProvider::new(session, "gpt-4o-mini")
  let events = collect_events(provider, messages)
  // 两个内容增量，加上一头一尾。账目帧与原 provider 不同，不会漏成第二个尾巴。
  assert_eq(events.length(), 4)
  assert_true(events[0] is @llm.StreamEvent::MessageStart)
  assert_true(events[1] is @llm.StreamEvent::TextDelta("你好"))
  assert_true(events[2] is @llm.StreamEvent::TextDelta("，世界"))
  match events[3] {
    @llm.StreamEvent::MessageEnd(finish_reason~, usage~) => {
      assert_true(finish_reason is @llm.FinishReason::Stop)
      match usage {
        Some(u) => {
          assert_eq(u.input_tokens, 31)
          assert_eq(u.output_tokens, 7)
        }
        None => fail("最后一帧应当带用量")
      }
    }
    _ => fail("最后一帧应当是 MessageEnd")
  }
}

///|
test "精确用量：上报值来自磁带，估算与上报能并排比较" {
  let messages = [@llm.Message::user("你好")]
  let cassette = cassette_with_stream(messages, openai_stream_frames())
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = CassetteProvider::new(session, "gpt-4o-mini")
  let _ = collect_events(provider, messages)
  assert_usage(provider.last_usage(), 31, 7)
  match provider.token_drift() {
    Some((estimated, reported)) => {
      // 上报值就是账单上的数字，一位不差。
      assert_eq(reported, 31)
      // 估算值一定存在，且对这种短消息一定比真实值小 —— 猜的 `(字符数+3)/4`
      // 会把 "你好" 这种多字节内容算漏。
      assert_true(estimated > 0)
      assert_true(estimated < reported)
    }
    None => fail("录到了用量，不该是 None")
  }
}

///|
test "reported_usage 直接查磁带，不需要先跑一轮" {
  let messages = [@llm.Message::user("你好")]
  let cassette = cassette_with_stream(messages, openai_stream_frames())
  let request = request_of_messages("openai", "gpt-4o-mini", messages)
  assert_usage(reported_usage(cassette, request), 31, 7)
  // 换个 model 就查不到了 —— 这不是缺陷，是不猜：宁可交回 None，
  // 也不要拿别的模型的用量糊弄过去。
  let other = request_of_messages("openai", "gpt-4o", messages)
  assert_true(reported_usage(cassette, other) is None)
}

///|
test "没录过的请求：回放给出 Error 事件，而不是抛异常" {
  let messages = [@llm.Message::user("从没录过的一句话")]
  let cassette = @core.Cassette::new("empty")
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = CassetteProvider::new(session, "gpt-4o-mini")
  let events = collect_events(provider, messages)
  assert_eq(events.length(), 1)
  match events[0] {
    @llm.StreamEvent::Error(message) => assert_true(message.length() > 0)
    _ => fail("缺失记录应当翻译成 Error 事件")
  }
}

///|
test "非流式记录也能回放：下游拿到的形态与流式一致" {
  let messages = [@llm.Message::user("你好")]
  let request = request_of_messages("openai", "gpt-4o-mini", messages)
  let body = @json.parse(
    "{\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"你好，世界\"},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":31,\"completion_tokens\":7}}",
  ) catch {
    _ => fail("测试夹具写错了")
  }
  let cassette = @core.Cassette::new("llm-replay-plain", interactions=[
    @core.Interaction::new(request, {
      status: 200,
      body,
      usage: Some(@core.Usage::new(31, 7)),
      stream: None,
    }),
  ])
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = CassetteProvider::new(session, "gpt-4o-mini")
  let events = collect_events(provider, messages)
  assert_eq(events.length(), 3)
  assert_true(events[0] is @llm.StreamEvent::MessageStart)
  assert_true(events[1] is @llm.StreamEvent::TextDelta("你好，世界"))
  assert_usage(provider.last_usage(), 31, 7)
}

///|
test "mizchi/llm 的 collect 能直接用：文本与用量一起拿到" {
  let messages = [@llm.Message::user("你好")]
  let cassette = cassette_with_stream(messages, openai_stream_frames())
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = CassetteProvider::new(session, "gpt-4o-mini")
  let result = @llm.collect(provider, messages)
  assert_eq(result.text, "你好，世界")
  assert_true(result.finish_reason is @llm.FinishReason::Stop)
  match result.usage {
    Some(u) => {
      assert_eq(u.input_tokens, 31)
      assert_eq(u.output_tokens, 7)
    }
    None => fail("collect 应当带回用量")
  }
}

///|
test "请求体形状与 mizchi/llm 的 OpenAI provider 对齐" {
  let body = openai_body(
    "gpt-4o-mini",
    1024,
    "你是助手",
    [@llm.Message::user("你好")],
    [],
  )
  // 始终流式，并索取用量 —— 少了 include_usage 就没有精确值可谈。
  assert_eq(@llm.json_get_int(body, "max_tokens"), Some(1024))
  assert_eq(@llm.json_get_string(body, "model"), Some("gpt-4o-mini"))
  match body {
    Json::Object(fields) => {
      assert_true(fields.get("stream") is Some(Json::True))
      match fields.get("stream_options") {
        Some(Json::Object(options)) =>
          assert_true(options.get("include_usage") is Some(Json::True))
        _ => fail("缺 stream_options")
      }
    }
    _ => fail("请求体应当是 JSON 对象")
  }
  // system prompt 排在最前面，这是协议要求的（也是原 provider 的做法）。
  match @llm.json_get_array(body, "messages") {
    Some(msgs) => {
      assert_eq(msgs.length(), 2)
      assert_eq(@llm.json_get_string(msgs[0], "role"), Some("system"))
      assert_eq(@llm.json_get_string(msgs[1], "role"), Some("user"))
    }
    None => fail("缺 messages")
  }
  // 没有工具时不出 tools 字段 —— 空数组也会进指纹，形状必须与录制端逐字一致。
  assert_true(@llm.json_get_array(body, "tools") is None)
}

///|
test "带工具的请求会把 tools 一起写进指纹" {
  let tool = @llm.ToolDef::new(
    "get_weather",
    "查天气",
    @json.parse("{\"type\":\"object\"}") catch {
      _ => Json::null()
    },
  )
  let body = openai_body(
    "gpt-4o-mini",
    1024,
    "",
    [@llm.Message::user("北京天气")],
    [tool],
  )
  match @llm.json_get_array(body, "tools") {
    Some(tools) => assert_eq(tools.length(), 1)
    None => fail("给了工具就该有 tools 字段")
  }
}

///|
test "请求互转：能从请求体把消息读回来" {
  let messages = [
    @llm.Message::user("你好"),
    @llm.Message::assistant("在的"),
  ]
  let request = request_of_messages(
    "openai",
    "gpt-4o-mini",
    messages,
    system_prompt="你是助手",
  )
  let back = messages_of_request(request)
  assert_eq(back.length(), 3)
  assert_true(back[0].role is @llm.Role::System)
  assert_eq(back[1].get_text(), "你好")
  assert_eq(back[2].get_text(), "在的")
}

///|
test "帧解析：错误帧翻译成 Error 事件" {
  match parse_frame("{\"error\":{\"message\":\"额度不足\"}}") {
    Some(@llm.StreamEvent::Error(message)) => assert_eq(message, "额度不足")
    _ => fail("错误帧应当翻译成 Error 事件")
  }
}

///|
test "帧解析：看不懂的字节返回 None，不抛异常" {
  assert_true(parse_frame("{不是 json") is None)
  assert_true(parse_frame("{}") is None)
}
