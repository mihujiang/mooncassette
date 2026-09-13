// mooncassette/matcher —— 把一次请求对应到一条录制记录。
//
// 匹配是「策略」而非「规范化」：规范化决定两个请求在语义上是否相同，
// 而匹配策略决定在不可完全复现时允许放宽到什么程度。
// 二者分层，避免把宽松规则混进指纹，导致指纹失去稳定性。

///|
/// 回放时使用的匹配策略。
pub(all) enum MatchPolicy {
  /// 严格：指纹相同**且**规范请求全等。默认值，推荐。
  Exact
  /// 宽松：只比较指纹，跳过规范文本比对。
  ///
  /// 与 `Exact` 的差别只有一处：指纹相同之后不再用规范文本确认。因此它省掉的
  /// 是**校验**而不是**计算**——指纹本身仍要从规范文本导出，「比较指纹」并不比
  /// 「比较规范文本」便宜（实测两者相当，见 `examples/benchmarks`）。
  ///
  /// 代价是理论上可能命中哈希碰撞产生的错误记录。除非确有理由，否则请用 `Exact`。
  FingerprintOnly
  /// 子集：只比较请求体顶层的指定字段，其余字段一律忽略。
  ///
  /// 适用于「只要 prompt 一致就算同一次调用」这类场景。
  Subset(Array[String])
  /// 顺序：不做任何请求比对，按录制顺序依次消费。
  ///
  /// 适用于调用顺序本身即语义的场景（例如流式多轮）。
  Sequential
} derive(Eq)

///|
/// 策略名，用于日志与诊断输出。
///
/// 单独提供而不复用 `Show`：诊断报告需要的是稳定、可断言的短标识，
/// 而 `Show` 的输出格式属于展示细节，将来可能调整。
pub fn MatchPolicy::name(self : MatchPolicy) -> String {
  match self {
    Exact => "Exact"
    FingerprintOnly => "FingerprintOnly"
    Subset(_) => "Subset"
    Sequential => "Sequential"
  }
}

///|
/// 该策略是否通过**整请求指纹**筛选候选。
///
/// 用来判断「这次匹配值不值得建指纹索引」：`Exact` 与 `FingerprintOnly` 逐条
/// 比较整请求指纹，索引能把「每条一次的重算」降为「整表一次」；而 `Sequential`
/// 根本不比对请求，`Subset` 比较的是子集投影（投影依赖 `keys`，不是整请求
/// 指纹），给它们建索引只是白白付一次 O(记录数) 的代价。
pub fn MatchPolicy::scans_by_fingerprint(self : MatchPolicy) -> Bool {
  match self {
    Exact => true
    FingerprintOnly => true
    Subset(_) => false
    Sequential => false
  }
}

///|
/// 一次成功匹配的结果。
pub(all) struct MatchResult {
  /// 命中的记录在 cassette 中的下标，调用方据此推进游标。
  index : Int
  interaction : @core.Interaction
} derive(Eq)

///|
/// 从 `cursor` 处开始查找匹配的记录。
///
/// 查找顺序为 `cursor, cursor+1, ..., 末尾, 开头, ..., cursor-1`（环形）。
/// 这样既能正确处理「同一请求被录制多次、按调用次序依次回放」，
/// 又能在实际调用次数多于录制次数时复用最早的一条，而不是直接失败。
///
/// 返回 `None` 表示当前 cassette 中没有候选。是否把它当作错误，
/// 由调用方决定（回放模式报错，自动模式回落真实调用）。
///
/// 只有当**指纹相同而规范请求不同**（即真实哈希碰撞）时才抛错：
/// 那是数据层面的异常，静默容忍会掩盖问题。
///
/// `index` 可选：传入 `MatchIndex` 可复用已算好的指纹（见 `MatchIndex` 的说明）。
/// 省略时逐条现算，结果完全一致，只是慢。重复查询同一份 cassette 时应当传入。
pub fn find_match(
  request : @core.Request,
  interactions : ArrayView[@core.Interaction],
  policy : MatchPolicy,
  cursor : Int,
  index? : MatchIndex,
) -> MatchResult? raise @core.CassetteError {
  let total = interactions.length()
  if total == 0 {
    return None
  }
  match policy {
    // 顺序模式**不做**游标归一：游标越界即代表录制已耗尽，
    // 必须如实报告，否则「录制覆盖不足」会被悄悄掩盖。
    Sequential =>
      if cursor >= 0 && cursor < total {
        Some({ index: cursor, interaction: interactions[cursor] })
      } else {
        None
      }
    Exact =>
      search_by_text(request, interactions, clamp_cursor(cursor, total), index)
    FingerprintOnly =>
      search_by_fingerprint(
        request,
        interactions,
        clamp_cursor(cursor, total),
        index,
      )
    Subset(keys) =>
      search_by_subset(request, interactions, clamp_cursor(cursor, total), keys)
  }
}

