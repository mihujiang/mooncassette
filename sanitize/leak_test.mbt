// mooncassette/sanitize —— 脱敏不泄漏（性质测试）。
//
// 这里断言的是一个**性质**而不是若干例子：无论密钥被埋在什么形状、哪一层、
// 以什么包装形式出现，序列化结果里都不允许出现它。
//
// 两个刻意的做法：
//
// 1. **用确定性伪随机（LCG）而不是真随机。** 性质测试一旦偶发失败就成了噪声；
//    固定种子保证失败必然可复现。
// 2. **同时守卫「测试自己是否有效」。** 若生成器没埋进密钥，断言会平凡成立，
//    所以循环结束时统计「确实埋了的次数」，太少就直接报错。

///|
/// 一个很小的线性同余发生器：确定性、可复现。
struct Rng {
  mut state : UInt64
}

///|
fn Rng::new(seed : UInt64) -> Rng {
  { state: seed, }
}

///|
/// 取 `[0, bound)` 内的下一个值。
fn Rng::next(self : Rng, bound : Int) -> Int {
  // Numerical Recipes 的常数；取高位输出，避开低位周期性。
  self.state = self.state * 6364136223846793005 + 1442695040888963407
  let raw = (self.state >> 33).to_int()
  let positive = if raw < 0 { -raw } else { raw }
  positive % bound
}

///|
/// 被埋进去的密钥。形状必须满足默认策略的子串扫描（`sk-` 后接 8 位以上）。
let planted_secret : String = "sk-abcdefghijklmnop"

///|
/// 密钥可能被包装成的几种形式 —— 后两种用来验证「子串级」扫描，
/// 而不只是「整个值恰好等于密钥」。
fn wrap_secret(rng : Rng) -> String {
  match rng.next(3) {
    0 => planted_secret
    1 => "Bearer " + planted_secret
    _ => "prefix: " + planted_secret + " :suffix"
  }
}

///|
/// 键名池：既有必然命中的敏感键，也有**不该**被误伤的计数字段与普通键。
fn key_at(rng : Rng) -> String {
  let pool : Array[String] = [
    "authorization",
    "x-api-key",
    "api_key",
    "secret_key",
    "access_token",
    "password",
    "max_tokens",
    "total_tokens",
    "content",
    "messages",
    "note",
    "data",
  ]
  pool[rng.next(pool.length())]
}

///|
/// 随机生成一个 JSON 结构，随机决定是否在叶子处埋入密钥。
fn random_json(rng : Rng, depth : Int) -> Json {
  if depth <= 0 {
    return random_leaf(rng)
  }
  match rng.next(4) {
    0 => {
      // 对象：1–4 个键，键名从池中取（可能重复，后写覆盖前者，无妨）。
      let fields : Map[String, Json] = Map([])
      let count = 1 + rng.next(4)
      for i = 0; i < count; i = i + 1 {
        fields.set(key_at(rng), random_json(rng, depth - 1))
      }
      Json::object(fields)
    }
    1 => {
      // 数组：1–4 个元素。
      let items : Array[Json] = []
      let count = 1 + rng.next(4)
      for i = 0; i < count; i = i + 1 {
        items.push(random_json(rng, depth - 1))
      }
      Json::array(items)
    }
    _ => random_leaf(rng)
  }
}

///|
/// 叶子值：三分之一的机会埋入密钥。
fn random_leaf(rng : Rng) -> Json {
  match rng.next(6) {
    0 =>
      // 数字型叶子：用来检查计数字段是否被误伤。
      Json::number((rng.next(100000)).to_double())
    1 => Json::boolean(rng.next(2) == 0)
    2 => Json::null()
    3 => Json::string("ordinary text")
    _ => Json::string(wrap_secret(rng))
  }
}

///|
test "a planted secret never survives sanitization" {
  let policy = @sanitize.SanitizePolicy::default()
  let mut planted = 0
  let leaks : Array[String] = []
  for seed = 0; seed < 300; seed = seed + 1 {
    let rng : Rng = Rng::new(seed.to_uint64())
    let structure = random_json(rng, 1 + rng.next(4))
    let before = @canon.to_canonical_string(structure)
    if before.contains(planted_secret) {
      planted = planted + 1
      let after = @canon.to_canonical_string(
        @sanitize.sanitize_json(structure, policy),
      )
      if after.contains(planted_secret) {
        leaks.push("seed " + seed.to_string() + ": " + after)
      }
    }
  }
  // 守卫：如果生成器几乎没埋进密钥，下面那条断言就是平凡成立的。
  if planted < 100 {
    fail(
      "the generator only planted the secret " +
      planted.to_string() +
      " time(s); the property below would pass vacuously",
    )
  }
  if leaks.length() > 0 {
    fail(
      "secret survived sanitization in " +
      leaks.length().to_string() +
      " case(s); first: " +
      leaks[0],
    )
  }
}

///|
test "sanitization is idempotent" {
  // 脱敏两次必须与一次相同；否则「先脱敏再落盘」在往返一次之后会继续变形。
  let policy = @sanitize.SanitizePolicy::default()
  for seed = 0; seed < 100; seed = seed + 1 {
    let rng : Rng = Rng::new(seed.to_uint64())
    let structure = random_json(rng, 1 + rng.next(3))
    let once = @canon.to_canonical_string(
      @sanitize.sanitize_json(structure, policy),
    )
    let twice = @canon.to_canonical_string(
      @sanitize.sanitize_json(
        @sanitize.sanitize_json(structure, policy),
        policy,
      ),
    )
    if once != twice {
      fail("sanitization is not idempotent at seed " + seed.to_string())
    }
  }
}

///|
test "token counting fields are not damaged by the shape scan" {
  // `max_tokens` / `total_tokens` 是计数字段而不是密钥。误伤它们会让 cassette
  // 失去可读性，而且这种「宁杀错」的脱敏最难被发现 —— 因为看不出少了什么。
  let structure = @json.parse(
    "{\"max_tokens\":1024,\"total_tokens\":9999,\"access_token\":\"s\",\"note\":\"keep me\"}",
  )
  let out = @canon.to_canonical_string(
    @sanitize.sanitize_json(
      structure,
      @sanitize.SanitizePolicy::default(),
    ),
  )
  assert_true(out.contains("1024"))
  assert_true(out.contains("9999"))
  assert_true(out.contains("keep me"))
  assert_false(out.contains("\"s\""))
}

///|
test "numbers and booleans are never rewritten" {
  // 形状扫描只应作用于字符串；把 `123` 或 `true` 改掉是明显的错。
  let structure = @json.parse("{\"a\":123,\"b\":true,\"c\":null}")
  let out = @canon.to_canonical_string(
    @sanitize.sanitize_json(
      structure,
      @sanitize.SanitizePolicy::default(),
    ),
  )
  assert_eq(out, "{\"a\":123,\"b\":true,\"c\":null}")
}
