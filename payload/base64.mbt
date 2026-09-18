// mooncassette/payload —— base64 规范形式。
//
// 为什么必须有这一层：
// 多模态载荷（图片 / 音频 / 内联附件）在请求体里以 base64 字符串出现，而
// 「同一份字节」在真实世界里至少有四种写法：换行折行的、URL-safe 字母表的、
// 省略填充的、混入空白的。它们语义完全等价，却会让规范文本不同、指纹不同，
// 于是「同一份字节、同一份请求」在回放时命中不了。
//
// 本文件定义的规则只有一条：**规范 base64 = 标准字母表 + 补齐 `=` + 不含任何空白**。
//
// 另一端是安全：归一化是「试探性」的（见 `looks_like_base64`），
// 因此它必须只改写**疑似载荷**，并且必须幂等 —— 已是规范形式的字符串
// 归一后逐字节不变。这一条保证了历史 cassette 里本来规范的载荷不会被再写一遍。

///|
/// 6 位值到标准 base64 字母表（RFC 4648 §4）字符的映射。
///
/// 刻意用算术而不是「查字符串」：字符串按下标取字符的接口在不同版本间变过，
/// 而字母表本身是规范的一部分，写成算术才是真正不依赖环境的定义。
fn symbol(value : Int) -> Char {
  if value < 26 {
    // A-Z -> 0..25
    (65 + value).to_byte().to_char()
  } else if value < 52 {
    // a-z -> 26..51
    (97 + value - 26).to_byte().to_char()
  } else if value < 62 {
    // 0-9 -> 52..61
    (48 + value - 52).to_byte().to_char()
  } else if value == 62 {
    '+'
  } else {
    '/'
  }
}

///|
/// 判定「疑似载荷」的最小字符数。
///
/// 阈值不是审美偏好，而是**唯一能压住误判的手段**：短字符串（`"abc"` 之类）
/// 往往也能通过 base64 解码，但它们几乎不可能是真正的二进制载荷。
pub let min_payload_chars : Int = 64

///|
/// 判定「疑似载荷」的最小解码字节数。
///
/// 与 `min_payload_chars` 是两道独立的闸：字符数闸挡住短串，
/// 字节数闸挡住「长但解码后没几个字节」的退化写法。
pub let min_payload_bytes : Int = 48

///|
/// 判断某个字节是否为解码时可忽略的 ASCII 空白。
///
/// 只承认 ASCII 空白：Unicode 空白出现在 base64 里几乎必然是别的东西，
/// 放行它只会扩大误判面。
fn is_ascii_whitespace(byte : Int) -> Bool {
  byte == 32 || byte == 9 || byte == 10 || byte == 13
}

///|
/// 单字节对应的 6 位值；`-1` 表示不在字母表内。
///
/// 同时接受标准表（`+` `/`）与 URL-safe 表（`-` `_`）：两者表示同一份字节，
/// 必须归一到同一段规范文本，否则同一张图片换个库编码就命中不了。
fn sextet(byte : Int) -> Int {
  if byte >= 65 && byte <= 90 {
    // A-Z -> 0..25
    byte - 65
  } else if byte >= 97 && byte <= 122 {
    // a-z -> 26..51
    byte - 71
  } else if byte >= 48 && byte <= 57 {
    // 0-9 -> 52..61
    byte + 4
  } else if byte == 43 || byte == 45 {
    // '+' 或 URL-safe 的 '-'
    62
  } else if byte == 47 || byte == 95 {
    // '/' 或 URL-safe 的 '_'
    63
  } else {
    -1
  }
}

///|
/// 把字节编码为**规范 base64**：标准字母表、补齐 `=`、不含任何空白。
pub fn encode(bytes : Bytes) -> String {
  let length = bytes.length()
  let out : Array[Char] = []
  let whole = length / 3
  for i = 0; i < whole; i = i + 1 {
    let a = bytes.at(i * 3).to_int()
    let b = bytes.at(i * 3 + 1).to_int()
    let c = bytes.at(i * 3 + 2).to_int()
    out.push(symbol(a >> 2))
    out.push(symbol(((a & 3) << 4) | (b >> 4)))
    out.push(symbol(((b & 15) << 2) | (c >> 6)))
    out.push(symbol(c & 63))
  }
  let rest = length - whole * 3
  if rest == 1 {
    let a = bytes.at(whole * 3).to_int()
    out.push(symbol(a >> 2))
    out.push(symbol((a & 3) << 4))
    out.push('=')
    out.push('=')
  } else if rest == 2 {
    let a = bytes.at(whole * 3).to_int()
    let b = bytes.at(whole * 3 + 1).to_int()
    out.push(symbol(a >> 2))
    out.push(symbol(((a & 3) << 4) | (b >> 4)))
    out.push(symbol((b & 15) << 2))
    out.push('=')
  }
  String::from_array(out[:])
}

