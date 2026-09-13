// mooncassette 基准：把「量化指标」测出来，而不是估计。
//
// 运行：
//   moon run examples/benchmarks --target js
//   moon run examples/benchmarks --target wasm-gc
//
// 输出分成两类，**刻意分开**：
//
//   规模指标 —— 确定性的，只取决于数据本身（体积、每条记录的开销）。
//               换一台机器结果一样，因此可以在 CI 中断言。
//   时间指标 —— 取决于机器与后端。只有同一台机器上的前后对比才有意义，
//               跨机器比较毫无价值。
//
// 为什么必须分开：把时间写成断言，等于把「CI 机器今天有多忙」变成测试结果；
// 而规模指标是**代码的性质**，不是环境的性质。

///|
/// 累加器。
///
/// 两个用途：
///
/// - **防止计算被优化掉**：没有它，纯计算的基准可能被编译器整个删掉，
///   于是测出来的是「什么都不做」的耗时——一个漂亮但毫无意义的数字；
/// - **记录失败次数**：静默失败是基准最坏的结局，数字很漂亮，但测的是一个
///   恒等于空操作的路径。凡会抛错的被测代码都在闭包内捕获并计数。
///
/// 顶层不能写 `let mut`，因此可变状态放进 struct 实例。
struct Accumulator {
  mut checksum : Int
  mut failures : Int
}

///|
let accumulator : Accumulator = { checksum: 0, failures: 0 }

///|
/// 一行时间指标。
struct Row {
  name : String
  us_per_op : Double
  iterations : Int
}

///|
/// 测一段代码的平均耗时（微秒）。
///
/// 先空跑一轮：首次调用包含惰性初始化，计入平均值会明显失真。
fn measure(name : String, iterations : Int, op : () -> Unit) -> Row {
  op()
  let start = @bench.monotonic_clock_start()
  for i = 0; i < iterations; i = i + 1 {
    op()
  }
  let elapsed = @bench.monotonic_clock_end(start)
  { name, us_per_op: elapsed / iterations.to_double(), iterations }
}

///|
/// 把微秒数格式化成人能读的形式。全程整数运算，不依赖浮点格式化。
fn format_us(us : Double) -> String {
  if us >= 1000.0 {
    let tenths = (us / 100.0).to_int()
    (tenths / 10).to_string() + "." + (tenths % 10).to_string() + " ms"
  } else if us >= 1.0 {
    us.to_int().to_string() + " us"
  } else {
    // 亚微秒量级：用十分之一微秒为单位表示，保留一位小数。
    let tenths = (us * 10.0).to_int()
    (tenths / 10).to_string() + "." + (tenths % 10).to_string() + " us"
  }
}

