// mooncassette/canon —— JSON 规范文本。
//
// 为什么需要一个「自研」的 JSON 写出器，而不用标准库的 `Json::stringify`？
// 因为标准库的 `Json::Object` 底层是 `Map`，其迭代顺序未定义。
// 若直接使用，同一份语义的 cassette 在不同运行/不同后端下会产生
// 不同的字节序列，导致：
//   - 版本控制 diff 无意义地抖动；
//   - 指纹无法跨目标复现。
// 因此这里显式定义并实现一套规范排序与转义规则。

///|
/// 把 JSON 值写出为**规范文本**（紧凑形式，无任何多余空白）。
///
/// 规范化规则：
/// 1. 对象键按 UTF-8 字节序排序。UTF-8 的字节序与 Unicode 码点序一致，
///    因此该规则同时兼容 Python / Rust 等以码点序排序的实现，
///    便于用其它语言独立复核 cassette 内容；
/// 2. 字符串按 RFC 8259 转义：`/` 不转义，非 ASCII 原样输出为 UTF-8，
///    使包含中文的 cassette 保持人类可读；
/// 3. 数字优先使用解析阶段确定的字面量表示（`Number` 的 `repr`），
///    否则使用 `Double` 的字符串化结果。注意 `repr` 是解析器归一化后的
///    结果而非逐字节保留原文：`1e100` 会写成 `1e+100`，`1.0` 会写成 `1`。
///    也就是说规范文本**不区分** `1` 与 `1.0`（JSON 本身也只有一种数字类型）。
///    该表示是**幂等**的，因此「解析 → 写出 → 再解析 → 再写出」收敛，
///    这正是 cassette 能够稳定 diff 所需要的性质；
/// 4. 不产生任何多余空白。
///
/// 边界情况：JSON 无法表示 NaN / Infinity。若程序中构造出这类值，
/// 会退化为 `null`，而不会产出非法 JSON。
pub fn to_canonical_string(value : Json) -> String {
  let sb = StringBuilder::new()
  write_compact(sb, value)
  sb.to_string()
}

///|
/// 带缩进的规范文本，键序与 `to_canonical_string` 完全一致。
///
/// 用于落盘：保留缩进让 cassette 在版本控制中产生可读 diff，
/// 而键序固定保证 diff 不会因 Map 迭代顺序而抖动。
pub fn to_pretty_string(value : Json, indent? : Int) -> String {
  let width = match indent {
    Some(width) => width
    None => 2
  }
  let sb = StringBuilder::new()
  write_pretty(sb, value, width, 0)
  sb.to_string()
}

///|
/// 紧凑写出。
fn write_compact(sb : StringBuilder, value : Json) -> Unit {
  match value {
    Null => sb.write_string("null")
    True => sb.write_string("true")
    False => sb.write_string("false")
    Number(number, repr~) =>
      match repr {
        Some(text) => sb.write_string(text)
        None => write_number(sb, number)
      }
    String(text) => write_escaped(sb, text)
    Array(items) => {
      sb.write_string("[")
      let mut index = 0
      for item in items {
        if index > 0 {
          sb.write_string(",")
        }
        index = index + 1
        write_compact(sb, item)
      }
      sb.write_string("]")
    }
    Object(fields) => {
      let keys = sorted_keys(fields)
      sb.write_string("{")
      let mut index = 0
      for key in keys {
        if index > 0 {
          sb.write_string(",")
        }
        index = index + 1
        write_escaped(sb, key)
        sb.write_string(":")
        match fields.get(key) {
          Some(child) => write_compact(sb, child)
          None => sb.write_string("null")
        }
      }
      sb.write_string("}")
    }
  }
}

///|
/// 带缩进写出。空数组/空对象保持单行，避免无意义的多行 diff。
fn write_pretty(
  sb : StringBuilder,
  value : Json,
  width : Int,
  depth : Int,
) -> Unit {
  match value {
    Array(items) if items.length() == 0 => sb.write_string("[]")
    Array(items) => {
      sb.write_string("[\n")
      let mut index = 0
      for item in items {
        if index > 0 {
          sb.write_string(",\n")
        }
        index = index + 1
        write_indent(sb, width, depth + 1)
        write_pretty(sb, item, width, depth + 1)
      }
      sb.write_string("\n")
      write_indent(sb, width, depth)
      sb.write_string("]")
    }
    Object(fields) if fields.length() == 0 => sb.write_string("{}")
    Object(fields) => {
      let keys = sorted_keys(fields)
      sb.write_string("{\n")
      let mut index = 0
      for key in keys {
        if index > 0 {
          sb.write_string(",\n")
        }
        index = index + 1
        write_indent(sb, width, depth + 1)
        write_escaped(sb, key)
        sb.write_string(": ")
        match fields.get(key) {
          Some(child) => write_pretty(sb, child, width, depth + 1)
          None => sb.write_string("null")
        }
      }
      sb.write_string("\n")
      write_indent(sb, width, depth)
      sb.write_string("}")
    }
    scalar => write_compact(sb, scalar)
  }
}

