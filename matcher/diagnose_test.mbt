// mooncassette/matcher —— 未命中诊断测试。
//
// 诊断的价值在于「能照着改」，所以这里断言的是**具体路径与排序**，
// 而不是「输出非空」这类空洞的检查。排序与键序都必须稳定，否则
// 同一份输入在两次运行里可能给出不同的报告。

///|
fn diagnose_interaction(
  model : String,
  body : Json,
  marker : String,
) -> @core.Interaction {
  @core.Interaction::new(
    @core.Request::new("openai", model, body),
    @core.Response::ok(Json::string(marker)),
  )
}

///|
test "diagnose pinpoints the differing field" {
  let items = [
    diagnose_interaction(
      "gpt-4o",
      @json.parse("{\"messages\":[{\"content\":\"hi\"}]}"),
      "a",
    ),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"messages\":[{\"content\":\"bye\"}]}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.total, 1)
  assert_eq(diagnosis.candidates.length(), 1)
  assert_eq(diagnosis.candidates[0].differing_paths, [
    "$.body.messages[0].content",
  ])
}

///|
test "diagnose ranks the closest candidate first" {
  // 下标 1 只差一个字段，下标 0 差两个；排序后 1 应当排在前面，
  // 否则报告会把用户引向一个更不像的候选。
  let items = [
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":9,\"b\":9}"), "far"),
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":1,\"b\":9}"), "near"),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":1,\"b\":2}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].index, 1)
  assert_eq(diagnosis.candidates[1].index, 0)
}

///|
test "diagnose keeps recording order when distances tie" {
  // 差异数量相同时必须保持录制顺序（稳定排序），这样报告可被断言。
  let items = [
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":9}"), "first"),
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":8}"), "second"),
  ]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1}"))
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].index, 0)
  assert_eq(diagnosis.candidates[1].index, 1)
}

///|
test "differing paths are sorted so the report is stable" {
  // `Map` 迭代顺序不保证稳定，若不排序，同一份输入可能产出不同的路径顺序。
  let items = [
    diagnose_interaction(
      "gpt-4o",
      @json.parse("{\"z\":1,\"a\":1,\"m\":1}"),
      "a",
    ),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"z\":2,\"a\":2,\"m\":2}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths, [
    "$.body.a", "$.body.m", "$.body.z",
  ])
}

///|
test "the diagnostic order is lexicographic, not by length" {
  // `String` 自带的比较不是字典序（实测 "model" 会排在 "api_key" 前面），
  // 所以这里用一对「按长度排与按字典序排结果相反」的键把规则钉住：
  // 字典序是 "aa" < "b"，按长度则会得到 "b" < "aa"。
  let items = [
    diagnose_interaction("gpt-4o", @json.parse("{\"b\":1,\"aa\":1}"), "a"),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"b\":2,\"aa\":2}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths, ["$.body.aa", "$.body.b"])
}

///|
test "diagnose reports fields that exist on only one side" {
  let items = [
    diagnose_interaction(
      "gpt-4o",
      @json.parse("{\"a\":1,\"dropped\":true}"),
      "a",
    ),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":1,\"added\":true}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths, [
    "$.body.added (only in the request)", "$.body.dropped (only in the recording)",
  ])
}

///|
test "diagnose reports an array length difference" {
  let items = [
    diagnose_interaction("gpt-4o", @json.parse("{\"messages\":[1,2,3]}"), "a"),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"messages\":[1,2]}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths, [
    "$.body.messages.length (3 recorded vs 2 requested)",
  ])
}

///|
test "diagnose surfaces a model mismatch as a single path" {
  // 「录的是 gpt-4o，请求写成了 gpt-4o-mini」是最常见的一类原因，
  // 报告应当把它压成一个 `$.model`，而不是铺开成一堆 body 差异。
  let items = [diagnose_interaction("gpt-4o", @json.parse("{\"a\":1}"), "a")]
  let request = @core.Request::new(
    "openai",
    "gpt-4o-mini",
    @json.parse("{\"a\":1}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths, ["$.model"])
  assert_eq(
    diagnosis.hint(),
    "the cassette has 1 interaction(s); closest is #0 (provider=openai model=gpt-4o), differing at $.model",
  )
}

///|
test "diagnose caps the number of reported paths" {
  // 一个完全不同的对象可能刷出上百条路径，噪声会盖住真正的原因。
  let items = [
    diagnose_interaction(
      "gpt-4o",
      @json.parse("{\"a\":1,\"b\":1,\"c\":1,\"d\":1,\"e\":1,\"f\":1,\"g\":1}"),
      "a",
    ),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":2,\"b\":2,\"c\":2,\"d\":2,\"e\":2,\"f\":2,\"g\":2}"),
  )
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths.length(), 5)
}

///|
test "diagnose limits the number of reported candidates" {
  let items = [
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":1}"), "a"),
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":2}"), "b"),
    diagnose_interaction("gpt-4o", @json.parse("{\"a\":3}"), "c"),
  ]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":9}"))
  let limited = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
    top=2,
  )
  assert_eq(limited.candidates.length(), 2)
  let all = @matcher.diagnose(request, items[:], @matcher.MatchPolicy::Exact, 0)
  assert_eq(all.candidates.length(), 3)
}

///|
test "diagnose reports an empty cassette without inventing candidates" {
  let request = @core.Request::new("openai", "gpt-4o", Json::null())
  let diagnosis = @matcher.diagnose(
    request,
    ([] : Array[@core.Interaction])[:],
    @matcher.MatchPolicy::Exact,
    0,
  )
  assert_eq(diagnosis.total, 0)
  assert_eq(diagnosis.candidates.length(), 0)
  assert_eq(diagnosis.hint(), "the cassette contains no interactions")
}

///|
test "diagnose renders a multi-line report" {
  let items = [diagnose_interaction("gpt-4o", @json.parse("{\"a\":1}"), "a")]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":2}"))
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Subset(["a"]),
    1,
  )
  let lines = diagnosis.lines()
  assert_eq(lines.length(), 2)
  assert_eq(lines[0], "policy=Subset  cursor=1  interactions=1")
  assert_eq(lines[1], "  #0  provider=openai  model=gpt-4o  differs: $.body.a")
}

///|
test "diagnose reports that no candidate could be compared" {
  // 请求与记录在结构上完全相同却仍未命中，只可能出现在人为放宽的
  // 匹配策略下；此时差异列表为空，报告必须说清「不是字段的问题」，
  // 而不是给出一个空列表让用户困惑。
  let items = [diagnose_interaction("gpt-4o", @json.parse("{\"a\":1}"), "a")]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1}"))
  let diagnosis = @matcher.diagnose(
    request,
    items[:],
    @matcher.MatchPolicy::Sequential,
    0,
  )
  assert_eq(diagnosis.candidates[0].differing_paths.length(), 0)
  assert_eq(
    diagnosis.hint(),
    "the cassette has 1 interaction(s); closest is #0 (provider=openai model=gpt-4o), differing at (no field-level difference; check the matching policy)",
  )
}
