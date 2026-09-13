// mooncassette CLI。
//
// 关于命令行参数：不同后端的 `@env.args()` 语义不完全一致（JS 会把
// node 与脚本路径也放进来）。这里刻意**不依赖位置**，而是先扫描出
// 已知子命令关键字，再取它后面的第一个非关键字参数作为文件路径，
// 从而在 native 与 js 上得到一致行为。

///|
/// 已知子命令关键字。
fn is_command(token : String) -> Bool {
  token == "verify" ||
  token == "show" ||
  token == "diff" ||
  token == "cost" ||
  token == "tokens" ||
  token == "explain" ||
  token == "help" ||
  token == "--help"
}

///|
/// 打印用法。
fn print_usage() -> Unit {
  println("mooncassette - deterministic record & replay for LLM interactions")
  println("")
  println("USAGE:")
  println("  mooncassette verify <cassette.json>   decode and check integrity")
  println("  mooncassette show   <cassette.json>   print a summary")
  println("  mooncassette diff   <old.json> <new.json>")
  println(
    "                                        report behavioural drift between two recordings",
  )
  println(
    "                                        (exits 1 when drift is found)",
  )
  println("  mooncassette cost   <cassette.json> <prices.json>")
  println(
    "                                        total token cost against a price table",
  )
  println("  mooncassette tokens <cassette.json>")
  println(
    "                                        reported usage vs a chars/4 heuristic",
  )
  println("  mooncassette explain <cassette.json> <request.json>")
  println(
    "                                        say whether a request replays, and if not, why",
  )
  println(
    "                                        (exits 1 when it does not match)",
  )
  println("  mooncassette help                     print this message")
}

///|
/// 读取文件；失败返回 `None` 而不是抛错，便于上层统一处理。
fn read_text(location : String) -> String? {
  let text = @fs.read_file_to_string(location) catch { _ => return None }
  Some(text)
}

///|
/// 读文件并解码，同时做完整性校验。
fn load(location : String) -> Result[@core.Cassette, String] {
  match read_text(location) {
    None => Err("mooncassette: cannot read file: " + location)
    Some(text) => {
      // `decode` 是抛错型 API，这里统一收敛为 `Result`，
      // 让上层只需处理一种失败形态。
      let cassette = @codec.decode(text) catch {
        error => return Err(error.to_string())
      }
      Ok(cassette)
    }
  }
}

///|
/// 汇总 cassette 的要点。
fn summarize(cassette : @core.Cassette) -> String {
  let sb = StringBuilder::new()
  sb.write_string("name=" + cassette.meta.name)
  sb.write_string("  version=" + cassette.version.to_string())
  sb.write_string(
    "  interactions=" + cassette.interactions.length().to_string(),
  )
  sb.write_string("  tokens=")
  sb.write_string(cassette.total_input_tokens().to_string())
  sb.write_string("/")
  sb.write_string(cassette.total_output_tokens().to_string())
  sb.write_string("  models=")
  sb.write_string(join(distinct_models(cassette), ","))
  sb.to_string()
}

///|
/// 收集出现过的模型名（保持首次出现的顺序，便于稳定输出）。
fn distinct_models(cassette : @core.Cassette) -> Array[String] {
  let models : Array[String] = []
  for item in cassette.interactions {
    if !contains(models, item.request.model) {
      models.push(item.request.model)
    }
  }
  models
}

///|
fn contains(items : Array[String], target : String) -> Bool {
  for i = 0; i < items.length(); i = i + 1 {
    if items[i] == target {
      return true
    }
  }
  false
}

///|
fn join(items : Array[String], separator : String) -> String {
  let sb = StringBuilder::new()
  for i = 0; i < items.length(); i = i + 1 {
    if i > 0 {
      sb.write_string(separator)
    }
    sb.write_string(items[i])
  }
  sb.to_string()
}

///|
/// 打印错误并以非零码退出。
///
/// 这里不再额外加前缀：`@core.CassetteError` 的 `Show` 实现已经带了
/// `mooncassette: ` 前缀，重复拼接会出现「mooncassette: mooncassette: …」。
fn fail(message : String) -> Unit {
  println(message)
  @sys.exit(1)
}

///|
fn run_verify(location : String) -> Unit {
  match load(location) {
    Err(message) => fail(message)
    Ok(cassette) => println("OK  " + summarize(cassette))
  }
}

