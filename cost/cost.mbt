// mooncassette/cost —— 按价目表做成本核算。
//
// 两个刻意的设计选择：
//
// 1. **不内置价目表。** 模型价格变动频繁，把一张会过期的价格表编进库里，
//    等于让使用者拿到「看起来很精确、其实已经错了」的数字。这里只提供机制：
//    使用者填自己的价目表，或从 JSON 读入。
// 2. **金额用整数，不用浮点。** 单位是「微美元」，除法明确采用四舍五入，
//    行为在文档与测试里写死，避免浮点累加误差让同一份 cassette 报出不同金额。
//
// 单位约定：价格以**微美元 / 百万 token** 计。
// 例如「输入 $2.50 / 百万 token」写作 `2_500_000`。
// 于是 `花费(微美元) = token 数 × 价格 / 1_000_000`。

///|
/// 价格单位换算：每百万 token 对应的微美元数。
///
/// 金额一律用 `Int64`：MoonBit 的 `Int` 是 **32 位**，而
/// `token 数 × 价格` 轻易就越过 21 亿（1M token × $2.50/百万 = 2.5e12）。
/// 用 32 位算会静默溢出成一个看起来像模像样的错数——这类错误极难发现，
/// 因此这里的类型选择本身就是一条断言。
pub let micro_usd_per_million : Int64 = 1_000_000

///|
/// 一个模型的价格，单位是「微美元 / 百万 token」。
pub(all) struct Price {
  input : Int
  output : Int
} derive(Eq)

///|
/// 构造价格。
pub fn Price::new(input : Int, output : Int) -> Price {
  { input, output }
}

///|
/// 从 JSON 读一份价格，形状为 `{"input": 2500000, "output": 10000000}`。
pub fn Price::of_json(
  value : Json,
  path : String,
) -> Price raise @core.CassetteError {
  let fields = match value {
    Object(fields) => fields
    _ =>
      raise @core.CassetteError::SchemaViolation(
        path + ": expected an object with \"input\" and \"output\"",
      )
  }
  {
    input: required_int(fields, "input", path),
    output: required_int(fields, "output", path),
  }
}

///|
/// 价目表：模型名 → 价格。
pub(all) struct PriceTable {
  prices : Map[String, Price]
}

///|
pub fn PriceTable::new() -> PriceTable {
  { prices: Map([]) }
}

///|
/// 登记一个模型的价格；同名会覆盖。
pub fn PriceTable::set(
  self : PriceTable,
  model : String,
  price : Price,
) -> Unit {
  self.prices.set(model, price)
}

///|
/// 查询一个模型的价格。
pub fn PriceTable::get(self : PriceTable, model : String) -> Price? {
  self.prices.get(model)
}

///|
/// 已登记的模型数。
pub fn PriceTable::length(self : PriceTable) -> Int {
  self.prices.length()
}

///|
/// 从 JSON 读一张价目表：`{"模型名": {"input": …, "output": …}}`。
///
/// 以 `_` 开头的键视为**注记**并忽略。JSON 没有注释语法，而价目表恰恰最需要
/// 写清单位（微美元 / 百万 token），因此约定一个不会与模型名冲突的前缀，
/// 让配置文件自带说明。
pub fn PriceTable::of_json(
  value : Json,
) -> PriceTable raise @core.CassetteError {
  let fields = match value {
    Object(fields) => fields
    _ =>
      raise @core.CassetteError::SchemaViolation(
        "$: a price table must be a JSON object mapping model names to prices",
      )
  }
  let table = PriceTable::new()
  for model in fields.keys() {
    if !model.has_prefix("_") {
      match fields.get(model) {
        Some(price_value) =>
          table.set(model, Price::of_json(price_value, "$." + model))
        None => ()
      }
    }
  }
  table
}

///|
/// 一条记录或一份汇总的成本，单位微美元。
///
/// 用 `Int64` 而不是 `Int`：见 `micro_usd_per_million` 的说明。
pub(all) struct Cost {
  input : Int64
  output : Int64
} derive(Eq)

///|
/// 构造一个成本。
pub fn Cost::new(input : Int64, output : Int64) -> Cost {
  { input, output }
}

///|
/// 合计（输入 + 输出），单位微美元。
pub fn Cost::total(self : Cost) -> Int64 {
  self.input + self.output
}

