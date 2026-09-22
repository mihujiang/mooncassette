// mooncassette/maintain 的黑盒测试：只用包的公开 API。
//
// 夹具刻意用「请求体 = 一个标记字符串」：既保证每条记录的请求指纹互不相同，
// 又能让断言里直接看到顺序（`markers(...)` 返回 "a,b,c" 这样的串）。
//
// 注意 Json 的写法：构造用 `Json::string(...)`，匹配用不带前缀的 `String(...)`
// —— 与 `sanitize/sanitize.mbt` 保持一致（`Json::String(...)` 这种构造写法
// 在当前工具链下会被编译器拒绝）。

///|
fn marker_request(marker : String) -> @core.Request {
  @core.Request::new("openai", "gpt-4o", Json::string(marker))
}

///|
fn record_with(
  marker : String,
  reply : String,
  status : Int,
) -> @core.Interaction {
  @core.Interaction::new(
    marker_request(marker),
    @core.Response::new(status, Json::string(reply)),
  )
}

///|
fn hit(marker : String) -> @core.Interaction {
  @core.Interaction::new(
    marker_request(marker),
    @core.Response::new(
      200,
      Json::string("reply:" + marker),
      usage=@core.Usage::new(3, 1),
    ),
  )
}

///|
fn streamed_hit(marker : String) -> @core.Interaction {
  @core.Interaction::new(
    marker_request(marker),
    @core.Response::new(200, Json::string("reply:" + marker), stream=[
      @core.StreamFrame::new("data: [DONE]"),
    ]),
  )
}

///|
fn fixture() -> @core.Cassette {
  @core.Cassette::new("demo", interactions=[hit("a"), hit("b"), hit("c")])
}

///|
/// 直接构造一份 v1：`Cassette` 是 `pub(all)`，从别的包也能写字段字面量。
/// 这是测试「迁移」时唯一能造出旧版本的办法 —— 公开构造子只会给当前版本。
fn legacy(interactions : Array[@core.Interaction]) -> @core.Cassette {
  {
    version: 1,
    meta: {
      name: "legacy",
      generator: "mooncassette/0.1.0",
      recorded_at: Some("2026-01-01T00:00:00Z"),
    },
    interactions,
  }
}

///|
fn markers(cassette : @core.Cassette) -> String {
  let mut text = ""
  for item in cassette.interactions {
    if text != "" {
      text = text + ","
    }
    match item.request.body {
      String(marker) => text = text + marker
      _ => text = text + "?"
    }
  }
  text
}

///|
fn parsed(text : String) -> @maintain.Keep raise {
  match @maintain.Keep::parse(text) {
    Ok(keep) => keep
    Err(message) => fail(message)
  }
}

///|
fn refusal(text : String) -> String raise {
  match @maintain.Keep::parse(text) {
    Ok(keep) =>
      fail("expected \"" + text + "\" to be rejected, got " + keep.describe())
    Err(message) => message
  }
}

// ---------------------------------------------------------------------------
// --keep 的策略串
// ---------------------------------------------------------------------------

///|
test "keep spec: bare forms" {
  assert_true(parsed("all") == @maintain.All)
  assert_true(parsed("stream") == @maintain.Streamed)
  assert_true(parsed("non-stream") == @maintain.NonStreamed)
  // 从 shell 传参时前后带空白很常见，容忍掉。
  assert_true(parsed("  last:2 ") == @maintain.Last(2))
}

///|
test "keep spec: numeric and label forms" {
  assert_true(parsed("first:0") == @maintain.First(0))
  assert_true(parsed("first:12") == @maintain.First(12))
  assert_true(parsed("last:3") == @maintain.Last(3))
  assert_true(parsed("index:0,2,5") == @maintain.Indices([0, 2, 5]))
  assert_true(parsed("model:gpt-4o") == @maintain.Model("gpt-4o"))
  assert_true(parsed("provider:openai") == @maintain.Provider("openai"))
  assert_true(parsed("status:429") == @maintain.Status(429))
}

///|
test "keep spec: unusable input is refused with a hint" {
  let bad_specs : Array[String] = [
    "", "  ", "everything", "first", "first:", "first:abc", "first:-1", "last:-2",
    "index:", "index:0,,2", "index:1,x", "status:-1", "model:", "provider:", "streams",
  ]
  for bad in bad_specs {
    let message = refusal(bad)
    assert_true(message.contains("--keep"))
    assert_true(message.contains("first:"))
  }
}