///|
/// 写出 `width * depth` 个空格。
fn write_indent(sb : StringBuilder, width : Int, depth : Int) -> Unit {
  let total = width * depth
  for i = 0; i < total; i = i + 1 {
    sb.write_char(' ')
  }
}

///|
/// 写出一个数字。
///
/// NaN / ±Infinity 不是合法 JSON，这里退化为 `null`。
/// 注意不能用 `value == @double.not_a_number` 判断 NaN（NaN 不等于自身），
/// 必须使用自反不等。
fn write_number(sb : StringBuilder, value : Double) -> Unit {
  if value != value {
    sb.write_string("null")
  } else if value == @double.infinity || value == @double.neg_infinity {
    sb.write_string("null")
  } else {
    sb.write_string(value.to_string())
  }
}

///|
/// 写出一个 JSON 字符串字面量（含首尾引号）。
///
/// 转义规则遵循 RFC 8259：仅转义 `"`、`\` 与 U+0000–U+001F。
/// 其中常用的控制字符使用短转义（`\n` 等），其余使用 `\u00XX`。
/// 非 ASCII 字符原样输出为 UTF-8，以保证中文可读。
fn write_escaped(sb : StringBuilder, text : String) -> Unit {
  sb.write_string("\"")
  for ch in text {
    if ch == '"' {
      sb.write_string("\\\"")
    } else if ch == '\\' {
      sb.write_string("\\\\")
    } else if ch == '\n' {
      sb.write_string("\\n")
    } else if ch == '\r' {
      sb.write_string("\\r")
    } else if ch == '\t' {
      sb.write_string("\\t")
    } else if ch == '\u{08}' {
      sb.write_string("\\b")
    } else if ch == '\u{0C}' {
      sb.write_string("\\f")
    } else if ch.to_int() < 0x20 {
      sb.write_string("\\u")
      sb.write_string(hex4(ch.to_int()))
    } else {
      sb.write_char(ch)
    }
  }
  sb.write_string("\"")
}

///|
/// 把 0–0xFFFF 的码点渲染为 4 位小写十六进制（用于 `\uXXXX` 转义）。
fn hex4(code : Int) -> String {
  let digits : Array[Char] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ]
  let sb = StringBuilder::new()
  for shift = 12; shift >= 0; shift = shift - 4 {
    sb.write_char(digits[(code >> shift) & 0xF])
  }
  sb.to_string()
}

///|
/// 收集对象键并按 UTF-8 字节序排序。
///
/// 刻意自实现插入排序而不依赖标准库排序 API：
/// 规范文本的排序规则必须是**本文件定义的规则**，不能随标准库实现漂移；
/// 且对象键数量通常很小，插入排序足够。
fn sorted_keys(fields : Map[String, Json]) -> Array[String] {
  let keys : Array[String] = []
  for key in fields.keys() {
    keys.push(key)
  }
  let count = keys.length()
  for i = 1; i < count; i = i + 1 {
    let current = keys[i]
    let mut j = i - 1
    while j >= 0 && compare_utf8(keys[j], current) > 0 {
      keys[j + 1] = keys[j]
      j = j - 1
    }
    keys[j + 1] = current
  }
  keys
}

///|
/// 按 UTF-8 字节序比较两个字符串。
fn compare_utf8(left : String, right : String) -> Int {
  let left_bytes = @utf8.encode(left)
  let right_bytes = @utf8.encode(right)
  let left_len = left_bytes.length()
  let right_len = right_bytes.length()
  let limit = if left_len < right_len { left_len } else { right_len }
  for i = 0; i < limit; i = i + 1 {
    let x = left_bytes.at(i).to_int()
    let y = right_bytes.at(i).to_int()
    if x < y {
      return -1
    }
    if x > y {
      return 1
    }
  }
  if left_len < right_len {
    return -1
  }
  if left_len > right_len {
    return 1
  }
  0
}

///|
/// FNV-1a 64 位哈希。
///
/// 刻意不使用标准库 `Hasher`：其实现细节与目标后端相关，无法保证
/// wasm / wasm-gc / js / native 产出完全一致，而指纹必须跨目标、
/// 跨运行稳定（否则「在本机录制、在 CI 回放」这一核心场景会直接失败）。
///
/// 指纹只承担「索引与快速筛选」职责，最终一致性由规范文本全等校验兜底，
/// 因此 64 位非密码学哈希已足够。
pub fn fnv1a64(bytes : Bytes) -> UInt64 {
  let mut hash : UInt64 = 0xcbf29ce484222325
  let prime : UInt64 = 0x100000001b3
  for i = 0; i < bytes.length(); i = i + 1 {
    hash = (hash ^ bytes.at(i).to_uint64()) * prime
  }
  hash
}

///|
/// 对字符串的 UTF-8 编码计算 FNV-1a 64 位哈希。
pub fn fnv1a64_string(text : String) -> UInt64 {
  fnv1a64(@utf8.encode(text))
}

///|
/// 把 UInt64 渲染为固定 16 位小写十六进制字符串。
///
/// 固定宽度让指纹长度恒定，便于人眼比对与日志对齐。
pub fn hex_u64(value : UInt64) -> String {
  value.to_string(radix=16).pad_start(16, '0')
}
