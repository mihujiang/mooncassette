// mooncassette/sanitize —— 录制内容的脱敏。
//
// 为什么这是**默认行为**而不是可选功能：
// cassette 会被提交进版本控制、被贴进 issue、被用于演示。
// 一个不小心录进去的 API Key，等同于把密钥永久写进了 git 历史。
//
// 关于指纹的语义：脱敏会改变请求内容，从而改变指纹。
// 本项目刻意采用「指纹在编码时由存储内容派生」而不是「提前存死」，
// 因此「先脱敏、再落盘」得到的指纹始终自洽，完整性校验不会误报。

///|
/// 脱敏策略。
pub(all) struct SanitizePolicy {
  /// 大小写不敏感的**精确**键名匹配。
  exact_keys : Array[String]
  /// 大小写不敏感的**后缀**匹配，例如 `_token` 命中 `access_token`。
  ///
  /// 之所以用后缀而不是子串，是为了避免误伤：`max_tokens`、`total_tokens`
  /// 以 `_tokens` 结尾，不会被 `_token` 命中，因而不会被误替换。
  key_suffixes : Array[String]
  /// 命中后的替换值。
  placeholder : String
  /// 是否额外扫描字符串值中「形如密钥」的子串（例如 `sk-...`）。
  scan_secret_shapes : Bool
} derive(Eq)

///|
/// 默认策略：覆盖常见厂商的鉴权字段，并开启密钥形状扫描。
pub fn SanitizePolicy::default() -> SanitizePolicy {
  {
    exact_keys: [
      "authorization", "proxy-authorization", "api-key", "x-api-key", "api_key",
      "apikey", "token", "cookie", "set-cookie", "password",
    ],
    key_suffixes: ["_key", "_token", "_secret", "_password", "_credential"],
    placeholder: "***REDACTED***",
    scan_secret_shapes: true,
  }
}

///|
/// 判断某个键名是否需要脱敏。
pub fn is_sensitive_key(key : String, policy : SanitizePolicy) -> Bool {
  let lowered = ascii_lowercase(key)
  for i = 0; i < policy.exact_keys.length(); i = i + 1 {
    if lowered == ascii_lowercase(policy.exact_keys[i]) {
      return true
    }
  }
  for i = 0; i < policy.key_suffixes.length(); i = i + 1 {
    let suffix = ascii_lowercase(policy.key_suffixes[i])
    if lowered.length() >= suffix.length() && lowered.has_suffix(suffix) {
      return true
    }
  }
  false
}

///|
/// 递归脱敏一个 JSON 值。
///
/// 键名命中策略时，**整个值**被替换为占位符（不尝试保留部分内容）；
/// 字符串值若开启 `scan_secret_shapes`，则额外做子串级替换。
pub fn sanitize_json(value : Json, policy : SanitizePolicy) -> Json {
  match value {
    Object(fields) => {
      let out : Map[String, Json] = Map([])
      for key in fields.keys() {
        match fields.get(key) {
          Some(child) =>
            if is_sensitive_key(key, policy) {
              out.set(key, Json::string(policy.placeholder))
            } else {
              out.set(key, sanitize_json(child, policy))
            }
          None => ()
        }
      }
      Json::object(out)
    }
    Array(items) => {
      let out : Array[Json] = []
      for item in items {
        out.push(sanitize_json(item, policy))
      }
      Json::array(out)
    }
    String(text) =>
      if policy.scan_secret_shapes {
        Json::string(redact_secret_shapes(text, policy.placeholder))
      } else {
        value
      }
    scalar => scalar
  }
}

///|
/// 脱敏一个请求。
pub fn sanitize_request(
  request : @core.Request,
  policy : SanitizePolicy,
) -> @core.Request {
  {
    provider: request.provider,
    model: request.model,
    body: sanitize_json(request.body, policy),
  }
}

///|
/// 脱敏一个响应。
///
/// `status` 与 `usage` 原样保留：它们是数值元数据，不承载密钥。
///
/// 流式响应的**每一帧也要脱敏**，否则「落盘内容一定经过脱敏」这条承诺
/// 会在流式路径上被绕开——帧里装的是同一份模型输出。
pub fn sanitize_response(
  response : @core.Response,
  policy : SanitizePolicy,
) -> @core.Response {
  {
    status: response.status,
    body: sanitize_json(response.body, policy),
    usage: response.usage,
    stream: match response.stream {
      Some(frames) => Some(sanitize_frames(frames, policy))
      None => None
    },
  }
}