///|
test "keep spec: describe round-trips through parse" {
  let all : Array[@maintain.Keep] = [
    @maintain.All,
    @maintain.First(4),
    @maintain.Last(2),
    @maintain.Indices([1]),
    @maintain.Indices([0, 3, 9]),
    @maintain.Model("claude-3"),
    @maintain.Provider("anthropic"),
    @maintain.Status(500),
    @maintain.Streamed,
    @maintain.NonStreamed,
  ]
  for keep in all {
    assert_true(parsed(keep.describe()) == keep)
  }
}

// ---------------------------------------------------------------------------
// trim
// ---------------------------------------------------------------------------

///|
test "trim: first / last keep a contiguous window" {
  let source = fixture()
  assert_eq(markers(@maintain.trim(source, @maintain.First(2))), "a,b")
  assert_eq(markers(@maintain.trim(source, @maintain.Last(2))), "b,c")
  assert_eq(markers(@maintain.trim(source, @maintain.All)), "a,b,c")
  // 越界不是错误：要 10 条只有 3 条就给 3 条。
  assert_eq(markers(@maintain.trim(source, @maintain.First(10))), "a,b,c")
  // 0 与负数都退化成「一条不留」，不会反过来变成「全留」。
  assert_eq(markers(@maintain.trim(source, @maintain.First(0))), "")
  assert_eq(markers(@maintain.trim(source, @maintain.Last(0))), "")
}

///|
test "trim: indices come out in recording order, out-of-range silently skipped" {
  let source = fixture()
  assert_eq(markers(@maintain.trim(source, @maintain.Indices([2, 0]))), "a,c")
  assert_eq(markers(@maintain.trim(source, @maintain.Indices([7]))), "")
}

///|
test "trim: provider / model / status selectors" {
  let source = @core.Cassette::new("mixed", interactions=[
    record_with("a", "ok", 200),
    @core.Interaction::new(
      @core.Request::new("anthropic", "claude-3", Json::string("b")),
      @core.Response::new(429, Json::string("slow down")),
    ),
    streamed_hit("c"),
  ])
  assert_eq(
    markers(@maintain.trim(source, @maintain.Provider("openai"))),
    "a,c",
  )
  assert_eq(markers(@maintain.trim(source, @maintain.Model("claude-3"))), "b")
  assert_eq(markers(@maintain.trim(source, @maintain.Status(429))), "b")
  assert_eq(markers(@maintain.trim(source, @maintain.Streamed)), "c")
  assert_eq(markers(@maintain.trim(source, @maintain.NonStreamed)), "a,b")
}

///|
test "trim: never mutates the input and keeps the declared version" {
  let source = legacy([hit("a"), hit("b")])
  let trimmed = @maintain.trim(source, @maintain.First(1))
  assert_eq(markers(source), "a,b")
  assert_eq(markers(trimmed), "a")
  // 裁剪只减内容，不可能需要更高的格式版本，所以版本原样保留。
  assert_eq(trimmed.version, 1)
  assert_eq(trimmed.meta.name, "legacy")
}

// ---------------------------------------------------------------------------
// merge
// ---------------------------------------------------------------------------

///|
test "merge: identical records are collapsed, order is source order" {
  let left = @core.Cassette::new("left", interactions=[hit("a"), hit("b")])
  let right = @core.Cassette::new("right", interactions=[hit("b"), hit("c")])
  let outcome = @maintain.merge([left, right], policy=@maintain.KeepFirst)
  assert_eq(markers(outcome.cassette), "a,b,c")
  assert_eq(outcome.sources, 2)
  assert_eq(outcome.kept, 3)
  assert_eq(outcome.duplicates, 1)
  assert_eq(outcome.conflicts, 0)
  // meta 取第一份来源，保留出处。
  assert_eq(outcome.cassette.meta.name, "left")
}

///|
test "merge: conflict policies each behave as documented" {
  let left = @core.Cassette::new("left", interactions=[
    record_with("a", "first answer", 200),
  ])
  let right = @core.Cassette::new("right", interactions=[
    record_with("a", "second answer", 200),
  ])
  let first = @maintain.merge([left, right], policy=@maintain.KeepFirst)
  assert_eq(markers(first.cassette), "a")
  assert_eq(first.conflicts, 1)
  assert_eq(first.kept, 1)
  assert_true(
    first.cassette.interactions[0].response.body == Json::string("first answer"),
  )

  let last = @maintain.merge([left, right], policy=@maintain.KeepLast)
  assert_eq(markers(last.cassette), "a")
  assert_eq(last.conflicts, 1)
  // KeepLast 是「原地替换」：位置不变，内容换成后来者。
  assert_true(
    last.cassette.interactions[0].response.body == Json::string("second answer"),
  )

  let both = @maintain.merge([left, right], policy=@maintain.KeepBoth)
  assert_eq(markers(both.cassette), "a,a")
  assert_eq(both.conflicts, 1)
  assert_eq(both.kept, 2)
  assert_eq(both.duplicates, 0)
}

