// mooncassette/core —— 数据模型。
//
// 设计原则：
// 1. 本文件只描述「数据形状」与最基础的构造/查询，不含算法；
// 2. 所有进入 `Interaction` 的值必须是完全确定的；
//    任何跨运行会变化的信息（时间戳、耗时、随机数）只能放进 `CassetteMeta`。

///|
/// 当前写入的 cassette 格式版本。
///
/// 历史：
/// - `1`：0.3.0 及更早写出的格式；
/// - `2`：引入流式记录（`Response.stream`）。
pub let cassette_format_version : Int = 2

///|
/// 引入流式记录（`Response.stream`）的格式版本。
///
/// 单独写出来，是因为写入端需要判断「这份内容最低要用哪个版本才能表达」：
/// 从旧文件读进来、又追加了流式记录的 cassette 声明的仍是旧版本，此时必须
/// 升到本值，否则文件会谎报自己是旧格式。
pub let stream_format_version : Int = 2

///|
/// 读取端是否支持某个格式版本。
///
/// 读取端接受**所有已发布过的版本**，因此旧 cassette 不需要迁移就能继续用；
/// 写入端则始终写当前版本。这样旧读取端遇到带流式记录的 cassette 会明确报
/// `UnsupportedVersion`，而不是把不认识的 `stream` 字段悄悄丢掉——后者会让
/// 完整性校验以「摘要对不上」的形式失败，用户根本看不出真正的原因。
pub fn is_supported_version(version : Int) -> Bool {
  version >= 1 && version <= cassette_format_version
}

///|
/// 生成器标识。写入每个 cassette，便于追溯产出来源与排查兼容性问题。
///
/// 必须与 `moon.mod` 里的 `version` 保持一致：CI 会比对这两处，不一致
/// 直接失败。之所以要靠校验而不是共享常量，是因为 MoonBit 无法在编译期
/// 读取模块元信息，而这个标识一旦漂移，cassette 就会谎报产出版本。
pub let generator_id : String = "mooncassette/0.7.0"

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
/// 流式响应中的一帧。
///
/// 只保留 SSE 的 `event` 与 `data` 两个字段：
///
/// - `id` / `retry` 属于「断线重连」的传输层元数据，不是模型输出，而且往往
///   带随机性；写进 cassette 只会让漂移检测误报；
/// - 以 `:` 开头的注释行按规范本就应当忽略。
pub(all) struct StreamFrame {
  /// SSE 的 `event:` 字段。OpenAI 不发这个字段，此时为 `None`。
  event : String?
  /// SSE 的 `data:` 字段；同一帧内的多个 `data:` 行以 `\n` 连接。
  data : String
} derive(Eq)

///|
/// 构造一帧。
pub fn StreamFrame::new(data : String, event? : String) -> StreamFrame {
  { event, data }
}

///|
/// 一次 LLM 响应。
///
/// `status` 沿用 HTTP 语义；非 HTTP 传输（例如本地 mock）使用 0。
pub(all) struct Response {
  status : Int
  body : Json
  usage : Usage?
  /// 流式响应被逐帧记录时的帧序列。
  ///
  /// `body` 始终保存**聚合后的最终结果**（与非流式响应同形），因此匹配、
  /// 漂移检测与成本核算都不必区分两种形态；本字段额外保留分片，是为了让
  /// 回放能重放同样的帧序列。`None` 表示这不是一次流式响应。
  stream : Array[StreamFrame]?
} derive(Eq)

///|
/// 构造响应。
pub fn Response::new(
  status : Int,
  body : Json,
  usage? : Usage,
  stream? : Array[StreamFrame],
) -> Response {
  { status, body, usage, stream }
}

///|
/// 构造一个 200 响应。
///
/// 直接构造结构体而不转发给 `Response::new`：可选参数在函数体内已经是
/// `Usage?` / `Array[StreamFrame]?`，直接落入字段可以避免一次无意义的拆装。
pub fn Response::ok(
  body : Json,
  usage? : Usage,
  stream? : Array[StreamFrame],
) -> Response {
  { status: 200, body, usage, stream }
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
        "mooncassette: unsupported cassette format version " +
        version.to_string() +
        "; this build reads versions 1 to " +
        cassette_format_version.to_string(),
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
/// 一帧的 JSON 视图。`event` 缺省时省略该字段。
pub fn StreamFrame::to_json(self : StreamFrame) -> Json {
  let fields : Map[String, Json] = Map([])
  match self.event {
    Some(name) => fields.set("event", Json::string(name))
    None => ()
  }
  fields.set("data", Json::string(self.data))
  Json::object(fields)
}

///|
/// 帧序列的 JSON 视图。
fn stream_frames_to_json(frames : Array[StreamFrame]) -> Json {
  let items : Array[Json] = []
  for frame in frames {
    items.push(frame.to_json())
  }
  Json::array(items)
}

///|
/// 响应的 JSON 视图。
///
/// 未上报用量时省略 `usage` 字段；非流式响应省略 `stream` 字段。
pub fn Response::to_json(self : Response) -> Json {
  let fields : Map[String, Json] = Map([])
  fields.set("status", json_int(self.status))
  fields.set("body", self.body)
  match self.usage {
    Some(usage) => fields.set("usage", usage.to_json())
    None => ()
  }
  match self.stream {
    Some(frames) => fields.set("stream", stream_frames_to_json(frames))
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
