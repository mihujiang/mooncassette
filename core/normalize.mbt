// mooncassette/core —— 请求规范化。
//
// 规范化只做一件事：**剔除不影响语义、但每次调用都可能变化的字段**。
// 刻意的设计取舍：
// - 不在这里排序对象键。键序归一由 `@canon` 的规范文本负责，
//   这样规范化是幂等的，且与「如何序列化」解耦。
// - 不做模糊匹配。模糊/子集匹配是 `@matcher` 的职责，属于「策略」而非「规范化」。

///|
/// 默认剔除的易变字段名。
///
/// 这些字段在真实 API 请求中经常变化，却不影响语义；
/// 若它们参与指纹，回放将永远无法命中。
pub let default_drop_keys : Array[String] = [
  "request_id", "requestId", "stream_id", "timestamp", "created", "created_at", "nonce",
]

///|
/// 递归剔除对象中的指定键。
///
/// 数组元素会被逐项处理；标量原样返回。
pub fn prune_json(value : Json, drop_keys : ArrayView[String]) -> Json {
  match value {
    Object(fields) => {
      let kept : Map[String, Json] = Map([])
      for key in fields.keys() {
        if !contains_key(drop_keys, key) {
          match fields.get(key) {
            Some(child) => kept.set(key, prune_json(child, drop_keys))
            None => ()
          }
        }
      }
      Json::object(kept)
    }
    Array(items) => {
      let kept : Array[Json] = []
      for item in items {
        kept.push(prune_json(item, drop_keys))
      }
      Json::array(kept)
    }
    scalar => scalar
  }
}

///|
/// 规范化一个请求：剔除易变字段。
///
/// 未显式传入 `drop_keys` 时使用 `default_drop_keys`。
pub fn Request::normalize(
  self : Request,
  drop_keys? : ArrayView[String],
) -> Request {
  let keys = match drop_keys {
    Some(keys) => keys
    None => default_drop_keys[:]
  }
  {
    provider: self.provider,
    model: self.model,
    body: prune_json(self.body, keys),
  }
}

///|
/// 在键名列表中查找目标键（精确匹配，区分大小写）。
fn contains_key(keys : ArrayView[String], target : String) -> Bool {
  for i = 0; i < keys.length(); i = i + 1 {
    if keys[i] == target {
      return true
    }
  }
  false
}
