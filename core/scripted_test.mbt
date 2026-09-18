// mooncassette/core —— 脚本化应答序列的契约测试。
//
// 这条策略被两个测试替身共用，因此它的行为必须被单独钉死：
// 「按序给出、用完重复最后一个」一旦走样，两边的症状会完全不同，
// 而根因在这里。

///|
test "replies are handed out in registration order" {
  let replies : @core.ScriptedReplies[String] = @core.ScriptedReplies::new([
    "first", "second", "third",
  ])
  assert_eq(replies.take(), Some("first"))
  assert_eq(replies.take(), Some("second"))
  assert_eq(replies.take(), Some("third"))
}

///|
test "the last reply repeats once the sequence is spent" {
  // 同一个请求被反复调用是常态；用完就报错会把正常用法变成障碍。
  let replies : @core.ScriptedReplies[String] = @core.ScriptedReplies::new([
    "only",
  ])
  assert_eq(replies.take(), Some("only"))
  assert_eq(replies.take(), Some("only"))
  assert_eq(replies.take(), Some("only"))
}

///|
test "an empty sequence yields nothing" {
  let replies : @core.ScriptedReplies[String] = @core.ScriptedReplies::new([])
  assert_eq(replies.take(), None)
  assert_true(replies.is_spent())
}

///|
test "consumed and remaining track the cursor" {
  let replies : @core.ScriptedReplies[String] = @core.ScriptedReplies::new([
    "a", "b",
  ])
  assert_eq(replies.consumed(), 0)
  assert_eq(replies.remaining(), 2)
  let _ = replies.take()
  assert_eq(replies.consumed(), 1)
  assert_eq(replies.remaining(), 1)
  let _ = replies.take()
  assert_eq(replies.consumed(), 2)
  assert_eq(replies.remaining(), 0)
  assert_true(replies.is_spent())
  // 重复取不会再增加已消费数——它已经停在那里了。
  let _ = replies.take()
  assert_eq(replies.consumed(), 2)
}

///|
test "replies can be appended after construction" {
  let replies : @core.ScriptedReplies[Int] = @core.ScriptedReplies::new([1])
  replies.push(2)
  assert_eq(replies.remaining(), 2)
  assert_eq(replies.take(), Some(1))
  assert_eq(replies.take(), Some(2))
  assert_eq(replies.take(), Some(2))
}

///|
test "a two-step sequence models retry-then-succeed" {
  // 这就是速率限制场景的形状：先 429，重试后 200。
  let replies : @core.ScriptedReplies[Int] = @core.ScriptedReplies::new([
    429, 200,
  ])
  assert_eq(replies.take(), Some(429))
  assert_eq(replies.take(), Some(200))
}
