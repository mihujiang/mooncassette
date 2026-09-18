// mooncassette/payload —— 载荷信封与 base64 规范形式。
//
// 这一组测试守护三件事：
// 1. **矩阵 F（性质测试）**：随机字节 → 编码 → 归一 → 解码，逐字节相等；
// 2. **等价写法收敛**：换行折行 / URL-safe 字母表 / 省略填充这三种写法，
//    归一到同一段规范文本 —— 否则「同一张图片换个库编码」在回放时就命中不了；
// 3. **判据边界**：疑似载荷的判据、信封的合法性、以及展示折叠。
//
// 随机数用固定种子的 LCG 而不是真随机：性质测试一旦偶发失败就成了噪声，
// 固定种子保证失败必然可复现（与 `sanitize/leak_test.mbt` 同一做法）。

///|
/// 一个很小的线性同余发生器：确定性、可复现。
struct Rng {
  mut state : UInt64
}

///|
fn Rng::new(seed : UInt64) -> Rng {
  { state: seed }
}

///|
/// 取 `[0, bound)` 内的下一个值。
fn Rng::next_int(self : Rng, bound : Int) -> Int {
  self.state = self.state * 6364136223846793005 + 1442695040888963407
  // 取高位而不是低位：低位周期短，会让「随机」退化成几个值的循环。
  (self.state >> 33).to_int() % bound
}

///|
fn random_bytes(rng : Rng, length : Int) -> Bytes {
  let out : Array[Byte] = []
  for i = 0; i < length; i = i + 1 {
    out.push(rng.next_int(256).to_byte())
  }
  Bytes::from_array(out[:])
}

///|
fn bytes_of(values : Array[Int]) -> Bytes {
  let out : Array[Byte] = []
  for value in values {
    out.push(value.to_byte())
  }
  Bytes::from_array(out[:])
}

///|
/// 逐字节比较。刻意不依赖 `Bytes` 的 `Eq`：这里要断言的正是「一个字节都没变」，
/// 自己写一遍能让失败信息直接指向第一处不同的下标。
fn bytes_equal(a : Bytes, b : Bytes) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i = 0; i < a.length(); i = i + 1 {
    if a.at(i) != b.at(i) {
      return false
    }
  }
  true
}

