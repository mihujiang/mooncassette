// mooncassette/stream —— 解析器健壮性（模糊测试）。
//
// 解析器面对的是**外部输入**：任何一段字节都可能被当成事件流喂进来。这里用
// 两类输入逼它：
//
// 1. 手工构造的对抗语料（重复终止符、孤立冒号、超长行、非 ASCII、截断、BOM）；
// 2. 确定性伪随机字符串，字母表刻意偏向 SSE 里有语法含义的字符。
//
// 断言两件事：**不崩**（越界访问在 MoonBit 里会直接中止，所以「跑通」本身就是
// 断言），以及 `render ∘ parse` 幂等（解析再渲染再解析，必须收敛）。

///|
/// 确定性伪随机（LCG）。用固定种子，失败可复现。
struct FuzzRng {
  mut state : UInt64
}

///|
fn FuzzRng::new(seed : UInt64) -> FuzzRng {
  { state: seed }
}

///|
fn FuzzRng::next(self : FuzzRng, bound : Int) -> Int {
  self.state = self.state * 6364136223846793005 + 1442695040888963407
  let raw = (self.state >> 33).to_int()
  let positive = if raw < 0 { -raw } else { raw }
  positive % bound
}

///|
/// 随机字符串的字母表：全是 SSE 里有语法含义或边界意义的字符。
fn fuzz_alphabet() -> Array[String] {
  [
    "data", "event", "id", "retry", ":", " ", "\n", "\r", "\r\n", "[DONE]", "{",
    "}", "\"", "你", "\u{FEFF}", "x",
  ]
}

///|
/// 生成一段随机文本。
fn random_event_stream(rng : FuzzRng, pieces : Int) -> String {
  let alphabet = fuzz_alphabet()
  let sb = StringBuilder::new()
  for p = 0; p < pieces; p = p + 1 {
    sb.write_string(alphabet[rng.next(alphabet.length())])
  }
  sb.to_string()
}

///|
/// 断言「不崩 + 幂等」。
///
/// 幂等用 `render` 比较而不是直接比较帧数组：`StreamFrame` 不派生 `Show`，
/// 而渲染文本恰好把「事件名 + 数据顺序 + 分帧边界」全部编码进去了。
fn assert_parses_cleanly(input : String) -> Unit raise {
  let once = @stream.render(@stream.parse(input))
  let twice = @stream.render(@stream.parse(once))
  if once != twice {
    fail("parse/render is not idempotent for input: " + input)
  }
}

///|
test "adversarial corpus parses without crashing" {
  let corpus : Array[String] = [
    "", "\n", "\n\n\n", "\r", "\r\r\r\r", "\r\n\r\n\r\n", "::::", ":\n:\r\n:\r",
    "data", "data\n\n", "data:\n\n", "data: \n\n", "data:\r\n\r\n", "data: x", "data: x\n",
    "event:\ndata:\n\n", "data\r\n", "data\n", "\u{FEFF}data: x\n\n", "\u{FEFF}\u{FEFF}data: x\n\n",
    "data: 你好，世界 🌍\n\n", "event: 中文事件\ndata: {}\n\n", "data: [DONE]\n\n",
    "a\nb\nc\n\n", "data: {\"a\":1}\r\ndata: {\"b\":2}\r\n\r\n", "data: one\n\n\ndata: two\n\n",
  ]
  for input in corpus {
    assert_parses_cleanly(input)
  }
}

///|
test "a very long line does not break the parser" {
  let sb = StringBuilder::new()
  sb.write_string("data: ")
  for n = 0; n < 5000; n = n + 1 {
    sb.write_string("x")
  }
  sb.write_string("\n\n")
  let frames = @stream.parse(sb.to_string())
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data.length(), 5000)
}

///|
test "random inputs never crash and always converge" {
  for seed = 0; seed < 400; seed = seed + 1 {
    let rng : FuzzRng = FuzzRng::new(seed.to_uint64())
    let pieces = rng.next(24)
    assert_parses_cleanly(random_event_stream(rng, pieces))
  }
}

///|
test "random inputs biased towards well-formed frames stay well-formed" {
  // 这一组刻意生成「大半是合法的」输入：解析器在正常输入上的行为也要被随机
  // 覆盖，而不只是畸形输入。
  for seed = 0; seed < 200; seed = seed + 1 {
    let rng : FuzzRng = FuzzRng::new(seed.to_uint64())
    let sb = StringBuilder::new()
    let frames = 1 + rng.next(5)
    for f = 0; f < frames; f = f + 1 {
      if rng.next(2) == 0 {
        sb.write_string("event: e" + rng.next(10).to_string() + "\n")
      }
      let lines = 1 + rng.next(3)
      for l = 0; l < lines; l = l + 1 {
        sb.write_string("data: payload" + rng.next(100).to_string() + "\n")
      }
      sb.write_string("\n")
    }
    let text = sb.to_string()
    let parsed = @stream.parse(text)
    assert_eq(parsed.length(), frames)
    assert_parses_cleanly(text)
  }
}