///|
fn run_show(location : String) -> Unit {
  match load(location) {
    Err(message) => fail(message)
    Ok(cassette) => {
      println("cassette : " + location)
      println("generator: " + cassette.meta.generator)
      match cassette.meta.recorded_at {
        Some(text) => println("recorded : " + text)
        None => println("recorded : (not recorded)")
      }
      println(summarize(cassette))
    }
  }
}

///|
/// 比较两份录制并打印漂移报告。
///
/// 有漂移时以退出码 1 结束，因此可以直接当作 CI 的一步：
/// 「重新录制后模型行为变了没有」这个问题就能自动回答。
fn run_diff(old_path : String, new_path : String) -> Unit {
  let old = match load(old_path) {
    Err(message) => return fail(message)
    Ok(cassette) => cassette
  }
  let new = match load(new_path) {
    Err(message) => return fail(message)
    Ok(cassette) => cassette
  }
  let report = @drift.compare(old, new)
  for line in report.lines() {
    println(line)
  }
  println(report.summary())
  if !report.is_clean() {
    @sys.exit(1)
  }
}

///|
/// 读取一个 JSON 文件。
fn read_json(location : String) -> Json? {
  let text = match read_text(location) {
    None => return None
    Some(value) => value
  }
  let value = @json.parse(text) catch { _ => return None }
  Some(value)
}

///|
/// 按价目表汇总成本。
///
/// 价目表由调用方提供，形状为 `{"模型名": {"input": 微美元/百万, "output": …}}`。
/// 本项目刻意不内置价格：模型价格变动频繁，内置一张会过期的表只会让使用者
/// 拿到「看起来精确、其实已经错了」的数字。
fn run_cost(cassette_path : String, table_path : String) -> Unit {
  let cassette = match load(cassette_path) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let value = match read_json(table_path) {
    None =>
      return fail(
        "mooncassette: cannot read a JSON price table from: " + table_path,
      )
    Some(value) => value
  }
  let table = @cost.PriceTable::of_json(value) catch {
    error => return fail(error.to_string())
  }
  println(@cost.estimate_cassette(table, cassette).render())
}

///|
/// 判断一个请求能不能在这份录制里回放；不能则说明差在哪里。
///
/// 存在的意义是**不开编译器也能诊断**：CI 里一个回放失败的测试，可以把请求
/// 导出成 JSON 之后用这个子命令查，而不必改代码重跑一遍。
fn run_explain(cassette_path : String, request_path : String) -> Unit {
  let cassette = match load(cassette_path) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let text = match read_text(request_path) {
    None => return fail("mooncassette: cannot read file: " + request_path)
    Some(value) => value
  }
  let request = @codec.decode_request(text) catch {
    error => return fail(error.to_string())
  }
  // 会话默认就是最安全的 `Playback` + `Exact`，且回放模式在构造上不持有
  // Transport，因此这条命令绝不会发起任何真实调用。
  let session = @recorder.Session::new(cassette)
  let replayed = session.try_replay(request) catch {
    error => return fail(error.to_string())
  }
  match replayed {
    Some(_) => println("match: yes  the recording covers this request")
    None => {
      println("match: no")
      for line in session.diagnose(request).lines() {
        println(line)
      }
      @sys.exit(1)
    }
  }
}

///|
fn pad_right(text : String, width : Int) -> String {
  let mut out = text
  while out.length() < width {
    out = out + " "
  }
  out
}

///|
/// 一个模型上的 token 对照累计。
///
/// 字段可变：边遍历边累加，避免「先收集再分组」的两次遍历。
struct TokenRow {
  model : String
  mut records : Int
  mut reported_in : Int
  mut reported_out : Int
  mut heuristic_in : Int
}

///|
/// 取（必要时新建）某个模型的累计行。
///
/// 手写线性查找而不是用 `Map`：模型数量是个位数，而 `Map` 需要处理「取出后原地
/// 修改」的取值语义，在这里得不偿失。
fn row_for(rows : Array[TokenRow], model : String) -> TokenRow {
  for row in rows {
    if row.model == model {
      return row
    }
  }
  let fresh : TokenRow = {
    model,
    records: 0,
    reported_in: 0,
    reported_out: 0,
    heuristic_in: 0,
  }
  rows.push(fresh)
  fresh
}

