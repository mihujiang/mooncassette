// mooncassette/fingerprint —— 指纹行为契约测试。
//
// 指纹的稳定性是「本机录制、CI 回放」这一核心场景的前提，
// 因此这里必须覆盖：键序无关、字段敏感、算法前缀、以及
// 「指纹相同 ≠ 请求相同」这一关键区分的兜底判据。

///|
fn build_request(model : String, body : Json) -> @core.Request {
  @core.Request::new("openai", model, body)
}

///|
test "fingerprint is independent of object key order" {
  let first = build_request("gpt-4o", @json.parse("{\"a\":1,\"b\":2}"))
  let second = build_request("gpt-4o", @json.parse("{\"b\":2,\"a\":1}"))
  assert_eq(@fingerprint.fingerprint(first), @fingerprint.fingerprint(second))
  assert_true(@fingerprint.same_request(first, second))
}

///|
test "fingerprint changes when the model changes" {
  let first = build_request("gpt-4o", @json.parse("{\"a\":1}"))
  let second = build_request("gpt-4o-mini", @json.parse("{\"a\":1}"))
  assert_true(
    @fingerprint.fingerprint(first) != @fingerprint.fingerprint(second),
  )
  assert_false(@fingerprint.same_request(first, second))
}

///|
test "fingerprint changes when the provider changes" {
  let body = @json.parse("{\"a\":1}")
  let first = @core.Request::new("openai", "gpt-4o", body)
  let second = @core.Request::new("azure", "gpt-4o", body)
  assert_true(
    @fingerprint.fingerprint(first) != @fingerprint.fingerprint(second),
  )
}

///|
test "fingerprint changes when the body changes" {
  let first = build_request("gpt-4o", @json.parse("{\"a\":1}"))
  let second = build_request("gpt-4o", @json.parse("{\"a\":2}"))
  assert_true(
    @fingerprint.fingerprint(first) != @fingerprint.fingerprint(second),
  )
}

///|
test "fingerprint is prefixed by the algorithm identifier" {
  let request = build_request("gpt-4o", @json.parse("{}"))
  let value = @fingerprint.fingerprint(request)
  assert_true(value.has_prefix(@fingerprint.algorithm + ":"))
  // "fnv1a64:" 共 8 个字符，加上 16 位十六进制，总长固定为 24。
  assert_eq(value.length(), 24)
}

///|
test "fingerprint length is stable across inputs" {
  let short = @fingerprint.fingerprint(build_request("m", Json::null()))
  let long = @fingerprint.fingerprint(
    build_request(
      "m",
      @json.parse("{\"messages\":[{\"role\":\"user\",\"content\":\"月兔\"}]}"),
    ),
  )
  assert_eq(short.length(), long.length())
}

///|
test "provider/model concatenation ambiguity is avoided by the envelope" {
  // 若实现采用「provider + model」字符串拼接，这两个请求会撞车。
  let left = @core.Request::new("ab", "c", Json::null())
  let right = @core.Request::new("a", "bc", Json::null())
  assert_false(@fingerprint.same_request(left, right))
  assert_true(@fingerprint.fingerprint(left) != @fingerprint.fingerprint(right))
}

///|
test "canonical_request sorts keys so it can be diffed" {
  let request = build_request("gpt-4o", @json.parse("{\"b\":2,\"a\":1}"))
  assert_eq(
    @fingerprint.canonical_request(request),
    "{\"body\":{\"a\":1,\"b\":2},\"model\":\"gpt-4o\",\"provider\":\"openai\"}",
  )
}
