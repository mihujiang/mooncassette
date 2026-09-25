// mooncassette/codec —— cassette 的序列化格式。
//
// 写入端使用 `@core.cassette_format_version`（当前为 2）；
// 读取端接受所有已发布过的版本，见 `@core.is_supported_version`。
//
// 文件形状：
// {
//   "format": "mooncassette",
//   "version": 2,
//   "meta": { "name": "…", "generator": "mooncassette/0.9.0", "recorded_at": "…"? },
//   "interactions": [
//     {
//       "fingerprint": "fnv1a64:…",
//       "integrity":   "fnv1a64:…",
//       "request":  { "provider": "…", "model": "…", "body": … },
//       "response": {
//         "status": 200,
//         "body": …,                                   // 聚合后的最终结果
//         "usage":  { "input_tokens": …, "output_tokens": … }?,
//         "stream": [ { "event": "…"?, "data": "…" } ]?  // 仅流式响应
//       }
//     }
//   ]
// }
//
// 两个摘要字段都不参与解码（解码时按内容重算），存在意义有三：
// 文件自描述、便于人工核对、支持篡改检测。二者分工见
// `interaction_to_json` 的说明。

///|
/// 顶层格式标识，用于快速识别文件类型。
pub let format_tag : String = "mooncassette"

///|
/// 把 cassette 编码为 JSON 值。
pub fn to_json(cassette : @core.Cassette) -> Json {
  let root : Map[String, Json] = Map([])
  root.set("format", Json::string(format_tag))
  root.set("version", json_int(effective_version(cassette)))
  root.set("meta", meta_to_json(cassette.meta))
  let interactions : Array[Json] = []
  for item in cassette.interactions {
    interactions.push(interaction_to_json(item))
  }
  root.set("interactions", Json::array(interactions))
  Json::object(root)
}

///|
/// 把 cassette 编码为文本。
///
/// - `indent = Some(0)`：紧凑形式，适合机器比对；
/// - `indent = Some(n)`：n 空格缩进；
/// - `indent = None`：默认 2 空格缩进，适合提交进版本控制。
pub fn encode(cassette : @core.Cassette, indent? : Int) -> String {
  let value = to_json(cassette)
  match indent {
    Some(width) =>
      if width <= 0 {
        @canon.to_canonical_string(value)
      } else {
        @canon.to_pretty_string(value, indent=width)
      }
    None => @canon.to_pretty_string(value, indent=2)
  }
}

///|
/// 从 JSON 值还原 cassette，并做严格的结构校验。
///
/// `verify` 默认开启：会按记录内容重算指纹，与文件中保存的值比对，
/// 从而检出被手工改动或被工具破坏的文件。
pub fn of_json(
  value : Json,
  verify? : Bool,
) -> @core.Cassette raise @core.CassetteError {
  let should_verify = match verify {
    Some(flag) => flag
    None => true
  }
  let root = expect_object(value, "$")
  let tag = expect_string(require_field(root, "format", "$"), "$.format")
  if tag != format_tag {
    raise @core.CassetteError::Malformed(
      "$.format: expected \"" + format_tag + "\", got \"" + tag + "\"",
    )
  }
  let version = expect_int(require_field(root, "version", "$"), "$.version")
  // 读取端接受所有已发布过的版本（见 `@core.is_supported_version` 的说明），
  // 因此旧 cassette 不需要迁移；只有真正不认识的版本才拒绝。
  if !@core.is_supported_version(version) {
    raise @core.CassetteError::UnsupportedVersion(version)
  }
  let meta = meta_of_json(require_field(root, "meta", "$"))
  let items = expect_array(
    require_field(root, "interactions", "$"),
    "$.interactions",
  )
  let interactions : Array[@core.Interaction] = []
  let mut index = 0
  for item in items {
    let path = "$.interactions[" + index.to_string() + "]"
    interactions.push(interaction_of_json(item, path, should_verify))
    index = index + 1
  }
  { version, meta, interactions }
}

///|
/// 解析 cassette 文本。
pub fn decode(
  text : StringView,
  verify? : Bool,
) -> @core.Cassette raise @core.CassetteError {
  let should_verify = match verify {
    Some(flag) => flag
    None => true
  }
  let value = @json.parse(text) catch {
    _ => raise @core.CassetteError::Malformed("input is not valid JSON")
  }
  match value {
    Object(_) => of_json(value, verify=should_verify)
    _ =>
      raise @core.CassetteError::Malformed(
        "top-level value must be a JSON object",
      )
  }
}

// ---------------------------------------------------------------------------
// 编码
// ---------------------------------------------------------------------------

///|
/// 构造一个「看起来像整数」的 JSON 数字，避免输出 `200.0` 这类噪声。
fn json_int(value : Int) -> Json {
  Json::number(value.to_double(), repr=value.to_string())
}

