// mooncassette 异步适配层 —— 端到端示例。
//
// 演示两件事，而且都要看得见：
//
// 1. **真的走了网络**：用一个本地 HTTP 服务端（node 自带）假扮 LLM API，
//    客户端是 MoonBit 侧的异步客户端，链路上「把报文发出去」这一步确实过了一个 socket；
// 2. **录完之后不再需要网络**：关掉服务端，再回放一次，结果逐字节相同 ——
//    而且回放阶段用的是**一个拒绝发送的发送器**，所以「没有发起真实调用」
//    不是一句承诺，而是一条会被立刻触发的断言。
//
// 服务端为什么用 node 而不是 MoonBit：`@http.Server` 只在 native 上可用
// （其官方文档里的服务端示例就带 `#cfg(target="native")`），而本机没有 C 编译器。
// 服务端在这里只是脚手架，被测的是客户端与适配层，因此这个取舍不影响结论。

///|
/// 起一个 node http 服务端，把固定报文原样回答给每个请求。
///
/// 端口用 0 让系统分配：写死端口会在端口被占用时得到一个与本次改动毫无关系的失败。
/// 请求计数记在 `globalThis` 上，这样「客户端确实发了」不靠猜。
extern "js" fn start_local_server(body : String, status : Int) -> Unit =
  #| function(body, status) {
  #|   const http = require("node:http");
  #|   globalThis.__mooncassette_served = 0;
  #|   const server = http.createServer((req, res) => {
  #|     req.resume();
  #|     req.on("end", () => {
  #|       globalThis.__mooncassette_served += 1;
  #|       res.writeHead(status, { "Content-Type": "application/json" });
  #|       res.end(body);
  #|     });
  #|   });
  #|   server.listen(0, "127.0.0.1");
  #|   globalThis.__mooncassette_server = server;
  #| }

///|
extern "js" fn local_server_port() -> Int =
  #| function() {
  #|   const server = globalThis.__mooncassette_server;
  #|   return server && server.address() ? server.address().port : 0;
  #| }

///|
extern "js" fn served_count() -> Int =
  #| function() { return globalThis.__mooncassette_served || 0; }

///|
/// 关闭服务端。
extern "js" fn stop_local_server() -> Unit =
  #| function() {
  #|   const server = globalThis.__mooncassette_server;
  // `close()` 只是不再接受**新**连接；已经建立的连接可能还挂着，不显式销毁的话
  // node 进程会因为仍有活动连接而不退出（表现为示例「跑完了但不返回」）。
  #|   if (server) {
  #|     if (server.closeAllConnections) { server.closeAllConnections(); }
  #|     server.close();
  #|   }
  // 真服务器关掉之后，那个端口上就再也没人监听了。
  #|   globalThis.__mooncassette_server = null;
  #| }

///|
/// 本地服务端回答的报文，形状与 OpenAI 一致。
let answer_body : String = "{\"id\":\"chatcmpl-local\",\"object\":\"chat.completion\",\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"这是本地服务端的回答\"},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":11,\"completion_tokens\":7,\"total_tokens\":18}}"

///|
fn chat_request(prompt : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("user"))
  message.set("content", Json::string(prompt))
  body.set("messages", Json::array([Json::object(message)]))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
/// 一个**拒绝发送**的发送器。
///
/// 回放阶段用它，是为了把「没有发起真实调用」从一句承诺变成一条断言：
/// 只要回放期间有任何一步碰了网络，它就会立刻失败。
async fn refuse_to_send(
  _request : @providers.HttpRequest,
) -> @providers.HttpResponse raise @core.CassetteError {
  raise @core.CassetteError::TransportFailure(
    "replay graded a path that tried to make a real call",
  )
}

///|
async fn main {
  // ── 1. 起本地服务端 ─────────────────────────────────────────────────────
  start_local_server(answer_body, 200)
  // 等它完成绑定。`listen` 是异步的，端口要等 listen 回调之后才拿得到；
  // 这里用一次短睡眠换掉一整套回调桥接 —— 示例的价值在于把链路讲清楚，
  // 不在于把事件循环的细节也重写一遍。
  @async.sleep(100)
  let port = local_server_port()
  if port == 0 {
    println("本地服务端没有起来，示例无法继续")
    return
  }
  println("本地服务端已在 127.0.0.1:" + port.to_string() + " 监听")

  // ── 2. 用异步客户端录一次真实调用 ───────────────────────────────────────
  //
  // `base_url` 指向本地服务端：协议本身不需要知道这件事，编码出来的报文与
  // 发给真实 API 的**完全同形** —— 这也正是它能被录下来、之后再回放的前提。
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new(
    "sk-demo-key",
    base_url="http://127.0.0.1:" + port.to_string(),
  )
  let request = chat_request("用一句话说明异步客户端怎么接进来。")
  let recording = @recorder.Session::new(
    @core.Cassette::new("async-demo", recorded_at="2026-09-13T00:00:00Z"),
  )
  let live = @adapter.replay_or_record(
    recording,
    request,
    protocol,
    @adapter.send_with_async_http,
  ) catch {
    error => {
      println("录制失败：" + error.to_string())
      stop_local_server()
      return
    }
  }
  println(
    "录制完成：服务端收到 " +
    served_count().to_string() +
    " 次请求，回答 " +
    live.body.to_string().length().to_string() +
    " 字节（原样 JSON）",
  )
  println(
    "cassette 里现在有 " +
    recording.cassette().length().to_string() +
    " 条记录，编码后 " +
    @codec.encode(recording.cassette()).length().to_string() +
    " 字符",
  )

  // ── 3. 关掉服务端 ───────────────────────────────────────────────────────
  stop_local_server()
  println("服务端已关闭：那个端口上现在没有人监听")

  // ── 4. 离线回放，并用「拒绝发送」证明它没有碰网络 ───────────────────────
  let replay = @recorder.Session::new(recording.cassette())
  let replayed = @adapter.replay_or_record(
    replay,
    request,
    protocol,
    refuse_to_send,
  ) catch {
    error => {
      println("回放失败：" + error.to_string())
      return
    }
  }
  println(
    "回放完成：服务端累计收到 " +
    served_count().to_string() +
    " 次请求（没有增加）",
  )
  if replayed.body == live.body {
    println("回放结果与录制结果逐字节一致")
  } else {
    println("回放结果与录制结果不一致 —— 这是缺陷")
  }
  println("ok")
}
