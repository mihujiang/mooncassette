// mooncassette/drift —— 两次录制之间的漂移检测。
//
// 场景：你更新了 prompt 或换了模型版本，重新录制了一份 cassette。
// 直接看 JSON diff 是没法读的（指纹变了、key 顺序也变了），
// 你真正想知道的是三件事：
//   1. 哪些调用消失了（prompt 改了 / 被删了）；
//   2. 哪些调用是新增的；
//   3. 哪些调用**请求没变但响应变了** —— 这才是「模型行为漂移」。
//
// 第 3 类尤其重要：它意味着你没改代码，但模型输出变了。

///|
/// 漂移的类型。
pub(all) enum DriftKind {
  /// 只出现在旧录制中：该调用被删除，或请求被改动导致指纹变化。
  Removed
  /// 只出现在新录制中：新增调用，或请求被改动导致指纹变化。
  Added
  /// 两侧都有同一请求，但响应内容不同 —— 真正的「行为漂移」。
  Changed
} derive(Eq)

///|
/// 一条漂移记录。
pub(all) struct DriftEntry {
  kind : DriftKind
  /// 请求指纹（短形式，便于人眼比对）。
  fingerprint : String
  /// 该请求所属的模型名。
  model : String
  /// 在旧录制中的下标；`Removed` / `Changed` 时存在。
  old_index : Int?
  /// 在新录制中的下标；`Added` / `Changed` 时存在。
  new_index : Int?
} derive(Eq)

///|
/// 漂移报告。
///
/// 条目顺序是确定的：先 `Removed`，再 `Changed`，最后 `Added`；
/// 每组内部按各自的下标升序。这样报告可以直接用于 diff 或快照测试。
pub(all) struct DriftReport {
  entries : Array[DriftEntry]
  /// 两侧完全一致的请求条数。
  unchanged : Int
} derive(Eq)

///|
/// 是否存在任何漂移。
pub fn DriftReport::is_clean(self : DriftReport) -> Bool {
  self.entries.length() == 0
}

///|
/// 统计某一类漂移的条数。
pub fn DriftReport::count_of(self : DriftReport, kind : DriftKind) -> Int {
  let mut total = 0
  for entry in self.entries {
    if entry.kind == kind {
      total = total + 1
    }
  }
  total
}

///|
/// 一行式摘要，适合作为日志或 CI 输出。
pub fn DriftReport::summary(self : DriftReport) -> String {
  if self.is_clean() {
    return "no drift: " +
      self.unchanged.to_string() +
      " interaction(s) identical"
  }
  "drift detected: removed=" +
  self.count_of(Removed).to_string() +
  " changed=" +
  self.count_of(Changed).to_string() +
  " added=" +
  self.count_of(Added).to_string() +
  " unchanged=" +
  self.unchanged.to_string()
}

///|
/// 逐条渲染报告，每行一条。
pub fn DriftReport::lines(self : DriftReport) -> Array[String] {
  let out : Array[String] = []
  for entry in self.entries {
    out.push(render_entry(entry))
  }
  out
}