///|
fn object_field(value : Json, key : String) -> Json? {
  match value {
    Json::Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn field_string(value : Json, key : String) -> String? {
  match object_field(value, key) {
    Some(Json::String(text)) => Some(text)
    _ => None
  }
}

///|
/// 按 `width` 列插入换行 —— MIME 折行是真实世界里最常见的另一种写法。
/// 只用于 ASCII（base64 字母表）输入，因此逐字节转 `Char` 是安全的。
fn wrap_at(text : String, width : Int) -> String {
  let raw = @utf8.encode(text)
  let out : Array[Char] = []
  for i = 0; i < raw.length(); i = i + 1 {
    if i > 0 && i % width == 0 {
      out.push('\n')
    }
    out.push(raw.at(i).to_char())
  }
  String::from_array(out[:])
}

///|
/// 折行**并转义**：直接产出可以嵌进 JSON 字符串字面量的写法。
fn wrap_json(text : String, width : Int) -> String {
  let raw = @utf8.encode(text)
  let out : Array[Char] = []
  for i = 0; i < raw.length(); i = i + 1 {
    if i > 0 && i % width == 0 {
      out.push('\\')
      out.push('n')
    }
    out.push(raw.at(i).to_char())
  }
  String::from_array(out[:])
}

///|
/// 换成 URL-safe 字母表（`+`→`-`，`/`→`_`）。
fn to_url_safe(text : String) -> String {
  let raw = @utf8.encode(text)
  let out : Array[Char] = []
  for i = 0; i < raw.length(); i = i + 1 {
    let byte = raw.at(i).to_int()
    if byte == 43 {
      out.push('-')
    } else if byte == 47 {
      out.push('_')
    } else {
      out.push(byte.to_char().unwrap())
    }
  }
  String::from_array(out[:])
}

///|
/// 去掉全部填充 `=`。
fn strip_padding(text : String) -> String {
  let raw = @utf8.encode(text)
  let out : Array[Char] = []
  for i = 0; i < raw.length(); i = i + 1 {
    let byte = raw.at(i).to_int()
    if byte != 61 {
      out.push(byte.to_char().unwrap())
    }
  }
  String::from_array(out[:])
}

// ---------------------------------------------------------------------------
// base64 规范形式
// ---------------------------------------------------------------------------

///|
test "encode matches the RFC 4648 test vectors" {
  assert_eq(@payload.encode(bytes_of([])), "")
  assert_eq(@payload.encode(bytes_of([102])), "Zg==")
  assert_eq(@payload.encode(bytes_of([102, 111])), "Zm8=")
  assert_eq(@payload.encode(bytes_of([102, 111, 111])), "Zm9v")
  assert_eq(@payload.encode(bytes_of([102, 111, 111, 98])), "Zm9vYg==")
  assert_eq(@payload.encode(bytes_of([102, 111, 111, 98, 97])), "Zm9vYmE=")
  assert_eq(@payload.encode(bytes_of([102, 111, 111, 98, 97, 114])), "Zm9vYmFy")
}

///|
test "encode uses the standard alphabet, including + and /" {
  // 0xFB 0xFF 0xBF 是 RFC 4648 里唯一会同时用上字母表最后两个字符的向量。
  // 若写成 URL-safe 字母表（`-` `_`），规范形式就再也回不来了。
  assert_eq(@payload.encode(bytes_of([251, 255, 191])), "+/+/")
}

///|
test "decode accepts equivalent spellings" {
  let original = bytes_of([251, 255, 191])
  assert_true(bytes_equal(@payload.decode("+/+/").unwrap(), original))
  assert_true(bytes_equal(@payload.decode("-_-_").unwrap(), original))
  // 省略填充、以及混入换行 / 回车 / 制表符，都是同一份字节。
  assert_true(bytes_equal(@payload.decode("Zg").unwrap(), bytes_of([102])))
  assert_true(
    bytes_equal(@payload.decode("Zg\r\n==").unwrap(), bytes_of([102])),
  )
  assert_true(
    bytes_equal(@payload.decode("Zm9v\t").unwrap(), bytes_of([102, 111, 111])),
  )
}

///|
test "decode rejects illegal input instead of guessing" {
  assert_eq(@payload.decode("!!!!"), None)
  // 长度为 1 mod 4 永远解不出完整字节。
  assert_eq(@payload.decode("Z"), None)
  // 空串不是载荷（`decode` 不把它当成「零字节」）。
  assert_eq(@payload.decode(""), None)
  // 填充位只允许出现在末尾，且必须与剩余位数相符。
  assert_eq(@payload.decode("Zg="), None)
  assert_eq(@payload.decode("Zg==Zg=="), None)
  // 末尾残留位不全为零：这是另一份字节的写法，不能悄悄丢掉这几个位。
  assert_eq(@payload.decode("Zh=="), None)
}

///|
test "is_canonical means standard alphabet, padded, no whitespace" {
  assert_true(@payload.is_canonical("Zm9v"))
  assert_true(@payload.is_canonical("Zg=="))
  assert_false(@payload.is_canonical("Zg"))
  assert_false(@payload.is_canonical("Zm9v\n"))
  assert_false(@payload.is_canonical("-_-_"))
  assert_false(@payload.is_canonical(""))
  assert_false(@payload.is_canonical("不是 base64"))
}

///|
test "the payload guard is deliberately conservative" {
  let rng = Rng::new(1)
  let canonical = @payload.encode(random_bytes(rng, 60))
  // 长、字符全在字母表内、解出的字节数够多 → 判为载荷。
  assert_true(@payload.looks_like_base64(canonical))
  assert_true(@payload.looks_like_base64(wrap_at(canonical, 20)))
  assert_true(@payload.looks_like_base64(to_url_safe(canonical)))
  // 短串一律不是载荷：`"abc"` 之类也常常能解码，但它们不可能是真正的二进制。
  assert_false(@payload.looks_like_base64("abc"))
  assert_false(@payload.looks_like_base64("Zm9v"))
  // 含字母表之外的字符 → 不是载荷（普通文本几乎总会带标点或空格）。
  assert_false(@payload.looks_like_base64("not base64 at all, " + canonical))
  // 长度恰好 1 mod 4 → 不是载荷。
  assert_false(@payload.looks_like_base64(canonical + "A"))
}

///|
test "normalize is idempotent and collapses equivalent spellings" {
  let rng = Rng::new(99)
  for i = 0; i < 50; i = i + 1 {
    let original = random_bytes(rng, 60 + i)
    let canonical = @payload.encode(original)
    // 幂等：已是规范形式的串归一后逐字节不变，历史 cassette 因此不受影响。
    assert_eq(@payload.normalize(canonical), canonical)
    let variants : Array[String] = [
      wrap_at(canonical, 76),
      wrap_at(canonical, 3),
      to_url_safe(canonical),
      strip_padding(canonical),
      to_url_safe(strip_padding(canonical)),
      "  " + canonical + "\n",
    ]
    for variant in variants {
      assert_eq(@payload.normalize(variant), canonical)
      match @payload.decode(variant) {
        Some(bytes) => assert_true(bytes_equal(bytes, original))
        None => fail("decode rejected an equivalent spelling: " + variant)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 矩阵 F：随机字节 → 编码 → 归一 → 解码 → 逐字节相等
// ---------------------------------------------------------------------------

///|
test "matrix F: random bytes survive encode → normalize → decode" {
  let rng = Rng::new(20260914)
  for i = 0; i < 300; i = i + 1 {
    let original = random_bytes(rng, 1 + rng.next_int(200))
    let text = @payload.encode(original)
    if !@payload.is_canonical(text) {
      fail("encode produced a non-canonical spelling at case " + i.to_string())
    }
    if @payload.normalize(text) != text {
      fail(
        "normalize rewrote an already-canonical spelling at case " +
        i.to_string(),
      )
    }
    match @payload.decode(text) {
      Some(round) =>
        if !bytes_equal(round, original) {
          fail("round-trip lost bytes at case " + i.to_string())
        }
      None => fail("decode rejected our own encoding at case " + i.to_string())
    }
  }
}

// ---------------------------------------------------------------------------
// 载荷信封
// ---------------------------------------------------------------------------

///|
test "the envelope round-trips arbitrary bytes" {
  let rng = Rng::new(3)
  for i = 0; i < 40; i = i + 1 {
    let original = random_bytes(rng, 1 + rng.next_int(300))
    let envelope = @payload.pack_bytes(original)
    assert_eq(
      field_string(envelope, @payload.content_encoding_key),
      Some(@payload.encoding_base64),
    )
    assert_eq(
      field_string(envelope, @payload.payload_key),
      Some(@payload.encode(original)),
    )
    // 自己产出的信封必须是合法的 —— 否则 recorder 写出来的文件读不回。
    assert_eq(@payload.validate_envelope(envelope), None)
    match @payload.unpack_bytes(envelope) {
      Some(round) => assert_true(bytes_equal(round, original))
      None => fail("unpack rejected our own envelope at case " + i.to_string())
    }
  }
}

///|
test "ordinary objects are not mistaken for envelopes" {
  assert_eq(@payload.validate_envelope(@json.parse("{\"a\":1}")), None)
  assert_eq(@payload.validate_envelope(@json.parse("\"text\"")), None)
  assert_eq(@payload.validate_envelope(@json.parse("[]")), None)
  assert_eq(@payload.validate_envelope(@json.parse("null")), None)
  // 只有 payload 没有 content_encoding：是业务数据，不是信封。
  assert_eq(@payload.unpack_bytes(@json.parse("{\"payload\":\"Zm9v\"}")), None)
  // 认得的编码名但不是 base64：内容当普通文本处理，不报错。
  assert_eq(
    @payload.unpack_bytes(@json.parse("{\"content_encoding\":\"text\"}")),
    None,
  )
  // `content_encoding` 是 HTTP 语义里的常见字段名（`gzip` / `br` / `identity`……），
  // 历史 cassette 的 body 里出现它毫不稀奇，读端一律放过。
  // `validate_envelope` 与 `unpack_bytes` 必须同口径，否则同一份 JSON
  // 会在「不是信封」与「破损信封」之间得到两个互相矛盾的答案。
  assert_eq(
    @payload.validate_envelope(
      @json.parse("{\"content_encoding\":\"gzip\",\"payload\":\"eA==\"}"),
    ),
    None,
  )
  assert_eq(
    @payload.validate_envelope(
      @json.parse("{\"content_encoding\":1,\"payload\":\"Zm9v\"}"),
    ),
    None,
  )
}

///|
test "a broken envelope reports a reason instead of panicking" {
  // 只列**声明了 base64** 却写坏的：这才是破损信封。
  // 外来的 `content_encoding`（`gzip` / 数字……）是业务数据，见上一条测试。
  let broken : Array[String] = [
    "{\"content_encoding\":\"base64\"}", "{\"content_encoding\":\"base64\",\"payload\":123}",
    "{\"content_encoding\":\"base64\",\"payload\":\"!!!!\"}", "{\"content_encoding\":\"base64\",\"payload\":\"Zm9v\\n\"}",
  ]
  for text in broken {
    match @payload.validate_envelope(@json.parse(text)) {
      Some(reason) => assert_true(reason != "")
      None => fail("a broken envelope went unreported: " + text)
    }
  }
}

// ---------------------------------------------------------------------------
// JSON 遍历：归一化（进指纹）与折叠（只给眼睛看）
// ---------------------------------------------------------------------------

///|
test "normalize_json rewrites payload leaves and nothing else" {
  let rng = Rng::new(7)
  let canonical = @payload.encode(random_bytes(rng, 60))
  // 折行 + 转义，落到 JSON 里是一段带换行的等价写法
  let folded = wrap_json(canonical, 20)
  let text = "{\"image\":\"" +
    folded +
    "\",\"label\":\"short\",\"count\":7,\"nested\":{\"leaf\":\"" +
    folded +
    "\"},\"list\":[\"" +
    folded +
    "\",\"plain\"]}"
  let normalized = @payload.normalize_json(@json.parse(text))
  // 疑似载荷的叶子被改写成规范形式
  assert_eq(field_string(normalized, "image"), Some(canonical))
  match object_field(normalized, "nested") {
    Some(inner) => assert_eq(field_string(inner, "leaf"), Some(canonical))
    None => fail("normalize_json dropped a nested object")
  }
  // 不是载荷的叶子一个字节都不动
  assert_eq(field_string(normalized, "label"), Some("short"))
  // 非字符串叶子保持原样（数字不该变成字符串）
  assert_true(object_field(normalized, "count") is Some(_))
  assert_eq(field_string(normalized, "count"), None)
  // 数组结构保住了，且逐个叶子都被走到
  match object_field(normalized, "list") {
    Some(Json::Array(items)) => {
      assert_eq(items.length(), 2)
      match items[0] {
        Json::String(item) => assert_eq(item, canonical)
        _ => fail("array element lost its string type")
      }
      // 数组里的普通字符串同样不该被动
      match items[1] {
        Json::String(item) => assert_eq(item, "plain")
        _ => fail("array element lost its string type")
      }
    }
    _ => fail("normalize_json dropped an array")
  }
}

///|
test "normalize_json is a no-op on already-canonical content" {
  let rng = Rng::new(8)
  let canonical = @payload.encode(random_bytes(rng, 40))
  let value = @json.parse("{\"a\":\"" + canonical + "\",\"b\":\"hello world\"}")
  let once = @payload.normalize_json(value)
  let twice = @payload.normalize_json(once)
  assert_eq(field_string(twice, "a"), Some(canonical))
  assert_eq(field_string(twice, "b"), Some("hello world"))
}

///|
test "fold truncates payload strings and leaves prose alone" {
  let rng = Rng::new(11)
  let long = @payload.encode(random_bytes(rng, 150))
  // 200 字符 → 默认上限 96，省略 104 字符
  let folded = @payload.fold(long)
  assert_true(folded != long)
  assert_true(folded.contains("…(省略 104 字符)"))
  // 上限可调
  assert_true(@payload.fold(long, limit=20).contains("…(省略 180 字符)"))
  assert_true(@payload.fold(long, limit=1000) == long)
  // 短串不动 —— 折叠不是「一律截断」
  assert_eq(@payload.fold("short"), "short")
  assert_eq(@payload.fold(""), "")
  // 长但不像载荷的文本原样保留：折叠是展示变换，不该改写普通内容
  let prose = "{\"note\":\"" +
    long +
    "\"} 这段文字不是载荷，只是很长"
  assert_eq(@payload.fold(prose), prose)
}

///|
test "fold_json folds payload leaves and keeps the rest" {
  let rng = Rng::new(13)
  let long = @payload.encode(random_bytes(rng, 150))
  let value = @json.parse(
    "{\"payload\":\"" +
    wrap_json(long, 40) +
    "\",\"keep\":\"text\",\"list\":[\"" +
    wrap_json(long, 40) +
    "\"]}",
  )
  let folded = @payload.fold_json(value)
  match field_string(folded, "payload") {
    Some(text) => {
      assert_true(text.contains("…(省略 "))
      assert_true(text != long)
    }
    None => fail("fold_json dropped the payload field")
  }
  assert_eq(field_string(folded, "keep"), Some("text"))
  match object_field(folded, "list") {
    Some(Json::Array(items)) => {
      assert_eq(items.length(), 1)
      match items[0] {
        Json::String(item) => assert_true(item.contains("…(省略 "))
        _ => fail("fold_json lost the array element type")
      }
    }
    _ => fail("fold_json dropped an array")
  }
}