///|
/// **宽容解码**：接受标准与 URL-safe 两种字母表、允许省略填充、忽略 ASCII 空白。
///
/// 任何非法字符、非法长度或非法填充都返回 `None` —— 刻意不抛异常：
/// 归一化需要对「不确定是不是载荷」的字符串做试探，异常会污染调用方的控制流。
pub fn decode(text : String) -> Bytes? {
  let raw = @utf8.encode(text)
  let length = raw.length()
  let out : Array[Byte] = []
  let mut accumulator = 0
  let mut pending_bits = 0
  let mut data_chars = 0
  let mut padding = 0
  let mut padding_started = false
  for i = 0; i < length; i = i + 1 {
    let byte = raw.at(i).to_int()
    if is_ascii_whitespace(byte) {
      continue
    }
    if byte == 61 {
      // '='：填充只允许出现在末尾
      padding_started = true
      padding = padding + 1
      if padding > 2 {
        return None
      }
      continue
    }
    if padding_started {
      return None
    }
    let value = sextet(byte)
    if value < 0 {
      return None
    }
    data_chars = data_chars + 1
    // 只保留低 24 位：够用即可，避免高位不断堆进溢出区
    accumulator = ((accumulator << 6) | value) & 16777215
    pending_bits = pending_bits + 6
    if pending_bits >= 8 {
      pending_bits = pending_bits - 8
      out.push(((accumulator >> pending_bits) & 255).to_byte())
    }
  }
  // 长度为 1 mod 4 时永远解不出完整字节，属于非法长度
  if data_chars == 0 || data_chars % 4 == 1 {
    return None
  }
  // 末尾残留位必须全为零，否则不是「同一份字节」的合法写法
  if pending_bits > 0 && (accumulator & ((1 << pending_bits) - 1)) != 0 {
    return None
  }
  let expected_padding = if pending_bits == 0 {
    0
  } else if pending_bits == 4 {
    2
  } else {
    1
  }
  // 填了就必须填得对；没填也接受（省略填充是常见写法）
  if padding != 0 && padding != expected_padding {
    return None
  }
  Some(Bytes::from_array(out[:]))
}

///|
/// 字符串是否**已经**是规范 base64。
///
/// 实现上直接「解码再编码、看是否逐字节相同」，而不是另写一套判定规则，
/// 避免「判定」与「归一」两份定义日后各自漂移。
pub fn is_canonical(text : String) -> Bool {
  match decode(text) {
    Some(bytes) => encode(bytes) == text
    None => false
  }
}

///|
/// 判断一个字符串是否**疑似 base64 载荷**。
///
/// 判据刻意保守：长度够、字符全在字母表内、长度合法、能真正解码、解出的字节数够多。
/// 保守的代价是可能漏掉一些小载荷 —— 这个代价是刻意选的：
/// 漏归一只是少优化一次命中率，误判则会把普通字符串**改成另一个字符串**。
/// 归一化只作用于请求体（见 `@core.Request::normalize`），那里改写是有语义风险的，
/// 因此这里的闸门必须比「能解码就行」严得多。
pub fn looks_like_base64(
  text : String,
  min_chars? : Int,
  min_bytes? : Int,
) -> Bool {
  let chars_floor = match min_chars {
    Some(value) => value
    None => min_payload_chars
  }
  let bytes_floor = match min_bytes {
    Some(value) => value
    None => min_payload_bytes
  }
  let raw = @utf8.encode(text)
  if raw.length() < chars_floor {
    return false
  }
  let mut stripped = 0
  for i = 0; i < raw.length(); i = i + 1 {
    let byte = raw.at(i).to_int()
    if is_ascii_whitespace(byte) {
      continue
    }
    if byte != 61 && sextet(byte) < 0 {
      return false
    }
    stripped = stripped + 1
  }
  if stripped < chars_floor || stripped % 4 == 1 {
    return false
  }
  match decode(text) {
    Some(bytes) => bytes.length() >= bytes_floor
    None => false
  }
}

///|
/// 把「疑似载荷」的字符串归一到规范 base64；不是载荷则**原样返回**。
///
/// 幂等：已是规范形式时 `normalize(x) == x`。
/// 这一点是本函数最重要的性质 —— 它保证「历史 cassette 里本来规范的载荷，
/// 归一化后逐字节不变」，从而不会因为引入归一化而让旧文件对不上。
pub fn normalize(text : String, min_chars? : Int, min_bytes? : Int) -> String {
  if !looks_like_base64(text, min_chars?, min_bytes?) {
    return text
  }
  match decode(text) {
    Some(bytes) => encode(bytes)
    None => text
  }
}
