// mooncassette/codec —— 错误信息审计。
//
// 标准不是「抛没抛错」，而是：**看到报错的人是否需要读源码才知道该改哪里。**
// 所以这里断言的是消息里有没有定位所需的信息 —— 路径、字段名、期望的类型、
// 支持的版本范围、或者被保留下来的上下文。
//
// 有两个变体无法从数据侧触发（真实哈希碰撞需要打破 FNV；传输失败来自使用方的
// Transport），对它们只能审计 `Show` 输出。这一点在下面的测试里写明了，不假装
// 覆盖到了。

///|
/// 解码一段文本，返回错误消息；没有报错时返回 `<no error>`（对审计而言即失败）。
fn decode_error(text : StringView) -> String {
  let _ = @codec.decode(text) catch { error => return error.to_string() }
  "<no error>"
}

///|
/// 一段除指定字段外都合法的 cassette 前缀。
let valid_head : String = "{\"format\":\"mooncassette\",\"version\":2"

///|
test "invalid JSON is called out as such" {
  assert_true(decode_error("{not json").contains("not valid JSON"))
}

///|
test "a non-object top level is called out" {
  assert_true(
    decode_error("[]").contains("top-level value must be a JSON object"),
  )
}

///|
test "a foreign format tag names the expected tag" {
  // 只说「格式不对」不够，得说清楚期望的是什么。
  let message = decode_error("{\"format\":\"something-else\"}")
  assert_true(message.contains("mooncassette"))
  assert_true(message.contains("something-else"))
}

///|
test "an unsupported version names the version and the supported range" {
  // 缺 `version` 字段时也要报出路径。
  let missing = decode_error(
    "{\"format\":\"mooncassette\",\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[]}",
  )
  assert_true(missing.contains("$.version"))

  let unsupported = decode_error(
    "{\"format\":\"mooncassette\",\"version\":99,\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[]}",
  )
  assert_true(unsupported.contains("99"))
  assert_true(
    unsupported.contains("1 to " + @core.cassette_format_version.to_string()),
  )
}

///|
test "a missing field is reported with its full path" {
  let message = decode_error(
    valid_head + ",\"meta\":{\"generator\":\"g\"},\"interactions\":[]}",
  )
  assert_true(message.contains("$.meta.name"))
}

///|
test "a wrong field type is reported with its path and the expected type" {
  let message = decode_error(
    valid_head +
    ",\"meta\":{\"name\":1,\"generator\":\"g\"},\"interactions\":[]}",
  )
  assert_true(message.contains("$.meta.name"))
  assert_true(message.contains("expected a string"))
}

///|
test "a missing interactions array is reported with its path" {
  let message = decode_error(
    valid_head + ",\"meta\":{\"name\":\"x\",\"generator\":\"g\"}}",
  )
  assert_true(message.contains("$.interactions"))
}

///|
test "a malformed frame is reported down to the frame index and field" {
  // 深层结构里的问题必须能一路定位：哪条记录、哪个数组下标、哪个字段。
  let message = decode_error(
    valid_head +
    ",\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[{\"fingerprint\":\"f\",\"integrity\":\"i\",\"request\":{\"provider\":\"p\",\"model\":\"m\",\"body\":null},\"response\":{\"status\":200,\"body\":null,\"stream\":[{\"event\":1,\"data\":\"x\"}]}}]}",
  )
  assert_true(message.contains("$.interactions[0].response.stream[0].event"))
  assert_true(message.contains("expected a string"))
}

///|
test "a frame missing its data field is reported with its path" {
  let message = decode_error(
    valid_head +
    ",\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[{\"fingerprint\":\"f\",\"integrity\":\"i\",\"request\":{\"provider\":\"p\",\"model\":\"m\",\"body\":null},\"response\":{\"status\":200,\"body\":null,\"stream\":[{\"event\":\"e\"}]}}]}",
  )
  assert_true(message.contains("$.interactions[0].response.stream[0].data"))
}

///|
test "an integer field rejects a fractional number with its path" {
  // `1.5` 被悄悄取整成 1 是典型的静默错，必须拒绝并说清楚。
  let message = decode_error(
    valid_head +
    ",\"meta\":{\"name\":\"x\",\"generator\":\"g\"},\"interactions\":[{\"fingerprint\":\"f\",\"integrity\":\"i\",\"request\":{\"provider\":\"p\",\"model\":\"m\",\"body\":null},\"response\":{\"status\":200.5,\"body\":null}}]}",
  )
  assert_true(message.contains("$.interactions[0].response.status"))
  assert_true(message.contains("expected an integer"))
}

///|
test "every error variant renders with a prefix, a label and its context" {
  // 审计的是「统一性」：全部变体都带 `mooncassette: ` 前缀（CLI 不会出现
  // 「mooncassette: mooncassette:」这类重复拼接），而且都把上下文保留下来，
  // 而不是换成一句泛泛的「出错了」。
  let cases : Array[(@core.CassetteError, String, String)] = [
    (@core.CassetteError::Malformed("CTX"), "malformed cassette", "CTX"),
    (@core.CassetteError::SchemaViolation("CTX"), "schema violation", "CTX"),
    (
      @core.CassetteError::UnsupportedVersion(7),
      "unsupported cassette format version",
      "7",
    ),
    (
      @core.CassetteError::FingerprintCollision("CTX"),
      "fingerprint collision",
      "CTX",
    ),
    (
      @core.CassetteError::IntegrityViolation("CTX"),
      "integrity violation",
      "CTX",
    ),
    (
      @core.CassetteError::NoMatch("CTX"),
      "no recorded interaction matches",
      "CTX",
    ),
    (@core.CassetteError::Exhausted("CTX"), "recording exhausted", "CTX"),
    (@core.CassetteError::MissingTransport("CTX"), "missing transport", "CTX"),
    (@core.CassetteError::TransportFailure("CTX"), "transport failure", "CTX"),
  ]
  for item in cases {
    let (error, label, context) = item
    let text = error.to_string()
    assert_true(text.has_prefix("mooncassette: "))
    assert_true(text.contains(label))
    // 上下文必须保留：丢掉了它，报错就成了「出错了」。
    assert_true(text.contains(context))
  }
}

///|
test "the unsupported-version message states the supported range" {
  let text = @core.CassetteError::UnsupportedVersion(7).to_string()
  assert_true(text.contains("7"))
  assert_true(
    text.contains("1 to " + @core.cassette_format_version.to_string()),
  )
}

///|
test "variants that data cannot trigger still render informatively" {
  // 真实的哈希碰撞需要打破 FNV，传输失败来自使用方的 Transport —— 两者都无法
  // 在测试里自然构造。这里只审计它们的输出，并明确这是**输出审计**而不是
  // 端到端触发。
  let collision = @core.CassetteError::FingerprintCollision("fnv1a64:abc").to_string()
  assert_true(collision.contains("fnv1a64:abc"))
  assert_true(collision.contains("two different requests"))

  let failure = @core.CassetteError::TransportFailure(
    "connection reset by peer",
  ).to_string()
  assert_true(failure.contains("connection reset by peer"))
}