///|
/// 脱敏帧序列。
fn sanitize_frames(
  frames : Array[@core.StreamFrame],
  policy : SanitizePolicy,
) -> Array[@core.StreamFrame] {
  let out : Array[@core.StreamFrame] = []
  for frame in frames {
    out.push({
      event: frame.event,
      data: sanitize_frame_data(frame.data, policy),
    })
  }
  out
}

///|
/// 脱敏一帧的 `data`。
///
/// 帧的 `data` 通常是一段 JSON（增量片段），此时按**键名**递归脱敏后再写回
/// 规范文本——与响应体走同一套规则，不留缺口。
///
/// `[DONE]` 这类非 JSON 数据没有结构可依，退化为对整段文本做一次密钥形状
/// 扫描：能覆盖「模型复述了密钥」的情形，代价是这一路没有键名可依据。
fn sanitize_frame_data(data : String, policy : SanitizePolicy) -> String {
  let parsed = @json.parse(data) catch {
    _ => return sanitize_text(data, policy)
  }
  match parsed {
    Object(_) | Array(_) =>
      @canon.to_canonical_string(sanitize_json(parsed, policy))
    _ => sanitize_text(data, policy)
  }
}

///|
/// 对一段纯文本做子串级脱敏。
///
/// 直接复用 `sanitize_json` 对字符串值的处理，避免这里再实现一套形状扫描
/// 而与主路径产生分歧。
fn sanitize_text(text : String, policy : SanitizePolicy) -> String {
  match sanitize_json(Json::string(text), policy) {
    String(redacted) => redacted
    _ => text
  }
}

///|
/// 脱敏一条交互记录。
pub fn sanitize_interaction(
  interaction : @core.Interaction,
  policy : SanitizePolicy,
) -> @core.Interaction {
  {
    request: sanitize_request(interaction.request, policy),
    response: sanitize_response(interaction.response, policy),
  }
}

///|
/// 脱敏整个 cassette，返回新的 cassette（不修改入参）。
///
/// `meta` 原样保留：它由调用方掌控，不来自模型或网络。
pub fn sanitize_cassette(
  cassette : @core.Cassette,
  policy : SanitizePolicy,
) -> @core.Cassette {
  let interactions : Array[@core.Interaction] = []
  for item in cassette.interactions {
    interactions.push(sanitize_interaction(item, policy))
  }
  { version: cassette.version, meta: cassette.meta, interactions }
}

///|
/// 扫描字符串中「形如密钥」的子串并替换。
///
/// 刻意保守：只识别 `sk-` 这一类高置信度前缀，且要求后续至少 8 个
/// 密钥字符。宁可漏掉一个，也不要误判 —— 误判会把正常内容替换掉，
/// 让 cassette 失去作为测试基准的价值。
fn redact_secret_shapes(text : String, placeholder : String) -> String {
  let chars : Array[Char] = []
  for ch in text {
    chars.push(ch)
  }
  let total = chars.length()
  let out = StringBuilder::new()
  let mut index = 0
  while index < total {
    match secret_shape_end(chars, index) {
      Some(end) => {
        out.write_string(placeholder)
        index = end
      }
      None => {
        out.write_char(chars[index])
        index = index + 1
      }
    }
  }
  out.to_string()
}

///|
/// 若 `chars` 从 `start` 起是一个密钥形状子串，返回其结束下标（不含）。
/// 否则返回 `None`。
fn secret_shape_end(chars : Array[Char], start : Int) -> Int? {
  let total = chars.length()
  if start + 3 > total {
    return None
  }
  if !(chars[start] == 's' && chars[start + 1] == 'k' && chars[start + 2] == '-') {
    return None
  }
  let mut end = start + 3
  while end < total && is_secret_body_char(chars[end]) {
    end = end + 1
  }
  if end - (start + 3) >= 8 {
    Some(end)
  } else {
    None
  }
}

///|
/// 密钥主体允许出现的字符。
fn is_secret_body_char(ch : Char) -> Bool {
  ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '-' || ch == '_'
}

///|
/// ASCII 小写化。
///
/// 只处理 ASCII：键名比较场景足够，且避免引入 Unicode 大小写折叠的
/// 版本依赖（不同 Unicode 版本折叠结果可能不同，会破坏指纹稳定性）。
fn ascii_lowercase(text : String) -> String {
  let sb = StringBuilder::new()
  for ch in text {
    sb.write_char(ch.to_ascii_lowercase())
  }
  sb.to_string()
}