///|
/// 比较两份录制，产出漂移报告。
///
/// 匹配依据是**请求指纹**（即规范化后的请求），因此：
/// - 对象键顺序变化、`request_id` 之类的易变字段变化，都不会被误判成漂移；
/// - 请求本身改动则会表现为「一条 Removed + 一条 Added」，这是刻意的：
///   我们无法判断改后的请求「对应」原来哪一条，与其猜，不如如实报告。
///
/// 同一指纹出现多次时，按**出现顺序**两两配对，从而正确处理
/// 「同一请求被调用多次」的情形。
pub fn compare(old : @core.Cassette, new : @core.Cassette) -> DriftReport {
  let new_buckets : Map[String, Array[Int]] = Map([])
  for i = 0; i < new.interactions.length(); i = i + 1 {
    let key = request_key(new.interactions[i])
    match new_buckets.get(key) {
      Some(bucket) => bucket.push(i)
      None => {
        let bucket : Array[Int] = [i]
        new_buckets.set(key, bucket)
      }
    }
  }
  let consumed : Map[String, Int] = Map([])
  let taken : Array[Bool] = Array::make(new.interactions.length(), false)
  let removed : Array[DriftEntry] = []
  let changed : Array[DriftEntry] = []
  let mut unchanged = 0
  for i = 0; i < old.interactions.length(); i = i + 1 {
    let item = old.interactions[i]
    let key = request_key(item)
    let offset = consumed.get_or_default(key, 0)
    let candidate = match new_buckets.get(key) {
      Some(bucket) =>
        if offset < bucket.length() {
          Some(bucket[offset])
        } else {
          None
        }
      None => None
    }
    match candidate {
      Some(j) => {
        consumed.set(key, offset + 1)
        taken[j] = true
        if response_text(item) == response_text(new.interactions[j]) {
          unchanged = unchanged + 1
        } else {
          changed.push({
            kind: Changed,
            fingerprint: short_fingerprint(key),
            model: item.request.model,
            old_index: Some(i),
            new_index: Some(j),
          })
        }
      }
      None =>
        removed.push({
          kind: Removed,
          fingerprint: short_fingerprint(key),
          model: item.request.model,
          old_index: Some(i),
          new_index: None,
        })
    }
  }
  let added : Array[DriftEntry] = []
  for j = 0; j < new.interactions.length(); j = j + 1 {
    if !taken[j] {
      let item = new.interactions[j]
      added.push({
        kind: Added,
        fingerprint: short_fingerprint(request_key(item)),
        model: item.request.model,
        old_index: None,
        new_index: Some(j),
      })
    }
  }
  // 固定顺序输出：Removed → Changed → Added。
  let entries : Array[DriftEntry] = []
  append_all(entries, removed)
  append_all(entries, changed)
  append_all(entries, added)
  { entries, unchanged }
}

///|
/// 请求的匹配键：规范化请求的指纹。
///
/// 这里**主动再规范化一次**。正常录制出来的 cassette 请求已是规范化形态，
/// 再规范化是幂等的空操作；但对于手工构造、或被旧版本/外部工具改过的
/// cassette，这一步能避免把「易变字段残留」误判成漂移。
/// 漂移检测比较的是语义，因此容错方向应当是「宁可少报」。
fn request_key(interaction : @core.Interaction) -> String {
  @fingerprint.fingerprint(interaction.request.normalize())
}

///|
/// 响应内容比较用的规范文本。
///
/// 用规范文本而不是结构相等，是为了让「键顺序不同但语义相同」的响应
/// 不被误判为漂移。
fn response_text(interaction : @core.Interaction) -> String {
  @canon.to_canonical_string(interaction.response.to_json())
}

///|
/// 指纹的短形式（取算法名之后的 8 位十六进制），便于日志与报告排版。
fn short_fingerprint(fingerprint : String) -> String {
  let parts : Array[StringView] = fingerprint.split(":").to_array()
  if parts.length() != 2 {
    return fingerprint
  }
  let digest = parts[1].to_owned()
  // 十六进制全是 ASCII，因此按下标切片安全。
  if digest.length() <= 8 {
    digest
  } else {
    digest[:8].to_owned()
  }
}

///|
fn append_all(target : Array[DriftEntry], source : Array[DriftEntry]) -> Unit {
  for item in source {
    target.push(item)
  }
}

///|
/// 渲染一条漂移记录。
pub fn render_entry(entry : DriftEntry) -> String {
  match entry.kind {
    Removed =>
      "[removed] " +
      entry.model +
      " #" +
      index_text(entry.old_index) +
      "  " +
      entry.fingerprint
    Added =>
      "[added]   " +
      entry.model +
      " #" +
      index_text(entry.new_index) +
      "  " +
      entry.fingerprint
    Changed =>
      "[changed] " +
      entry.model +
      " #" +
      index_text(entry.old_index) +
      " -> #" +
      index_text(entry.new_index) +
      "  " +
      entry.fingerprint
  }
}

///|
fn index_text(index : Int?) -> String {
  match index {
    Some(value) => value.to_string()
    None => "-"
  }
}
