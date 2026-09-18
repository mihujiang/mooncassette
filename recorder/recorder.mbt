// mooncassette/recorder —— 录制/回放会话引擎。
//
// 分层意图：真实网络能力被隔离在 `Transport` 之后。引擎本身不碰 IO，
// 因此「录制/回放/自动」三种模式的全部逻辑都可以在纯环境下测试。
//
// 脱敏职责归属：**引擎**统一脱敏，而不是各个 Transport 各自处理。
// 这样无论接入哪家的适配器，「写进 cassette 的内容一定经过同一套策略」，
// 不会因为某个适配器忘记脱敏而泄漏密钥。

///|
/// 被录制的底层调用。
///
/// 实现方只需把真实客户端适配到本接口，不必关心录制、匹配、脱敏。
pub(open) trait Transport {
  fn send(Self, @core.Request) -> @core.Response raise @core.CassetteError
}

///|
/// 会话模式。
pub(all) enum Mode {
  /// 总是调用真实 Transport，并追加记录。
  Record
  /// 只从 cassette 取；未命中即报错，**绝不**发起真实调用。
  Playback
  /// 先尝试回放；未命中再调用真实 Transport 并追加记录。
  Auto
} derive(Eq)

///|
/// 会话统计。
pub(all) struct Stats {
  /// 命中已有录制的次数。
  hits : Int
  /// 未命中已有录制的次数。
  misses : Int
  /// 新产生的录制条数。
  recorded : Int
} derive(Eq)

///|
/// 录制/回放会话。
///
/// `cursor` 是回放推进位置：命中的记录会被跳过，从而正确处理
/// 「同一请求被录制多次」的场景。`Auto` 模式下每次新录制都会把
/// 游标推到末尾。
pub struct Session {
  priv mut mode : Mode
  priv cassette : @core.Cassette
  priv mut cursor : Int
  priv mut hits : Int
  priv mut misses : Int
  priv mut recorded : Int
  priv transport : &Transport?
  priv policy : @matcher.MatchPolicy
  priv sanitize : @sanitize.SanitizePolicy
  /// 指纹索引的缓存。`None` 表示尚未建立。
  ///
  /// 缓存在会话上而不是 cassette 上：索引是「为某次扫描服务」的派生数据，
  /// 而 cassette 是要落盘的**数据本身**——把派生数据塞进它，序列化就需要
  /// 额外解释「这个字段要不要写进文件」，得不偿失。
  priv mut match_index : @matcher.MatchIndex?
}

///|
/// 创建会话。
///
/// 默认模式为 `Playback`（最安全：不会意外发起真实调用），
/// 默认匹配策略为 `Exact`，默认脱敏策略为 `SanitizePolicy::default()`。
pub fn Session::new(
  cassette : @core.Cassette,
  mode? : Mode,
  transport? : &Transport,
  policy? : @matcher.MatchPolicy,
  sanitize? : @sanitize.SanitizePolicy,
) -> Session {
  {
    mode: match mode {
      Some(value) => value
      None => Mode::Playback
    },
    cassette,
    cursor: 0,
    hits: 0,
    misses: 0,
    recorded: 0,
    transport,
    policy: match policy {
      Some(value) => value
      None => @matcher.MatchPolicy::Exact
    },
    sanitize: match sanitize {
      Some(value) => value
      None => @sanitize.SanitizePolicy::default()
    },
    match_index: None,
  }
}

///|
/// 发送一次请求。
///
/// 这里存在一条**关键的不变量**：同一次业务请求会被派生成两种形态，
/// 分别走两条不同链路，二者不可混用。
///
/// - `live`（发给 provider）：`normalize` 后直接发出，**保留密钥**。
///   若这里也脱敏，真实鉴权会失败。
/// - `stored`（用于匹配与落盘）：在 `live` 之上再 `sanitize`，**抹掉密钥**。
///
/// 录制与回放两侧都必须走这条同样的链路，指纹才能对齐。否则会出现
/// 「录得进去、回放不出来」——因为落盘的是脱敏版本，而回放查询的是原版。
/// 这个缺陷在早期版本里真实存在过，现在由本函数与 `prepare` 共同保证对称。
///
/// - `Record`：调用真实 Transport，追加记录，返回真实响应；
/// - `Playback`：只从 cassette 取，未命中报 `NoMatch`；
/// - `Auto`：先回放，未命中再录制（即为「首次自动录制」工作流）。
pub fn Session::send(
  self : Session,
  request : @core.Request,
) -> @core.Response raise @core.CassetteError {
  let live = request.normalize()
  let stored = @sanitize.sanitize_request(live, self.sanitize)
  match self.mode {
    Mode::Record => self.capture(live, stored)
    Mode::Playback => self.replay_prepared(stored)
    Mode::Auto =>
      match self.try_match(stored) {
        Some(response) => response
        None => self.capture(live, stored)
      }
  }
}

