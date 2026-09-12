// mooncassette/providers —— 协议适配器契约测试。
//
// 这里的响应报文刻意采用**真实 API 的形状**（字段名、嵌套层级、错误体），
// 这样即便没有网络与密钥，也能验证「真实场景下能不能正确解析」。

// ---------------------------------------------------------------------------
// 辅助构造

///|
/// 构造一个 OpenAI 兼容的请求体（含 model 字段）。
fn chat_request(model : String, content : String) -> @core.Request {
  let body : Map[String, Json] = Map([])
  body.set("model", Json::string(model))
  let messages : Array[Json] = []
  let message : Map[String, Json] = Map([])
  message.set("role", Json::string("user"))
  message.set("content", Json::string(content))
  messages.push(Json::object(message))
  body.set("messages", Json::array(messages))
  @core.Request::new("openai", model, Json::object(body))
}

///|
/// 一个真实形状的 OpenAI 成功响应。
let openai_ok_body : String = "{\"choices\":[{\"finish_reason\":\"stop\",\"index\":0,\"message\":{\"content\":\"Hello\",\"role\":\"assistant\"}}],\"created\":1677652288,\"id\":\"chatcmpl-123\",\"model\":\"gpt-4o\",\"object\":\"chat.completion\",\"usage\":{\"completion_tokens\":12,\"prompt_tokens\":9,\"total_tokens\":21}}"

///|
/// 一个真实形状的 OpenAI 限流响应。
let openai_rate_limit_body : String = "{\"error\":{\"code\":\"rate_limit_exceeded\",\"message\":\"Rate limit reached for gpt-4o\",\"type\":\"requests\"}}"

///|
/// 一个真实形状的 Anthropic 成功响应。
let anthropic_ok_body : String = "{\"content\":[{\"text\":\"Hello\",\"type\":\"text\"}],\"id\":\"msg_01\",\"model\":\"claude-3-5-sonnet-20241022\",\"role\":\"assistant\",\"stop_reason\":\"end_turn\",\"type\":\"message\",\"usage\":{\"input_tokens\":10,\"output_tokens\":5}}"

///|
fn header_of(headers : Array[(String, String)], name : String) -> String? {
  for header in headers {
    let (key, value) = header
    if key == name {
      return Some(value)
    }
  }
  None
}

// ---------------------------------------------------------------------------
// OpenAI 编码

///|
test "openai encodes a POST to the chat completions endpoint" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let http = protocol.encode(chat_request("gpt-4o", "hi")) catch {
    _ => panic()
  }
  assert_eq(http.method_name(), "POST")
  assert_eq(http.url, "https://api.openai.com/v1/chat/completions")
}

///|
test "openai puts the api key in a bearer authorisation header" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let http = protocol.encode(chat_request("gpt-4o", "hi")) catch {
    _ => panic()
  }
  assert_eq(header_of(http.headers, "authorization"), Some("Bearer sk-test"))
  assert_eq(header_of(http.headers, "content-type"), Some("application/json"))
}

///|
test "openai supports a compatible base url" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new(
    "sk-test",
    base_url="https://api.deepseek.com/v1",
  )
  let http = protocol.encode(chat_request("deepseek-chat", "hi")) catch {
    _ => panic()
  }
  assert_eq(http.url, "https://api.deepseek.com/v1/chat/completions")
}

///|
test "openai serialises the body in canonical form" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let http = protocol.encode(chat_request("gpt-4o", "hi")) catch {
    _ => panic()
  }
  // 键必须有序：model 在 messages 之前。
  assert_eq(
    http.body,
    "{\"messages\":[{\"content\":\"hi\",\"role\":\"user\"}],\"model\":\"gpt-4o\"}",
  )
}

// ---------------------------------------------------------------------------
// OpenAI 解码

///|
test "openai extracts usage using its own field names" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(
    @providers.HttpResponse::new(200, openai_ok_body),
  ) catch {
    _ => panic()
  }
  assert_eq(response.status, 200)
  let usage = response.usage.unwrap()
  assert_eq(usage.input_tokens, 9)
  assert_eq(usage.output_tokens, 12)
  assert_eq(usage.total(), 21)
}

