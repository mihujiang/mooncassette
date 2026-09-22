///|
/// 合并时遇到**同一请求指纹、不同记录内容**该怎么办。
///
/// 为什么必须显式（没有默认值）：这既可能是哈希碰撞，也可能正是漂移检测
/// 关心的「同一请求在不同时间录了两次、响应不同」。默认替调用方选一个，
/// 就等于把「悄悄丢数据」或「悄悄留下同指纹的两条」写进库里。
pub(all) enum MergePolicy {
  /// 保留先出现的那条，后来的丢弃。
  KeepFirst
  /// 用后来的替换先出现的（在结果里的位置不变）。
  KeepLast
  /// 两条都保留 —— 用于刻意保留重试序列或漂移对照。
  KeepBoth
} derive(Eq)

///|
/// 合并的结果与统计。
///
/// 刻意用一个结构体而不是 `(Cassette, MergeReport)` 元组：以后要加统计项时
/// 不必改调用点的解构写法，也让 CLI 里的取用更直白。
pub(all) struct MergeOutcome {
  /// 合并结果。
  cassette : @core.Cassette
  /// 来源份数。
  sources : Int
  /// 真正写进结果的条数。
  kept : Int
  /// 完全相同的重复（同指纹 + 同摘要），被丢弃。
  duplicates : Int
  /// 同指纹但内容不同的冲突次数。
  conflicts : Int
} derive(Eq)

///|
/// 合并多份录制。
///
/// 去重口径是「请求指纹 + 整条记录摘要」**同时**相同：只有两者都一样，
/// 才敢断定两条记录等价。只要响应不同就走冲突分支，交给 `policy` 决定。
///
/// 输出顺序 = 来源顺序、来源内保持原顺序；`stats` 想要的「稳定可复现」
/// 在这里就是「同一组输入必然给出同一份输出」。
///
/// `meta` 取自第一份来源（保留出处），格式版本取各来源的**最大值**；
/// 若合并后的内容含流式记录，则至少提到 `stream_format_version`
/// —— 与 `@codec` 的 `effective_version` 是同一条规则。想把版本与
/// `generator` 一起对齐到当前构建，请再跑一次 `migrate`。
pub fn merge(
  sources : Array[@core.Cassette],
  policy? : MergePolicy,
) -> MergeOutcome {
  // `policy` 是必填参数（无默认值），所以这里 `None` 只是形式上的分支：
  // 真走到就按 `KeepBoth` 来 —— 那是唯一不会丢数据的选项。
  let chosen = policy.unwrap_or(KeepBoth)
  let ordered : Array[@core.Interaction] = []
  // 指纹 → 它在 `ordered` 里的代表位置。`KeepLast` 需要原地替换，所以必须记下标。
  let representative : Map[String, Int] = Map([])
  // "指纹|摘要" → 见过。用来识别「完全相同的重复」。
  let seen : Map[String, Bool] = Map([])
  let mut duplicates = 0
  let mut conflicts = 0
  let mut declared_version = 0
  for cassette in sources {
    if cassette.version > declared_version {
      declared_version = cassette.version
    }
    for item in cassette.interactions {
      let request_fingerprint = @fingerprint.fingerprint(item.request)
      let digest = @fingerprint.integrity_digest(item)
      let key = request_fingerprint + "|" + digest
      if seen.contains(key) {
        duplicates = duplicates + 1
        continue
      }
      seen.set(key, true)
      match representative.get(request_fingerprint) {
        None => {
          representative.set(request_fingerprint, ordered.length())
          ordered.push(item)
        }
        Some(at) => {
          conflicts = conflicts + 1
          match chosen {
            KeepFirst => ()
            KeepLast => ordered[at] = item
            KeepBoth => ordered.push(item)
          }
        }
      }
    }
  }
  let mut version = if declared_version > 0 {
    declared_version
  } else {
    @core.cassette_format_version
  }
  if version < @core.stream_format_version && contains_streamed(ordered) {
    version = @core.stream_format_version
  }
  let meta = if sources.length() > 0 {
    sources[0].meta
  } else {
    @core.CassetteMeta::new("merged")
  }
  let merged : @core.Cassette = { version, meta, interactions: ordered }
  {
    cassette: merged,
    sources: sources.length(),
    kept: ordered.length(),
    duplicates,
    conflicts,
  }
}

///|
fn contains_streamed(items : Array[@core.Interaction]) -> Bool {
  for item in items {
    if is_streamed(item) {
      return true
    }
  }
  false
}