///|
/// 流式调用：先取到响应，再按录制顺序把每一帧交给 `sink`。
///
/// 为什么需要它：录制时应用是从自己的 HTTP 客户端**逐块**拿到数据的，回放时
/// 若只拿到一个聚合结果，那段「逐块渲染 / 逐块回调」的代码路径就永远跑不到，
/// 而它恰恰是最容易出错的部分。本函数把帧按原顺序递回去，让回放与真实调用在
/// 调用方看来是同一条路径。
///
/// 三种模式都适用：它建立在 `send` 之上，因此 `Record` / `Auto` / `Playback`
/// 的语义完全一致——先拿到响应（回放命中或真实录制），再重放其中的帧。
///
/// 非流式响应**不会**触发 `sink`：那是「本来就没有分片」，不是「分片丢了」。
/// 需要区分时可以看返回值的 `stream` 是否为 `None`。
pub fn Session::replay_stream(
  self : Session,
  request : @core.Request,
  sink : (@core.StreamFrame) -> Unit,
) -> @core.Response raise @core.CassetteError {
  let response = self.send(request)
  match response.stream {
    Some(frames) =>
      for frame in frames {
        sink(frame)
      }
    None => ()
  }
  response
}

///|
/// 把外部请求转换为「用于匹配与落盘」的形态。
///
/// 顺序是**先规范化、再脱敏**，与 `send` 中的派生顺序严格一致。
fn Session::prepare(self : Session, request : @core.Request) -> @core.Request {
  @sanitize.sanitize_request(request.normalize(), self.sanitize)
}

///|
/// 尝试回放。命中则推进游标并返回响应，未命中返回 `None`。
///
/// 调用方只需原样传入业务请求：规范化与脱敏由 `prepare` 统一处理，
/// 因此不会出现「直接调用本函数时忘了脱敏导致命中不了」的陷阱。
pub fn Session::try_replay(
  self : Session,
  request : @core.Request,
) -> @core.Response? raise @core.CassetteError {
  self.try_match(self.prepare(request))
}

///|
/// 在**已准备好**（规范化 + 脱敏）的请求上执行匹配与游标推进。
fn Session::try_match(
  self : Session,
  request : @core.Request,
) -> @core.Response? raise @core.CassetteError {
  let interactions = self.cassette.interactions[:]
  // 只有靠指纹筛选的策略才值得建索引；顺序与子集策略根本用不上它，
  // 为它们建索引只是白白付一次 O(记录数)。
  let result = if self.policy.scans_by_fingerprint() {
    @matcher.find_match(
      request,
      interactions,
      self.policy,
      self.cursor,
      index=self.fingerprint_index(),
    )
  } else {
    @matcher.find_match(request, interactions, self.policy, self.cursor)
  }
  match result {
    Some(found) => {
      self.cursor = found.index + 1
      self.hits = self.hits + 1
      Some(found.interaction.response)
    }
    None => {
      self.misses = self.misses + 1
      None
    }
  }
}

///|
/// 取（必要时建立）当前 cassette 的指纹索引。
///
/// 索引缓存在会话上，因此重复回放只付一次建立成本（实测 1000 条记录约
/// 19 毫秒），此后每次匹配都是纯粹的字符串比较。
///
/// 条数对不上就整体重建：调用方有可能直接改动了 `cassette()` 返回的记录，
/// 而索引一旦与记录错位，症状会是「回放出了另一个响应」——不是报错，
/// 而是**静默的错误结果**。宁可重建。
fn Session::fingerprint_index(self : Session) -> @matcher.MatchIndex {
  let interactions = self.cassette.interactions[:]
  match self.match_index {
    Some(built) =>
      if built.aligned_with(interactions) {
        built
      } else {
        let rebuilt = @matcher.MatchIndex::build(interactions)
        self.match_index = Some(rebuilt)
        rebuilt
      }
    None => {
      let built = @matcher.MatchIndex::build(interactions)
      self.match_index = Some(built)
      built
    }
  }
}

///|
/// 强制回放。未命中时报 `NoMatch`。
///
/// 与 `try_replay` 的区别只在于「未命中」的处置：
/// 这里的失败是显式的，适合在测试里断言「录制覆盖完整」。
pub fn Session::replay(
  self : Session,
  request : @core.Request,
) -> @core.Response raise @core.CassetteError {
  self.replay_prepared(self.prepare(request))
}

