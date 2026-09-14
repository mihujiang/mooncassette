// mooncassette/matcher —— 请求指纹索引。
//
// 存在的理由只有一个：**避免在扫描过程中重复计算指纹**。
//
// 指纹要从请求的规范文本导出，单次成本约等于「规范化 + 一次哈希」。
// 没有索引时，凡是必须扫完整张表的路径都会对每条记录重算一遍：
// 未命中、游标靠后的命中、以及重复回放同一份 cassette。
//
// 实测（examples/benchmarks，1000 条记录，js 后端）：
//
//   命中在首位                59 us
//   未命中（扫完全表）      18.8 ms   ← 每条记录约 18.8 us，正是单次指纹的成本
//
// 索引把这件事从「每次扫描」降到「每份 cassette 一次」。

///|
/// 一批记录的请求指纹索引。
///
/// 只覆盖**请求**：指纹本就不含响应，因此同一份索引在录制阶段与回放阶段都
/// 有效——录制时在末尾追加以保持对齐即可。
///
/// 不变量：`fingerprints` 与对应的记录**逐位对齐**。一旦错位，匹配就会指向
/// 错误的记录，而这个错误不会表现为崩溃，只会表现为「回放出了另一个响应」，
/// 极难追查。因此本类型只提供两种修改方式：整体重建，或在**末尾**追加。
///
/// 字段是 `priv` 的：若可公开构造，上面这条不变量就只是注释里的一句话，
/// 任何人都能造一个与记录无关的索引塞进 `find_match`。这里的可见性就是那条
/// 不变量的执行者。需要读取时用 `length()`。
pub struct MatchIndex {
  priv fingerprints : Array[String]
} derive(Eq)

///|
/// 为一批记录建立索引。
pub fn MatchIndex::build(
  interactions : ArrayView[@core.Interaction],
) -> MatchIndex {
  let fingerprints : Array[String] = []
  for interaction in interactions {
    fingerprints.push(@fingerprint.fingerprint(interaction.request))
  }
  // 带尾随逗号：否则 `{ fingerprints }` 会被当成「块表达式」而不是结构体字面量。
  { fingerprints, }
}

///|
/// 索引覆盖的记录条数。
pub fn MatchIndex::length(self : MatchIndex) -> Int {
  self.fingerprints.length()
}

///|
/// 在末尾追加一条记录对应的指纹，保持逐位对齐。
pub fn MatchIndex::push(
  self : MatchIndex,
  interaction : @core.Interaction,
) -> Unit {
  self.fingerprints.push(@fingerprint.fingerprint(interaction.request))
}

///|
/// 索引是否仍然与这批记录逐位对齐。
///
/// 判定依据是条数相等。这建立在一条约定上：**记录只会被追加，不会被就地
/// 修改**。追加会让条数不等、从而暴露出来；就地修改则不会。`Session` 因此在
/// 每次追加记录时同步索引，使这项约定成为事实而非期望。
pub fn MatchIndex::aligned_with(
  self : MatchIndex,
  interactions : ArrayView[@core.Interaction],
) -> Bool {
  self.fingerprints.length() == interactions.length()
}

///|
/// 取第 `at` 条记录的指纹。
fn MatchIndex::at(self : MatchIndex, at : Int) -> String {
  self.fingerprints[at]
}

///|
/// 取第 `at` 条记录的指纹：有索引就用索引，没有就现算。
///
/// 现算是**正确但昂贵**的路径（每条记录一次规范化加一次哈希）。保留它是因为
/// `find_match` 也用于一次性查询——为一次查找建立整张索引并不划算。
fn recorded_fingerprint(
  interactions : ArrayView[@core.Interaction],
  index : MatchIndex?,
  at : Int,
) -> String {
  match index {
    Some(built) => built.at(at)
    None => @fingerprint.fingerprint(interactions[at].request)
  }
}
