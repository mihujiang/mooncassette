// mooncassette/core —— 数据模型。
//
// 设计原则：
// 1. 本文件只描述「数据形状」与最基础的构造/查询，不含算法；
// 2. 所有进入 `Interaction` 的值必须是完全确定的；
//    任何跨运行会变化的信息（时间戳、耗时、随机数）只能放进 `CassetteMeta`。

///|
/// cassette 格式版本号。
///
/// 写入时使用当前版本；读取时严格校验。这样未来若改变语义，
/// 旧版本的 reader 会明确报错，而不是把新格式「读歪」。
pub let cassette_format_version : Int = 1

///|
/// 生成器标识。写入每个 cassette，便于追溯产出来源与排查兼容性问题。
///
/// 必须与 `moon.mod` 里的 `version` 保持一致：CI 会比对这两处，不一致
/// 直接失败。之所以要靠校验而不是共享常量，是因为 MoonBit 无法在编译期
/// 读取模块元信息，而这个标识一旦漂移，cassette 就会谎报产出版本。
pub let generator_id : String = "mooncassette/0.3.0"

///|
/// 一次 LLM 请求。
///
/// 不变量：
/// - `body` 的**对象键顺序不参与语义**，由 `@canon` 的规范文本统一归一；
/// - 生成指纹前必须先调用 `Request::normalize` 剔除易变字段，
///   否则同一语义的请求每次都会得到不同指纹，回放将永远无法命中。
pub(all) struct Request {
  provider : String
  model : String
  body : Json
} derive(Eq)

///|
/// 构造一个请求。
pub fn Request::new(provider : String, model : String, body : Json) -> Request {
  { provider, model, body }
}

///|
/// 供应方返回的 token 用量。
pub(all) struct Usage {
  input_tokens : Int
  output_tokens : Int
} derive(Eq)

///|
/// 构造用量信息。
pub fn Usage::new(input_tokens : Int, output_tokens : Int) -> Usage {
  { input_tokens, output_tokens }
}

///|
/// 输入与输出 token 数之和。
pub fn Usage::total(self : Usage) -> Int {
  self.input_tokens + self.output_tokens
}

///|
/// 一次 LLM 响应。
///
/// `status` 沿用 HTTP 语义；非 HTTP 传输（例如本地 mock）使用 0。
pub(all) struct Response {
  status : Int
  body : Json
  usage : Usage?
} derive(Eq)

///|
/// 构造响应。
pub fn Response::new(status : Int, body : Json, usage? : Usage) -> Response {
  { status, body, usage }
}

///|
/// 构造一个 200 响应。
///
/// 直接构造结构体而不转发给 `Response::new`：可选参数在函数体内
/// 已经是 `Usage?`，直接落入字段可以避免一次无意义的拆装。
pub fn Response::ok(body : Json, usage? : Usage) -> Response {
  { status: 200, body, usage }
}

///|
/// cassette 元信息。
///
/// 与 `Interaction` 相反，本类型**允许**包含非确定性字段。
/// 重新录制时这些字段出现 diff 属预期行为，不影响回放。
pub(all) struct CassetteMeta {
  name : String
  generator : String
  recorded_at : String?
} derive(Eq)

///|
/// 构造元信息，`generator` 自动填为当前 `generator_id`。
pub fn CassetteMeta::new(name : String, recorded_at? : String) -> CassetteMeta {
  { name, generator: generator_id, recorded_at }
}

///|
/// 一条被录制的交互。
///
/// 不变量：本类型必须**完全确定**。任何不确定字段一经混入，
/// 「确定性回放」这一核心承诺即被破坏，因此这里刻意不提供时间戳字段。
pub(all) struct Interaction {
  request : Request
  response : Response
} derive(Eq)

///|
/// 构造一条交互记录。
pub fn Interaction::new(request : Request, response : Response) -> Interaction {
  { request, response }
}

///|
/// 一个 cassette：一组按录制顺序排列的交互。
pub(all) struct Cassette {
  version : Int
  meta : CassetteMeta
  interactions : Array[Interaction]
} derive(Eq)

///|
/// 构造一个空 cassette，`version` 自动填为当前格式版本。
pub fn Cassette::new(
  name : String,
  recorded_at? : String,
  interactions? : Array[Interaction],
) -> Cassette {
  {
    version: cassette_format_version,
    meta: { name, generator: generator_id, recorded_at },
    interactions: match interactions {
      Some(items) => items
      None => []
    },
  }
}

///|
/// 记录条数。
pub fn Cassette::length(self : Cassette) -> Int {
  self.interactions.length()
}

///|
/// 追加一条记录（录制时使用）。
pub fn Cassette::push(self : Cassette, interaction : Interaction) -> Unit {
  self.interactions.push(interaction)
}

///|
/// 输入 token 合计（忽略未上报用量的记录）。
pub fn Cassette::total_input_tokens(self : Cassette) -> Int {
  let mut total = 0
  for item in self.interactions {
    match item.response.usage {
      Some(usage) => total = total + usage.input_tokens
      None => ()
    }
  }
  total
}