///|
/// 诊断「为什么没命中」，不抛错。
///
/// `replay` 失败时抛出的 `NoMatch` 消息里已经包含同样的结论；本函数提供给
/// 需要自行格式化输出的场景，例如 CLI、自定义断言，或「先看清楚再决定是
/// 补录制还是改请求」的调试流程。
///
/// 调用方传业务原样的请求即可：规范化与脱敏由本函数统一处理，与匹配路径
/// 保持一致。
pub fn Session::diagnose(
  self : Session,
  request : @core.Request,
  top? : Int,
) -> @matcher.Diagnosis {
  let limit = match top {
    Some(value) => value
    None => 3
  }
  @matcher.diagnose(
    self.prepare(request),
    self.cassette.interactions[:],
    self.policy,
    self.cursor,
    top=limit,
  )
}

///|
/// 在**已准备好**的请求上强制回放。未命中时报 `NoMatch`。
fn Session::replay_prepared(
  self : Session,
  request : @core.Request,
) -> @core.Response raise @core.CassetteError {
  match self.try_match(request) {
    Some(response) => response
    None => {
      let total = self.cassette.length()
      // 先判耗尽：顺序模式下「游标越界」与「没有对应记录」是两回事，
      // 前者的修法是补录制，后者是改请求或换匹配策略。报错了种类，
      // 用户就会朝错误的方向排查。
      if @matcher.is_exhausted(self.policy, self.cursor, total) {
        raise @core.CassetteError::Exhausted(
          "sequential playback consumed all " +
          total.to_string() +
          " recording(s); the test asked for one call more than was recorded",
        )
      }
      raise @core.CassetteError::NoMatch(self.miss_message(request))
    }
  }
}

///|
/// 拼出未命中时的错误详情：请求指纹 + 一句可操作的原因。
///
/// 只报指纹是不够的——用户拿着一个哈希无法判断该去补录制、改请求，还是
/// 换匹配策略。这里把诊断结论直接放进错误消息，让 `moon test` 的失败输出
/// 本身就能定位问题。
///
/// 传入的 `request` 必须已经规范化（必要时也已脱敏）：本函数内部直接调用
/// `@matcher.diagnose`，不再重复 `prepare`。
fn Session::miss_message(self : Session, request : @core.Request) -> String {
  let diagnosis = @matcher.diagnose(
    request,
    self.cassette.interactions[:],
    self.policy,
    self.cursor,
  )
  @fingerprint.fingerprint(request) + " (" + diagnosis.hint() + ")"
}

///|
/// 调用真实 Transport 并追加记录。
///
/// `live` 发给 provider（保留密钥），`stored` 写入 cassette（已脱敏）。
/// 响应侧只做脱敏，因为 provider 返回的内容同样可能包含敏感信息
/// （例如回显的鉴权头、或模型复述的密钥）。
fn Session::capture(
  self : Session,
  live : @core.Request,
  stored : @core.Request,
) -> @core.Response raise @core.CassetteError {
  let transport = match self.transport {
    Some(transport) => transport
    None =>
      raise @core.CassetteError::MissingTransport(
        "this mode needs a real transport, but the session was created without one",
      )
  }
  let response = transport.send(live)
  let safe_response = @sanitize.sanitize_response(response, self.sanitize)
  self.store(stored, safe_response)
  safe_response
}

///|
/// 把一条已准备好的记录并入 cassette，并推进游标与计数。
///
/// 自动录制（`capture`）与手动录制（`record`）共用本函数，这样两条路径在
/// 「游标推进到哪、计数怎么加」上不会各自演化出分歧。
fn Session::store(
  self : Session,
  stored : @core.Request,
  response : @core.Response,
) -> Unit {
  let interaction = @core.Interaction::new(stored, response)
  self.cassette.push(interaction)
  self.cursor = self.cassette.length()
  self.recorded = self.recorded + 1
  // 同步追加而不是作废索引：这样才能维持「索引与记录逐位对齐」这条不变量。
  // 作废后重建是 O(记录数)，放进录制循环会退化成 O(记录数²)。
  match self.match_index {
    Some(built) => built.push(interaction)
    None => ()
  }
}

