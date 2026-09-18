// 限流重试示例：为什么「错误响应」也必须被录下来。
//
// 运行：
//   moon run examples/rate_limit_retry --target js
//
// 场景很常见：第一次调用被限流（429），退避后重试成功（200）。
//
// 如果只录「最终成功」，能被离线回归的也只有「最终成功」。把 429 一起录下来
// 之后，**重试路径本身**也进入了回归范围 —— 而重试逻辑恰恰是写错了也不会
// 立刻暴露的那类代码：少重试一次、多重试一次、或对不该重试的错误重试，
// 「最终成功」的断言全都不会变红。

///|
let output_path : String = "examples/rate_limit_retry.cassette.json"

///|
/// 429 的响应体，按 OpenAI 的真实形状（含 `code` 字段，重试逻辑通常依据它）。
let rate_limited_body : String = "{\"error\":{\"message\":\"Rate limit reached for gpt-4o on requests per min (RPM): Limit 3, Used 3, Requested 1.\",\"type\":\"rate_limit_error\",\"param\":null,\"code\":\"rate_limit_exceeded\"}}"

///|
/// 重试成功后的报文。
let ok_body : String = "{\"id\":\"chatcmpl-retry\",\"object\":\"chat.completion\",\"created\":1677652288,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"你好！我是月兔助手。\"},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":9,\"completion_tokens\":5,\"total_tokens\":14}}"

///|
fn chat_request(content : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  let messages : Array[Json] = []
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("user"))
  message.set("content", Json::string(content))
  messages.push(Json::object(message))
  body.set("messages", Json::array(messages))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
/// 朴素的「遇到 429 就再试」包装。
///
/// 重试逻辑属于业务侧，mooncassette 只负责让这条路径能被离线回归 ——
/// 这里把它写成普通函数，正是为了说明「引擎不介入业务逻辑」。
fn call_with_retry(
  session : @recorder.Session,
  request : @core.Request,
  max_attempts : Int,
) -> @core.Response raise @core.CassetteError {
  let mut attempt = 1
  let mut response = session.send(request)
  while response.status == 429 && attempt < max_attempts {
    println("    attempt " + attempt.to_string() + " -> 429, retrying")
    attempt = attempt + 1
    response = session.send(request)
  }
  response
}

///|
/// 调一次，并把「成功」或「失败的种类」描述成一行文字。
///
/// 把抛错也当成一种结果来展示，是因为**失败的种类本身就是信息**：
/// 「录制条数不够」要补录制，「请求对不上」要改请求或换匹配策略。
fn describe_call(
  session : @recorder.Session,
  request : @core.Request,
) -> String {
  let response = session.send(request) catch {
    error => return describe_error(error)
  }
  "status " + response.status.to_string()
}

///|
fn describe_error(error : @core.CassetteError) -> String {
  match error {
    @core.CassetteError::Exhausted(_) =>
      "Exhausted —— 录制条数不够，应补录制"
    @core.CassetteError::NoMatch(_) =>
      "NoMatch —— 请求对不上，应改请求或换匹配策略"
    _ => "error: " + error.to_string()
  }
}

///|
fn print_statuses(cassette : @core.Cassette) -> Unit {
  println(
    "  recorded     : " + cassette.length().to_string() + " interaction(s)",
  )
  for i = 0; i < cassette.length(); i = i + 1 {
    println(
      "    #" +
      i.to_string() +
      " status=" +
      cassette.interactions[i].response.status.to_string(),
    )
  }
}

///|
fn main {
  // ── 第一步：录制。同一个请求，先 429 再 200 ────────────────────────
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new(
    "sk-demo-key",
  )
  let sender = @providers.ScriptedHttpSender::new()
  let request = chat_request("你好，请介绍一下自己")
  let outgoing = protocol.encode(request) catch {
    error => {
      println("encode failed: " + error.to_string())
      return
    }
  }
  // 关键的一步：给**同一个请求**登记一串应答，而不是一个应答。
  sender.on_sequence(outgoing, [
    @providers.HttpResponse::new(429, rate_limited_body),
    @providers.HttpResponse::new(200, ok_body),
  ])

  let transport = @providers.ProviderTransport::new(protocol, sender)
  let session = @mooncassette.record_session(
    @core.Cassette::new("rate-limit-retry", recorded_at="2026-09-13T12:00:00Z"),
    transport,
  )
  println("recording:")
  let response = call_with_retry(session, request, 3) catch {
    error => {
      println("  failed: " + error.to_string())
      return
    }
  }
  println("  final status : " + response.status.to_string())
  println("  answer       : " + @canon.to_canonical_string(response.body))
  println("  http calls   : " + sender.call_count().to_string())
  print_statuses(session.cassette())

  // ── 第二步：落盘。429 与 200 都在文件里 ──────────────────────────
  let text = @mooncassette.save(session)
  @fs.write_string_to_file(output_path, text) catch {
    _ => println("failed to write " + output_path)
  }
  println("written      : " + output_path)

  // ── 第三步：离线回放。同样的重试代码，零网络 ──────────────────────
  let playback = @mooncassette.replay_session(text) catch {
    error => {
      println("load failed: " + error.to_string())
      return
    }
  }
  println("replaying (default ring policy):")
  let replayed = call_with_retry(playback, request, 3) catch {
    error => {
      println("  failed: " + error.to_string())
      return
    }
  }
  println("  final status : " + replayed.status.to_string())
  println("  answer       : " + @canon.to_canonical_string(replayed.body))
  // 与录制阶段同一个数字：回放没有发起任何网络调用。
  println("  http calls   : " + sender.call_count().to_string())
  println("  retry path reproduced: yes")

  // ── 第四步：调用次数多于录制条数时，两种策略的差别 ────────────────
  // 环形策略（默认）会回卷复用最早的一条，因此第三次调用又拿到 429。
  // 这在「稳态场景下调用次数本就不固定」时是有用的，但也会掩盖「录制不足」。
  println("one call too many, ring policy:")
  println("  " + describe_call(playback, request))

  // 顺序策略不做回卷：游标越界即代表录制条数不够，如实报出来。
  // 两种失败的修法不同 —— 这就是把它们分开的理由。
  let raw = @codec.decode(text) catch {
    error => {
      println("load failed: " + error.to_string())
      return
    }
  }
  let strict = @recorder.Session::new(
    raw,
    mode=@recorder.Mode::Playback,
    policy=@matcher.MatchPolicy::Sequential,
  )
  println("one call too many, sequential policy:")
  println("  first  : " + describe_call(strict, request))
  println("  second : " + describe_call(strict, request))
  println("  third  : " + describe_call(strict, request))
  println("ok")
}