///|
/// 输出 token 合计（忽略未上报用量的记录）。
pub fn Cassette::total_output_tokens(self : Cassette) -> Int {
  let mut total = 0
  for item in self.interactions {
    match item.response.usage {
      Some(usage) => total = total + usage.output_tokens
      None => ()
    }
  }
  total
}

///|
/// mooncassette 统一错误类型。
///
/// 所有错误都携带足以定位问题的上下文：出错路径、指纹或记录序号。
pub(all) suberror CassetteError {
  /// 输入文本不是合法 JSON，或顶层不是 JSON 对象。
  Malformed(String)
  /// JSON 结构合法，但字段缺失或类型不符；字符串给出出错路径。
  SchemaViolation(String)
  /// cassette 的格式版本不受支持。
  UnsupportedVersion(Int)
  /// 存在两条指纹相同、但规范请求不同的记录（哈希碰撞）。
  FingerprintCollision(String)
  /// 记录中保存的指纹与按记录内容重算的结果不一致（文件被手工改动）。
  IntegrityViolation(String)
  /// 回放时找不到与请求匹配的录制记录。
  ///
  /// 内容是「请求指纹」加上一句诊断结论：cassette 里有多少条记录、
  /// 最接近的是哪一条、差在哪个字段。只给指纹不足以定位问题。
  NoMatch(String)
  /// 顺序回放模式下记录已耗尽：测试要的调用次数多于录制的条数。
  ///
  /// 与 `NoMatch` 分开是必要的：耗尽要补录制，没有对应记录要改请求，
  /// 两者混在一起会把排查引向错误的方向。
  Exhausted(String)
  /// 当前模式需要真实 Transport，但会话未提供。
  MissingTransport(String)
  /// 底层 Transport 调用失败（网络、鉴权等）。
  TransportFailure(String)
}

///|
pub impl Show for CassetteError with fn output(self, logger) {
  match self {
    Malformed(message) =>
      logger.write_string("mooncassette: malformed cassette: " + message)
    SchemaViolation(message) =>
      logger.write_string("mooncassette: schema violation: " + message)
    UnsupportedVersion(version) =>
      logger.write_string(
        "mooncassette: unsupported cassette format version \{version}, expected \{cassette_format_version}",
      )
    FingerprintCollision(fingerprint) =>
      logger.write_string(
        "mooncassette: fingerprint collision on \{fingerprint}: two different requests share one fingerprint",
      )
    IntegrityViolation(message) =>
      logger.write_string("mooncassette: integrity violation: " + message)
    NoMatch(detail) =>
      logger.write_string(
        "mooncassette: no recorded interaction matches request " + detail,
      )
    Exhausted(message) =>
      logger.write_string("mooncassette: recording exhausted: " + message)
    MissingTransport(message) =>
      logger.write_string("mooncassette: missing transport: " + message)
    TransportFailure(message) =>
      logger.write_string("mooncassette: transport failure: " + message)
  }
}

// ---------------------------------------------------------------------------
// 规范 JSON 视图
//
// 这些函数定义「数据模型如何映射为 JSON」。它们是**唯一**的映射定义：
// 匹配用的规范文本（@fingerprint）与落盘格式（@codec）都基于它们，
// 从而不会出现「匹配按一种形状算、落盘按另一种形状写」的漂移。
//
// 注意：对象键顺序由 @canon 统一排序，因此这里无需关心插入顺序。

///|
/// 构造一个「看起来像整数」的 JSON 数字，避免输出 `200.0` 这类噪声。
fn json_int(value : Int) -> Json {
  Json::number(value.to_double(), repr=value.to_string())
}

///|
/// 由三要素拼出请求的 JSON 形状。
///
/// 独立暴露该函数是为了让「子集匹配」也能基于同一形状投影，
/// 而不是各自拼一遍、日后产生分歧。
pub fn request_json(provider : String, model : String, body : Json) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("provider", Json::string(provider))
  fields.set("model", Json::string(model))
  fields.set("body", body)
  Json::object(fields)
}

///|
/// 请求的 JSON 视图。
pub fn Request::to_json(self : Request) -> Json {
  request_json(self.provider, self.model, self.body)
}

///|
/// 用量的 JSON 视图。
pub fn Usage::to_json(self : Usage) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("input_tokens", json_int(self.input_tokens))
  fields.set("output_tokens", json_int(self.output_tokens))
  Json::object(fields)
}

///|
/// 响应的 JSON 视图。未上报用量时省略 `usage` 字段。
pub fn Response::to_json(self : Response) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("status", json_int(self.status))
  fields.set("body", self.body)
  match self.usage {
    Some(usage) => fields.set("usage", usage.to_json())
    None => ()
  }
  Json::object(fields)
}

///|
/// 交互记录的 JSON 视图（请求 + 响应）。
pub fn Interaction::to_json(self : Interaction) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("request", self.request.to_json())
  fields.set("response", self.response.to_json())
  Json::object(fields)
}
