// 离线示例：完整走一遍「录制 → 落盘 → 回放」，全程不联网、不需要密钥。
//
// 运行：
//   moon run examples/offline_demo --target js
//
// 这个例子本身就是项目的价值主张：演示用的 cassette 一旦生成，
// 后续所有验证都可以在没有网络、没有密钥的环境里重复执行。

///|
let output_path : String = "examples/demo.cassette.json"

///|
/// 第二份录制：模拟「模型换了版本」，用于演示漂移检测。
let drifted_path : String = "examples/demo.drifted.cassette.json"

///|
/// 构造一个请求（含一个会泄漏密钥的字段，用来演示脱敏）。
fn request_of(content : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("api_key", Json::string("sk-abcdefgh12345678"))
  let messages : Array[Json] = []
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("user"))
  message.set("content", Json::string(content))
  messages.push(Json::object(message))
  body.set("messages", Json::array(messages))
  // 易变字段：每次调用都不同，规范化时会被剔除，不会影响指纹命中。
  body.set("request_id", Json::string("req-" + content.length().to_string()))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
fn chat_response(
  text : String,
  input_tokens : Int,
  output_tokens : Int,
) -> @core.Response {
  let body : Map[String, Json] = Map([])
  let choices : Array[Json] = []
  let choice : Map[String, Json] = Map([])
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("assistant"))
  message.set("content", Json::string(text))
  choice.set("message", Json::object(message))
  choices.push(Json::object(choice))
  body.set("choices", Json::array(choices))
  @core.Response::ok(
    Json::object(body),
    usage=@core.Usage::new(input_tokens, output_tokens),
  )
}

///|
fn main {
  // ── 第一步：录制 ──────────────────────────────────────────────────
  // 真实项目里这里换成你的 HTTP Transport；本例用脚本化的 MockTransport，
  // 以便在没有密钥的机器上也能完整演示。
  let transport = @recorder.MockTransport::new()
  transport.on(
    request_of("你好，请介绍一下自己"),
    chat_response("你好！我是月兔助手。", 12, 9),
  )
  transport.on(
    request_of("第二个问题"),
    chat_response("这是第二个回答。", 8, 7),
  )

  let session = @mooncassette.record_session(
    @core.Cassette::new("offline-demo", recorded_at="2026-09-12T08:00:00Z"),
    transport,
  )
  let _ = session.send(request_of("你好，请介绍一下自己")) catch {
    _ => panic()
  }
  let _ = session.send(request_of("第二个问题")) catch { _ => panic() }
  let text = @mooncassette.save(session)
  @fs.write_string_to_file(output_path, text) catch {
    _ => {
      println("failed to write " + output_path)
      return
    }
  }
  let stats = session.stats()
  println("recorded : " + stats.recorded.to_string() + " interaction(s)")
  println("written  : " + output_path)
  println(
    "transport calls during recording: " + transport.call_count().to_string(),
  )

  // ── 第二步：回放 ──────────────────────────────────────────────────
  // 关键点：这个会话**没有** transport，物理上不可能发起真实调用。
  let playback = @mooncassette.replay_session(text) catch {
    error => {
      println("failed to load cassette: " + error.to_string())
      return
    }
  }
  let replayed = playback.send(request_of("你好，请介绍一下自己")) catch {
    error => {
      println("replay failed: " + error.to_string())
      return
    }
  }
  println("replayed : " + @canon.to_canonical_string(replayed.body))
  let playback_stats = playback.stats()
  println("replay hits: " + playback_stats.hits.to_string())

  // ── 第三步：漂移检测 ──────────────────────────────────────────────
  // 模拟「模型换了版本」：同一批请求，第一个问题的答案变了。
  // 注意这里的代码一行没改 —— 输出却变了，这正是漂移检测要捕获的情形。
  let revised_transport = @recorder.MockTransport::new()
  revised_transport.on(
    request_of("你好，请介绍一下自己"),
    chat_response("嗨，我是助手。", 12, 6),
  )
  revised_transport.on(
    request_of("第二个问题"),
    chat_response("这是第二个回答。", 8, 7),
  )
  let revised = @mooncassette.record_session(
    @core.Cassette::new("offline-demo-v2", recorded_at="2026-09-12T09:00:00Z"),
    revised_transport,
  )
  let _ = revised.send(request_of("你好，请介绍一下自己")) catch {
    _ => panic()
  }
  let _ = revised.send(request_of("第二个问题")) catch { _ => panic() }

  // 把 v2 也落盘，这样 CLI 的 `diff` 可以直接用仓库里的两个文件演示。
  @fs.write_string_to_file(drifted_path, @mooncassette.save(revised)) catch {
    _ => println("failed to write " + drifted_path)
  }

  let report = @mooncassette.compare_recordings(
    session.cassette(),
    revised.cassette(),
  )
  println("")
  println("drift report (v1 -> v2):")
  for line in report.lines() {
    println("  " + line)
  }
  println("  " + report.summary())
  println("ok")
}
