// mooncassette CLI。
//
// 关于命令行参数：不同后端的 `@env.args()` 语义不完全一致（JS 会把
// node 与脚本路径也放进来）。这里刻意**不依赖位置**，而是先扫描出
// 已知子命令关键字，再取它后面的第一个非关键字参数作为文件路径，
// 从而在 native 与 js 上得到一致行为。

///|
/// 已知子命令关键字。
fn is_command(token : String) -> Bool {
  token == "verify" || token == "show" || token == "help" || token == "--help"
}

///|
/// 打印用法。
fn print_usage() -> Unit {
  println("mooncassette - deterministic record & replay for LLM interactions")
  println("")
  println("USAGE:")
  println("  mooncassette verify <cassette.json>   decode and check integrity")
  println("  mooncassette show   <cassette.json>   print a summary")
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
  let mut location : String? = None
  let mut location_at = -1
  for i = command_at + 1; i < args.length(); i = i + 1 {
    if location_at < 0 && !is_command(args[i]) {
      location_at = i
    }
  }
  if location_at >= 0 {
    location = Some(args[location_at])
  }
  match command {
    None => print_usage()
    Some(name) =>
      if name == "verify" {
        match location {
          Some(path) => run_verify(path)
          None => print_usage()
        }
      } else if name == "show" {
        match location {
          Some(path) => run_show(path)
          None => print_usage()
        }
      } else {
        print_usage()
      }
  }
}
