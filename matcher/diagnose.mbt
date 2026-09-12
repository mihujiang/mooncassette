// mooncassette/matcher —— 未命中诊断。
//
// 回放失败时只报一句「no match」几乎没有可操作性：用户无法判断是请求
// 写错了、录制没覆盖，还是匹配策略选得不合适。本文件把失败拆成可读的
// 结论，并指出与请求最接近的几条录制记录到底差在哪个字段上。
//
// 这里只报告**路径**，不报告字段值：诊断信息常被写进测试输出或日志，
// 而传进来的请求未必经过脱敏。

///|
/// 每条候选最多报告几个差异路径。
///
/// 差异通常集中在少数几个字段上，把上百条路径全部列出反而会淹没真正的原因。
let max_reported_paths : Int = 5

///|
/// 诊断中的一条候选记录。
pub(all) struct Candidate {
  /// 该记录在 cassette 中的下标。
  index : Int
  /// 记录中的 provider。
  provider : String
  /// 记录中的模型名。
  ///
  /// 单独列出它，是因为「所有候选的模型都与请求不同」是最常见的一类原因
  /// （录的是 `gpt-4o`，请求却写成了 `gpt-4o-mini`），摆出来一望便知。
  model : String
  /// 与请求不同的字段路径，例如 `$.body.messages[0].content`。
  differing_paths : Array[String]
} derive(Eq)

///|
/// 一次未命中的诊断结果。
pub(all) struct Diagnosis {
  /// 诊断时使用的匹配策略。
  policy : MatchPolicy
  /// 诊断时的回放游标。
  cursor : Int
  /// cassette 中的记录总数。
  total : Int
  /// 按「差异最少」排序的候选，最多 `top` 条。
  ///
  /// `total` 为 0 时本数组为空。
  candidates : Array[Candidate]
} derive(Eq)

///|
/// 诊断一次未命中：找出与 `request` 最接近的记录，以及差在哪些字段。
///
/// 调用方应先对 `request` 做规范化（必要时再脱敏），否则差异里会混进
/// 易变字段，噪声会盖住真正的原因。`@recorder.Session::diagnose` 已经代劳。
///
/// 代价是 O(记录数 × 字段数)：它会把请求与**每一条**记录做一次结构比较。
/// 这是排错路径，不在回放的正常路径上。
pub fn diagnose(
  request : @core.Request,
  interactions : ArrayView[@core.Interaction],
  policy : MatchPolicy,
  cursor : Int,
  top? : Int,
) -> Diagnosis {
  let limit = match top {
    Some(value) => value
    None => 3
  }
  let total = interactions.length()
  let request_view = request.to_json()
  let collected : Array[Candidate] = []
  for i = 0; i < total; i = i + 1 {
    let recorded = interactions[i].request
    let paths : Array[String] = []
    collect_differences(
      recorded.to_json(),
      request_view,
      "$",
      paths,
      max_reported_paths,
    )
    collected.push({
      index: i,
      provider: recorded.provider,
      model: recorded.model,
      differing_paths: paths,
    })
  }
  sort_by_distance(collected)
  let ranked : Array[Candidate] = []
  for i = 0; i < collected.length() && i < limit; i = i + 1 {
    ranked.push(collected[i])
  }
  { policy, cursor, total, candidates: ranked }
}

///|
/// 一行结论，可直接拼进错误消息。
pub fn Diagnosis::hint(self : Diagnosis) -> String {
  if self.total == 0 {
    return "the cassette contains no interactions"
  }
  match self.candidates {
    [] =>
      "the cassette has " +
      self.total.to_string() +
      " interaction(s) but none of them could be compared"
    [best, ..] =>
      "the cassette has " +
      self.total.to_string() +
      " interaction(s); closest is #" +
      best.index.to_string() +
      " (provider=" +
      best.provider +
      " model=" +
      best.model +
      "), differing at " +
      render_paths(best.differing_paths)
  }
}

///|
/// 多行报告，便于打印或写进 CI 日志。
pub fn Diagnosis::lines(self : Diagnosis) -> Array[String] {
  let out : Array[String] = []
  out.push(
    "policy=" +
    self.policy.name() +
    "  cursor=" +
    self.cursor.to_string() +
    "  interactions=" +
    self.total.to_string(),
  )
  if self.candidates.length() == 0 {
    out.push("no candidate available for comparison")
  }
  for candidate in self.candidates {
    out.push(
      "  #" +
      candidate.index.to_string() +
      "  provider=" +
      candidate.provider +
      "  model=" +
      candidate.model +
      "  differs: " +
      render_paths(candidate.differing_paths),
    )
  }
  out
}

