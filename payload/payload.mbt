// mooncassette/payload —— 载荷信封与 JSON 遍历。
//
// 两件事放在这里：
// 1. **载荷信封**：当正文根本不是 JSON（二进制、或无法用 JSON 字符串无损表示的原始字节）时，
//    把它包成 `{"content_encoding":"base64","payload":"<规范 base64>"}`。
//    信封是自描述的 —— 读端不必猜「这个字段到底是文本还是字节」；
// 2. **JSON 遍历**：把归一化 / 折叠作用到整棵 JSON 树的字符串叶子上。
//    只改字符串叶子，键名与结构一概不动。

///|
/// 载荷信封里声明编码的字段名。
pub let content_encoding_key : String = "content_encoding"

///|
/// 载荷信封里承载正文的字段名。
pub let payload_key : String = "payload"

///|
/// 载荷信封目前支持的唯一编码：规范 base64。
pub let encoding_base64 : String = "base64"

///|
/// 把一串字节打包成可安全存进 cassette 的**载荷信封**。
///
/// 存在的理由：cassette 是 JSON，而 JSON 字符串表示不了任意字节。
/// 直接把二进制塞进字符串会在生成 / 转义 / 解析环节丢信息，
/// 于是「录下来的响应」与「真发出去的响应」不再逐字节相等 —— 回放就失去了意义。
pub fn pack_bytes(bytes : Bytes) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set(content_encoding_key, Json::string(encoding_base64))
  fields.set(payload_key, Json::string(encode(bytes)))
  Json::object(fields)
}

///|
/// 字节能否**无损**地用文本承载。
///
/// 判据是往返：解码再编码必须逐字节相等。单看「能不能解码」不够 ——
/// 有损解码会把非法字节替换成 U+FFFD，而替换出来的文本再编码回去
/// 已经是另一串字节，「录下来的响应」就此与被录制的事实分道扬镳。
pub fn is_text(bytes : Bytes) -> Bool {
  @utf8.encode(@utf8.decode_lossy(bytes, ignore_bom=false)) == bytes
}

///|
/// 字节的**文本视图**：能无损承载时就是它本身，否则退化为规范 base64。
///
/// 只供阅读、调试与错误信息：一份响应该按文本还是载荷存，由 `is_text` 判定，
/// 不从本函数的结果反推。
pub fn text_view(bytes : Bytes) -> String {
  let text = @utf8.decode_lossy(bytes, ignore_bom=false)
  if @utf8.encode(text) == bytes {
    text
  } else {
    encode(bytes)
  }
}

///|
/// 若 `value` 是**声明了 base64 编码**的载荷信封，返回其中的载荷文本。
///
/// 没有 `content_encoding` 字段的对象一律返回 `None` ——
/// 历史 cassette 里的普通对象从来不缺这个字段，因此完全不受影响。
fn envelope_payload(value : Json) -> String? {
  let fields = match value {
    Json::Object(fields) => fields
    _ => return None
  }
  match fields.get(content_encoding_key) {
    None => return None
    Some(Json::String(encoding)) =>
      if encoding != encoding_base64 {
        return None
      }
    Some(_) => return None
  }
  match fields.get(payload_key) {
    Some(Json::String(text)) => Some(text)
    _ => None
  }
}

///|
/// 解出载荷信封里的原始字节；不是合法信封时返回 `None`。
pub fn unpack_bytes(value : Json) -> Bytes? {
  match envelope_payload(value) {
    Some(text) =>
      match decode(text) {
        Some(bytes) => Some(bytes)
        None => None
      }
    None => None
  }
}

