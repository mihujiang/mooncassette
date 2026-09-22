///|
/// 把一份 cassette 升到**当前**格式版本，并把 `meta.generator` 更新为
/// 本次构建的标识。
///
/// 为什么不能只做「解码 + 编码」：`@codec` 的写出侧刻意保持
/// 「读入旧版本 → 写出旧版本」的字节稳定（见 `effective_version`），
/// 所以一个没有流式记录的 v1 文件过一次手仍然自称 v1。
/// 迁移是**显式动作**，只有这里才会把声明版本提上去。
///
/// 两条边界：
///
/// - 入参不被修改，返回新值；调用方负责写到**新文件**，绝不原地覆盖
///   （不变量 3：绝不静默改写旧文件）；
/// - 万一拿到一个本读端不认识的**更高**版本（手工构造的 `Cassette`），
///   原样保留。把未知内容标成已知版本写出去，才是真正的破坏。
pub fn migrate(cassette : @core.Cassette) -> @core.Cassette {
  let version = if cassette.version > @core.cassette_format_version {
    cassette.version
  } else {
    @core.cassette_format_version
  }
  {
    version,
    meta: {
      name: cassette.meta.name,
      generator: @core.generator_id,
      recorded_at: cassette.meta.recorded_at,
    },
    interactions: cassette.interactions,
  }
}

///|
/// 迁移会改动什么 —— 供 CLI 打印变更摘要，也供测试断言。
///
/// 单独成一个函数而不是让调用方自己比对，是因为「变更摘要」的输出
/// 必须可复现：两个字段的取值口径只在这里定义一次。
pub(all) struct MigrationDiff {
  from_version : Int
  to_version : Int
  from_generator : String
  to_generator : String
} derive(Eq)

///|
/// 计算迁移前后的差异（不修改入参）。
pub fn migration_diff(cassette : @core.Cassette) -> MigrationDiff {
  let migrated = migrate(cassette)
  {
    from_version: cassette.version,
    to_version: migrated.version,
    from_generator: cassette.meta.generator,
    to_generator: migrated.meta.generator,
  }
}

///|
/// 迁移是否什么也没改 —— 已经是最新格式且 `generator` 已是本次构建时为真。
pub fn MigrationDiff::is_noop(self : MigrationDiff) -> Bool {
  self.from_version == self.to_version &&
  self.from_generator == self.to_generator
}
