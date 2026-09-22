///|
/// 裁剪策略。
pub(all) enum Keep {
  /// 原样保留全部记录（用于「只重写文件、不改内容」）。
  All
  /// 只保留最前面的 n 条。
  First(Int)
  /// 只保留最后面的 n 条。
  Last(Int)
  /// 只保留给定下标的记录，输出时仍按录制顺序。
  Indices(Array[Int])
  /// 只保留该模型的记录。
  Model(String)
  /// 只保留该 provider 的记录。
  Provider(String)
  /// 只保留该 HTTP 状态码的记录。
  Status(Int)
  /// 只保留流式记录。
  Streamed
  /// 只保留非流式记录。
  NonStreamed
} derive(Eq)

///|
/// 解析 `--keep` 的策略串。
///
/// 刻意返回 `Result` 而不是抛 `@core.CassetteError`：策略串是**命令行输入**，
/// 不是 cassette 自身的问题；混进同一套错误变体只会让 `CassetteError`
/// 的含义变模糊（矩阵 E 要求每个变体都能被真实触发且可定位）。
pub fn Keep::parse(text : String) -> Result[Keep, String] {
  // 先落到 `String`：下面全是与字面量的比较与前缀剥离，用 `String` 更直白。
  let spec = text.trim().to_owned()
  if spec == "all" {
    return Ok(All)
  }
  if spec == "stream" {
    return Ok(Streamed)
  }
  if spec == "non-stream" {
    return Ok(NonStreamed)
  }
  // 下面几段刻意逐条写开，而不是 `结果.map(First)`：MoonBit 禁止把构造子
  // 直接当高阶函数用（错误 4203），包装一层匿名函数反而更绕。
  if spec.strip_prefix("first:") is Some(rest) {
    match keep_count(rest, spec) {
      Ok(n) => return Ok(First(n))
      Err(message) => return Err(message)
    }
  }
  if spec.strip_prefix("last:") is Some(rest) {
    match keep_count(rest, spec) {
      Ok(n) => return Ok(Last(n))
      Err(message) => return Err(message)
    }
  }
  if spec.strip_prefix("model:") is Some(rest) {
    match keep_label(rest, spec) {
      Ok(name) => return Ok(Model(name))
      Err(message) => return Err(message)
    }
  }
  if spec.strip_prefix("provider:") is Some(rest) {
    match keep_label(rest, spec) {
      Ok(name) => return Ok(Provider(name))
      Err(message) => return Err(message)
    }
  }
  if spec.strip_prefix("status:") is Some(rest) {
    match keep_count(rest, spec) {
      Ok(code) => return Ok(Status(code))
      Err(message) => return Err(message)
    }
  }
  if spec.strip_prefix("index:") is Some(rest) {
    return keep_indices(rest, spec)
  }
  Err(keep_error(spec))
}

///|
/// 策略串的用法提示。单独抽出来是为了让「不合法」与「合法但空」两种情况
/// 给出同一段提示，避免两处文案漂移。
fn keep_hint() -> String {
  "  expected one of: all | first:<n> | last:<n> | index:<i,j,...> | model:<name> | provider:<name> | status:<code> | stream | non-stream"
}

///|
fn keep_error(spec : String) -> String {
  "mooncassette: --keep: cannot parse " + "\"" + spec + "\"\n" + keep_hint()
}

///|
/// `first:` / `last:` / `status:` 共用的非负整数解析。
fn keep_count(rest : StringView, spec : String) -> Result[Int, String] {
  let value = @string.parse_int(rest) catch {
    _ => return Err(keep_error(spec))
  }
  if value < 0 {
    return Err(keep_error(spec))
  }
  Ok(value)
}

///|
/// `model:` / `provider:` 共用的非空标签解析。
fn keep_label(rest : StringView, spec : String) -> Result[String, String] {
  let label = rest.to_owned()
  if label == "" {
    return Err(keep_error(spec))
  }
  Ok(label)
}

///|
/// `index:` 的下标列表解析。
fn keep_indices(rest : StringView, spec : String) -> Result[Keep, String] {
  let indices : Array[Int] = []
  for piece in rest.split(",") {
    let value = @string.parse_int(piece) catch {
      _ => return Err(keep_error(spec))
    }
    if value < 0 {
      return Err(keep_error(spec))
    }
    indices.push(value)
  }
  if indices.length() == 0 {
    return Err(keep_error(spec))
  }
  Ok(Indices(indices))
}

///|
/// 把策略回写成规范串（用于回显「我按什么裁的」）。
pub fn Keep::describe(self : Keep) -> String {
  match self {
    All => "all"
    First(n) => "first:" + n.to_string()
    Last(n) => "last:" + n.to_string()
    Indices(list) => {
      let sb = StringBuilder::new()
      sb.write_string("index:")
      for i = 0; i < list.length(); i = i + 1 {
        if i > 0 {
          sb.write_string(",")
        }
        sb.write_string(list[i].to_string())
      }
      sb.to_string()
    }
    Model(name) => "model:" + name
    Provider(name) => "provider:" + name
    Status(code) => "status:" + code.to_string()
    Streamed => "stream"
    NonStreamed => "non-stream"
  }
}

///|
/// 一条记录是否流式。
///
/// 判据是「有非空帧序列」而不是「`stream` 字段存在」：写入侧只会在有帧时才写
/// 这个字段，但手工编辑过的文件可能写一个空数组，那种情况按非流式算更符合直觉。
pub fn is_streamed(item : @core.Interaction) -> Bool {
  match item.response.stream {
    Some(frames) => frames.length() > 0
    None => false
  }
}

///|
/// 按策略裁剪记录，返回新 `Cassette`，入参不变。
///
/// 版本号原样保留：裁剪只会**减少**内容，删记录不可能让文件需要更高的格式版本。
/// 反过来说，即便删光了所有流式记录，这里也不会把版本降回 1 ——
/// 「降版本」属于 `migrate` 的语义，两个动作不混。
///
/// 越界的 `Indices` 会被静默忽略（`Keep` 在解析时还看不到记录条数），
/// 因此调用方应当把「保留了几条 / 原有几条」一并展示出来，
/// 让「我明明要了 5 条却只剩 2 条」这种差异是可见的而不是被吞掉。
pub fn trim(cassette : @core.Cassette, keep : Keep) -> @core.Cassette {
  let kept : Array[@core.Interaction] = []
  let total = cassette.interactions.length()
  for i = 0; i < total; i = i + 1 {
    let item = cassette.interactions[i]
    if keep_takes(keep, i, total, item) {
      kept.push(item)
    }
  }
  { version: cassette.version, meta: cassette.meta, interactions: kept }
}

///|
fn keep_takes(
  keep : Keep,
  index : Int,
  total : Int,
  item : @core.Interaction,
) -> Bool {
  match keep {
    All => true
    First(n) => index < n
    Last(n) => index >= total - n
    Indices(list) => {
      let mut hit = false
      for wanted in list {
        if wanted == index {
          hit = true
        }
      }
      hit
    }
    Model(name) => item.request.model == name
    Provider(name) => item.request.provider == name
    Status(code) => item.response.status == code
    Streamed => is_streamed(item)
    NonStreamed => !is_streamed(item)
  }
}
