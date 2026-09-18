// mooncassette/providers —— 响应体「按内容决定编码」。
//
// 三种形态各守一条边界：
//   json   —— 历史文件里的样子，一个字节都不许变；
//   raw    —— 文本响应（HTML 错误页之类）仍然可读地留在 `raw_body` 里；
//   base64 —— 二进制与超阈值报文进载荷信封，字节逐字节还原。

///|
/// 逐字节比较。不用 `Bytes` 的 `Eq`：这里要断言的正是「一个字节都没变」，
/// 自己走一遍能让失败信息直接指向第一处不同的下标。
fn same_bytes(actual : Bytes, expected : Bytes) -> Bool {
  if actual.length() != expected.length() {
    return false
  }
  for i = 0; i < expected.length(); i = i + 1 {
    if actual.at(i) != expected.at(i) {
      return false
    }
  }
  true
}

///|
/// `new` 构造的响应走的仍是历史路径：能解析成 JSON 就用 JSON，否则包 `raw_body`。
/// 这条守的是「既有文件的字节不发生变化」。
test "a response built with new() keeps the historical encoding" {
  let samples : Array[String] = [
    "{\"choices\":[],\"id\":\"chatcmpl-1\"}", "[1,2,3]", "<html>Bad Gateway</html>",
    "plain text", "\"scalar\"", "",
  ]
  for text in samples {
    assert_eq(
      @providers.parse_response_body(@providers.HttpResponse::new(200, text)),
      @providers.parse_body_or_raw(text),
    )
  }
}

///|
test "a JSON body stays a JSON body" {
  let response = @providers.HttpResponse::new(
    200, "{\"choices\":[{\"index\":0}],\"id\":\"chatcmpl-1\"}",
  )
  match @providers.parse_response_body(response) {
    Json::Object(fields) =>
      assert_eq(fields.get("id"), Some(Json::string("chatcmpl-1")))
    _ => fail("JSON 响应体应当原样存成对象")
  }
}

///|
test "a plain-text body still lands in raw_body" {
  let response = @providers.HttpResponse::new(502, "<html>Bad Gateway</html>")
  match @providers.parse_response_body(response) {
    Json::Object(fields) =>
      assert_eq(
        fields.get("raw_body"),
        Some(Json::string("<html>Bad Gateway</html>")),
      )
    _ => fail("文本响应体应当包成 raw_body")
  }
}

///|
test "binary bytes are carried inside a payload envelope" {
  // PNG 魔数之后跟一个非 UTF-8 字节：文本承载不了它。
  // （魔数本身是合法 UTF-8，只有后面的 0xFF / 0x00 才暴露出这是二进制。）
  let bytes : Bytes = Bytes::from_array([
    137, 80, 78, 71, 13, 10, 26, 10, 255, 0, 1,
  ])
  let response = @providers.HttpResponse::from_bytes(200, bytes)
  match @providers.parse_response_body(response) {
    Json::Object(fields) =>
      assert_eq(
        fields.get(@payload.content_encoding_key),
        Some(Json::string(@payload.encoding_base64)),
      )
    _ => fail("响应体应当是 JSON 对象")
  }
  match @payload.unpack_bytes(@providers.parse_response_body(response)) {
    Some(restored) =>
      assert_true(
        same_bytes(restored, bytes),
        msg="二进制响应体应当能逐字节还原",
      )
    None => fail("非 UTF-8 的响应体应当进载荷信封")
  }
}

///|
test "text bytes stay on the raw_body path" {
  let text = "<html><body>gateway timeout</body></html>"
  let response = @providers.HttpResponse::from_bytes(504, @utf8.encode(text))
  match @providers.parse_response_body(response) {
    Json::Object(fields) =>
      assert_eq(fields.get("raw_body"), Some(Json::string(text)))
    _ => fail("能无损承载的文本字节应当走 raw_body")
  }
}

///|
test "a payload envelope passes the reader-side guard" {
  let bytes : Bytes = Bytes::from_array([0, 1, 2, 253, 254, 255])
  let response = @providers.HttpResponse::from_bytes(200, bytes)
  let body = @providers.parse_response_body(response)
  // 自己产出的信封必须能通过读端校验 —— 否则 recorder 写出来的文件读不回。
  assert_eq(@payload.validate_envelope(body), None)
  match @payload.unpack_bytes(body) {
    Some(restored) =>
      assert_true(
        same_bytes(restored, bytes),
        msg="信封应当逐字节还原",
      )
    None => fail("自己产出的信封应当能被解回")
  }
}

///|
test "bytes over the threshold go to the envelope even when they are text" {
  let builder = StringBuilder::new()
  for i = 0; i < @providers.inline_limit_bytes; i = i + 1 {
    builder.write_string("a")
  }
  let just_fits = builder.to_string()
  match
    @providers.parse_response_body(
      @providers.HttpResponse::from_bytes(200, @utf8.encode(just_fits)),
    ) {
    Json::Object(fields) =>
      assert_true(
        fields.get("raw_body") is Some(_),
        msg="阈值以内应当走 raw_body",
      )
    _ => fail("阈值以内的文本字节应当是 JSON 对象")
  }
  match
    @providers.parse_response_body(
      @providers.HttpResponse::from_bytes(200, @utf8.encode(just_fits + "a")),
    ) {
    Json::Object(fields) =>
      assert_true(
        fields.get(@payload.content_encoding_key) is Some(_),
        msg="越过阈值应当进载荷信封",
      )
    _ => fail("超阈值报文应当是 JSON 对象")
  }
}

///|
test "the threshold is overridable per call" {
  let response = @providers.HttpResponse::from_bytes(200, @utf8.encode("hello"))
  // 默认阈值下「hello」是文本；把阈值收到 4 字节，它就该进信封。
  match @providers.parse_response_body(response) {
    Json::Object(fields) =>
      assert_true(
        fields.get("raw_body") is Some(_),
        msg="默认阈值下应当是文本",
      )
    _ => fail("应当是 JSON 对象")
  }
  match @providers.parse_response_body(response, limit=4) {
    Json::Object(fields) =>
      assert_true(
        fields.get(@payload.content_encoding_key) is Some(_),
        msg="自定义阈值下应当进信封",
      )
    _ => fail("应当是 JSON 对象")
  }
}