///|
test "openai keeps error responses instead of raising" {
  // 错误响应同样要能录下来，否则「限流时怎么办」无法写回归测试。
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(
    @providers.HttpResponse::new(429, openai_rate_limit_body),
  ) catch {
    _ => panic()
  }
  assert_eq(response.status, 429)
  assert_true(response.usage is None)
  assert_eq(response.body, @json.parse(openai_rate_limit_body))
}

///|
test "openai wraps a non-json body instead of losing it" {
  // 网关经常直接返回 HTML 错误页；丢掉它会让排查变困难。
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(
    @providers.HttpResponse::new(502, "<html>bad gateway</html>"),
  ) catch {
    _ => panic()
  }
  assert_eq(
    response.body,
    @json.parse("{\"raw_body\":\"<html>bad gateway</html>\"}"),
  )
}

///|
test "openai wraps a scalar top-level body for a uniform shape" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(@providers.HttpResponse::new(200, "\"ok\"")) catch {
    _ => panic()
  }
  assert_eq(response.body, @json.parse("{\"raw_body\":\"\\\"ok\\\"\"}"))
}

///|
test "openai tolerates a response without a usage object" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(
    @providers.HttpResponse::new(200, "{\"choices\":[]}"),
  ) catch {
    _ => panic()
  }
  assert_true(response.usage is None)
}

///|
test "openai rejects a non-integer token count" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let response = protocol.decode(
    @providers.HttpResponse::new(
      200, "{\"usage\":{\"completion_tokens\":1.5,\"prompt_tokens\":9}}",
    ),
  ) catch {
    _ => panic()
  }
  // 宁可判为「没有用量」，也不要把 1.5 悄悄取整成 2。
  assert_true(response.usage is None)
}

// ---------------------------------------------------------------------------
// Anthropic

///|
test "anthropic targets the messages endpoint with its own headers" {
  let protocol : &@providers.Protocol = @providers.AnthropicMessages::new(
    "sk-ant-test",
  )
  let http = protocol.encode(chat_request("claude-3-5-sonnet-20241022", "hi")) catch {
    _ => panic()
  }
  assert_eq(http.method_name(), "POST")
  assert_eq(http.url, "https://api.anthropic.com/v1/messages")
  assert_eq(header_of(http.headers, "x-api-key"), Some("sk-ant-test"))
  assert_eq(header_of(http.headers, "anthropic-version"), Some("2023-06-01"))
  // Anthropic 不使用 bearer 鉴权。
  assert_true(header_of(http.headers, "authorization") is None)
}

///|
test "anthropic extracts usage using the shared field names" {
  let protocol : &@providers.Protocol = @providers.AnthropicMessages::new(
    "sk-ant-test",
  )
  let response = protocol.decode(
    @providers.HttpResponse::new(200, anthropic_ok_body),
  ) catch {
    _ => panic()
  }
  let usage = response.usage.unwrap()
  assert_eq(usage.input_tokens, 10)
  assert_eq(usage.output_tokens, 5)
}

///|
test "anthropic protocol id is distinct from openai" {
  let openai : &@providers.Protocol = @providers.OpenAiChat::new("k")
  let anthropic : &@providers.Protocol = @providers.AnthropicMessages::new("k")
  assert_eq(openai.name(), "openai.chat")
  assert_eq(anthropic.name(), "anthropic.messages")
  assert_true(openai.name() != anthropic.name())
}

// ---------------------------------------------------------------------------
// 一致性校验

///|
test "a model declared in the body must match Request.model" {
  // 这是一类很难查的静默不一致：body 里写 gpt-4o-mini，
  // Request.model 还是 gpt-4o，两者会分别进入指纹与计费口径。
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"model\":\"gpt-4o-mini\"}"),
  )
  let failed = try_encode(protocol, request)
  assert_true(failed.contains("gpt-4o-mini"))
  assert_true(failed.contains("gpt-4o"))
}

///|
test "a body without a model field is accepted" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"messages\":[]}"),
  )
  let http = protocol.encode(request) catch { _ => panic() }
  assert_eq(http.body, "{\"messages\":[]}")
}