///|
test "merge: repeated collisions stay counted and stable" {
  let a = @core.Cassette::new("a", interactions=[record_with("x", "1", 200)])
  let b = @core.Cassette::new("b", interactions=[record_with("x", "2", 200)])
  let c = @core.Cassette::new("c", interactions=[record_with("x", "1", 200)])
  // KeepFirst：三条同指纹、两种内容，只留最早的那条；同内容的后到者算重复。
  let first = @maintain.merge([a, b, c], policy=@maintain.KeepFirst)
  assert_eq(first.kept, 1)
  assert_eq(first.conflicts, 1)
  assert_eq(first.duplicates, 1)
  assert_true(first.cassette.interactions[0].response.body == Json::string("1"))
  // 同一组输入必然给出同一份输出。
  let again = @maintain.merge([a, b, c], policy=@maintain.KeepFirst)
  assert_true(again.cassette == first.cassette)
}

///|
test "merge: version is the max of sources, and streamed content wins" {
  let old = legacy([hit("a")])
  let recent = @core.Cassette::new("recent", interactions=[hit("b")])
  let merged = @maintain.merge([old, recent], policy=@maintain.KeepFirst)
  assert_eq(merged.cassette.version, 2)
  // 两个 v1 且都没有流式：合并结果仍然是 v1，不该被悄悄升版。
  let older = @maintain.merge(
    [old, legacy([hit("c")])],
    policy=@maintain.KeepFirst,
  )
  assert_eq(older.cassette.version, 1)
}

///|
test "merge: empty source list yields an empty, named cassette" {
  let merged = @maintain.merge([], policy=@maintain.KeepBoth)
  assert_eq(merged.sources, 0)
  assert_eq(merged.kept, 0)
  assert_eq(markers(merged.cassette), "")
  assert_eq(merged.cassette.version, @core.cassette_format_version)
}

// ---------------------------------------------------------------------------
// migrate
// ---------------------------------------------------------------------------

///|
test "migrate: v1 becomes current and the generator is refreshed" {
  let old = legacy([hit("a")])
  assert_eq(old.version, 1)
  let migrated = @maintain.migrate(old)
  assert_eq(migrated.version, @core.cassette_format_version)
  assert_eq(migrated.meta.generator, @core.generator_id)
  // 名字与录制时间属于出处，必须原样留着。
  assert_eq(migrated.meta.name, "legacy")
  assert_true(migrated.meta.recorded_at == Some("2026-01-01T00:00:00Z"))
  assert_eq(markers(migrated), "a")
  // 入参不动。
  assert_eq(old.version, 1)
  assert_eq(old.meta.generator, "mooncassette/0.1.0")
}

///|
test "migrate: diff reports the change, and is_noop when nothing changes" {
  let diff = @maintain.migration_diff(legacy([hit("a")]))
  assert_eq(diff.from_version, 1)
  assert_eq(diff.to_version, @core.cassette_format_version)
  assert_eq(diff.from_generator, "mooncassette/0.1.0")
  assert_eq(diff.to_generator, @core.generator_id)
  assert_false(diff.is_noop())

  let current = @core.Cassette::new("fresh", interactions=[hit("a")])
  assert_true(@maintain.migration_diff(current).is_noop())
}

///|
test "migrate: an unknown higher version is never downgraded" {
  let future : @core.Cassette = {
    version: 99,
    meta: {
      name: "from-the-future",
      generator: "mooncassette/9.9.9",
      recorded_at: None,
    },
    interactions: [hit("a")],
  }
  let migrated = @maintain.migrate(future)
  assert_eq(migrated.version, 99)
  // 版本没被改，但 generator 仍然记成「这份文件由本次构建重新写出」。
  assert_eq(migrated.meta.generator, @core.generator_id)
}

