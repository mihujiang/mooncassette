// mooncassette/codec —— 序列化格式契约测试。
//
// 这里的重点是「严格性」：格式必须能稳定往返，同时对被手工改动、
// 版本不匹配、字段缺失、类型错误等情形给出明确错误，而不是静默容错。

///|
fn sample_cassette() -> @core.Cassette raise {
  @core.Cassette::new("demo", recorded_at="2026-09-12T00:00:00Z", interactions=[
    @core.Interaction::new(
      @core.Request::new(
        "openai",
        "gpt-4o",
        @json.parse("{\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}"),
      ),
      @core.Response::ok(
        @json.parse("{\"choices\":[]}"),
        usage=@core.Usage::new(10, 2),
      ),
    ),
    @core.Interaction::new(
      @core.Request::new(
        "openai",
        "gpt-4o-mini",
        @json.parse("{\"messages\":[]}"),
      ),
      @core.Response::new(429, @json.parse("{\"error\":\"rate limit\"}")),
    ),
  ])
}

///|
/// 把 `decode` 的抛错行为转成 `Result`，便于在测试中区分错误种类。
fn decode_result(
  text : StringView,
) -> Result[@core.Cassette, @core.CassetteError] {
  let cassette = @codec.decode(text) catch { error => return Err(error) }
  Ok(cassette)
}

///|
test "round-trip preserves the cassette" {
  let original = sample_cassette()
  let restored = decode_result(@codec.encode(original)).unwrap()
  // 断言的是重新编码后的**字节**相等，比比较对象更严格：
  // 它同时约束了字段内容与规范键序。
  assert_eq(
    @codec.encode(restored, indent=0),
    @codec.encode(original, indent=0),
  )
}

///|
test "round-trip works for an empty cassette" {
  let original = @core.Cassette::new("empty")
  let restored = decode_result(@codec.encode(original)).unwrap()
  assert_eq(
    @codec.encode(restored, indent=0),
    @codec.encode(original, indent=0),
  )
}

///|
test "compact and pretty encodings decode to the same cassette" {
  let original = sample_cassette()
  let compact = @codec.encode(original, indent=0)
  let pretty = @codec.encode(original, indent=4)
  assert_true(!compact.contains("\n"))
  assert_true(pretty.contains("\n"))
  assert_eq(@codec.encode(decode_result(compact).unwrap(), indent=0), compact)
  assert_eq(@codec.encode(decode_result(pretty).unwrap(), indent=0), compact)
}

///|
test "encoding is byte-for-byte deterministic" {
  let original = sample_cassette()
  assert_eq(@codec.encode(original), @codec.encode(original))
}

///|
test "pretty encoding is the default" {
  let cassette = @core.Cassette::new("demo")
  assert_true(@codec.encode(cassette).contains("\n"))
}

///|
test "encoding writes the format tag and current version" {
  let text = @codec.encode(sample_cassette(), indent=0)
  assert_true(
    text.has_prefix("{\"format\":\"mooncassette\",\"interactions\":["),
  )
  assert_true(text.contains("\"version\":1"))
}

///|
test "encoding writes both digests per interaction" {
  let cassette = sample_cassette()
  let text = @codec.encode(cassette, indent=0)
  let request_digest = @fingerprint.fingerprint(
    cassette.interactions[0].request,
  )
  let record_digest = @fingerprint.integrity_digest(cassette.interactions[0])
  assert_true(text.contains("\"fingerprint\":\"" + request_digest + "\""))
  assert_true(text.contains("\"integrity\":\"" + record_digest + "\""))
  // 两者必须不同：它们覆盖的范围不一样。
  assert_true(request_digest != record_digest)
}