///|
/// 校验载荷信封：合法（或本来就不是信封）返回 `None`，非法返回可读的原因。
///
/// `@codec` 在读入时逐条调用它。好处是把「载荷被改坏」从笼统的
/// 「完整性摘要不符」细化成「第 N 条记录的 response.body 里 payload 不是规范 base64」——
/// 篡改检测的价值，取决于报错能不能直接指向现场。
pub fn validate_envelope(value : Json) -> String? {
  let fields = match value {
    Json::Object(fields) => fields
    _ => return None
  }
  let encoding = match fields.get(content_encoding_key) {
    // 没声明编码 → 普通 JSON，本函数不做任何约束
    None => return None
    Some(Json::String(text)) => text
    // 非字符串同理：body 是任意 JSON，不该替它定规矩
    Some(_) => return None
  }
  // 只认自己认识的那一种，其余一律当普通业务字段放过。
  //
  // `content_encoding` 在 HTTP 语义里是个常见字段名（`gzip` / `br` / `identity`……），
  // 历史 cassette 的响应体里出现它毫不稀奇。仅凭「这个字段存在且值不是 base64」
  // 就判成破损信封，会把本来好好的旧文件读成错误 ——「旧文件永远读得懂」
  // 比「多报一种错」重要。这里与 `envelope_payload` 必须同口径，
  // 否则同一份 JSON 会在 `unpack_bytes`（不是信封）与 `validate_envelope`（破损信封）
  // 之间得到两个互相矛盾的答案。
  if encoding != encoding_base64 {
    return None
  }
  let text = match fields.get(payload_key) {
    Some(Json::String(text)) => text
    Some(_) => return Some("payload 必须是字符串")
    None => return Some("声明了 content_encoding 却缺少 payload 字段")
  }
  match decode(text) {
    None => return Some("payload 不是合法的 base64")
    Some(_) =>
      if !is_canonical(text) {
        return Some(
          "payload 不是规范 base64（应使用标准字母表、补齐填充、不含空白）",
        )
      }
  }
  None
}

///|
/// 递归归一 JSON 中所有**疑似载荷**的字符串叶子。
///
/// 只用于请求体：响应体会原样回放给调用方，改写它会改变「回放出来的响应」，
/// 那等于篡改被录制的事实。请求体不同 —— 它只参与计算指纹，
/// 等价的书写本来就该得到同一个指纹。
///
/// 不是载荷的字符串（含已规范的）原样返回，因此对历史内容是恒等变换。
pub fn normalize_json(value : Json, min_chars? : Int, min_bytes? : Int) -> Json {
  match value {
    Json::Object(fields) => {
      let out : Map[String, Json] = Map([])
      for key in fields.keys() {
        match fields.get(key) {
          Some(child) =>
            out.set(key, normalize_json(child, min_chars?, min_bytes?))
          None => ()
        }
      }
      Json::object(out)
    }
    Json::Array(items) => {
      let out : Array[Json] = []
      for item in items {
        out.push(normalize_json(item, min_chars?, min_bytes?))
      }
      Json::array(out)
    }
    Json::String(text) => Json::string(normalize(text, min_chars?, min_bytes?))
    scalar => scalar
  }
}

///|
/// 展示用折叠：**只对疑似载荷生效**，非载荷原样返回。
///
/// 这是纯展示变换：不参与指纹、不参与完整性摘要、也永远不会被写回 cassette。
/// 一段 200 KB 的 base64 打印出来只会把终端和网页糊满；
/// 折叠之后才能看见它**周围**真正有信息量的字段。
pub fn fold(text : String, limit? : Int) -> String {
  let cap = match limit {
    Some(value) => value
    None => 96
  }
  if !looks_like_base64(text) {
    return text
  }
  let raw = @utf8.encode(text)
  if raw.length() <= cap {
    return text
  }
  let head : Array[Char] = []
  for i = 0; i < cap; i = i + 1 {
    // 走到这里说明全串只含字母表字符与 ASCII 空白，逐字节转 Char 是安全的
    head.push(raw.at(i).to_char())
  }
  String::from_array(head[:]) +
  "…(省略 " +
  (raw.length() - cap).to_string() +
  " 字符)"
}

///|
/// 递归折叠 JSON 中的载荷字符串（展示用，语义同 `fold`）。
pub fn fold_json(value : Json, limit? : Int) -> Json {
  match value {
    Json::Object(fields) => {
      let out : Map[String, Json] = Map([])
      for key in fields.keys() {
        match fields.get(key) {
          Some(child) => out.set(key, fold_json(child, limit?))
          None => ()
        }
      }
      Json::object(out)
    }
    Json::Array(items) => {
      let out : Array[Json] = []
      for item in items {
        out.push(fold_json(item, limit?))
      }
      Json::array(out)
    }
    Json::String(text) => Json::string(fold(text, limit?))
    scalar => scalar
  }
}
