// mooncassette/drift —— 漂移检测契约测试。

///|
fn interaction_of(
  model : String,
  prompt : String,
  answer : String,
) -> @core.Interaction raise {
  @core.Interaction::new(
    @core.Request::new(
      "openai",
      model,
      @json.parse(
        "{\"messages\":[{\"content\":\"" + prompt + "\",\"role\":\"user\"}]}",
      ),
    ),
    @core.Response::ok(Json::string(answer)),
  )
}

///|
fn cassette_of(items : Array[@core.Interaction]) -> @core.Cassette {
  @core.Cassette::new("demo", interactions=items)
}

///|
test "identical cassettes report no drift" {
  let old = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let new = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let report = @drift.compare(old, new)
  assert_true(report.is_clean())
  assert_eq(report.unchanged, 1)
  assert_eq(report.summary(), "no drift: 1 interaction(s) identical")
}

///|
test "a changed response is reported as drift" {
  let old = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let new = cassette_of([interaction_of("gpt-4o", "hi", "HELLO")])
  let report = @drift.compare(old, new)
  assert_false(report.is_clean())
  assert_eq(report.count_of(@drift.Changed), 1)
  assert_eq(report.count_of(@drift.Removed), 0)
  assert_eq(report.count_of(@drift.Added), 0)
  assert_eq(report.unchanged, 0)
  assert_eq(
    report.summary(),
    "drift detected: removed=0 changed=1 added=0 unchanged=0",
  )
}

///|
test "an extra call is reported as added" {
  let old = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let new = cassette_of([
    interaction_of("gpt-4o", "hi", "hello"),
    interaction_of("gpt-4o", "bye", "goodbye"),
  ])
  let report = @drift.compare(old, new)
  assert_eq(report.count_of(@drift.Added), 1)
  assert_eq(report.unchanged, 1)
  assert_eq(report.lines(), [
    "[added]   gpt-4o #1  " + short_of(new.interactions[1]),
  ])
}

///|
test "a dropped call is reported as removed" {
  let old = cassette_of([
    interaction_of("gpt-4o", "hi", "hello"),
    interaction_of("gpt-4o", "bye", "goodbye"),
  ])
  let new = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let report = @drift.compare(old, new)
  assert_eq(report.count_of(@drift.Removed), 1)
  assert_eq(report.unchanged, 1)
  assert_eq(report.lines(), [
    "[removed] gpt-4o #1  " + short_of(old.interactions[1]),
  ])
}

///|
test "changing a prompt shows up as one removal plus one addition" {
  // 刻意不猜「改后的请求对应原来哪一条」：与其误配，不如如实报告。
  let old = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let new = cassette_of([interaction_of("gpt-4o", "hello!", "hi there")])
  let report = @drift.compare(old, new)
  assert_eq(report.count_of(@drift.Removed), 1)
  assert_eq(report.count_of(@drift.Added), 1)
  assert_eq(report.count_of(@drift.Changed), 0)
  assert_eq(report.unchanged, 0)
}

///|
test "volatile fields and key order do not count as drift" {
  // 旧录制里带 request_id，新录制里键顺序不同：都不应触发漂移。
  let old = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new(
        "openai",
        "gpt-4o",
        @json.parse("{\"b\":2,\"a\":1,\"request_id\":\"x\"}"),
      ),
      @core.Response::ok(@json.parse("{\"b\":2,\"a\":1}")),
    ),
  ])
  let new = @core.Cassette::new("demo", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1,\"b\":2}")),
      @core.Response::ok(@json.parse("{\"a\":1,\"b\":2}")),
    ),
  ])
  let report = @drift.compare(old, new)
  assert_true(report.is_clean())
  assert_eq(report.unchanged, 1)
}

///|
test "repeated identical requests are paired in recording order" {
  // 第一次调用响应不变，第二次调用响应变了：应恰好报 1 条 Changed。
  let old = cassette_of([
    interaction_of("gpt-4o", "hi", "same"),
    interaction_of("gpt-4o", "hi", "before"),
  ])
  let new = cassette_of([
    interaction_of("gpt-4o", "hi", "same"),
    interaction_of("gpt-4o", "hi", "after"),
  ])
  let report = @drift.compare(old, new)
  assert_eq(report.count_of(@drift.Changed), 1)
  assert_eq(report.unchanged, 1)
  assert_eq(report.entries[0].old_index, Some(1))
  assert_eq(report.entries[0].new_index, Some(1))
}

///|
test "entries are ordered removed, then changed, then added" {
  let old = cassette_of([
    interaction_of("gpt-4o", "keep", "same"),
    interaction_of("gpt-4o", "gone", "x"),
    interaction_of("gpt-4o", "drift", "before"),
  ])
  let new = cassette_of([
    interaction_of("gpt-4o", "keep", "same"),
    interaction_of("gpt-4o", "drift", "after"),
    interaction_of("gpt-4o", "fresh", "y"),
  ])
  let report = @drift.compare(old, new)
  let lines = report.lines()
  assert_eq(lines.length(), 3)
  assert_true(lines[0].has_prefix("[removed]"))
  assert_true(lines[1].has_prefix("[changed]"))
  assert_true(lines[2].has_prefix("[added]"))
}

///|
test "model changes alone are reported as removed plus added" {
  let old = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let new = cassette_of([interaction_of("gpt-4o-mini", "hi", "hello")])
  let report = @drift.compare(old, new)
  assert_eq(report.count_of(@drift.Removed), 1)
  assert_eq(report.count_of(@drift.Added), 1)
}

///|
test "an empty recording compared against anything reports only additions" {
  let empty = @core.Cassette::new("demo")
  let full = cassette_of([interaction_of("gpt-4o", "hi", "hello")])
  let report = @drift.compare(empty, full)
  assert_eq(report.count_of(@drift.Added), 1)
  assert_eq(report.unchanged, 0)
}

///|
test "comparing two empty recordings is clean" {
  let report = @drift.compare(
    @core.Cassette::new("a"),
    @core.Cassette::new("b"),
  )
  assert_true(report.is_clean())
  assert_eq(report.summary(), "no drift: 0 interaction(s) identical")
}

///|
test "short fingerprint is eight hex characters" {
  let item = interaction_of("gpt-4o", "hi", "hello")
  let digest = short_of(item)
  assert_eq(digest.length(), 8)
  assert_true(!digest.contains(":"))
}

///|
/// 取某条交互的短指纹，用于与报告文本比对。
fn short_of(interaction : @core.Interaction) -> String {
  let full = @fingerprint.fingerprint(interaction.request)
  full.split(":").to_array()[1].to_owned()[:8].to_owned()
}
