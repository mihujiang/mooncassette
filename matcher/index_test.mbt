// mooncassette/matcher —— 指纹索引的契约测试。
//
// 索引是纯粹的加速手段，因此它的第一契约是「不改变任何一次查询的结果」。
// 这条契约一旦破坏，症状不是报错，而是**回放出了另一个响应** —— 静默的错误
// 结果，比崩溃难查得多。所以这里逐个策略、逐个游标地比对有索引与无索引。

///|
/// 构造一个可区分的请求。
///
/// 直接拼 JSON 对象而不是解析字面量：普通函数不能调用会抛错的 `@json.parse`，
/// 而测试辅助函数没有理由声明 `raise`。
fn index_sample(n : Int) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("n", Json::number(n.to_double()))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
fn indexed_fixture() -> Array[@core.Interaction] {
  [
    @core.Interaction::new(
      index_sample(1),
      @core.Response::ok(Json::string("one")),
    ),
    @core.Interaction::new(
      index_sample(2),
      @core.Response::ok(Json::string("two")),
    ),
    @core.Interaction::new(
      index_sample(3),
      @core.Response::ok(Json::string("three")),
    ),
  ]
}

///|
/// 用给定的索引（或不给索引）查一次，返回命中的下标；未命中或出错返回 -1。
fn index_of(
  request : @core.Request,
  interactions : Array[@core.Interaction],
  policy : @matcher.MatchPolicy,
  cursor : Int,
  index : @matcher.MatchIndex?,
) -> Int {
  let found = match index {
    Some(built) =>
      @matcher.find_match(request, interactions[:], policy, cursor, index=built)
        catch {
        _ => return -1
      }
    None =>
      @matcher.find_match(request, interactions[:], policy, cursor) catch {
        _ => return -1
      }
  }
  match found {
    Some(result) => result.index
    None => -1
  }
}

///|
test "an index never changes the answer" {
  let interactions = indexed_fixture()
  let built = @matcher.MatchIndex::build(interactions[:])
  let policies : Array[@matcher.MatchPolicy] = [
    @matcher.MatchPolicy::Exact,
    @matcher.MatchPolicy::FingerprintOnly,
  ]
  for policy in policies {
    // 游标覆盖环形的每个起点，包括越界后被折回 0 的情形。
    for cursor = 0; cursor <= 4; cursor = cursor + 1 {
      let request = index_sample(2)
      assert_eq(
        index_of(request, interactions, policy, cursor, Some(built)),
        index_of(request, interactions, policy, cursor, None),
      )
    }
  }
}

///|
test "an index does not invent matches" {
  let interactions = indexed_fixture()
  let built = @matcher.MatchIndex::build(interactions[:])
  assert_eq(
    index_of(
      index_sample(99),
      interactions,
      @matcher.MatchPolicy::Exact,
      0,
      Some(built),
    ),
    -1,
  )
  assert_eq(
    index_of(
      index_sample(99),
      interactions,
      @matcher.MatchPolicy::FingerprintOnly,
      0,
      Some(built),
    ),
    -1,
  )
}

///|
test "a subset policy gives the same answer with and without an index" {
  // 子集策略不用整请求指纹，因此索引对它应当**完全无影响**。
  let interactions = indexed_fixture()
  let built = @matcher.MatchIndex::build(interactions[:])
  let policy = @matcher.MatchPolicy::Subset(["n"])
  assert_eq(
    index_of(index_sample(3), interactions, policy, 0, Some(built)),
    index_of(index_sample(3), interactions, policy, 0, None),
  )
}

///|
test "an index stays aligned as interactions are appended" {
  // 录制过程中会不断追加记录，索引必须跟着长。错位的症状是回放指到别的
  // 记录上，因此这里既验证对齐判定，也验证追加后新记录可被匹配。
  let interactions = indexed_fixture()
  let built = @matcher.MatchIndex::build(interactions[:])
  assert_eq(built.length(), 3)
  assert_true(built.aligned_with(interactions[:]))
  let extra = @core.Interaction::new(
    index_sample(4),
    @core.Response::ok(Json::string("four")),
  )
  interactions.push(extra)
  assert_false(built.aligned_with(interactions[:]))
  built.push(extra)
  assert_true(built.aligned_with(interactions[:]))
  assert_eq(
    index_of(
      index_sample(4),
      interactions,
      @matcher.MatchPolicy::Exact,
      0,
      Some(built),
    ),
    3,
  )
}

///|
test "only fingerprint-scoped policies claim to scan by fingerprint" {
  // 这条判断决定「值不值得建索引」：写错的方向是浪费一次 O(记录数)，
  // 而不是给出错误结果，但仍然值得钉住。
  assert_true(@matcher.MatchPolicy::Exact.scans_by_fingerprint())
  assert_true(@matcher.MatchPolicy::FingerprintOnly.scans_by_fingerprint())
  assert_false(@matcher.MatchPolicy::Subset(["a"]).scans_by_fingerprint())
  assert_false(@matcher.MatchPolicy::Sequential.scans_by_fingerprint())
}

///|
test "an empty cassette yields an empty index" {
  let built = @matcher.MatchIndex::build(([] : Array[@core.Interaction])[:])
  assert_eq(built.length(), 0)
}
