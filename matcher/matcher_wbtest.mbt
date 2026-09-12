// mooncassette/matcher —— 白盒测试：覆盖包内私有工具函数。
//
// 这两个函数是回卷查找的核心算术，容易写错又不容易通过公开 API
// 精确触发边界（尤其是「游标正好越界」这类情形），因此单独直测。

///|
test "ring_index walks forward and wraps exactly once" {
  assert_eq(ring_index(0, 0, 3), 0)
  assert_eq(ring_index(0, 2, 3), 2)
  assert_eq(ring_index(1, 1, 3), 2)
  assert_eq(ring_index(2, 1, 3), 0)
  assert_eq(ring_index(2, 2, 3), 1)
}

///|
test "ring_index covers every slot exactly once per full pass" {
  let total = 5
  let seen : Array[Int] = []
  for offset = 0; offset < total; offset = offset + 1 {
    seen.push(ring_index(3, offset, total))
  }
  seen.sort()
  assert_eq(seen, [0, 1, 2, 3, 4])
}

///|
test "clamp_cursor keeps in-range cursors untouched" {
  assert_eq(clamp_cursor(0, 3), 0)
  assert_eq(clamp_cursor(2, 3), 2)
}

///|
test "clamp_cursor folds out-of-range cursors back to zero" {
  assert_eq(clamp_cursor(3, 3), 0)
  assert_eq(clamp_cursor(99, 3), 0)
  assert_eq(clamp_cursor(-1, 3), 0)
}
