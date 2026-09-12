// mooncassette/canon —— 规范文本与哈希的行为契约测试。
//
// 本文件里的断言刻意写得「啰嗦」：规范文本规则是整个项目的地基，
// 一旦这里的行为漂移，所有已录制的 cassette 都会失效。

///|
test "fnv1a64 matches the published FNV-1a 64-bit test vectors" {
  assert_eq(@canon.hex_u64(@canon.fnv1a64_string("")), "cbf29ce484222325")
  assert_eq(@canon.hex_u64(@canon.fnv1a64_string("a")), "af63dc4c8601ec8c")
  assert_eq(@canon.hex_u64(@canon.fnv1a64_string("foobar")), "85944171f73967e8")
}

///|
test "hex_u64 always renders 16 lowercase hex digits" {
  assert_eq(@canon.hex_u64(0UL), "0000000000000000")
  assert_eq(@canon.hex_u64(1UL), "0000000000000001")
  assert_eq(@canon.hex_u64(0xffffffffffffffffUL), "ffffffffffffffff")
}

///|
test "canonical form sorts object keys" {
  let value = @json.parse("{\"b\":1,\"a\":2}")
  assert_eq(@canon.to_canonical_string(value), "{\"a\":2,\"b\":1}")
}

///|
test "canonical form is independent of the input key order" {
  let first = @json.parse("{\"z\":1,\"a\":2,\"m\":3}")
  let second = @json.parse("{\"m\":3,\"z\":1,\"a\":2}")
  assert_eq(
    @canon.to_canonical_string(first),
    @canon.to_canonical_string(second),
  )
}

///|
test "canonical form sorts keys recursively and preserves array order" {
  let value = @json.parse("{\"outer\":{\"b\":1,\"a\":2},\"list\":[3,2,1]}")
  assert_eq(
    @canon.to_canonical_string(value),
    "{\"list\":[3,2,1],\"outer\":{\"a\":2,\"b\":1}}",
  )
}

///|
test "canonical form escapes quotes, backslashes and control characters" {
  let value = Json::string("a\"b\\c\nd\te")
  assert_eq(@canon.to_canonical_string(value), "\"a\\\"b\\\\c\\nd\\te\"")
}

///|
test "canonical form escapes remaining control characters as \\u00XX" {
  let value = Json::string("\u{01}\u{1F}")
  assert_eq(@canon.to_canonical_string(value), "\"\\u0001\\u001f\"")
}

///|
test "canonical form keeps non-ASCII characters readable" {
  let value = Json::string("月兔")
  assert_eq(@canon.to_canonical_string(value), "\"月兔\"")
}

///|
test "canonical form round-trips through the JSON parser" {
  let original = @json.parse(
    "{\"messages\":[{\"role\":\"user\",\"content\":\"你好\"}],\"temperature\":0.7}",
  )
  let text = @canon.to_canonical_string(original)
  let reparsed = @json.parse(text)
  assert_eq(@canon.to_canonical_string(reparsed), text)
}

///|
test "canonical form keeps empty containers on one line" {
  assert_eq(@canon.to_canonical_string(@json.parse("{}")), "{}")
  assert_eq(@canon.to_canonical_string(@json.parse("[]")), "[]")
}

///|
test "pretty form agrees with compact form on key order" {
  let value = @json.parse("{\"b\":[1,2],\"a\":{\"d\":1,\"c\":2}}")
  assert_eq(
    @canon.to_pretty_string(value, indent=2),
    "{\n  \"a\": {\n    \"c\": 2,\n    \"d\": 1\n  },\n  \"b\": [\n    1,\n    2\n  ]\n}",
  )
}

///|
test "pretty form renders empty containers inline" {
  assert_eq(
    @canon.to_pretty_string(@json.parse("{\"a\":[],\"b\":{}}")),
    "{\n  \"a\": [],\n  \"b\": {}\n}",
  )
}

///|
test "pretty form defaults to two-space indentation" {
  assert_eq(
    @canon.to_pretty_string(@json.parse("{\"a\":1}")),
    "{\n  \"a\": 1\n}",
  )
}

///|
test "non-finite numbers degrade to null instead of emitting invalid JSON" {
  assert_eq(@canon.to_canonical_string(Json::number(@double.infinity)), "null")
  assert_eq(
    @canon.to_canonical_string(Json::number(@double.neg_infinity)),
    "null",
  )
  assert_eq(
    @canon.to_canonical_string(Json::number(@double.not_a_number)),
    "null",
  )
}

///|
test "canonical form keeps the parser's normalized numeric literal" {
  assert_eq(
    @canon.to_canonical_string(@json.parse("{\"big\":1e100}")),
    "{\"big\":1e+100}",
  )
  // 规范文本不区分 `1` 与 `1.0`：JSON 只有一种数字类型，二者语义相同。
  assert_eq(@canon.to_canonical_string(@json.parse("{\"n\":1.0}")), "{\"n\":1}")
  assert_eq(
    @canon.to_canonical_string(@json.parse("{\"n\":1.0}")),
    @canon.to_canonical_string(@json.parse("{\"n\":1}")),
  )
}

///|
test "number formatting is idempotent under parse/write cycles" {
  let once = @canon.to_canonical_string(@json.parse("[1e100,0.1,1.0,-3,1e-7]"))
  let twice = @canon.to_canonical_string(@json.parse(once))
  let thrice = @canon.to_canonical_string(@json.parse(twice))
  assert_eq(twice, once)
  assert_eq(thrice, twice)
}
