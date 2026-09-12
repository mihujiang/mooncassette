// mooncassette/providers —— Anthropic Messages 协议。
//
// 与 OpenAI 的三处关键差异，都在这里被吸收掉：
//   1. 路径是 `/messages` 而不是 `/chat/completions`；
//   2. 鉴权用 `x-api-key` 头，且必须带 `anthropic-version`；
//   3. usage 字段直接就叫 `input_tokens` / `output_tokens`（与统一模型同名）。

///|
/// 默认的 API 版本。Anthropic 要求显式声明，否则请求会被拒绝。
pub let default_anthropic_version : String = "2023-06-01"

///|
/// 协议标识。
pub let anthropic_protocol_id : String = "anthropic.messages"

///|
/// Anthropic `/messages` 协议。
pub struct AnthropicMessages {
  base_url : String
  api_key : String
  version : String
}

///|
/// 构造协议。
///
/// `base_url` 省略时使用官方地址 `https://api.anthropic.com/v1`。
pub fn AnthropicMessages::new(
  api_key : String,
  base_url? : String,
  version? : String,
) -> AnthropicMessages {
  {
    base_url: match base_url {
      Some(url) => url
      None => "https://api.anthropic.com/v1"
    },
    api_key,
    version: match version {
      Some(value) => value
      None => default_anthropic_version
    },
  }
}

///|
/// 请求的目标地址。
pub fn AnthropicMessages::endpoint(self : AnthropicMessages) -> String {
  self.base_url + "/messages"
}

///|
/// 请求头。
pub fn AnthropicMessages::auth_headers(
  self : AnthropicMessages,
) -> Array[(String, String)] {
  [
    ("content-type", "application/json"),
    ("x-api-key", self.api_key),
    ("anthropic-version", self.version),
  ]
}

///|
/// 解码：HTTP 响应 → 统一响应。
///
/// 独立成自由函数，理由同 OpenAI：响应形状与 `base_url` 无关。
///
/// 流式响应会自动识别并聚合，判据与 OpenAI 相同（见
/// `decode_openai_response` 的说明）。
pub fn decode_anthropic_response(response : HttpResponse) -> @core.Response {
  if @stream.looks_like_event_stream(response.body) {
    return decode_anthropic_stream_response(response)
  }
  let body = parse_body_or_raw(response.body)
  let usage = match as_object(body) {
    Some(fields) => usage_of(fields, "usage", "input_tokens", "output_tokens")
    None => None
  }
  { status: response.status, body, usage, stream: None }
}

///|
pub impl Protocol for AnthropicMessages with fn name(_self) {
  anthropic_protocol_id
}

///|
/// 编码：统一请求 → HTTP 请求。
pub impl Protocol for AnthropicMessages with fn encode(self, request) {
  check_model_consistency(request)
  HttpRequest::new(
    "POST",
    self.endpoint(),
    self.auth_headers(),
    @canon.to_canonical_string(request.body),
  )
}

///|
pub impl Protocol for AnthropicMessages with fn decode(_self, response) {
  decode_anthropic_response(response)
}
