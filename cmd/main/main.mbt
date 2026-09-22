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
  token == "migrate" ||
  token == "trim" ||
  token == "merge" ||
  token == "stats" ||
  token == "help" ||
  token == "--help"
}

///|
/// 带值的选项：它们后面紧跟一个参数，因此收集路径时要连值一起跳过。
///
/// 与子命令一样，这里也**不依赖位置**：`--keep first:3` 放在路径之前或之后都一样。
fn is_flag(token : String) -> Bool {
  token == "--keep" || token == "--policy"
}

///|
/// 取 `--name <value>` 形式的值；没给返回 `None`。
///
/// 只找第一个：同一选项给两次时，以先出现的为准，避免「后面的悄悄覆盖前面的」。
fn flag_value(args : Array[String], name : String) -> String? {
  for i = 0; i < args.length() - 1; i = i + 1 {
    if args[i] == name {
      return Some(args[i + 1])
    }
  }
  None
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
  println("  mooncassette migrate <old.json> <new.json>")
  println(
    "                                        upgrade a recording to the current format (never in place)",
  )
  println("  mooncassette trim   <in.json> <out.json> --keep <spec>")
  println(
    "                                        keep a subset of the records (see --keep below)",
  )
  println(
    "  mooncassette merge  <out.json> <in.json> [<in.json> ...] [--policy <p>]",
  )
  println(
    "                                        merge recordings; exact duplicates are dropped",
  )
  println("  mooncassette stats  <in.json> [<in.json> ...]")
  println(
    "                                        roll up one or more recordings",
  )
  println("  mooncassette help                     print this message")
  println("")
  println("OPTIONS:")
  println(
    "  --keep <spec>    all | first:<n> | last:<n> | index:<i,j,...> | model:<name>",
  )
  println(
    "                   | provider:<name> | status:<code> | stream | non-stream",
  )
  println(
    "  --policy <p>     keep-first | keep-last | keep-both   (merge only)",
  )
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
  println(
    "      heuristic_in 是把请求体的规范文本按「4 字符 1 token」折算的估算 ——",
  )
  println("      mizchi/llm 的 estimate_tokens 用的就是这条规则。")
  println(
    "      偏差随内容类型变化：中文、代码与 emoji 的偏差远大于英文。",
  )
  println(
    "      本仓库的示例 cassette 是构造的，因此文档里不给比值；",
  )
  println(
    "      要数字的话，请在你自己的真实录制上跑这条命令。",
  )
}

///|
/// 把 cassette 写到文件；失败以非零码结束。
///
/// 这些子命令写的都是**新文件**：就地改写旧录制会让「录一次、永久离线」
/// 悄悄变成「录一次、随时被改」。
fn write_cassette(location : String, cassette : @core.Cassette) -> Unit {
  @fs.write_string_to_file(location, @codec.encode(cassette)) catch {
    // `IOError` 只有一个变体（内部是消息串），这里把它取出来，
    // 让「写不进去」的失败带上原因，而不是只报一个路径。
    @fs.IOError(message) =>
      fail(
        "mooncassette: cannot write file: " + location + " (" + message + ")",
      )
  }
}

///|
/// 把历史格式升到当前格式，并打印变更摘要。
///
/// **绝不原地覆盖**：来源与目标相同直接报错。迁移是要留下痕迹的动作 ——
/// 旧文件还在，新旧两版可以互相对照，出了问题也退得回去。
fn run_migrate(old_path : String, new_path : String) -> Unit {
  if old_path == new_path {
    return fail(
      "mooncassette: migrate refuses to overwrite the source file in place",
    )
  }
  let cassette = match load(old_path) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let diff = @maintain.migration_diff(cassette)
  write_cassette(new_path, @maintain.migrate(cassette))
  println("migrated : " + old_path + " -> " + new_path)
  println(
    "version  : " +
    diff.from_version.to_string() +
    " -> " +
    diff.to_version.to_string(),
  )
  println("generator: " + diff.from_generator + " -> " + diff.to_generator)
  if diff.is_noop() {
    println("note     : already current; the output is a byte-stable rewrite")
  }
}

///|
/// 按 `--keep` 策略裁剪，写出新文件。
fn run_trim(
  input_path : String,
  output_path : String,
  keep_spec : String,
) -> Unit {
  let cassette = match load(input_path) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let keep = match @maintain.Keep::parse(keep_spec) {
    Err(message) => return fail(message)
    Ok(value) => value
  }
  let trimmed = @maintain.trim(cassette, keep)
  write_cassette(output_path, trimmed)
  let before = cassette.interactions.length()
  let after = trimmed.interactions.length()
  println("trimmed  : " + input_path + " -> " + output_path)
  println("keep     : " + keep.describe())
  println("records  : " + before.to_string() + " -> " + after.to_string())
  // 越界的下标会被 `trim` 静默忽略（解析策略串时还看不到记录条数），
  // 因此「原有几条、留下几条」必须同时可见，否则差异会被吞掉。
  println(
    "note     : 越界的 index 或不存在的 model 不报错，只会少留几条",
  )
}

