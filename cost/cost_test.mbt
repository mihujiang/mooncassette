// mooncassette/cost —— 成本核算契约测试。
//
// 重点断言两件事：**整数算术的取整方向是确定的**，以及**算不出来的部分
// 会被如实说出来**（而不是当成 0 混进总额）。

///|
fn table_with_gpt4o() -> @cost.PriceTable {
  let table = @cost.PriceTable::new()
  // 输入 $2.50 / 百万 token，输出 $10.00 / 百万 token。
  table.set("gpt-4o", @cost.Price::new(2_500_000, 10_000_000))
  table
}

///|
fn interaction(model : String, usage : @core.Usage?) -> @core.Interaction {
  @core.Interaction::new(
    @core.Request::new("openai", model, Json::null()),
    @core.Response::ok(Json::null(), usage?),
  )
}

///|
fn table_error(text : String) -> String {
  let value = @json.parse(text) catch { _ => return "<invalid json>" }
  let _ = @cost.PriceTable::of_json(value) catch {
    error => return error.to_string()
  }
  "<no error>"
}

///|
test "cost is computed from the price table" {
  let cost = @cost.estimate(
    table_with_gpt4o(),
    "gpt-4o",
    @core.Usage::new(1_000_000, 1_000_000),
  ).unwrap()
  assert_eq(cost.input, 2_500_000)
  assert_eq(cost.output, 10_000_000)
  assert_eq(cost.total(), 12_500_000)
  assert_eq(cost.render(), "$12.500000")
}

///|
test "rounding is half-up and stated explicitly" {
  // 1 token × $2.50/百万 = 2.5 微美元 → 3（四舍五入，而非截断）。
  let small = @cost.estimate(
    table_with_gpt4o(),
    "gpt-4o",
    @core.Usage::new(1, 0),
  ).unwrap()
  assert_eq(small.input, 3)
  // $1.00 / 百万 token 时，1 token 恰好是 1 微美元。
  let table = @cost.PriceTable::new()
  table.set("exact", @cost.Price::new(1_000_000, 0))
  let exact = @cost.estimate(table, "exact", @core.Usage::new(1, 0)).unwrap()
  assert_eq(exact.input, 1)
  // 0 token 一定是 0，不会因为四舍五入变成 1。
  let zero = @cost.estimate(
    table_with_gpt4o(),
    "gpt-4o",
    @core.Usage::new(0, 0),
  ).unwrap()
  assert_eq(zero.total(), 0)
}

///|
test "the same input always yields the same amount" {
  // 整数算术的意义：同一份 cassette 在任何后端、任何一次运行都报同一个金额。
  let usage = @core.Usage::new(123_457, 89_123)
  let first = @cost.estimate(table_with_gpt4o(), "gpt-4o", usage).unwrap()
  let second = @cost.estimate(table_with_gpt4o(), "gpt-4o", usage).unwrap()
  assert_eq(first.input, second.input)
  assert_eq(first.output, second.output)
}

///|
test "an unknown model reports unknown rather than free" {
  assert_true(
    @cost.estimate(
      table_with_gpt4o(),
      "mystery-model",
      @core.Usage::new(100, 100),
    )
    is None,
  )
}

///|
test "cassette rollup is explicit about what it could not price" {
  let cassette = @core.Cassette::new("demo", interactions=[
    interaction("gpt-4o", Some(@core.Usage::new(1_000_000, 0))),
    interaction("mystery-model", Some(@core.Usage::new(1_000_000, 0))),
    interaction("gpt-4o", None),
  ])
  let summary = @cost.estimate_cassette(table_with_gpt4o(), cassette)
  assert_eq(summary.priced, 1)
  assert_eq(summary.unpriced, 1)
  assert_eq(summary.no_usage, 1)
  assert_eq(summary.total.render(), "$2.500000")
  assert_eq(
    summary.render(),
    "cost=$2.500000  priced=1  unpriced=1  no_usage=1",
  )
}

///|
test "a price table can be read from json" {
  let table = @cost.PriceTable::of_json(
    @json.parse("{\"gpt-4o\":{\"input\":2500000,\"output\":10000000}}"),
  ) catch {
    _ => panic()
  }
  assert_eq(table.length(), 1)
  match table.get("gpt-4o") {
    Some(price) => {
      assert_eq(price.input, 2_500_000)
      assert_eq(price.output, 10_000_000)
    }
    None => fail("expected the model to be present")
  }
}

///|
test "a malformed price table is rejected with a path" {
  assert_true(
    table_error("{\"gpt-4o\":{\"input\":\"cheap\"}}").contains("$.gpt-4o.input"),
  )
  assert_true(
    table_error("{\"gpt-4o\":{\"input\":1}}").contains("$.gpt-4o.output"),
  )
  assert_true(table_error("[]").contains("$:"))
  // 非整数也要拒绝，避免把 1.5 悄悄取整成 1。
  assert_true(
    table_error("{\"m\":{\"input\":1.5,\"output\":1}}").contains("$.m.input"),
  )
}

///|
test "annotation keys are ignored so the file can explain its own unit" {
  // JSON 没有注释语法，而价目表最需要写清单位。
  let table = @cost.PriceTable::of_json(
    @json.parse(
      "{\"_unit\":\"micro USD per million tokens\",\"gpt-4o\":{\"input\":2500000,\"output\":10000000}}",
    ),
  ) catch {
    _ => panic()
  }
  assert_eq(table.length(), 1)
  assert_true(table.get("_unit") is None)
  assert_true(table.get("gpt-4o") is Some(_))
}

///|
test "rendering keeps a fixed number of decimals" {
  // 固定小数位而不是去掉尾零：金额要能被逐字比较。
  assert_eq(@cost.Cost::new(0, 0).render(), "$0.000000")
  assert_eq(@cost.Cost::new(1, 0).render(), "$0.000001")
  assert_eq(@cost.Cost::new(1_000_000, 0).render(), "$1.000000")
}
