// mooncassette/core —— 脚本化应答的共享取值策略。
//
// 为什么放在 `core` 而不是各自的包里：`MockTransport`（`recorder`）与
// `ScriptedHttpSender`（`providers`）都要回答同一个问题——「同一个请求被
// 调用多次时，依次给什么」。这条策略只能有一份实现：两实现必然漂移，
// 而漂移的后果是「测试里通过、示例里不通过」这类极难排查的不一致。

///|
/// 一个请求对应的应答序列。
///
/// 取值规则：**按登记顺序依次给出；序列用完之后重复最后一个**。
///
/// 为什么是「重复最后一个」而不是「用完报错」：
///
/// - 同一个请求被反复调用是常态（服务端重试、循环里重复提问、多轮对话里
///   相同的前缀），报错会把正常用法变成障碍；
/// - 「调用次数超出预期」应当由 `call_count` 断言来管。让测试替身去决定它，
///   等于把一条业务断言藏进了替身内部，失败信息反而更难懂。
///
/// 与之配套的是「重试后成功」这类序列（例如先 429 再 200）：它让**重试路径
/// 本身**也能被离线回归，而不只是被测试到「最终成功」。
/// 字段是 `priv` 的：`next` 若可被外部写成负数，`take()` 就会用负下标取数组，
/// 那是越界崩溃而不是「行为不同」。取值状态是本类型的全部内容，因此由它自己管。
pub struct ScriptedReplies[T] {
  priv replies : Array[T]
  priv mut next : Int
}

///|
/// 构造一个应答序列。
pub fn[T] ScriptedReplies::new(replies : Array[T]) -> ScriptedReplies[T] {
  { replies, next: 0 }
}

///|
/// 追加一个应答。
pub fn[T] ScriptedReplies::push(self : ScriptedReplies[T], reply : T) -> Unit {
  self.replies.push(reply)
}

///|
/// 取下一个应答；序列为空时返回 `None`。
pub fn[T] ScriptedReplies::take(self : ScriptedReplies[T]) -> T? {
  let total = self.replies.length()
  if total == 0 {
    return None
  }
  let index = if self.next < total { self.next } else { total - 1 }
  // 停在最后一个上：计数器不无限增长，语义也更明确。
  if self.next < total {
    self.next = self.next + 1
  }
  Some(self.replies[index])
}

///|
/// 已经被取走的应答个数。
pub fn[T] ScriptedReplies::consumed(self : ScriptedReplies[T]) -> Int {
  if self.next < self.replies.length() {
    self.next
  } else {
    self.replies.length()
  }
}

///|
/// 尚未被取走的应答个数。
pub fn[T] ScriptedReplies::remaining(self : ScriptedReplies[T]) -> Int {
  self.replies.length() - self.consumed()
}

///|
/// 是否一个应答都没剩。
pub fn[T] ScriptedReplies::is_spent(self : ScriptedReplies[T]) -> Bool {
  self.remaining() == 0
}