///|
/// 写入时实际使用的格式版本。
///
/// 规则：取「cassette 自己声明的版本」与「表达当前内容所需的最低版本」的
/// 较大者。
///
/// - 内容里出现流式记录时最低需要 `@core.stream_format_version`：一个从旧
///   文件读进来、又追加了流式记录的 cassette 声明值仍是旧版本，此时不升级
///   就会写出一个「自称旧格式、其实含新字段」的文件；
/// - 其余情况沿用声明值，于是「读入旧版本 → 写出旧版本」保持字节稳定，
///   旧文件不会因为过一次手就悄悄改头换面。
fn effective_version(cassette : @core.Cassette) -> Int {
  let required = if has_stream(cassette) {
    @core.stream_format_version
  } else {
    1
  }
  if cassette.version > required {
    cassette.version
  } else {
    required
  }
}

///|
/// 是否含流式记录。
fn has_stream(cassette : @core.Cassette) -> Bool {
  for item in cassette.interactions {
    match item.response.stream {
      Some(_) => return true
      None => ()
    }
  }
  false
}

///|
fn meta_to_json(meta : @core.CassetteMeta) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("name", Json::string(meta.name))
  fields.set("generator", Json::string(meta.generator))
  match meta.recorded_at {
    Some(text) => fields.set("recorded_at", Json::string(text))
    None => ()
  }
  Json::object(fields)
}

///|
/// 交互记录的 JSON 视图。
///
/// 写入两个摘要字段，二者职责不同，不可互相替代：
///
/// - `fingerprint`：只覆盖**请求**，供回放匹配与人工排查；
/// - `integrity`：覆盖**整条记录（含响应）**，用于检出任何手工改动。
///
/// 只写 `fingerprint` 是不够的：响应恰恰是最容易被改动的地方
/// （例如为了让失败的测试通过而直接改期望输出），必须单独覆盖。
fn interaction_to_json(item : @core.Interaction) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set(
    "fingerprint",
    Json::string(@fingerprint.fingerprint(item.request)),
  )
  fields.set("integrity", Json::string(@fingerprint.integrity_digest(item)))
  fields.set("request", item.request.to_json())
  fields.set("response", item.response.to_json())
  Json::object(fields)
}

// ---------------------------------------------------------------------------
// 解码
// ---------------------------------------------------------------------------

///|
/// 深度校验正文里出现的**每一处载荷信封**，并把出错位置落到具体字段路径。
///
/// `@payload.validate_envelope` 只能看一个对象；信封却可以嵌在正文的任意深度。
/// 少了这一步，改坏内层 `payload` 只会得到「完整性摘要不符」——
/// 那句话说不到现场。篡改检测的价值，取决于报错能不能直接指向现场。
fn check_envelopes(
  value : Json,
  path : String,
) -> Unit raise @core.CassetteError {
  match @payload.validate_envelope(value) {
    Some(reason) =>
      raise @core.CassetteError::SchemaViolation(path + ": " + reason)
    None => ()
  }
  match value {
    Object(fields) =>
      for key in fields.keys() {
        match fields.get(key) {
          Some(child) => check_envelopes(child, path + "." + key)
          None => ()
        }
      }
    Array(items) => {
      let mut index = 0
      for item in items {
        check_envelopes(item, path + "[" + index.to_string() + "]")
        index = index + 1
      }
    }
    _ => ()
  }
}

///|
fn meta_of_json(value : Json) -> @core.CassetteMeta raise @core.CassetteError {
  let fields = expect_object(value, "$.meta")
  let name = expect_string(
    require_field(fields, "name", "$.meta"),
    "$.meta.name",
  )
  let generator = expect_string(
    require_field(fields, "generator", "$.meta"),
    "$.meta.generator",
  )
  let recorded_at = match fields.get("recorded_at") {
    Some(text) => Some(expect_string(text, "$.meta.recorded_at"))
    None => None
  }
  { name, generator, recorded_at }
}

///|
fn interaction_of_json(
  value : Json,
  path : String,
  verify : Bool,
) -> @core.Interaction raise @core.CassetteError {
  let fields = expect_object(value, path)
  let request = request_of_json(
    require_field(fields, "request", path),
    path + ".request",
  )
  let response = response_of_json(
    require_field(fields, "response", path),
    path + ".response",
  )
  let interaction : @core.Interaction = { request, response }
  if verify {
    // 先于摘要校验：信封坏掉时能直接指到字段，
    // 而摘要不符只能说明「这条记录被动过」，说不到现场。
    check_envelopes(request.body, path + ".request.body")
    check_envelopes(response.body, path + ".response.body")
    // 两个摘要都要校验：前者覆盖请求，后者覆盖整条记录（含响应）。
    check_digest(fields, path, "fingerprint", @fingerprint.fingerprint(request))
    check_digest(
      fields,
      path,
      "integrity",
      @fingerprint.integrity_digest(interaction),
    )
  }
  interaction
}

///|
/// 比对记录中保存的摘要与按内容重算的结果；不一致即判定文件被改动。
///
/// 错误信息同时给出「存储值」与「重算值」，便于直接定位是哪一条记录
/// 的哪一个字段被改过（两个值相等的前缀长度往往就是改动位置）。
fn check_digest(
  fields : Map[String, Json],
  path : String,
  key : String,
  recomputed : String,
) -> Unit raise @core.CassetteError {
  let stored = expect_string(require_field(fields, key, path), path + "." + key)
  if stored != recomputed {
    raise @core.CassetteError::IntegrityViolation(
      path +
      "." +
      key +
      ": stored " +
      stored +
      " does not match recomputed " +
      recomputed,
    )
  }
}

