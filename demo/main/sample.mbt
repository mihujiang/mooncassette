// mooncassette Demo —— 自带样例。
//
// 为什么用构造函数生成，而不是内嵌一段 cassette 文本：
//
// - 内嵌文本必须与落盘格式**逐字节**保持一致，抄进源码之后会随格式演进而悄悄
//   过期，而过期的表现是「点开自带样例就报错」—— 最难看的一种坏法；
// - 生成则永远与当前格式一致，而且「这份录制里有什么」在源码里一望便知。
//
// 自带样例的存在意义是**零准备**：打开页面就能点，不必先去找一个文件。
// 真实文件仍然走界面上的文件输入，两条路径共用同一个解码入口。

///|
fn user_message(role : String, content : String) -> Json {
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string(role))
  message.set("content", Json::string(content))
  Json::object(message)
}

///|
fn chat_request(prompt : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("temperature", Json::number(0.2))
  body.set("messages", Json::array([user_message("user", prompt)]))
  @core.Request::new("openai", "gpt-4o", Json::object(body))
}

///|
fn chat_answer(id : String, content : String) -> Json {
  let choice : Map[String, Json] = Map([])
  choice.set("index", Json::number(0))
  choice.set(
    "message",
    Json::object({
      "role": Json::string("assistant"),
      "content": Json::string(content),
    }),
  )
  choice.set("finish_reason", Json::string("stop"))
  let body : Map[String, Json] = Map([])
  body.set("id", Json::string(id))
  body.set("model", Json::string("gpt-4o"))
  body.set("choices", Json::array([Json::object(choice)]))
  Json::object(body)
}

///|
/// 一条普通（非流式）记录。
fn plain_interaction(answer : String) -> @core.Interaction {
  @core.Interaction::new(
    chat_request("用一句话说明什么是确定性回放。"),
    @core.Response::ok(
      chat_answer("chatcmpl-plain", answer),
      usage=@core.Usage::new(38, 24),
    ),
  )
}

///|
/// 一条流式记录。
///
/// 需要说清楚的是：`body` 存的是**聚合后的最终结果**，与普通响应同形；`stream`
/// 只是额外保留了分片。因此「是不是流式」不影响匹配、漂移检测与成本核算，
/// 只影响能不能按帧重放。
fn streaming_interaction(prefix : String) -> @core.Interaction {
  let frames : Array[@core.StreamFrame] = [
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{\"content\":\"" + prefix + "\"}}]}",
    ),
    @core.StreamFrame::new("{\"choices\":[{\"delta\":{\"content\":\"。\"}}]}"),
    @core.StreamFrame::new("[DONE]"),
  ]
  @core.Interaction::new(
    chat_request("请分两步说明：先给结论，再给理由。"),
    @core.Response::ok(
      chat_answer("chatcmpl-stream", prefix + "。"),
      usage=@core.Usage::new(41, 96),
      stream=frames,
    ),
  )
}

///|
/// 一条被限流的记录。
///
/// 错误响应同样会被录下来 —— 这一点值得在界面上看得见：只录「最终成功」的话，
/// 重试逻辑写错了不会被任何测试发现。
fn rate_limited_interaction() -> @core.Interaction {
  let error : Map[String, Json] = Map([])
  error.set("message", Json::string("Rate limit reached for gpt-4o"))
  error.set("type", Json::string("rate_limit_error"))
  error.set("code", Json::string("rate_limit_exceeded"))
  let body : Map[String, Json] = Map([])
  body.set("error", Json::object(error))
  @core.Interaction::new(
    chat_request("再问一次同样的问题。"),
    @core.Response::new(429, Json::object(body)),
  )
}

///|
/// 自带样例：三条记录，覆盖「普通」「流式」「被限流」三种形态。
pub fn sample_text() -> String {
  @codec.encode(
    @core.Cassette::new(
      "demo",
      recorded_at="2026-09-13T00:00:00Z",
      interactions=[
        plain_interaction("确定性回放指的是：不重新调用模型，只按录制好的响应逐字节重演。"),
        streaming_interaction("结论：它把外部依赖变成可离线运行的测试"),
        rate_limited_interaction(),
      ],
    ),
  )
}

///|
/// 默认的诊断输入：与样例第一条请求几乎相同，只有模型名不同。
///
/// 刻意让默认输入**能看出差异**：模型名对不上是「匹配不上」最常见的原因
/// （录的是 `gpt-4o`，请求却写成了 `gpt-4o-mini`），一进诊断页就能看到它被
/// 指出来 —— 而填一个必然命中的请求，什么也演示不了。
pub fn miss_query_text() -> String {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o-mini"))
  body.set("temperature", Json::number(0.2))
  body.set(
    "messages",
    Json::array([user_message("user", "用一句话说明什么是确定性回放。")]),
  )
  @canon.to_pretty_string(
    @core.Request::new("openai", "gpt-4o-mini", Json::object(body)).to_json(),
  )
}

///|
/// 一份**含密钥**的录制，用来演示脱敏。
///
/// 它是手工构造的，因此绕过了录制链路上的脱敏 —— 这正是「文件来自别处、
/// 未经脱敏」的样子。真实的录制路径会在写入前就抹掉这些字段，所以正常产出的
/// cassette 里看不到它们。
pub fn leaky_text() -> String {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string("gpt-4o"))
  body.set("api_key", Json::string("sk-abcdefgh12345678"))
  body.set("authorization", Json::string("Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig"))
  body.set(
    "messages",
    Json::array([user_message("user", "帮我查一下订单。")]),
  )
  let answer : Map[String, Json] = Map([])
  answer.set("access_token", Json::string("ya29.a0AfH6SMBsecretvalue"))
  answer.set("content", Json::string("已查询，安全字段会保留。"))
  @codec.encode(
    @core.Cassette::new(
      "leaky",
      recorded_at="2026-09-13T00:00:00Z",
      interactions=[
        @core.Interaction::new(
          @core.Request::new("openai", "gpt-4o", Json::object(body)),
          @core.Response::ok(Json::object(answer)),
        ),
      ],
    ),
  )
}

///|
/// 另一份样例：模型换了版本之后，第二条回答变了。
///
/// 只改**响应**、不改请求，正是「行为漂移」的定义：请求没变而结果变了。
/// 界面上的漂移对比要能一眼把它挑出来。
pub fn drifted_text() -> String {
  @codec.encode(
    @core.Cassette::new(
      "demo",
      recorded_at="2026-09-13T00:00:00Z",
      interactions=[
        plain_interaction("确定性回放指的是：不重新调用模型，只按录制好的响应逐字节重演。"),
        streaming_interaction("结论：它把外部依赖变成了可离线运行、且可复现的测试"),
        rate_limited_interaction(),
      ],
    ),
  )
}