///|
/// 手动写入一条录制：把「在别处拿到的响应」并入 cassette。
///
/// 主要用途是**异步 HTTP 客户端**。`Transport::send` 是同步的，而
/// `mizchi/x/http` 这类客户端只能在 async 上下文里调用，因此无法实现
/// `Transport`；此时在 async 上下文里手工走一遍即可：
///
/// ```text
/// match session.try_replay(request) {
///   Some(response) => response
///   None => {
///     let response = await my_client.send(request)   // 只有这一步是异步的
///     session.record(request, response)
///   }
/// }
/// ```
///
/// 请求与响应都会先经过与 `send` 完全相同的派生链（规范化 + 脱敏），因此
/// 手工录下的记录与自动录下的记录在 cassette 里形态一致，可以互相回放。
/// 换句话说，本函数绕开了 `Transport`，但没有绕开任何不变量。
///
/// 返回值是**已脱敏**的响应，与 `send` 在录制模式下的返回保持一致。保持一致
/// 的原因是确定性：回放返回的必然是 cassette 里存的那一份，若录制时返回未
/// 脱敏的原文，同一段代码在首次运行与后续运行就会看到不同的值。
///
/// 本函数不接触任何外部资源，因此在 `Playback` 模式下调用它也不会破坏
/// 「回放不发起真实调用」这一保证；但它确实会修改 cassette。
pub fn Session::record(
  self : Session,
  request : @core.Request,
  response : @core.Response,
) -> @core.Response {
  let stored = self.prepare(request)
  let safe_response = @sanitize.sanitize_response(response, self.sanitize)
  self.store(stored, safe_response)
  safe_response
}

///|
/// 当前统计。
pub fn Session::stats(self : Session) -> Stats {
  { hits: self.hits, misses: self.misses, recorded: self.recorded }
}

///|
/// 当前 cassette（录制模式下即为最新结果，可直接交给 `@codec.encode` 落盘）。
pub fn Session::cassette(self : Session) -> @core.Cassette {
  self.cassette
}

///|
/// 当前回放游标。
pub fn Session::cursor(self : Session) -> Int {
  self.cursor
}

///|
/// 切换模式。
pub fn Session::set_mode(self : Session, mode : Mode) -> Unit {
  self.mode = mode
}

///|
/// 脚本化的假 Transport，用于测试与示例。
///
/// 未配置的请求返回 500：这样在测试里「本不该发生的真实调用」
/// 会立刻表现为可断言的失败，而不是静默通过。
///
/// 注意：脚本按**规范化请求的指纹**索引（注册与查询两侧都会先
/// `normalize`），因此调用方可以按业务原样书写请求，不必关心
/// 对象键顺序或易变字段是否已剔除。
///
/// 这里刻意**不**做脱敏：真实 Transport 收到的是「保留密钥」的请求，
/// Mock 必须与真实行为一致，否则会掩盖脱敏相关问题。
///
/// 同一请求可以登记**多个**响应：按登记顺序依次给出，用完重复最后一个
/// （取值策略见 `@core.ScriptedReplies`）。这让「先 429、重试后 200」这类
/// 序列可以被离线回归，而不只是测到「最终成功」。
pub struct MockTransport {
  scripted : Map[String, @core.ScriptedReplies[@core.Response]]
  mut calls : Int
}

///|
/// 创建一个空的 MockTransport。
pub fn MockTransport::new() -> MockTransport {
  { scripted: Map([]), calls: 0 }
}

///|
/// 为某个请求登记响应。
///
/// 对同一请求重复调用会**追加**到该请求的应答序列末尾，而不是覆盖。
pub fn MockTransport::on(
  self : MockTransport,
  request : @core.Request,
  response : @core.Response,
) -> Unit {
  self.sequence_for(request).push(response)
}

///|
/// 为某个请求登记一串响应，按顺序依次给出。
///
/// 用于「重试后成功」这类序列，例如 `[429 的响应, 200 的响应]`。
pub fn MockTransport::on_sequence(
  self : MockTransport,
  request : @core.Request,
  responses : Array[@core.Response],
) -> Unit {
  let sequence = self.sequence_for(request)
  for response in responses {
    sequence.push(response)
  }
}

///|
/// 取（必要时新建）某个请求的应答序列。
fn MockTransport::sequence_for(
  self : MockTransport,
  request : @core.Request,
) -> @core.ScriptedReplies[@core.Response] {
  let key = @fingerprint.fingerprint(request.normalize())
  match self.scripted.get(key) {
    Some(sequence) => sequence
    None => {
      let fresh : @core.ScriptedReplies[@core.Response] = @core.ScriptedReplies::new([],
      )
      self.scripted.set(key, fresh)
      fresh
    }
  }
}

///|
/// 实际被调用的次数。
pub fn MockTransport::call_count(self : MockTransport) -> Int {
  self.calls
}

///|
pub impl Transport for MockTransport with fn send(self, request) {
  self.calls = self.calls + 1
  let key = @fingerprint.fingerprint(request.normalize())
  let played = match self.scripted.get(key) {
    Some(sequence) => sequence.take()
    None => None
  }
  match played {
    Some(response) => response
    None => {
      let body : Map[String, Json] = Map([])
      body.set("error", Json::string("no scripted response for " + key))
      @core.Response::new(500, Json::object(body))
    }
  }
}
