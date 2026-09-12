// 流式示例：SSE 报文 → 录制（逐帧递给应用）→ 落盘 → 离线逐帧回放 → 成本汇总。
//
// 运行：
//   moon run examples/streaming_demo --target js
//
// 本示例用 ScriptedHttpSender 代替真实网络，因此无需密钥、无需联网。
// 换成真实客户端时，只需要替换 `sender` 一个对象，其余代码一行都不用改。
//
// 它要展示的核心点：录制时应用是「逐块」拿到数据的，回放时也应该逐块拿到 ——
// 这样「逐块渲染」那段最容易出错的代码在离线测试里也会被真正跑到。

///|
let output_path : String = "examples/streaming.cassette.json"

///|
/// 一段真实形状的 OpenAI 流式响应（SSE）。
///
/// 包含：角色增量、两段文本增量、结束帧、以及只在最后一帧出现的 `usage`。
/// 最后一帧的 `choices` 是空数组 —— OpenAI 把用量放在一个没有内容的帧里。
fn openai_stream() -> String {
  let chunks : Array[String] = [
    "{\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\",\"created\":1677652288,\"model\":\"gpt-4o\",\"system_fingerprint\":\"fp_demo\",\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\",\"content\":\"\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\",\"created\":1677652288,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"你好\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\",\"created\":1677652288,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"！我是月兔助手。\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\",\"created\":1677652288,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}",
    "{\"id\":\"chatcmpl-stream\",\"object\":\"chat.completion.chunk\",\"created\":1677652288,\"model\":\"gpt-4o\",\"choices\":[],\"usage\":{\"prompt_tokens\":9,\"completion_tokens\":5,\"total_tokens\":14}}",
  ]
  let sb = StringBuilder::new()
  for chunk in chunks {
    sb.write_string("data: ")
    sb.write_string(chunk)
    sb.write_string("\n\n")
  }
  sb.write_string("data: [DONE]\n\n")
  sb.to_string()
}

///|
fn chat_request(content : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("stream", Json::boolean(true))
  let messages : Array[Json] = []
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("user"))
  message.set("content", Json::string(content))
  messages.push(Json::object(message))
  body.set("messages", Json::array(messages))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
fn main {
  // ── 第一步：协议 + HTTP 执行器 ────────────────────────────────────
  // api_key 只进入 HTTP 头，因此永远不会进入 cassette。
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
  println("http request  : " + outgoing.method_name() + " " + outgoing.url)
  sender.on(outgoing, @providers.HttpResponse::new(200, openai_stream()))

  // ── 第二步：录制，并逐帧递给应用 ──────────────────────────────────
  // `replay_stream` 在三种模式下语义一致：先拿到响应，再重放其中的帧。
  // 递帧的顺序就是它们在线上到达的顺序。
  let transport = @providers.ProviderTransport::new(protocol, sender)
  let session = @mooncassette.record_session(
    @core.Cassette::new("streaming-demo", recorded_at="2026-09-12T11:00:00Z"),
    transport,
  )
  let delivered : Array[String] = []
  let response = session.replay_stream(request, fn(frame) {
    let label = "chunk " + (delivered.length() + 1).to_string() + ": "
    let event = match frame.event {
      Some(name) => "event=" + name + " "
      None => ""
    }
    println("  " + label + event + frame.data)
    delivered.push(frame.data)
  }) catch {
    error => {
      println("send failed: " + error.to_string())
      return
    }
  }
  println("http status   : " + response.status.to_string())
  println("frames        : " + delivered.length().to_string())
  println("answer        : " + @canon.to_canonical_string(response.body))

  // ── 第三步：落盘 + 成本汇总 ───────────────────────────────────────
  let text = @mooncassette.save(session)
  @fs.write_string_to_file(output_path, text) catch {
    _ => println("failed to write " + output_path)
  }
  println("written       : " + output_path)

  // 价目表由使用方提供（单位：微美元 / 百万 token），库里刻意不内置价格。
  let table = @cost.PriceTable::new()
  table.set("gpt-4o", @cost.Price::new(2_500_000, 10_000_000))
  println(
    "cost          : " +
    @cost.estimate_cassette(table, session.cassette()).render(),
  )

  // ── 第四步：离线逐帧回放 ─────────────────────────────────────────
  // 回放会话不持有任何 HttpSender，因此不可能发起网络调用。
  let playback = @mooncassette.replay_session(text) catch {
    error => {
      println("load failed: " + error.to_string())
      return
    }
  }
  let replayed : Array[String] = []
  let _ = playback.replay_stream(request, fn(frame) {
    replayed.push(frame.data)
  }) catch {
    error => {
      println("replay failed: " + error.to_string())
      return
    }
  }
  println("http calls    : " + sender.call_count().to_string())
  // 录制时递给应用的帧与回放时递给应用的帧必须逐帧一致，否则「回放」只是近似。
  if replayed == delivered {
    println(
      "frames equal  : yes (" + replayed.length().to_string() + " frames)",
    )
  } else {
    println("frames equal  : NO")
  }
  println("ok")
}