///|
/// 合并多份录制：`<out.json> <in.json> ...`。
fn run_merge(
  output_path : String,
  source_paths : Array[String],
  policy_name : String?,
) -> Unit {
  if source_paths.length() == 0 {
    return fail("mooncassette: merge needs at least one source cassette")
  }
  let sources : Array[@core.Cassette] = []
  for path in source_paths {
    match load(path) {
      Err(message) => return fail(message)
      Ok(value) => sources.push(value)
    }
  }
  let policy = match policy_name {
    None => @maintain.KeepBoth
    Some(name) =>
      if name == "keep-first" {
        @maintain.KeepFirst
      } else if name == "keep-last" {
        @maintain.KeepLast
      } else if name == "keep-both" {
        @maintain.KeepBoth
      } else {
        return fail(
          "mooncassette: --policy: expected keep-first | keep-last | keep-both, got \"" +
          name +
          "\"",
        )
      }
  }
  let chosen = policy_name.unwrap_or("keep-both")
  let outcome = @maintain.merge(sources, policy~)
  write_cassette(output_path, outcome.cassette)
  println(
    "merged   : " + outcome.sources.to_string() + " sources -> " + output_path,
  )
  println("policy   : " + chosen)
  println("records  : " + outcome.kept.to_string() + " kept")
  println(
    "dupes    : " + outcome.duplicates.to_string() + " exact duplicates dropped",
  )
  println(
    "conflicts: " +
    outcome.conflicts.to_string() +
    " same request, different response (resolved by " +
    chosen +
    ")",
  )
}

///|
/// 打印一组「标签 → 条数」。
fn print_buckets(title : String, buckets : Array[@maintain.Bucket]) -> Unit {
  if buckets.length() == 0 {
    return
  }
  println(title + ":")
  for bucket in buckets {
    println("  " + pad_right(bucket.label, 20) + bucket.records.to_string())
  }
}

///|
/// 把 0.0 ~ 1.0 的比值打印成整数百分比。
///
/// 用整数而不是浮点原文：`Double` 的字符串位数随工具链而变，而本项目的输出
/// 要求「稳定可复现」—— 同一组输入在任何后端、任何进程里都必须逐字一样。
fn percent(value : Double) -> String {
  (value * 100.0).to_int().to_string() + "%"
}

///|
/// 汇总一批录制。
fn run_stats(paths : Array[String]) -> Unit {
  if paths.length() == 0 {
    return fail("mooncassette: stats needs at least one cassette")
  }
  let cassettes : Array[@core.Cassette] = []
  for path in paths {
    match load(path) {
      Err(message) => return fail(message)
      Ok(value) => cassettes.push(value)
    }
  }
  let report = @maintain.stats(cassettes)
  println(
    pad_right("cassettes", 12) +
    pad_right("records", 9) +
    pad_right("streamed", 10) +
    pad_right("frames", 9) +
    pad_right("failing", 9) +
    pad_right("in_tokens", 11) +
    "out_tokens",
  )
  println(
    pad_right(report.cassettes.to_string(), 12) +
    pad_right(report.interactions.to_string(), 9) +
    pad_right(report.streamed.to_string(), 10) +
    pad_right(report.frames.to_string(), 9) +
    pad_right(report.failing.to_string(), 9) +
    pad_right(report.input_tokens.to_string(), 11) +
    report.output_tokens.to_string(),
  )
  println("")
  print_buckets("versions", report.versions)
  print_buckets("providers", report.providers)
  print_buckets("statuses", report.statuses)
  println("")
  println(
    pad_right("model", 24) +
    pad_right("records", 9) +
    pad_right("reported", 10) +
    pad_right("unreported", 12) +
    pad_right("in_tokens", 11) +
    "out_tokens",
  )
  for row in report.models {
    println(
      pad_right(row.model, 24) +
      pad_right(row.records.to_string(), 9) +
      pad_right(row.reported.to_string(), 10) +
      pad_right(row.unreported.to_string(), 12) +
      pad_right(row.input_tokens.to_string(), 11) +
      row.output_tokens.to_string(),
    )
  }
  println("")
  println("stream_ratio: " + percent(report.stream_ratio()))
  println("reported    : " + report.reported().to_string())
  println("unreported  : " + report.unreported().to_string())
  println("")
  println(
    "note: unreported 单列 —— 「不知道」与「是 0」是两回事，混起来会让成本看起来精确。",
  )
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
  // 带值选项先取出来，收集路径时要连它的值一起跳过。
  let keep_spec = flag_value(args, "--keep")
  let policy_name = flag_value(args, "--policy")
  // 子命令之后的所有非关键字、非选项 token 才视作路径参数（`diff` 需要两个）。
  let paths : Array[String] = []
  let mut i = command_at + 1
  while i < args.length() {
    if is_flag(args[i]) {
      // 选项的值不是路径，整体跳过（值缺失时越界，循环条件自然收束）。
      i = i + 2
      continue
    }
    if !is_command(args[i]) {
      paths.push(args[i])
    }
    i = i + 1
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
      } else if name == "migrate" {
        match paths {
          [old_path, new_path, ..] => run_migrate(old_path, new_path)
          _ => print_usage()
        }
      } else if name == "trim" {
        // 没有 `--keep` 就不裁剪：没给策略时打印用法，而不是默认「全留」——
        // 一个悄悄什么也没做的子命令，比报错更难发现。
        match (paths, keep_spec) {
          ([input_path, output_path, ..], Some(spec)) =>
            run_trim(input_path, output_path, spec)
          _ => print_usage()
        }
      } else if name == "merge" {
        // 第一个路径是输出，其余是来源。
        match paths {
          [output_path, ..] =>
            run_merge(output_path, paths[1:].to_owned(), policy_name)
          _ => print_usage()
        }
      } else if name == "stats" {
        run_stats(paths)
      } else {
        print_usage()
      }
  }
}
