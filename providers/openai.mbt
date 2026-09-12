// mooncassette/providers —— OpenAI Chat Completions 协议。
//
// 之所以把这个协议做成第一个适配器：它是事实标准。DeepSeek、Moonshot、
// 通义、vLLM、Ollama 的 OpenAI 兼容端点都用同一套形状，换一个 `base_url`
// 即可，因此这一个适配器覆盖面很广。

///|
/// OpenAI `/chat/completions` 协议。
pub struct OpenAiChat {
  base_url : String
  api_key : String
}

///|
/// 协议标识。
pub let openai_protocol_id : String = "openai.chat"

///|
/// 构造协议。
///
/// `base_url` 省略时使用官方地址 `https://api.openai.com/v1`；
/// 接入兼容端点时传入例如 `https://api.deepseek.com/v1`（注意不要带尾斜杠）。
pub fn OpenAiChat::new(api_key : String, base_url? : String) -> OpenAiChat {
  {
    base_url: match base_url {
      Some(url) => url
      None => "https://api.openai.com/v1"
    },
    api_key,
  }
}

///|
/// 请求的目标地址。
pub fn OpenAiChat::endpoint(self : OpenAiChat) -> String {
  self.base_url + "/chat/completions"
}

///|
/// 请求头。
///
/// 抽成独立函数是为了能在测试里直接断言「密钥确实进了鉴权头」，
/// 而不必把整条 HTTP 请求拆开。
pub fn OpenAiChat::auth_headers(self : OpenAiChat) -> Array[(String, String)] {
  [
    ("content-type", "application/json"),
    ("authorization", "Bearer " + self.api_key),
  ]
}

///|
/// 解码：HTTP 响应 → 统一响应。
///
/// 独立成自由函数，因为 OpenAI 的响应形状不随 `base_url` 变化，
/// 解码不需要协议实例参与；这样也避免了一个「签名更宽、实际用不到」
/// 的方法把接口搞复杂。
///
/// 错误状态码同样正常返回（并把错误体一并保留），因为「限流时怎么办」
/// 也需要回归测试。
pub fn decode_openai_response(response : HttpResponse) -> @core.Response {
  let body = parse_body_or_raw(response.body)
  let usage = match as_object(body) {
    // 注意字段名差异：OpenAI 叫 prompt_tokens / completion_tokens，
    // 而统一模型采用 input / output。
    Some(fields) =>
      usage_of(fields, "usage", "prompt_tokens", "completion_tokens")
    None => None
  }
  { status: response.status, body, usage }
}

///|
pub impl Protocol for OpenAiChat with fn name(_self) {
  openai_protocol_id
}

///|
/// 编码：统一请求 → HTTP 请求。
///
/// 请求体使用**规范文本**序列化（对象键排序）。这样「实际发出的字节」
/// 与「cassette 里记录的字节」完全一致，服务端也不关心键序。
pub impl Protocol for OpenAiChat with fn encode(self, request) {
  check_model_consistency(request)
  HttpRequest::new(
    "POST",
    self.endpoint(),
    self.auth_headers(),
    @canon.to_canonical_string(request.body),
  )
}

///|
pub impl Protocol for OpenAiChat with fn decode(_self, response) {
  decode_openai_response(response)
}