///|
test "a non-string model field in the body is rejected" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"model\":123}"),
  )
  let failed = try_encode(protocol, request)
  assert_true(failed.contains("must be a string"))
}

///|
fn try_encode(
  protocol : &@providers.Protocol,
  request : @core.Request,
) -> String {
  let _ = protocol.encode(request) catch { error => return error.to_string() }
  ""
}

// ---------------------------------------------------------------------------
// 与 recorder 的桥接

///|
test "provider transport performs the full encode-send-decode round trip" {
  let protocol : &@providers.Protocol = @providers.OpenAiChat::new("sk-test")
  let sender = @providers.ScriptedHttpSender::new()
  let request = chat_request("gpt-4o", "hi")
  // 先用协议编码出「即将发出的那条 HTTP 请求」，作为脚本的键。
  let expected_http = protocol.encode(request) catch { _ => panic() }
  sender.on(expected_http, @providers.HttpResponse::new(200, openai_ok_body))
  let transport = @providers.ProviderTransport::new(protocol, sender)
  let response = transport.send(request) catch { _ => panic() }
  assert_eq(response.status, 200)
  assert_eq(response.usage.unwrap().input_tokens, 9)
  assert_eq(sender.call_count(), 1)
}

///|
test "scripted sender ignores headers so key rotation does not break scripts" {
  // 同一个请求体、不同的密钥，应命中同一条脚本：
  // 否则每次轮换密钥都要重录脚本。
  let sender = @providers.ScriptedHttpSender::new()
  let with_key_a = @providers.HttpRequest::new(
    "POST",
    "https://api.openai.com/v1/chat/completions",
    [("authorization", "Bearer a")],
    "{\"model\":\"gpt-4o\"}",
  )
  let with_key_b = @providers.HttpRequest::new(
    "POST",
    "https://api.openai.com/v1/chat/completions",
    [("authorization", "Bearer b")],
    "{\"model\":\"gpt-4o\"}",
  )
  sender.on(with_key_a, @providers.HttpResponse::new(200, "{}"))
  let response = sender.send(with_key_b) catch { _ => panic() }
  assert_eq(response.status, 200)
}

///|
test "unscripted http requests surface as an explicit 500" {
  let sender = @providers.ScriptedHttpSender::new()
  let response = sender.send(
    @providers.HttpRequest::new("POST", "https://example.invalid", [], "{}"),
  ) catch {
    _ => panic()
  }
  assert_eq(response.status, 500)
}

///|
test "function sender lets a plain closure act as the http client" {
  let seen : Array[String] = []
  let sender = @providers.FunctionSender::new(fn(request) {
    seen.push(request.url)
    @providers.HttpResponse::new(200, "{\"ok\":true}")
  })
  let response = sender.send(
    @providers.HttpRequest::new(
      "POST",
      "https://api.example.com/v1/messages",
      [],
      "{}",
    ),
  ) catch {
    _ => panic()
  }
  assert_eq(response.status, 200)
  assert_eq(seen, ["https://api.example.com/v1/messages"])
}

///|
test "function sender propagates failures as cassette errors" {
  // 用箭头函数形式：闭包会抛错，需要显式的效果标注（`fn` 形式的效果推断已弃用）。
  let sender = @providers.FunctionSender::new(_request => {
    raise @core.CassetteError::TransportFailure("connection refused")
  })
  let message = try_send(sender, "https://api.example.com/v1/chat/completions")
  assert_true(message.contains("connection refused"))
}

///|
fn try_send(sender : &@providers.HttpSender, url : String) -> String {
  let _ = sender.send(@providers.HttpRequest::new("POST", url, [], "{}")) catch {
    error => return error.to_string()
  }
  ""
}

///|
test "provider transport reports the underlying protocol name" {
  let protocol : &@providers.Protocol = @providers.AnthropicMessages::new("k")
  let sender = @providers.ScriptedHttpSender::new()
  let transport = @providers.ProviderTransport::new(protocol, sender)
  assert_eq(transport.protocol_name(), "anthropic.messages")
}
