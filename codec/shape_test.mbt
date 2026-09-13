// mooncassette/codec —— 形状矩阵（稳定往返）。
//
// 这里不用随机，而是把「有意义的形状轴」逐个列出来：有无 usage、有无流式帧、
// 空对象 / 空数组、非 ASCII、状态码 0、用量为 0、深层嵌套……
//
// 之所以要用笛卡尔式的穷举而不是随机：往返失败往往发生在**组合**上
// （例如「没有 usage」+「有帧」），随机采样很难刚好命中，而轴的数量本来就不多。
//
// 断言的是「编码 → 解码 → 再编码」的**字节相等**：它同时约束字段内容与规范键序，
// 比比较对象更严格。

///|
fn assert_roundtrip_stable(cassette : @core.Cassette) -> Unit raise {
  let text = @codec.encode(cassette)
  let restored = @codec.decode(text) catch {
    error => fail("decode failed: " + error.to_string())
  }
  assert_eq(@codec.encode(restored), text)
}

///|
fn one_interaction_cassette(
  body : Json,
  response : @core.Response,
) -> @core.Cassette {
  @core.Cassette::new("shapes", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", body),
      response,
    ),
  ])
}

///|
test "an empty cassette round-trips" {
  assert_roundtrip_stable(@core.Cassette::new("empty"))
}

///|
test "a response without usage round-trips" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"a\":1}"),
      @core.Response::new(200, @json.parse("{}")),
    ),
  )
}

///|
test "a response with usage round-trips" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"a\":1}"),
      @core.Response::ok(@json.parse("{}"), usage=@core.Usage::new(0, 0)),
    ),
  )
}

///|
test "a zero status code round-trips" {
  // 非 HTTP 传输（例如本地 mock）用 0，不能被当成「缺失」。
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{}"),
      @core.Response::new(0, Json::null()),
    ),
  )
}

///|
test "empty containers round-trip" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"empty_object\":{},\"empty_array\":[]}"),
      @core.Response::ok(@json.parse("{}")),
    ),
  )
}

///|
test "non-ascii content round-trips" {
  // 规范文本要求非 ASCII 原样输出（保持 cassette 可读），因此这条同时验证
  // 「不转义非 ASCII」与「转义后仍能解析回来」。
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"messages\":[{\"role\":\"user\",\"content\":\"你好，世界 🌍\"}]}"),
      @core.Response::ok(@json.parse("{\"text\":\"¡Hola! Ünïcödé — 日本語\"}")),
    ),
  )
}

///|
test "control characters and quotes round-trip" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"text\":\"line\\nbreak\\ttab\\\"quote\\\\slash\"}"),
      @core.Response::ok(@json.parse("{\"text\":\"\\u0001\\u001f\"}")),
    ),
  )
}

///|
test "a streamed response round-trips" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{\"stream\":true}"),
      @core.Response::ok(
        @json.parse("{\"choices\":[]}"),
        usage=@core.Usage::new(9, 5),
        stream=[
          @core.StreamFrame::new("{\"i\":1}", event="chunk"),
          @core.StreamFrame::new("multi\nline"),
          @core.StreamFrame::new("[DONE]"),
        ],
      ),
    ),
  )
}

///|
test "an empty stream array round-trips" {
  // 「有流但零帧」只可能来自手工编辑；如实往返，不悄悄抹平。
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{}"),
      @core.Response::ok(Json::null(), stream=[]),
    ),
  )
}

///|
test "a frame sequence with mixed event names round-trips" {
  assert_roundtrip_stable(
    one_interaction_cassette(
      @json.parse("{}"),
      @core.Response::ok(
        Json::null(),
        stream=[
          @core.StreamFrame::new("a", event="message_start"),
          @core.StreamFrame::new("", event="ping"),
          @core.StreamFrame::new("你好"),
        ],
      ),
    ),
  )
}

///|
test "deeply nested payloads round-trip" {
  let nested = @json.parse(
    "{\"a\":{\"b\":{\"c\":{\"d\":{\"e\":[1,[2,[3,[4]]]]}}}}}",
  )
  assert_roundtrip_stable(
    one_interaction_cassette(
      nested,
      @core.Response::ok(@json.parse("{\"mirror\":true}")),
    ),
  )
}

///|
test "many interactions keep their order" {
  let interactions : Array[@core.Interaction] = []
  for i = 0; i < 20; i = i + 1 {
    interactions.push(
      @core.Interaction::new(
        @core.Request::new("openai", "gpt-4o", @json.parse("{\"i\":" + i.to_string() + "}")),
        @core.Response::ok(Json::null()),
      ),
    )
  }
  let cassette = @core.Cassette::new("many", interactions=interactions)
  assert_roundtrip_stable(cassette)
  // 顺序就是回放语义，必须原样保留。
  let restored = @codec.decode(@codec.encode(cassette)) catch {
    error => fail("decode failed: " + error.to_string())
  }
  assert_eq(restored.length(), 20)
  assert_eq(restored.interactions[19].request.body, @json.parse("{\"i\":19}"))
}
