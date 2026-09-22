///|
/// 一个「标签 → 条数」的桶。
pub(all) struct Bucket {
  label : String
  mut records : Int
} derive(Eq)

///|
/// 按模型汇总。
pub(all) struct ModelStat {
  model : String
  mut records : Int
  /// 有上报用量的条数。
  mut reported : Int
  /// 没有上报用量的条数 —— 「不知道」不等于 0，所以必须单独计。
  mut unreported : Int
  mut input_tokens : Int
  mut output_tokens : Int
} derive(Eq)

///|
/// 一批 cassette 的汇总。
///
/// 这里只统计**能从头文件算出来的东西**：体积（字节）取决于序列化方式与换行，
/// 由调用方在读文件时另行累计，不算进本结构，免得同一个数字有两个来源。
pub(all) struct Stats {
  cassettes : Int
  interactions : Int
  /// 流式条数。
  streamed : Int
  /// 帧总数（只统计流式记录的帧）。
  frames : Int
  /// HTTP 状态 >= 400 的条数。
  failing : Int
  input_tokens : Int
  output_tokens : Int
  /// 按声明版本计数，标签形如 "1" / "2"。
  versions : Array[Bucket]
  providers : Array[Bucket]
  statuses : Array[Bucket]
  models : Array[ModelStat]
} derive(Eq)

///|
/// 统计一批录制。
///
/// 所有数组都经过显式排序（条数降序、同数按标签的码点序升序），
/// 因此同一组输入在任何后端、任何进程里都会打印出同样的顺序 ——
/// 这是「输出稳定可复现」在实现上的落点。
pub fn stats(cassettes : Array[@core.Cassette]) -> Stats {
  let versions : Array[Bucket] = []
  let providers : Array[Bucket] = []
  let statuses : Array[Bucket] = []
  let models : Array[ModelStat] = []
  let mut interactions = 0
  let mut streamed = 0
  let mut frames = 0
  let mut failing = 0
  let mut input_tokens = 0
  let mut output_tokens = 0
  for cassette in cassettes {
    bump(versions, cassette.version.to_string())
    for item in cassette.interactions {
      interactions = interactions + 1
      bump(providers, item.request.provider)
      bump(statuses, item.response.status.to_string())
      if is_streamed(item) {
        streamed = streamed + 1
        match item.response.stream {
          Some(list) => frames = frames + list.length()
          None => ()
        }
      }
      if item.response.status >= 400 {
        failing = failing + 1
      }
      let row = model_row(models, item.request.model)
      row.records = row.records + 1
      match item.response.usage {
        Some(usage) => {
          row.reported = row.reported + 1
          row.input_tokens = row.input_tokens + usage.input_tokens
          row.output_tokens = row.output_tokens + usage.output_tokens
          input_tokens = input_tokens + usage.input_tokens
          output_tokens = output_tokens + usage.output_tokens
        }
        None => row.unreported = row.unreported + 1
      }
    }
  }
  sort_buckets(versions)
  sort_buckets(providers)
  sort_buckets(statuses)
  models.sort_by(compare_model_stats)
  {
    cassettes: cassettes.length(),
    interactions,
    streamed,
    frames,
    failing,
    input_tokens,
    output_tokens,
    versions,
    providers,
    statuses,
    models,
  }
}

///|
fn bump(buckets : Array[Bucket], label : String) -> Unit {
  for bucket in buckets {
    if bucket.label == label {
      bucket.records = bucket.records + 1
      return
    }
  }
  let fresh : Bucket = { label, records: 1 }
  buckets.push(fresh)
}

///|
fn model_row(rows : Array[ModelStat], model : String) -> ModelStat {
  for row in rows {
    if row.model == model {
      return row
    }
  }
  let fresh : ModelStat = {
    model,
    records: 0,
    reported: 0,
    unreported: 0,
    input_tokens: 0,
    output_tokens: 0,
  }
  rows.push(fresh)
  fresh
}

///|
/// 条数降序、同数按标签升序。用 `lexical_compare`（显式的字典序）而不是
/// `<`：后者在 MoonBit 里不是字典序（实测先比长度），拿来做展示排序会
/// 得到「看着随机、其实稳定」的顺序。
fn compare_buckets(a : Bucket, b : Bucket) -> Int {
  if a.records != b.records {
    return b.records - a.records
  }
  a.label.lexical_compare(b.label)
}

///|
fn sort_buckets(buckets : Array[Bucket]) -> Unit {
  buckets.sort_by(compare_buckets)
}

///|
fn compare_model_stats(a : ModelStat, b : ModelStat) -> Int {
  if a.records != b.records {
    return b.records - a.records
  }
  a.model.lexical_compare(b.model)
}

///|
/// 流式占比，取值 0.0 ~ 1.0。没有记录时返回 0.0（而不是 NaN —— NaN 打印出来
/// 会让「输出稳定可复现」这条要求当场失效）。
pub fn Stats::stream_ratio(self : Stats) -> Double {
  if self.interactions == 0 {
    return 0.0
  }
  self.streamed.to_double() / self.interactions.to_double()
}

///|
/// 有上报用量的条数。
pub fn Stats::reported(self : Stats) -> Int {
  let mut total = 0
  for row in self.models {
    total = total + row.reported
  }
  total
}

///|
/// 没有上报用量的条数。
pub fn Stats::unreported(self : Stats) -> Int {
  let mut total = 0
  for row in self.models {
    total = total + row.unreported
  }
  total
}