///|
/// 把 provider 上报的 usage 与「按字符数折算」的估算放在一起对照。
///
/// 本项目主张「成本来自上报值，不是估算」。这个主张很容易被读成一句广告，所以
/// 把它变成一条可执行的命令：在**你自己的真实录制**上跑一遍，偏差多大由数据说话。
///
/// 也正因如此，项目文档里刻意**不**给出比值：仓库里的示例 cassette 是构造出来的，
/// 基于它们算出的比值同样是编的。数字只能来自真实调用。
fn run_tokens(cassette_path : String) -> Unit {
  let cassette = match load(cassette_path) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let rows : Array[TokenRow] = []
  for interaction in cassette.interactions {
    let row = row_for(rows, interaction.request.model)
    row.records = row.records + 1
    // 估算口径：请求体的**规范文本**长度除以 4。
    //
    // 用规范文本而不是原始字节，是为了与匹配用的形状保持一致 —— 键序与空白
    // 都不该影响这个数字。
    row.heuristic_in = row.heuristic_in +
      @canon.to_canonical_string(interaction.request.body).length() / 4
    match interaction.response.usage {
      Some(usage) => {
        row.reported_in = row.reported_in + usage.input_tokens
        row.reported_out = row.reported_out + usage.output_tokens
      }
      // 没有上报就是没有上报：这里不补零、也不估算。
      // 「不知道」与「是 0」是两回事，混起来会让成本看起来精确而其实没有依据。
      None => ()
    }
  }
  if rows.length() == 0 {
    println("mooncassette: this cassette has no interactions to compare")
    return
  }
  println(
    pad_right("model", 20) +
    pad_right("records", 9) +
    pad_right("reported_in", 13) +
    pad_right("reported_out", 14) +
    pad_right("heuristic_in", 14) +
    "reported/heuristic",
  )
  for row in rows {
    let ratio = if row.heuristic_in > 0 {
      (row.reported_in * 100 / row.heuristic_in).to_string() + "%"
    } else {
      "-"
    }
    println(
      pad_right(row.model, 20) +
      pad_right(row.records.to_string(), 9) +
      pad_right(row.reported_in.to_string(), 13) +
      pad_right(row.reported_out.to_string(), 14) +
      pad_right(row.heuristic_in.to_string(), 14) +
      ratio,
    )
  }
  println("")
  println("note: reported_* 是 provider 上报的 usage（精确值）。")
  println("      heuristic_in 是把请求体的规范文本按「4 字符 1 token」折算的估算 ——")
  println("      mizchi/llm 的 estimate_tokens 用的就是这条规则。")
  println("      偏差随内容类型变化：中文、代码与 emoji 的偏差远大于英文。")
  println("      本仓库的示例 cassette 是构造的，因此文档里不给比值；")
  println("      要数字的话，请在你自己的真实录制上跑这条命令。")
}

///|
fn main {
  let argv = @env.args()
  // 丢掉 argv[0]（native 为程序名，js 为运行时），其余用关键字扫描定位。
  let args : Array[String] = if argv.length() <= 1 {
    []
  } else {
    argv[1:].to_owned()
  }
  let mut command : String? = None
  let mut command_at = -1
  for i = 0; i < args.length(); i = i + 1 {
    if command_at < 0 && is_command(args[i]) {
      command_at = i
    }
  }
  if command_at >= 0 {
    command = Some(args[command_at])
  }
  // 子命令之后的所有非关键字 token 都视作路径参数（`diff` 需要两个）。
  let paths : Array[String] = []
  for i = command_at + 1; i < args.length(); i = i + 1 {
    if !is_command(args[i]) {
      paths.push(args[i])
    }
  }
  match command {
    None => print_usage()
    Some(name) =>
      if name == "verify" {
        match paths {
          [path, ..] => run_verify(path)
          _ => print_usage()
        }
      } else if name == "show" {
        match paths {
          [path, ..] => run_show(path)
          _ => print_usage()
        }
      } else if name == "diff" {
        match paths {
          [old_path, new_path, ..] => run_diff(old_path, new_path)
          _ => print_usage()
        }
      } else if name == "cost" {
        match paths {
          [cassette_path, table_path, ..] => run_cost(cassette_path, table_path)
          _ => print_usage()
        }
      } else if name == "tokens" {
        match paths {
          [cassette_path, ..] => run_tokens(cassette_path)
          _ => print_usage()
        }
      } else if name == "explain" {
        match paths {
          [cassette_path, request_path, ..] =>
            run_explain(cassette_path, request_path)
          _ => print_usage()
        }
      } else {
        print_usage()
      }
  }
}
