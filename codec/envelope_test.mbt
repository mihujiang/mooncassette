// mooncassette/codec —— 载荷信封在读取端的契约测试。
//
// 这里只关心一件事：**报错能不能指到现场**。
// 信封可以嵌在正文的任意深度，改坏内层 `payload` 若只报「完整性摘要不符」，
// 等于什么都没说 —— 那句话既没说哪条记录，也没说哪个字段。

///|
/// 造一个「响应体就是你给的那段 JSON」的最小 cassette。
fn envelope_cassette(body : Json) -> @core.Cassette {
  @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", Json::null()),
      @core.Response::ok(body),
    ),
  ])
}

///|
/// 把 `decode` 的抛错行为转成 `Result`，便于区分错误种类。
fn envelope_decode(
  text : StringView,
) -> Result[@core.Cassette, @core.CassetteError] {
  let cassette = @codec.decode(text) catch { error => return Err(error) }
  Ok(cassette)
}

///|
fn field_of(value : Json, key : String) -> Json {
  match value {
    Json::Object(fields) =>
      match fields.get(key) {
        Some(child) => child
        None => Json::null()
      }
    _ => Json::null()
  }
}

///|
fn zeros(length : Int) -> Bytes {
  let out : Array[Byte] = []
  for i = 0; i < length; i = i + 1 {
    out.push((0).to_byte())
  }
  Bytes::from_array(out[:])
}

///|
test "a cassette carrying a payload envelope round-trips" {
  let original = zeros(60)
  let cassette = envelope_cassette(
    @json.parse(
      "{\"kind\":\"image\",\"data\":" +
      @canon.to_canonical_string(@payload.pack_bytes(original)) +
      "}",
    ),
  )
  let text = @codec.encode(cassette, indent=0)
  assert_true(text.contains("\"content_encoding\":\"base64\""))
  let restored = match envelope_decode(text) {
    Ok(value) => value
    Err(error) =>
      fail("a valid envelope cassette failed to decode: " + error.to_string())
  }
  // 重新编码后逐字节相等：信封不会在过一次手之后变形。
  assert_eq(@codec.encode(restored, indent=0), text)
  // 解出来的字节必须还给调用方，一个字节都不能少。
  match
    @payload.unpack_bytes(
      field_of(restored.interactions[0].response.body, "data"),
    ) {
    Some(round) => assert_eq(@payload.encode(round), @payload.encode(original))
    None => fail("the envelope did not survive the round-trip")
  }
}

///|
test "a broken payload is reported with its exact field path" {
  let cassette = envelope_cassette(
    @json.parse(
      "{\"kind\":\"image\",\"data\":{\"content_encoding\":\"base64\",\"payload\":\"Zm9v\"}}",
    ),
  )
  let text = @codec.encode(cassette, indent=0)
  let tampered = text.replace(
    old="\"payload\":\"Zm9v\"",
    new="\"payload\":\"!!!!\"",
  )
  assert_true(tampered != text)
  match envelope_decode(tampered) {
    Ok(_) => fail("expected a schema violation")
    // 关键在于报的是 `SchemaViolation` 而不是笼统的 `IntegrityViolation`：
    // 后者只说明「这条记录被动过」，说不出动在哪里。
    Err(@core.CassetteError::SchemaViolation(message)) =>
      assert_eq(
        message, "$.interactions[0].response.body.data: payload 不是合法的 base64",
      )
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "a non-canonical payload is rejected, not silently repaired" {
  // 折行写法在读取端不算合法信封：规范形式只有一个，
  // 允许两种写法等于允许同一个文件有两种字节表示。
  let cassette = envelope_cassette(
    @json.parse(
      "{\"kind\":\"image\",\"data\":{\"content_encoding\":\"base64\",\"payload\":\"Zm9v\"}}",
    ),
  )
  let text = @codec.encode(cassette, indent=0)
  let tampered = text.replace(
    old="\"payload\":\"Zm9v\"",
    new="\"payload\":\"Zm9v\\n\"",
  )
  match envelope_decode(tampered) {
    Ok(_) => fail("expected a schema violation")
    Err(@core.CassetteError::SchemaViolation(message)) =>
      assert_true(message.contains("不是规范 base64"))
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "envelopes nested in arrays get an indexed path" {
  let cassette = envelope_cassette(
    @json.parse(
      "{\"items\":[{\"content_encoding\":\"base64\",\"payload\":\"!!!!\"}]}",
    ),
  )
  match envelope_decode(@codec.encode(cassette, indent=0)) {
    Ok(_) => fail("expected a schema violation")
    Err(@core.CassetteError::SchemaViolation(message)) =>
      assert_eq(
        message, "$.interactions[0].response.body.items[0]: payload 不是合法的 base64",
      )
    Err(other) => fail("unexpected error: " + other.to_string())
  }
}

///|
test "envelope validation follows the verify switch" {
  let cassette = envelope_cassette(
    @json.parse("{\"content_encoding\":\"base64\",\"payload\":\"!!!!\"}"),
  )
  let text = @codec.encode(cassette, indent=0)
  // `verify=false` 的语义是「原样相信文件」，因此坏掉的载荷会被如实保留，
  // 而不是被悄悄修好 —— 抹平手工痕迹会让这个开关变成陷阱。
  let restored = @codec.decode(text, verify=false) catch { _ => panic() }
  assert_eq(
    restored.interactions[0].response.body,
    @json.parse("{\"content_encoding\":\"base64\",\"payload\":\"!!!!\"}"),
  )
}

///|
/// `content_encoding` 在 HTTP 语义里是个常见字段名（`gzip` / `br` / `identity`……），
/// 历史 cassette 的响应体里出现它毫不稀奇。读端必须把它当**普通业务字段**放过：
/// 仅凭「有这个字段、值又不是 base64」就判破损，会让本来好好的旧文件读不出来 ——
/// 「旧文件永远读得懂」比「多报一种错」重要。
///
/// 这条同时守住 `validate_envelope` 与 `unpack_bytes` 的口径一致：
/// 若前者严格、后者宽松，同一份 JSON 就会得到两个互相矛盾的答案。
test "a foreign content_encoding is ordinary data, not a broken envelope" {
  let cassette = envelope_cassette(
    @json.parse(
      "{\"content_encoding\":\"gzip\",\"payload\":\"not base64 at all\",\"note\":\"hi\"}",
    ),
  )
  match envelope_decode(@codec.encode(cassette, indent=0)) {
    Ok(restored) =>
      assert_eq(
        field_of(restored.interactions[0].response.body, "content_encoding"),
        Json::string("gzip"),
      )
    Err(error) =>
      fail(
        "外来 content_encoding 不该让读取失败：" + error.to_string(),
      )
  }
}

///|
test "a non-string content_encoding is ordinary data too" {
  let cassette = envelope_cassette(
    @json.parse("{\"content_encoding\":2,\"payload\":\"whatever\"}"),
  )
  match envelope_decode(@codec.encode(cassette, indent=0)) {
    Ok(_) => ()
    Err(error) =>
      fail(
        "非字符串 content_encoding 不该让读取失败：" +
        error.to_string(),
      )
  }
}
