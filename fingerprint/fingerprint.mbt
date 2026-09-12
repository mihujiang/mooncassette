// mooncassette/fingerprint —— 请求指纹。
//
// 设计要点：
// 1. 指纹由「规范化请求的规范文本」导出，因此与对象键顺序无关，
//    也与 Map 的迭代顺序无关；
// 2. 指纹只承担**索引与快速筛选**职责。最终等价性判据是规范文本全等
//    （见 `same_request`）。这样即使出现哈希碰撞，也不会产生错误匹配，
//    而是会被显式检出并报错；
// 3. 指纹带算法前缀，未来更换算法时旧 cassette 仍然可识别、可迁移。

///|
/// 指纹所用算法的标识。
pub let algorithm : String = "fnv1a64"

///|
/// 把 `provider` / `model` / `body` 组合为用于指纹计算的规范文本。
///
/// 刻意使用**对象信封**而不是字符串拼接：拼接会产生歧义
/// （`provider="ab" + model="c"` 与 `provider="a" + model="bc"` 会撞车），
/// 而对象信封配合键名可以彻底避免这类问题。
pub fn canonical_text(provider : String, model : String, body : Json) -> String {
  // 复用 `@core.request_json`，保证「匹配用的形状」与「落盘的形状」
  // 永远是同一个定义，不会日后各自漂移。
  @canon.to_canonical_string(@core.request_json(provider, model, body))
}

///|
/// 请求的规范文本。
///
/// 调用方应传入已经 `@core.Request::normalize` 过的请求。
pub fn canonical_request(request : @core.Request) -> String {
  canonical_text(request.provider, request.model, request.body)
}

///|
/// 计算请求指纹，形如 `fnv1a64:0123456789abcdef`。
pub fn fingerprint(request : @core.Request) -> String {
  algorithm +
  ":" +
  @canon.hex_u64(@canon.fnv1a64_string(canonical_request(request)))
}

///|
/// 严格判断两个请求是否等价。
///
/// 这是「两个请求是否相同」的**最终判据**：指纹相同不等于请求相同。
pub fn same_request(left : @core.Request, right : @core.Request) -> Bool {
  canonical_request(left) == canonical_request(right)
}

///|
/// 整条交互记录（请求 **与** 响应）的完整性摘要。
///
/// 与 `fingerprint` 的分工必须说清楚：
///
/// - `fingerprint` 只覆盖**请求**，用于**匹配**：回放时要拿它去
///   检索候选记录，因此它不能包含响应（那时响应还不存在）。
/// - `integrity_digest` 覆盖**整条记录**，用于**防篡改**。
///   响应内容恰恰是最容易被手工改动的地方 —— 例如为了让失败的
///   测试通过而直接改期望输出。若只校验请求，这类改动会悄无声息
///   地溜过去，测试便失去了意义。
pub fn integrity_digest(interaction : @core.Interaction) -> String {
  algorithm +
  ":" +
  @canon.hex_u64(
    @canon.fnv1a64_string(@canon.to_canonical_string(interaction.to_json())),
  )
}