///|
test "decoding rejects input that is not valid JSON" {
  match decode_result("{not json") {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::Malformed(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding rejects a non-object top level" {
  match decode_result("[]") {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::Malformed(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding rejects a foreign format tag" {
  match decode_result("{\"format\":\"other\",\"version\":1}") {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::Malformed(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding rejects an unsupported format version" {
  let text = "{\"format\":\"mooncassette\",\"version\":2,\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[]}"
  match decode_result(text) {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::UnsupportedVersion(version)) =>
      assert_eq(version, 2)
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding reports the exact path of a missing field" {
  let text = "{\"format\":\"mooncassette\",\"version\":1,\"meta\":{\"name\":\"x\"},\"interactions\":[]}"
  match decode_result(text) {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::SchemaViolation(message)) =>
      assert_eq(message, "$.meta.generator: missing required field")
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding rejects a non-integer status" {
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", Json::null()),
      @core.Response::ok(Json::null()),
    ),
  ])
  let text = @codec.encode(cassette, indent=0).replace(
    old="\"status\":200",
    new="\"status\":200.5",
  )
  match decode_result(text) {
    Ok(_) => fail("expected a failure")
    Err(@core.CassetteError::SchemaViolation(message)) =>
      assert_eq(
        message, "$.interactions[0].response.status: expected an integer",
      )
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding detects a hand-edited request body" {
  let text = @codec.encode(sample_cassette())
  assert_true(text.contains("\"hi\""))
  let tampered = text.replace(old="\"hi\"", new="\"bye\"")
  match decode_result(tampered) {
    Ok(_) => fail("expected an integrity violation")
    Err(@core.CassetteError::IntegrityViolation(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding detects a hand-edited response body" {
  // 回归测试：早期版本只对**请求**做校验，改动响应内容不会被发现。
  // 而「为了让失败的测试通过，直接改期望输出」恰恰是最常见的误用，
  // 因此响应必须纳入完整性校验。
  //
  // 这里用紧凑编码：缩进格式会在冒号后插入空格，做字符串替换不方便。
  let text = @codec.encode(sample_cassette(), indent=0)
  assert_true(text.contains("\"choices\":[]"))
  let tampered = text.replace(old="\"choices\":[]", new="\"choices\":[1]")
  match decode_result(tampered) {
    Ok(_) => fail("expected an integrity violation")
    Err(@core.CassetteError::IntegrityViolation(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding detects a hand-edited status code" {
  let text = @codec.encode(sample_cassette(), indent=0)
  let tampered = text.replace(old="\"status\":429", new="\"status\":200")
  match decode_result(tampered) {
    Ok(_) => fail("expected an integrity violation")
    Err(@core.CassetteError::IntegrityViolation(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "decoding detects a hand-edited token usage" {
  let text = @codec.encode(sample_cassette(), indent=0)
  let tampered = text.replace(
    old="\"input_tokens\":10",
    new="\"input_tokens\":1",
  )
  match decode_result(tampered) {
    Ok(_) => fail("expected an integrity violation")
    Err(@core.CassetteError::IntegrityViolation(_)) => ()
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "integrity checking can be disabled explicitly" {
  let text = @codec.encode(sample_cassette())
  let tampered = text.replace(old="\"hi\"", new="\"bye\"")
  let restored = @codec.decode(tampered, verify=false) catch { _ => panic() }
  assert_eq(
    restored.interactions[0].request.body,
    @json.parse("{\"messages\":[{\"role\":\"user\",\"content\":\"bye\"}]}"),
  )
}

///|
test "decoding keeps the recorded_at metadata when present" {
  let restored = decode_result(@codec.encode(sample_cassette())).unwrap()
  assert_eq(restored.meta.recorded_at, Some("2026-09-12T00:00:00Z"))
  assert_eq(restored.meta.name, "demo")
}

///|
test "decoding omits recorded_at when it was not recorded" {
  let restored = decode_result(@codec.encode(@core.Cassette::new("no-time"))).unwrap()
  assert_true(restored.meta.recorded_at is None)
}

///|
test "response without usage round-trips as None" {
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", Json::null()),
      @core.Response::new(500, @json.parse("{\"error\":\"boom\"}")),
    ),
  ])
  let restored = decode_result(@codec.encode(cassette)).unwrap()
  assert_true(restored.interactions[0].response.usage is None)
  assert_eq(
    @codec.encode(restored, indent=0),
    @codec.encode(cassette, indent=0),
  )
}