///|
fn format_bytes(bytes : Int) -> String {
  if bytes < 1024 {
    bytes.to_string() + " B"
  } else if bytes < 1024 * 1024 {
    let tenths = bytes * 10 / 1024
    (tenths / 10).to_string() + "." + (tenths % 10).to_string() + " KiB"
  } else {
    let tenths = bytes * 10 / (1024 * 1024)
    (tenths / 10).to_string() + "." + (tenths % 10).to_string() + " MiB"
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
fn print_timings(rows : Array[Row]) -> Unit {
  for row in rows {
    let per_op = row.us_per_op
    let ops_per_sec = if per_op > 0.0 { (1000000.0 / per_op).to_int() } else { 0 }
    println(
      "  " +
      pad_right(row.name, 32) +
      pad_right(format_us(per_op) + "/op", 14) +
      pad_right(ops_per_sec.to_string() + " ops/s", 18) +
      "n=" +
      row.iterations.to_string(),
    )
  }
}

///|
/// 造一个约 1 KB 的请求体：5 条消息，内容有代表性长度。
fn synth_request_body(index : Int) -> Json {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("temperature", Json::number(0.7))
  let messages : Array[Json] = []
  for m = 0; m < 5; m = m + 1 {
    let message : Map[String, Json] = Map([])
    message.set(
      "role",
      Json::string(if m % 2 == 0 { "user" } else { "assistant" }),
    )
    message.set(
      "content",
      Json::string(
        "第 " +
        index.to_string() +
        " 组对话的第 " +
        m.to_string() +
        " 段内容：这里放一段有代表性的长度，用于让请求体接近真实使用中的规模。",
      ),
    )
    messages.push(Json::object(message))
  }
  body.set("messages", Json::array(messages))
  Json::object(body)
}

///|
/// 造一个 n 条记录的 cassette。
fn synth_cassette(n : Int) -> @core.Cassette {
  let interactions : Array[@core.Interaction] = []
  for i = 0; i < n; i = i + 1 {
    let request = @core.Request::new("openai", "gpt-4o", synth_request_body(i))
    let answer : Map[String, Json] = Map([])
    answer.set("id", Json::string("chatcmpl-" + i.to_string()))
    answer.set("model", Json::string("gpt-4o"))
    let choice : Map[String, Json] = Map([])
    choice.set("index", Json::number(0))
    let message : Map[String, Json] = Map([])
    message.set("role", Json::string("assistant"))
    message.set(
      "content",
      Json::string("这是第 " + i.to_string() + " 条回答，长度也接近真实情况。"),
    )
    choice.set("message", Json::object(message))
    choice.set("finish_reason", Json::string("stop"))
    answer.set("choices", Json::array([Json::object(choice)]))
    let response = @core.Response::ok(
      Json::object(answer),
      usage=@core.Usage::new(120, 48),
    )
    interactions.push(@core.Interaction::new(request, response))
  }
  @core.Cassette::new("bench", recorded_at="2026-09-13T00:00:00Z", interactions~)
}

///|
/// 造一段 n 帧的 SSE 文本，形状与 OpenAI 流式响应一致。
fn synth_sse(n : Int) -> String {
  let text = StringBuilder::new()
  for i = 0; i < n; i = i + 1 {
    text.write_string(
      "data: {\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\"," +
      "\"choices\":[{\"index\":0,\"delta\":{\"content\":\"片段 " +
      i.to_string() +
      "\"},\"finish_reason\":null}]}\n\n",
    )
  }
  text.write_string("data: [DONE]\n\n")
  text.to_string()
}

///|
/// 一份含若干密钥的 JSON，用于测脱敏开销。
///
/// 直接构造而不是解析一段字面量：`fn main` 里不能调用会抛错的函数，
/// 而且基准的输入不该把「解析」这一步混进被测开销。
fn synth_secrets() -> Json {
  let nested : Map[String, Json] = Map([])
  nested.set("password", Json::string("hunter2"))
  let root : Map[String, Json] = Map([])
  root.set("api_key", Json::string("sk-abcdefgh12345678"))
  root.set("authorization", Json::string("Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig"))
  root.set("nested", Json::object(nested))
  root.set("safe", Json::string("keep me"))
  Json::object(root)
}

///|
fn print_sizes(records : Array[Int]) -> Unit {
  println("规模指标（确定性，只取决于数据本身）")
  println(
    "  " +
    pad_right("records", 10) +
    pad_right("pretty", 12) +
    pad_right("compact", 12) +
    "compact/record",
  )
  let mut last_pretty = 0
  let mut last_compact = 0
  let mut last_n = 0
  for n in records {
    let cassette = synth_cassette(n)
    let pretty = @codec.encode(cassette).length()
    let compact = @codec.encode(cassette, indent=0).length()
    println(
      "  " +
      pad_right(n.to_string(), 10) +
      pad_right(format_bytes(pretty), 12) +
      pad_right(format_bytes(compact), 12) +
      format_bytes(compact / n) +
      "/record",
    )
    last_pretty = pretty
    last_compact = compact
    last_n = n
  }
  let floor_compact = @codec.encode(synth_cassette(10), indent=0).length()
  if last_pretty > 0 {
    println(
      "  紧凑编码比 2 空格缩进省 " +
      (100 - last_compact * 100 / last_pretty).to_string() +
      "%",
    )
    println(
      "  每条记录的开销 = (compact(1000) - compact(10)) / 990 = " +
      format_bytes((last_compact - floor_compact) / (last_n - 10)) +
      "（与上面的每记录字节数一致，说明增长是线性的）",
    )
  }
}

///|
fn main {
  println("mooncassette 基准")
  println("  规模指标是确定性的；时间指标取决于机器与后端，跨机器比较没有意义。")
  print_sizes([10, 100, 1000])

  println("")
  println("时间指标")
  let rows : Array[Row] = []
  let probe = @core.Request::new("openai", "gpt-4o", synth_request_body(0))
  rows.push(
    measure("fingerprint (1 KB request)", 2000, fn() {
      accumulator.checksum = accumulator.checksum +
        @fingerprint.fingerprint(probe).length()
    }),
  )
  rows.push(
    measure("canonical text (1 KB JSON)", 2000, fn() {
      accumulator.checksum = accumulator.checksum +
        @canon.to_canonical_string(probe.body).length()
    }),
  )
  let mid = synth_cassette(100)
  let mid_text = @codec.encode(mid)
  rows.push(
    measure("encode (100 records)", 100, fn() {
      accumulator.checksum = accumulator.checksum + @codec.encode(mid).length()
    }),
  )
  rows.push(
    measure("decode + verify (100 records)", 100, fn() {
      let decoded = @codec.decode(mid_text) catch {
        _ => {
          accumulator.failures = accumulator.failures + 1
          return
        }
      }
      accumulator.checksum = accumulator.checksum + decoded.length()
    }),
  )

  // 匹配：最贵的是「未命中」——它必须扫完整张表。
  let big = synth_cassette(1000)
  let hit = @core.Request::new("openai", "gpt-4o", synth_request_body(0))
  let miss = @core.Request::new("openai", "gpt-4o", synth_request_body(999999))
  let cases : Array[(@matcher.MatchPolicy, String, @core.Request)] = [
    (@matcher.MatchPolicy::Exact, "match exact hit (1000)", hit),
    (@matcher.MatchPolicy::Exact, "match exact miss (1000)", miss),
    (@matcher.MatchPolicy::FingerprintOnly, "match fp miss (1000)", miss),
    (
      @matcher.MatchPolicy::Subset(["messages"]),
      "match subset miss (1000)",
      miss,
    ),
  ]
  for entry in cases {
    let (policy, name, request) = entry
    rows.push(
      measure(name, 20, fn() {
        let found = @matcher.find_match(request, big.interactions[:], policy, 0)
          catch {
          _ => {
            accumulator.failures = accumulator.failures + 1
            return
          }
        }
        match found {
          Some(result) => accumulator.checksum = accumulator.checksum + result.index
          None => accumulator.checksum = accumulator.checksum + 1
        }
      }),
    )
  }

  // 索引：建立一次，之后的扫描不再重算指纹。
  //
  // 这一组与上一组的差值，就是「每条记录重算一次指纹」的代价。
  let built_index = @matcher.MatchIndex::build(big.interactions[:])
  rows.push(
    measure("index build (1000)", 20, fn() {
      let built = @matcher.MatchIndex::build(big.interactions[:])
      accumulator.checksum = accumulator.checksum + built.length()
    }),
  )
  let indexed_cases : Array[(@matcher.MatchPolicy, String)] = [
    (@matcher.MatchPolicy::Exact, "match exact miss indexed (1000)"),
    (
      @matcher.MatchPolicy::FingerprintOnly,
      "match fp miss indexed (1000)",
    ),
  ]
  for entry in indexed_cases {
    let (policy, name) = entry
    rows.push(
      measure(name, 2000, fn() {
        let found = @matcher.find_match(
          miss,
          big.interactions[:],
          policy,
          0,
          index=built_index,
        ) catch {
          _ => {
            accumulator.failures = accumulator.failures + 1
            return
          }
        }
        match found {
          Some(result) => accumulator.checksum = accumulator.checksum + result.index
          None => accumulator.checksum = accumulator.checksum + 1
        }
      }),
    )
  }

  // 脱敏：一份含若干密钥的 JSON。
  let secrets = synth_secrets()
  let policy = @sanitize.SanitizePolicy::default()
  rows.push(
    measure("sanitize json (3 secrets)", 2000, fn() {
      accumulator.checksum = accumulator.checksum +
        @canon.to_canonical_string(@sanitize.sanitize_json(secrets, policy)).length()
    }),
  )

  // SSE 解析：200 帧的一整段流式响应。
  let sse = synth_sse(200)
  rows.push(
    measure("sse parse (200 frames)", 500, fn() {
      accumulator.checksum = accumulator.checksum + @stream.parse(sse).length()
    }),
  )

  // 会话回放：在 100 条记录中命中，含规范化与脱敏。
  let playback = @recorder.Session::new(mid, mode=@recorder.Mode::Playback)
  rows.push(
    measure("session replay (100 records)", 1000, fn() {
      let response = playback.send(hit) catch {
        _ => {
          accumulator.failures = accumulator.failures + 1
          return
        }
      }
      accumulator.checksum = accumulator.checksum + response.status
    }),
  )

  print_timings(rows)
  println("")
  println(
    "  被测路径的失败次数：" +
    accumulator.failures.to_string() +
    "（必须为 0，否则时间测的是空路径）",
  )
  println("  结果校验值：" + accumulator.checksum.to_string() + "（防止计算被优化掉）")
  println("ok")
}
