// mooncassette/sanitize —— 脱敏契约测试。
//
// 这里的断言围绕两个方向：
// ① 该脱的必须脱（授权头、后缀命中的密钥字段、密钥形状子串）；
// ② 不该脱的绝不能误伤（max_tokens / total_tokens 等数值统计字段）。

///|
fn policy() -> @sanitize.SanitizePolicy {
  @sanitize.SanitizePolicy::default()
}

///|
test "exact key names are redacted case-insensitively" {
  let value = @json.parse(
    "{\"Authorization\":\"Bearer abc\",\"X-Api-Key\":\"k\",\"api_key\":\"k2\"}",
  )
  assert_eq(
    @sanitize.sanitize_json(value, policy()),
    @json.parse(
      "{\"Authorization\":\"***REDACTED***\",\"X-Api-Key\":\"***REDACTED***\",\"api_key\":\"***REDACTED***\"}",
    ),
  )
}

///|
test "suffix rules redact credential-shaped keys" {
  let value = @json.parse(
    "{\"access_token\":\"t\",\"client_secret\":\"s\",\"db_password\":\"p\"}",
  )
  assert_eq(
    @sanitize.sanitize_json(value, policy()),
    @json.parse(
      "{\"access_token\":\"***REDACTED***\",\"client_secret\":\"***REDACTED***\",\"db_password\":\"***REDACTED***\"}",
    ),
  )
}

///|
test "token accounting fields are not collateral damage" {
  let value = @json.parse(
    "{\"max_tokens\":1024,\"total_tokens\":30,\"input_tokens\":10,\"output_tokens\":20}",
  )
  assert_eq(@sanitize.sanitize_json(value, policy()), value)
}

///|
test "redaction descends into nested objects and arrays" {
  let value = @json.parse(
    "{\"messages\":[{\"role\":\"user\",\"meta\":{\"api_key\":\"k\"}}]}",
  )
  assert_eq(
    @sanitize.sanitize_json(value, policy()),
    @json.parse(
      "{\"messages\":[{\"role\":\"user\",\"meta\":{\"api_key\":\"***REDACTED***\"}}]}",
    ),
  )
}

///|
test "secret-shaped substrings inside free text are redacted" {
  let value = Json::string("my key is sk-abcdefgh12345678 and it is secret")
  assert_eq(
    @sanitize.sanitize_json(value, policy()),
    Json::string("my key is ***REDACTED*** and it is secret"),
  )
}

///|
test "short sk- tokens are left alone to avoid false positives" {
  let value = Json::string("sk-abc is not a key")
  assert_eq(@sanitize.sanitize_json(value, policy()), value)
}

///|
test "secret shape scanning can be turned off" {
  let custom : @sanitize.SanitizePolicy = {
    ..@sanitize.SanitizePolicy::default(),
    scan_secret_shapes: false,
  }
  let value = Json::string("sk-abcdefgh12345678")
  assert_eq(@sanitize.sanitize_json(value, custom), value)
}

///|
test "sanitize_request keeps provider and model, rewrites only the body" {
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"api_key\":\"k\",\"model\":\"gpt-4o\"}"),
  )
  let safe = @sanitize.sanitize_request(request, policy())
  assert_eq(safe.provider, "openai")
  assert_eq(safe.model, "gpt-4o")
  assert_eq(
    safe.body,
    @json.parse("{\"api_key\":\"***REDACTED***\",\"model\":\"gpt-4o\"}"),
  )
}

///|
test "sanitize_response preserves status and usage metadata" {
  let response = @core.Response::ok(
    @json.parse("{\"token\":\"abc\"}"),
    usage=@core.Usage::new(1, 2),
  )
  let safe = @sanitize.sanitize_response(response, policy())
  assert_eq(safe.status, 200)
  assert_eq(safe.usage.unwrap().input_tokens, 1)
  assert_eq(safe.usage.unwrap().output_tokens, 2)
  assert_eq(safe.body, @json.parse("{\"token\":\"***REDACTED***\"}"))
}

///|
test "sanitize_cassette rewrites every interaction and keeps meta intact" {
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", @json.parse("{\"api_key\":\"k\"}")),
      @core.Response::ok(@json.parse("{\"authorization\":\"Bearer x\"}")),
    ),
  ])
  let safe = @sanitize.sanitize_cassette(cassette, policy())
  assert_eq(safe.meta.name, cassette.meta.name)
  assert_eq(safe.meta.generator, cassette.meta.generator)
  assert_eq(safe.version, cassette.version)
  assert_eq(
    safe.interactions[0].request.body,
    @json.parse("{\"api_key\":\"***REDACTED***\"}"),
  )
  assert_eq(
    safe.interactions[0].response.body,
    @json.parse("{\"authorization\":\"***REDACTED***\"}"),
  )
}

///|
test "sanitizing does not mutate the input cassette" {
  let body = @json.parse("{\"api_key\":\"k\"}")
  let cassette = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", body),
      @core.Response::ok(Json::null()),
    ),
  ])
  let _ = @sanitize.sanitize_cassette(cassette, policy())
  assert_eq(cassette.interactions[0].request.body, body)
}
