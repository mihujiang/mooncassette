// mooncassette/core —— 规范化行为契约测试。

///|
test "prune_json removes volatile keys at the top level" {
  let value = @json.parse("{\"model\":\"gpt-4o\",\"request_id\":\"abc\"}")
  assert_eq(
    @core.prune_json(value, @core.default_drop_keys[:]),
    @json.parse("{\"model\":\"gpt-4o\"}"),
  )
}

///|
test "prune_json removes volatile keys recursively" {
  let value = @json.parse(
    "{\"a\":{\"timestamp\":1,\"keep\":2},\"b\":{\"request_id\":\"x\"}}",
  )
  assert_eq(
    @core.prune_json(value, @core.default_drop_keys[:]),
    @json.parse("{\"a\":{\"keep\":2},\"b\":{}}"),
  )
}

///|
test "prune_json descends into arrays" {
  let value = @json.parse("[{\"request_id\":\"a\",\"v\":1},{\"v\":2}]")
  assert_eq(
    @core.prune_json(value, @core.default_drop_keys[:]),
    @json.parse("[{\"v\":1},{\"v\":2}]"),
  )
}

///|
test "prune_json keeps scalar roots unchanged" {
  assert_eq(
    @core.prune_json(Json::string("x"), @core.default_drop_keys[:]),
    Json::string("x"),
  )
  assert_eq(
    @core.prune_json(Json::number(1.0), @core.default_drop_keys[:]),
    Json::number(1.0),
  )
}

///|
test "prune_json matches keys case-sensitively" {
  let value = @json.parse("{\"request_id\":1,\"REQUEST_ID\":2}")
  assert_eq(
    @core.prune_json(value, @core.default_drop_keys[:]),
    @json.parse("{\"REQUEST_ID\":2}"),
  )
}

///|
test "Request::normalize uses the default drop list" {
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"messages\":[],\"request_id\":\"xyz\"}"),
  )
  let normalized = request.normalize()
  assert_eq(normalized.body, @json.parse("{\"messages\":[]}"))
}

///|
test "Request::normalize accepts a custom drop list" {
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"messages\":[],\"request_id\":\"xyz\"}"),
  )
  let normalized = request.normalize(drop_keys=["messages"][:])
  assert_eq(normalized.body, @json.parse("{\"request_id\":\"xyz\"}"))
}

///|
test "Request::normalize is idempotent" {
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":{\"timestamp\":1},\"b\":2}"),
  )
  let once = request.normalize()
  let twice = once.normalize()
  assert_eq(once.body, twice.body)
}

///|
test "Request::normalize collapses equivalent payload spellings" {
  // 40 个字符的规范 base64 片段，两段拼起来是 80 字符 ——
  // 刚好越过「疑似载荷」的门槛（≥64 字符、解码后 ≥48 字节）。
  let half = "QUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFB"
  let canonical = half + half
  assert_eq(canonical.length(), 80)
  // 同一份字节的折行写法：换的是书写，不是内容。
  let folded = half + "\\n" + half
  let plain = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"image\":\"" + canonical + "\"}"),
  )
  let wrapped = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"image\":\"" + folded + "\"}"),
  )
  assert_eq(wrapped.normalize().body, plain.normalize().body)
  // 判据刻意保守：不属于载荷的字符串一个字节都不动，
  // 因此把正常内容放进同一个请求里也不会被误改。
  let mixed = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"label\":\"short\",\"image\":\"" + folded + "\"}"),
  )
  assert_eq(
    mixed.normalize().body,
    @json.parse("{\"label\":\"short\",\"image\":\"" + canonical + "\"}"),
  )
}

///|
test "Request::normalize does not mutate the original request" {
  let body = @json.parse("{\"request_id\":\"xyz\"}")
  let request = @core.Request::new("openai", "gpt-4o", body)
  let _ = request.normalize()
  assert_eq(request.body, body)
}

///|
test "Usage::total sums input and output tokens" {
  assert_eq(@core.Usage::new(3, 4).total(), 7)
  assert_eq(@core.Usage::new(0, 0).total(), 0)
}

///|
test "Cassette aggregates token usage and skips records without usage" {
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", Json::null()),
      @core.Response::ok(Json::null(), usage=@core.Usage::new(10, 1)),
    ),
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", Json::null()),
      @core.Response::new(500, Json::null()),
    ),
  ])
  assert_eq(cassette.length(), 2)
  assert_eq(cassette.total_input_tokens(), 10)
  assert_eq(cassette.total_output_tokens(), 1)
}

///|
test "Cassette::new stamps the current format version and generator" {
  let cassette = @core.Cassette::new("demo")
  assert_eq(cassette.version, @core.cassette_format_version)
  assert_eq(cassette.meta.generator, @core.generator_id)
  assert_eq(cassette.length(), 0)
}

///|
test "Cassette::push appends in recording order" {
  let cassette = @core.Cassette::new("demo")
  let first = @core.Request::new("openai", "gpt-4o", Json::string("first"))
  let second = @core.Request::new("openai", "gpt-4o", Json::string("second"))
  cassette.push(@core.Interaction::new(first, @core.Response::ok(Json::null())))
  cassette.push(
    @core.Interaction::new(second, @core.Response::ok(Json::null())),
  )
  assert_eq(cassette.length(), 2)
  assert_eq(cassette.interactions[0].request.body, Json::string("first"))
  assert_eq(cassette.interactions[1].request.body, Json::string("second"))
}

///|
test "CassetteError renders actionable messages" {
  assert_eq(
    @core.CassetteError::UnsupportedVersion(99).to_string(),
    "mooncassette: unsupported cassette format version 99; this build reads versions 1 to " +
    @core.cassette_format_version.to_string(),
  )
}