///|
/// 解析一个请求文本。
///
/// 形状与 `@core.Request::to_json` 对称：`{"provider": …, "model": …, "body": …}`。
/// 供工具使用（例如 CLI 的未命中诊断），因此只做结构校验，不涉及任何摘要。
pub fn decode_request(
  text : StringView,
) -> @core.Request raise @core.CassetteError {
  let value = @json.parse(text) catch {
    _ =>
      raise @core.CassetteError::Malformed("request: input is not valid JSON")
  }
  request_of_json(value, "$")
}

///|
pub fn request_of_json(
  value : Json,
  path : String,
) -> @core.Request raise @core.CassetteError {
  let fields = expect_object(value, path)
  let provider = expect_string(
    require_field(fields, "provider", path),
    path + ".provider",
  )
  let model = expect_string(
    require_field(fields, "model", path),
    path + ".model",
  )
  let body = require_field(fields, "body", path)
  { provider, model, body }
}

///|
fn response_of_json(
  value : Json,
  path : String,
) -> @core.Response raise @core.CassetteError {
  let fields = expect_object(value, path)
  let status = expect_int(
    require_field(fields, "status", path),
    path + ".status",
  )
  let body = require_field(fields, "body", path)
  let usage = match fields.get("usage") {
    Some(usage_value) => Some(usage_of_json(usage_value, path + ".usage"))
    None => None
  }
  // 缺省即「非流式响应」；版本 1 的文件永远走这一支。
  let stream = match fields.get("stream") {
    Some(stream_value) =>
      Some(stream_frames_of_json(stream_value, path + ".stream"))
    None => None
  }
  { status, body, usage, stream }
}

///|
/// 解析帧序列。
///
/// 空数组同样被如实还原成「有流但零帧」：那只可能来自手工编辑，
/// 而把手工痕迹悄悄抹平会让完整性校验失去意义。
fn stream_frames_of_json(
  value : Json,
  path : String,
) -> Array[@core.StreamFrame] raise @core.CassetteError {
  let items = expect_array(value, path)
  let frames : Array[@core.StreamFrame] = []
  let mut index = 0
  for item in items {
    let frame_path = path + "[" + index.to_string() + "]"
    let fields = expect_object(item, frame_path)
    let data = expect_string(
      require_field(fields, "data", frame_path),
      frame_path + ".data",
    )
    let event = match fields.get("event") {
      Some(event_value) =>
        Some(expect_string(event_value, frame_path + ".event"))
      None => None
    }
    frames.push({ event, data })
    index = index + 1
  }
  frames
}

///|
fn usage_of_json(
  value : Json,
  path : String,
) -> @core.Usage raise @core.CassetteError {
  let fields = expect_object(value, path)
  let input_tokens = expect_int(
    require_field(fields, "input_tokens", path),
    path + ".input_tokens",
  )
  let output_tokens = expect_int(
    require_field(fields, "output_tokens", path),
    path + ".output_tokens",
  )
  { input_tokens, output_tokens }
}

// ---------------------------------------------------------------------------
// 校验辅助
// ---------------------------------------------------------------------------

///|
fn expect_object(
  value : Json,
  path : String,
) -> Map[String, Json] raise @core.CassetteError {
  match value {
    Object(fields) => fields
    _ =>
      raise @core.CassetteError::SchemaViolation(
        path + ": expected a JSON object",
      )
  }
}

///|
fn expect_array(
  value : Json,
  path : String,
) -> Array[Json] raise @core.CassetteError {
  match value {
    Array(items) => items
    _ =>
      raise @core.CassetteError::SchemaViolation(
        path + ": expected a JSON array",
      )
  }
}

///|
fn expect_string(
  value : Json,
  path : String,
) -> String raise @core.CassetteError {
  match value {
    String(text) => text
    _ =>
      raise @core.CassetteError::SchemaViolation(path + ": expected a string")
  }
}

///|
/// 取出一个整数。
///
/// 不仅要求是数字，还要求它确实是整数值：`1.5` 或 NaN 都会被拒绝。
/// 这样「文件被改成非法内容」会在解码期就暴露，而不是悄悄地取整。
fn expect_int(value : Json, path : String) -> Int raise @core.CassetteError {
  match value {
    Number(number, ..) =>
      if number == number.to_int().to_double() {
        number.to_int()
      } else {
        raise @core.CassetteError::SchemaViolation(
          path + ": expected an integer",
        )
      }
    _ =>
      raise @core.CassetteError::SchemaViolation(path + ": expected an integer")
  }
}

///|
fn require_field(
  fields : Map[String, Json],
  key : String,
  path : String,
) -> Json raise @core.CassetteError {
  match fields.get(key) {
    Some(value) => value
    None =>
      raise @core.CassetteError::SchemaViolation(
        path + "." + key + ": missing required field",
      )
  }
}