///|
/// 渲染成美元字符串，固定 6 位小数。
///
/// 固定小数位而不是「去掉尾零」：金额要能被逐字比较与断言，
/// 长度不稳定会带来无意义的 diff。
pub fn Cost::render(self : Cost) -> String {
  render_micro_usd(self.total())
}

///|
/// 估算一次用量的成本。
///
/// 价目表里没有这个模型时返回 `None`，而不是当成 0：把「不知道价格」报成
/// 「免费」是最糟的一种错法。
pub fn estimate(
  table : PriceTable,
  model : String,
  usage : @core.Usage,
) -> Cost? {
  match table.get(model) {
    Some(price) =>
      Some({
        input: cost_of(usage.input_tokens, price.input),
        output: cost_of(usage.output_tokens, price.output),
      })
    None => None
  }
}

///|
/// 一份 cassette 的成本汇总。
pub(all) struct CassetteCost {
  total : Cost
  /// 有上报用量、且价目表里查得到模型的记录数。
  priced : Int
  /// 有上报用量、但价目表里查不到模型的记录数。
  unpriced : Int
  /// 完全没有上报用量的记录数。
  no_usage : Int
} derive(Eq)

///|
/// 汇总一份 cassette 里所有记录的用量与成本。
///
/// 三个计数与总额一起给出，是为了让「这个总额覆盖了多少条记录」可见：
/// 只给一个数字，使用者会误以为它是完整的。
pub fn estimate_cassette(
  table : PriceTable,
  cassette : @core.Cassette,
) -> CassetteCost {
  let mut total : Cost = { input: 0L, output: 0L }
  let mut priced = 0
  let mut unpriced = 0
  let mut no_usage = 0
  for item in cassette.interactions {
    match item.response.usage {
      None => no_usage = no_usage + 1
      Some(usage) =>
        match estimate(table, item.request.model, usage) {
          Some(cost) => {
            total = {
              input: total.input + cost.input,
              output: total.output + cost.output,
            }
            priced = priced + 1
          }
          None => unpriced = unpriced + 1
        }
    }
  }
  { total, priced, unpriced, no_usage }
}

///|
/// 一行汇总，便于 CLI 或测试直接断言。
pub fn CassetteCost::render(self : CassetteCost) -> String {
  "cost=" +
  self.total.render() +
  "  priced=" +
  self.priced.to_string() +
  "  unpriced=" +
  self.unpriced.to_string() +
  "  no_usage=" +
  self.no_usage.to_string()
}

///|
/// `token 数 × 价格 / 1_000_000`，四舍五入到微美元。
///
/// 加半个单位再整除即为四舍五入；除数恒为正，因此取整方向是确定的。
/// 乘法在 `Int64` 上进行，`price`（单模型单价的量级）用 `Int` 足够。
fn cost_of(tokens : Int, price : Int) -> Int64 {
  (tokens.to_int64() * price.to_int64() + micro_usd_per_million / 2) /
  micro_usd_per_million
}

///|
/// 把微美元渲染成美元字符串，固定 6 位小数。
///
/// 非负是**前置条件，而不是已校验的事实**：费率由调用方填进价目表，token 数来自
/// cassette —— 而 `Usage` 允许任意整数，解码也不拒绝负数（拒绝会让此前能加载的文件
/// 突然失败）。因此这里不做符号处理。
///
/// 后果需要说清：传入负的 token 数不会崩溃，但会渲染出没有意义的字符串
/// （`$-1.-500000` 这类，因为整除向零取整）。真要支持负值，必须同时更新这里的
/// 渲染与 `cost_of` 的取整方向。
fn render_micro_usd(value : Int64) -> String {
  let sb = StringBuilder::new()
  sb.write_string("$")
  sb.write_string((value / micro_usd_per_million).to_string())
  sb.write_string(".")
  sb.write_string((value % micro_usd_per_million).to_string().pad_start(6, '0'))
  sb.to_string()
}

///|
/// 读一个必需的整数字段。
fn required_int(
  fields : Map[String, Json],
  key : String,
  path : String,
) -> Int raise @core.CassetteError {
  match fields.get(key) {
    Some(Number(value, ..)) =>
      if value == value.to_int().to_double() {
        value.to_int()
      } else {
        raise @core.CassetteError::SchemaViolation(
          path + "." + key + ": expected an integer",
        )
      }
    Some(_) =>
      raise @core.CassetteError::SchemaViolation(
        path + "." + key + ": expected an integer",
      )
    None =>
      raise @core.CassetteError::SchemaViolation(
        path + "." + key + ": missing required field",
      )
  }
}
