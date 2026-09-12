// 协议路径示例：真实 provider 报文 → 录制 → 落盘 → 离线回放。
//
// 运行：
//   moon run examples/openai_protocol --target js
//
// 本示例用 ScriptedHttpSender 代替真实网络，因此无需密钥、无需联网。
// 换成真实客户端时，只需要替换 `sender` 一个对象：
//
//   let sender : &@providers.HttpSender = MyHttpSender::new(...)
//
// 其余代码（协议、录制、回放、漂移检测）一行都不用改。

///|
let output_path : String = "examples/openai_protocol.cassette.json"

///|
/// 一份真实形状的 OpenAI 成功响应。
/// 使用**未排序**的键，顺便验证解码不依赖键序。
let openai_ok_body : String = "{\"usage\":{\"total_tokens\":21,\"completion_tokens\":12,\"prompt_tokens\":9},\"model\":\"gpt-4o\",\"object\":\"chat.completion\",\"id\":\"chatcmpl-demo\",\"created\":1677652288,\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"你好！我是月兔助手。\"},\"index\":0,\"finish_reason\":\"stop\"}]}"

///|
fn chat_request(content : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("temperature", Json::number(0.7))
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
  // api_key 只进入 HTTP 头，因此**永远不会**进入 cassette。
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new(
    "sk-demo-key",
  )
  let sender = @providers.ScriptedHttpSender::new()

  let request = chat_request("你好，请介绍一下自己")
  // 预登记一条响应：键是「协议编码后即将发出的那条 HTTP 请求」。
  let outgoing = protocol.encode(request) catch {
    error => {
      println("encode failed: " + error.to_string())
      return
    }
  }
  println("http request  : " + outgoing.method_name() + " " + outgoing.url)
  sender.on(outgoing, @providers.HttpResponse::new(200, openai_ok_body))

  // ── 第二步：录制 ──────────────────────────────────────────────────
  let transport = @providers.ProviderTransport::new(protocol, sender)
  let session = @mooncassette.record_session(
    @core.Cassette::new(
      "openai-protocol-demo",
      recorded_at="2026-09-12T10:00:00Z",
    ),
    transport,
  )
  let response = session.send(request) catch {
    error => {
      println("send failed: " + error.to_string())
      return
    }
  }
  println("http status   : " + response.status.to_string())
  let usage = match response.usage {
    Some(usage) => usage
    None => {
      println("response carried no usage field")
      return
    }
  }
  println(
    "usage         : in=" +
    usage.input_tokens.to_string() +
    " out=" +
    usage.output_tokens.to_string(),
  )
  println("answer        : " + @canon.to_canonical_string(response.body))

  // ── 第三步：落盘 ──────────────────────────────────────────────────
  // 注意：cassette 里既没有 api_key，也没有任何 HTTP 层细节 ——
  // 记录的是**统一请求/响应**，这正是它与「抓包」的本质区别。
  let text = @mooncassette.save(session)
  @fs.write_string_to_file(output_path, text) catch {
    _ => println("failed to write " + output_path)
  }
  println("written       : " + output_path)

  // ── 第四步：离线回放 ──────────────────────────────────────────────
  // 回放会话不持有任何 HttpSender，因此不可能发起网络调用。
  let playback = @mooncassette.replay_session(text) catch {
    error => {
      println("load failed: " + error.to_string())
      return
    }
  }
  let replayed = playback.send(request) catch {
    error => {
      println("replay failed: " + error.to_string())
      return
    }
  }
  println("replayed      : " + @canon.to_canonical_string(replayed.body))
  println("http calls    : " + sender.call_count().to_string())
  println("ok")
}
