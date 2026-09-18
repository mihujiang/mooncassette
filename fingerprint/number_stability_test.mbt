// 数字的规范文本必须跨后端稳定。
//
// 为什么单独钉住这一件事：指纹由规范文本导出。若同一个数字在 js 与 wasm-gc 上
// 写出不同字节，指纹就会漂移，而漂移的症状是「在本机录制、在 CI 回放」时莫名
// 不命中 —— 没有报错，只有找不到记录。
//
// 为什么既有测试覆盖不到这条路径：从文件解析出来的数字自带 `repr`（原样写出），
// 只有**程序里现算出来**的数字才会走 `Double::to_string()`。
//
// 下面的期望值是两个后端分别实测得到的，逐字节一致。把它们钉在这里，是为了让
// 「小数格式变化」表现为一次显式失败：那会改变所有**程序内构造**的请求的指纹，
// 属于一次兼容性事件，应当被看见而不是被放过。

///|
test "number spelling is identical on every backend" {
  let cases : Array[(String, Double, String)] = [
    ("{\"n\":0.1}", 0.1, "fnv1a64:81f7261436e39e95"),
    ("{\"n\":1}", 1.0, "fnv1a64:a0d39112ec4e8fdb"),
    // `-0.0` 与 `0.0` 写出同一个字节序列：JSON 只有一种数字类型，无符号零无处可表。
    ("{\"n\":0}", -0.0, "fnv1a64:38b575861232bf66"),
    ("{\"n\":1e+21}", 1.0e21, "fnv1a64:41b95b1ab1778e44"),
    ("{\"n\":1e-7}", 1.0e-7, "fnv1a64:1a4a8b2eb2aac0e6"),
    // 该 Double 无法精确表示给定字面量，两个后端都收敛到同一个 17 位结果。
    (
      "{\"n\":123456789012345680}", 123456789012345678.0, "fnv1a64:dc253ed1b2618b9a",
    ),
    // 最小次正规数：格式化器的极端情况。
    ("{\"n\":5e-324}", 5.0e-324, "fnv1a64:9c5ee9b115879048"),
    ("{\"n\":0.3333333333333333}", 1.0 / 3.0, "fnv1a64:0df1e7bb21bde1ca"),
  ]
  for case in cases {
    let (expected_text, value, expected_fingerprint) = case
    let body : Map[String, Json] = Map([])
    body.set("n", Json::number(value))
    let request = @core.Request::new("openai", "gpt-4o", Json::object(body))
    assert_eq(@canon.to_canonical_string(request.body), expected_text)
    assert_eq(@fingerprint.fingerprint(request), expected_fingerprint)
  }
}