///|
/// 判断「没找到」是不是因为**录制已耗尽**。
///
/// 只有 `Sequential` 会耗尽：它按位置消费，游标越界就意味着录制的条数不够用。
/// 环形模式（`Exact` / `FingerprintOnly` / `Subset`）永远会回卷，因此它们返回
/// 「没找到」一定是确实没有对应记录。
///
/// 区分这两种情况的意义在于**修法不同**：耗尽要补录制，没有对应记录要改请求
/// 或换匹配策略。把前者报成「没有匹配记录」会把用户引向错误的方向。
///
/// 空 cassette 不算耗尽：那属于「一条都没录」，报「没有匹配记录」更贴切。
pub fn is_exhausted(policy : MatchPolicy, cursor : Int, total : Int) -> Bool {
  match policy {
    Sequential => total > 0 && (cursor < 0 || cursor >= total)
    _ => false
  }
}

///|
/// 把越界游标折回 0。
///
/// 只用于环形查找（`Exact` / `FingerprintOnly` / `Subset`）：
/// 这类模式允许在录制耗尽后回卷复用此前的记录。
fn clamp_cursor(cursor : Int, total : Int) -> Int {
  if cursor >= 0 && cursor < total {
    cursor
  } else {
    0
  }
}

///|
/// 环形遍历下标：第 `offset` 个访问的下标。
fn ring_index(start : Int, offset : Int, total : Int) -> Int {
  let raw = start + offset
  if raw < total {
    raw
  } else {
    raw - total
  }
}

///|
/// 严格匹配：指纹筛选 + 规范文本全等校验。
///
/// 规范文本只在该候选指纹相同时才计算：它是**校验**，不是筛选条件，
/// 对绝大多数不匹配的候选都是白算。
fn search_by_text(
  request : @core.Request,
  interactions : ArrayView[@core.Interaction],
  start : Int,
  index : MatchIndex?,
) -> MatchResult? raise @core.CassetteError {
  let total = interactions.length()
  let target_fingerprint = @fingerprint.fingerprint(request)
  let mut offset = 0
  while offset < total {
    let at = ring_index(start, offset, total)
    if recorded_fingerprint(interactions, index, at) == target_fingerprint {
      if @fingerprint.canonical_request(interactions[at].request) ==
        @fingerprint.canonical_request(request) {
        return Some({ index: at, interaction: interactions[at] })
      }
      raise @core.CassetteError::FingerprintCollision(target_fingerprint)
    }
    offset = offset + 1
  }
  None
}

///|
/// 宽松匹配：只比较指纹。
fn search_by_fingerprint(
  request : @core.Request,
  interactions : ArrayView[@core.Interaction],
  start : Int,
  index : MatchIndex?,
) -> MatchResult? {
  let total = interactions.length()
  let target = @fingerprint.fingerprint(request)
  let mut offset = 0
  while offset < total {
    let at = ring_index(start, offset, total)
    if recorded_fingerprint(interactions, index, at) == target {
      return Some({ index: at, interaction: interactions[at] })
    }
    offset = offset + 1
  }
  None
}

///|
/// 子集匹配：只比较请求体顶层的指定字段。
fn search_by_subset(
  request : @core.Request,
  interactions : ArrayView[@core.Interaction],
  start : Int,
  keys : Array[String],
) -> MatchResult? {
  let total = interactions.length()
  let target = subset_text(request, keys)
  let mut offset = 0
  while offset < total {
    let index = ring_index(start, offset, total)
    let candidate = interactions[index]
    if subset_text(candidate.request, keys) == target {
      return Some({ index, interaction: candidate })
    }
    offset = offset + 1
  }
  None
}

///|
/// 把请求投影到指定字段后取规范文本。
///
/// 只投影 `body` 的顶层字段；其余层级原样保留，
/// 以免「子集匹配」在嵌套结构上产生难以预期的宽松行为。
///
/// 投影后仍复用 `@fingerprint.canonical_text` 生成文本，因此
/// 「子集匹配」与「精确匹配」共享同一套形状定义与排序规则。
fn subset_text(request : @core.Request, keys : Array[String]) -> String {
  let body = match request.body {
    Object(fields) => {
      let kept : Map[String, Json] = Map([])
      for key in keys {
        match fields.get(key) {
          Some(value) => kept.set(key, value)
          None => ()
        }
      }
      Json::object(kept)
    }
    scalar => scalar
  }
  @fingerprint.canonical_text(request.provider, request.model, body)
}