///|
test "migrate: output survives an encode/decode round trip" {
  let old = legacy([hit("a"), streamed_hit("b")])
  let migrated = @maintain.migrate(old)
  let text = @codec.encode(migrated, indent=0)
  let again = @codec.decode(text) catch { _ => return fail("decode failed") }
  assert_eq(again.version, @core.cassette_format_version)
  assert_eq(again.meta.generator, @core.generator_id)
  assert_true(again == migrated)
}

///|
test "migrate: re-encoding a legacy file without migrating keeps it v1" {
  // 这条是「不变量 3」的护栏：只解码再编码不允许静默改版本。
  // 迁移必须由 `migrate` 显式完成，两者行为不同才算把这件事做对了。
  let old = legacy([hit("a")])
  let text = @codec.encode(old, indent=0)
  let again = @codec.decode(text) catch { _ => return fail("decode failed") }
  assert_eq(again.version, 1)
}

// ---------------------------------------------------------------------------
// stats
// ---------------------------------------------------------------------------

///|
fn bucket_labels(buckets : Array[@maintain.Bucket]) -> String {
  let mut text = ""
  for bucket in buckets {
    if text != "" {
      text = text + "|"
    }
    text = text + bucket.label + ":" + bucket.records.to_string()
  }
  text
}

///|
fn model_labels(rows : Array[@maintain.ModelStat]) -> String {
  let mut text = ""
  for row in rows {
    if text != "" {
      text = text + "|"
    }
    text = text + row.model + ":" + row.records.to_string()
  }
  text
}

///|
test "stats: counts, tokens, and the unreported bucket" {
  let source = @core.Cassette::new("mixed", interactions=[
    hit("a"),
    hit("b"),
    record_with("c", "no usage", 200),
    streamed_hit("d"),
    @core.Interaction::new(
      @core.Request::new("anthropic", "claude-3", Json::string("e")),
      @core.Response::new(503, Json::string("down")),
    ),
  ])
  let report = @maintain.stats([source])
  assert_eq(report.cassettes, 1)
  assert_eq(report.interactions, 5)
  assert_eq(report.streamed, 1)
  assert_eq(report.frames, 1)
  assert_eq(report.failing, 1)
  // 两条 hit 各上报了 (3, 1)。
  assert_eq(report.input_tokens, 6)
  assert_eq(report.output_tokens, 2)
  assert_eq(report.reported(), 2)
  // 另外三条没有 usage —— 是「不知道」，不是 0。
  assert_eq(report.unreported(), 3)
  assert_eq(bucket_labels(report.providers), "openai:4|anthropic:1")
  assert_eq(bucket_labels(report.statuses), "200:4|503:1")
  assert_eq(model_labels(report.models), "gpt-4o:4|claude-3:1")
  assert_eq(bucket_labels(report.versions), "2:1")
}

///|
test "stats: sorting is by count desc then label asc, and reproducible" {
  let source = @core.Cassette::new("order", interactions=[
    @core.Interaction::new(
      @core.Request::new("zeta", "m", Json::string("1")),
      @core.Response::new(200, Json::null()),
    ),
    @core.Interaction::new(
      @core.Request::new("alpha", "m", Json::string("2")),
      @core.Response::new(200, Json::null()),
    ),
    @core.Interaction::new(
      @core.Request::new("alpha", "m", Json::string("3")),
      @core.Response::new(200, Json::null()),
    ),
  ])
  let report = @maintain.stats([source])
  // alpha 2 条在前（条数多），zeta 1 条在后；条数相同才比标签。
  assert_eq(bucket_labels(report.providers), "alpha:2|zeta:1")
  assert_true(@maintain.stats([source]) == report)
}

///|
test "stats: several cassettes add up, ratios are finite" {
  let left = @core.Cassette::new("left", interactions=[
    hit("a"),
    streamed_hit("b"),
  ])
  let right = legacy([hit("c")])
  let report = @maintain.stats([left, right])
  assert_eq(report.cassettes, 2)
  assert_eq(report.interactions, 3)
  assert_eq(report.streamed, 1)
  assert_eq(report.stream_ratio(), 1.0 / 3.0)
  // 条数相同（各 1 份）时按标签码点序升序，所以 "1" 在前。
  assert_eq(bucket_labels(report.versions), "1:1|2:1")

  let empty = @maintain.stats([])
  assert_eq(empty.interactions, 0)
  // 空输入给 0.0 而不是 NaN：NaN 会让「输出可复现」这条要求当场失效。
  assert_eq(empty.stream_ratio(), 0.0)
}