///|
/// 把差异路径渲染成一行。
fn render_paths(paths : Array[String]) -> String {
  if paths.length() == 0 {
    return "(no field-level difference; check the matching policy)"
  }
  let sb = StringBuilder::new()
  for i = 0; i < paths.length(); i = i + 1 {
    if i > 0 {
      sb.write_string(", ")
    }
    sb.write_string(paths[i])
  }
  sb.to_string()
}

///|
/// 按差异数量升序排列候选。
///
/// 用插入排序而非库的排序函数：这里要求**稳定**（差异数相同时保持录制顺序），
/// 否则同一个输入可能给出不同的候选次序，诊断结果就无法被测试断言。
fn sort_by_distance(items : Array[Candidate]) -> Unit {
  for i = 1; i < items.length(); i = i + 1 {
    let value = items[i]
    let mut j = i - 1
    while j >= 0 &&
          items[j].differing_paths.length() > value.differing_paths.length() {
      items[j + 1] = items[j]
      j = j - 1
    }
    items[j + 1] = value
  }
}

///|
/// 递归比较两个 JSON 值，把不同的位置按路径收集进 `out`。
///
/// 路径形如 `$.body.messages[0].content`，与 cassette 的 JSON 视图对齐，
/// 可以直接照着去改代码或改 cassette。
fn collect_differences(
  recorded : Json,
  incoming : Json,
  path : String,
  out : Array[String],
  limit : Int,
) -> Unit {
  if out.length() >= limit {
    return
  }
  match (recorded, incoming) {
    (Object(left), Object(right)) =>
      for key in sorted_key_union(left, right) {
        let field_path = path + "." + key
        match (left.get(key), right.get(key)) {
          (Some(a), Some(b)) =>
            collect_differences(a, b, field_path, out, limit)
          (Some(_), None) =>
            push_path(out, field_path + " (only in the recording)", limit)
          (None, Some(_)) =>
            push_path(out, field_path + " (only in the request)", limit)
          (None, None) => ()
        }
      }
    (Array(left), Array(right)) => {
      let common = if left.length() < right.length() {
        left.length()
      } else {
        right.length()
      }
      for i = 0; i < common; i = i + 1 {
        collect_differences(
          left[i],
          right[i],
          path + "[" + i.to_string() + "]",
          out,
          limit,
        )
      }
      if left.length() != right.length() {
        push_path(
          out,
          path +
          ".length (" +
          left.length().to_string() +
          " recorded vs " +
          right.length().to_string() +
          " requested)",
          limit,
        )
      }
    }
    // 其余情况都按标量处理：取值不同即记为差异，
    // 类型不同（对象对数组等）同样会落到这里，报告为路径本身不同。
    (a, b) => if a != b { push_path(out, path, limit) }
  }
}

///|
fn push_path(out : Array[String], value : String, limit : Int) -> Unit {
  if out.length() < limit {
    out.push(value)
  }
}

///|
/// 两个对象的键的并集，按字典序排序。
///
/// 排序是必要的：`Map` 的迭代顺序不保证稳定，而诊断输出要能被测试断言，
/// 也要能在两次运行之间保持一致。
fn sorted_key_union(
  left : Map[String, Json],
  right : Map[String, Json],
) -> Array[String] {
  let keys : Array[String] = []
  for key in left.keys() {
    keys.push(key)
  }
  for key in right.keys() {
    if !contains_key(keys, key) {
      keys.push(key)
    }
  }
  sort_strings(keys)
  keys
}

///|
fn contains_key(keys : Array[String], target : String) -> Bool {
  for key in keys {
    if key == target {
      return true
    }
  }
  false
}

///|
/// 原地插入排序。键的数量很少，不值得为此引入排序依赖。
fn sort_strings(items : Array[String]) -> Unit {
  for i = 1; i < items.length(); i = i + 1 {
    let value = items[i]
    let mut j = i - 1
    while j >= 0 && items[j] > value {
      items[j + 1] = items[j]
      j = j - 1
    }
    items[j + 1] = value
  }
}
