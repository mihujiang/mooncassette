// mooncassette/providers —— 流式聚合契约测试。
//
// 报文按真实 API 的形状构造：多帧增量、`[DONE]` 哨兵、末帧才带 usage、
// 以及 Anthropic 那一串命名事件。断言的是**聚合结果与非流式响应同形**，
// 因为整个统一模型（匹配、漂移、成本核算）都建立在这个形状上。

///|
/// 把若干 JSON 片段拼成一条只有 `data:` 的 SSE（OpenAI 的形状）。
fn sse(chunks : Array[String]) -> String {
  let sb = StringBuilder::new()
  for chunk in chunks {
    sb.write_string("data: ")
    sb.write_string(chunk)
    sb.write_string("\n\n")
  }
  sb.to_string()
}

///|
/// 把若干（事件名, 数据）对拼成命名事件流（Anthropic 的形状）。
fn sse_named(items : Array[(String, String)]) -> String {
  let sb = StringBuilder::new()
  for item in items {
    let (event, data) = item
    sb.write_string("event: ")
    sb.write_string(event)
    sb.write_string("\ndata: ")
    sb.write_string(data)
    sb.write_string("\n\n")
  }
  sb.to_string()
}

///|
/// 用规范文本比较两个 JSON，从而不必关心键序。
fn same_json(left : Json, right : Json) -> Bool {
  @canon.to_canonical_string(left) == @canon.to_canonical_string(right)
}

///|
test "openai text deltas aggregate into a chat.completion body" {
  let body = sse([
    "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion.chunk\",\"created\":1712345678,\"model\":\"gpt-4o\",\"system_fingerprint\":\"fp_x\",\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\",\"content\":\"\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion.chunk\",\"created\":1712345678,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"Hel\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion.chunk\",\"created\":1712345678,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"lo\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion.chunk\",\"created\":1712345678,\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}",
    "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion.chunk\",\"created\":1712345678,\"model\":\"gpt-4o\",\"choices\":[],\"usage\":{\"prompt_tokens\":9,\"completion_tokens\":2,\"total_tokens\":11}}",
    "[DONE]",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(200, body))
  assert_eq(response.status, 200)
  // 六帧全部保留，`[DONE]` 也在内——它是流的一部分，回放时要原样重放。
  assert_eq(response.stream.unwrap().length(), 6)
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"chatcmpl-9\",\"object\":\"chat.completion\",\"created\":1712345678,\"model\":\"gpt-4o\",\"system_fingerprint\":\"fp_x\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"Hello\"},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":9,\"completion_tokens\":2,\"total_tokens\":11}}",
      ),
    ),
  )
  // 用量要从末帧里被抽出来，而不是留在 body 里等人自己去翻。
  match response.usage {
    Some(usage) => {
      assert_eq(usage.input_tokens, 9)
      assert_eq(usage.output_tokens, 2)
    }
    None => fail("expected usage to be extracted from the final chunk")
  }
}

///|
test "openai tool call arguments are concatenated across frames" {
  // 工具参数是分片发送的：中途任何一帧单独看都是非法 JSON，只有拼完才成立。
  let body = sse([
    "{\"choices\":[{\"index\":0,\"delta\":{\"tool_calls\":[{\"index\":0,\"id\":\"call_1\",\"type\":\"function\",\"function\":{\"name\":\"weather\",\"arguments\":\"{\\\"city\\\":\\\"S\"}}]},\"finish_reason\":null}]}",
    "{\"choices\":[{\"index\":0,\"delta\":{\"tool_calls\":[{\"index\":0,\"function\":{\"arguments\":\"F\\\"}\"}}]},\"finish_reason\":null}]}",
    "{\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"tool_calls\"}]}",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"object\":\"chat.completion\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":null,\"tool_calls\":[{\"index\":0,\"id\":\"call_1\",\"type\":\"function\",\"function\":{\"name\":\"weather\",\"arguments\":\"{\\\"city\\\":\\\"SF\\\"}\"}}]},\"finish_reason\":\"tool_calls\"}]}",
      ),
    ),
  )
}

///|
test "a pure tool call stream reports null content rather than an empty string" {
  // 「服务端压根没发 content」与「content 确实是空串」是两回事，
  // 统一模型用 `null` 表达前者。
  let body = sse([
    "{\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\"},\"finish_reason\":null}]}",
    "{\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"object\":\"chat.completion\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":null},\"finish_reason\":\"stop\"}]}",
      ),
    ),
  )
}

///|
test "an openai error frame becomes the body verbatim" {
  let body = sse([
    "{\"error\":{\"message\":\"Rate limit reached\",\"type\":\"rate_limit_error\",\"code\":\"rate_limit_exceeded\"}}",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(429, body))
  assert_eq(response.status, 429)
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"error\":{\"message\":\"Rate limit reached\",\"type\":\"rate_limit_error\",\"code\":\"rate_limit_exceeded\"}}",
      ),
    ),
  )
  assert_true(response.usage is None)
}

///|
test "unparseable lines inside a stream do not break aggregation" {
  // 网关偶尔会在流里塞一行纯文本。原始帧已完整保留，聚合不该因此失败。
  let body = sse([
    "{\"choices\":[{\"index\":0,\"delta\":{\"content\":\"ok\"},\"finish_reason\":null}]}",
    "upstream timeout (text, not json)", "{\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(200, body))
  assert_eq(response.stream.unwrap().length(), 3)
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"object\":\"chat.completion\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"ok\"},\"finish_reason\":\"stop\"}]}",
      ),
    ),
  )
}

///|
test "a usage-only chunk without a choices field still contributes usage" {
  // 官方 usage chunk 带的是 `"choices": []`（字段在、数组为空），因此会走正常路径；
  // 但网关可能发出**完全没有 `choices` 字段**的用量帧。若先按「没有 choices ⇒ 错误体」
  // 提前返回，那一帧的用量就被丢掉了 —— 丢用量不会报错，只会让成本少算。
  let body = sse([
    "{\"id\":\"c1\",\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"hi\"},\"finish_reason\":\"stop\"}]}",
    "{\"id\":\"c1\",\"model\":\"gpt-4o\",\"usage\":{\"prompt_tokens\":7,\"completion_tokens\":3,\"total_tokens\":10}}",
  ])
  let response = decode_openai_stream_response(HttpResponse::new(200, body))
  match response.usage {
    Some(usage) => {
      assert_eq(usage.input_tokens, 7)
      assert_eq(usage.output_tokens, 3)
    }
    None =>
      fail("usage must survive a chunk that carries no `choices` field at all")
  }
  // 该帧没有被误当成错误体：最终结果仍是正常聚合出来的 completion。
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"c1\",\"model\":\"gpt-4o\",\"object\":\"chat.completion\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"hi\"},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":7,\"completion_tokens\":3,\"total_tokens\":10}}",
      ),
    ),
  )
}

///|
test "anthropic named events aggregate into a message body" {
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"msg_1\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude-3-5-sonnet\",\"content\":[],\"stop_reason\":null,\"stop_sequence\":null,\"usage\":{\"input_tokens\":12,\"output_tokens\":1}}}",
    ),
    (
      "content_block_start", "{\"type\":\"content_block_start\",\"index\":0,\"content_block\":{\"type\":\"text\",\"text\":\"\"}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"text_delta\",\"text\":\"Bon\"}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"text_delta\",\"text\":\"jour\"}}",
    ),
    ("content_block_stop", "{\"type\":\"content_block_stop\",\"index\":0}"),
    (
      "message_delta", "{\"type\":\"message_delta\",\"delta\":{\"stop_reason\":\"end_turn\",\"stop_sequence\":null},\"usage\":{\"output_tokens\":5}}",
    ),
    ("message_stop", "{\"type\":\"message_stop\"}"),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_eq(response.stream.unwrap().length(), 7)
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"msg_1\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude-3-5-sonnet\",\"content\":[{\"type\":\"text\",\"text\":\"Bonjour\"}],\"stop_reason\":\"end_turn\",\"stop_sequence\":null,\"usage\":{\"input_tokens\":12,\"output_tokens\":5}}",
      ),
    ),
  )
  match response.usage {
    Some(usage) => {
      assert_eq(usage.input_tokens, 12)
      assert_eq(usage.output_tokens, 5)
    }
    None =>
      fail("expected usage to be combined across message_start/message_delta")
  }
}

///|
test "anthropic aggregation keeps provider-specific usage fields" {
  // 非流式响应的 `usage` 不止两个计数字段：开了 prompt caching 还会有
  // `cache_read_input_tokens` / `cache_creation_input_tokens`（成本核算要用）。
  // 聚合体若只写两个字段，就与「与非流式同形」这条承诺不符。
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"m\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude\",\"content\":[],\"usage\":{\"input_tokens\":12,\"output_tokens\":1,\"cache_read_input_tokens\":100,\"cache_creation_input_tokens\":2}}}",
    ),
    (
      "content_block_start", "{\"type\":\"content_block_start\",\"index\":0,\"content_block\":{\"type\":\"text\",\"text\":\"\"}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"text_delta\",\"text\":\"hi\"}}",
    ),
    (
      "message_delta", "{\"type\":\"message_delta\",\"delta\":{\"stop_reason\":\"end_turn\"},\"usage\":{\"output_tokens\":5}}",
    ),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"m\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude\",\"content\":[{\"type\":\"text\",\"text\":\"hi\"}],\"stop_reason\":\"end_turn\",\"usage\":{\"input_tokens\":12,\"output_tokens\":5,\"cache_read_input_tokens\":100,\"cache_creation_input_tokens\":2}}",
      ),
    ),
  )
  match response.usage {
    Some(usage) => assert_eq(usage.output_tokens, 5)
    None => fail("usage should still be extracted from message_delta")
  }
}

///|
test "an unknown content block type is passed through verbatim" {
  // `redacted_thinking`、各类服务端工具结果这类 block 在 start 帧里就是完整的、
  // 没有后续增量。若一律按 `text` 重建，它们在聚合体里会变成空壳 ——
  // 内容静默消失，而原始帧还在，排查时更看不出问题在哪。
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"m2\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude\",\"content\":[]}}",
    ),
    (
      "content_block_start", "{\"type\":\"content_block_start\",\"index\":0,\"content_block\":{\"type\":\"redacted_thinking\",\"data\":\"EroBCk\"}}",
    ),
    ("content_block_stop", "{\"type\":\"content_block_stop\",\"index\":0}"),
    (
      "message_delta", "{\"type\":\"message_delta\",\"delta\":{\"stop_reason\":\"end_turn\"},\"usage\":{\"output_tokens\":3}}",
    ),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"m2\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude\",\"content\":[{\"type\":\"redacted_thinking\",\"data\":\"EroBCk\"}],\"stop_reason\":\"end_turn\",\"usage\":{\"input_tokens\":0,\"output_tokens\":3}}",
      ),
    ),
  )
}

///|
test "anthropic tool_use input is parsed only once the fragments are complete" {
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"msg_2\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude-3-5-sonnet\",\"content\":[]}}",
    ),
    (
      "content_block_start", "{\"type\":\"content_block_start\",\"index\":0,\"content_block\":{\"type\":\"tool_use\",\"id\":\"toolu_1\",\"name\":\"weather\",\"input\":{}}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"input_json_delta\",\"partial_json\":\"{\\\"city\\\":\"}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"input_json_delta\",\"partial_json\":\"\\\"SF\\\"}\"}}",
    ),
    (
      "message_delta", "{\"type\":\"message_delta\",\"delta\":{\"stop_reason\":\"tool_use\"},\"usage\":{\"output_tokens\":20}}",
    ),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"msg_2\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"claude-3-5-sonnet\",\"content\":[{\"type\":\"tool_use\",\"id\":\"toolu_1\",\"name\":\"weather\",\"input\":{\"city\":\"SF\"}}],\"stop_reason\":\"tool_use\",\"usage\":{\"input_tokens\":0,\"output_tokens\":20}}",
      ),
    ),
  )
}

///|
test "an anthropic error event becomes the body verbatim" {
  let body = sse_named([
    (
      "error", "{\"type\":\"error\",\"error\":{\"type\":\"overloaded_error\",\"message\":\"Overloaded\"}}",
    ),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"type\":\"error\",\"error\":{\"type\":\"overloaded_error\",\"message\":\"Overloaded\"}}",
      ),
    ),
  )
  assert_true(response.usage is None)
}

///|
test "a half-reported usage is left empty rather than filled with zero" {
  // 补 0 会把「没上报」写成「上报了 0」，那是错误信息而不是缺失信息。
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"msg_3\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"m\",\"content\":[],\"usage\":{\"input_tokens\":7}}}",
    ),
  ])
  let response = decode_anthropic_stream_response(HttpResponse::new(200, body))
  assert_true(response.usage is None)
  // 但聚合体仍然给出一个结构完整的 usage，缺的一侧按 0 写入，
  // 因为响应体必须是合法形状；是否可信由 `Response.usage` 判断。
  assert_true(
    same_json(
      response.body,
      @json.parse(
        "{\"id\":\"msg_3\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"m\",\"content\":[],\"stop_reason\":null,\"usage\":{\"input_tokens\":7,\"output_tokens\":0}}",
      ),
    ),
  )
}

///|
test "a non-streaming body still takes the ordinary path" {
  // 自动识别不能把普通 JSON 响应误送进流式聚合。
  let response = decode_openai_response(
    HttpResponse::new(
      200, "{\"id\":\"chatcmpl-1\",\"choices\":[],\"usage\":{\"prompt_tokens\":1,\"completion_tokens\":2}}",
    ),
  )
  assert_true(response.stream is None)
  match response.usage {
    Some(usage) => {
      assert_eq(usage.input_tokens, 1)
      assert_eq(usage.output_tokens, 2)
    }
    None => fail("expected usage")
  }
}

///|
test "protocol decode routes sse bodies to the streaming path" {
  let protocol = OpenAiChat::new("sk-test")
  let response = protocol.decode(
    HttpResponse::new(
      200,
      sse([
        "{\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}]}",
      ]),
    ),
  )
  assert_true(response.stream is Some(_))
}

///|
test "the frame entry point agrees with the response entry point" {
  // 两条入口只是「谁来解析帧」不同，聚合结果必须完全一致；
  // 若不一致，说明「自己逐块收数据的客户端」录下来的东西与自动录制的不是一回事。
  let body = sse([
    "{\"id\":\"chatcmpl-1\",\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{\"role\":\"assistant\",\"content\":\"Hi\"},\"finish_reason\":null}]}",
    "{\"id\":\"chatcmpl-1\",\"model\":\"gpt-4o\",\"choices\":[{\"index\":0,\"delta\":{},\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":3,\"completion_tokens\":1,\"total_tokens\":4}}",
  ])
  let from_response = decode_openai_stream_response(
    HttpResponse::new(200, body),
  )
  let from_frames = decode_openai_stream_frames(@stream.parse(body), 200)
  assert_true(same_json(from_response.body, from_frames.body))
  assert_eq(from_frames.stream.unwrap().length(), 2)
  match (from_response.usage, from_frames.usage) {
    (Some(left), Some(right)) => {
      assert_eq(left.input_tokens, right.input_tokens)
      assert_eq(left.output_tokens, right.output_tokens)
    }
    _ => fail("expected usage from both entry points")
  }
}

///|
test "the anthropic frame entry point agrees with the response entry point" {
  let body = sse_named([
    (
      "message_start", "{\"type\":\"message_start\",\"message\":{\"id\":\"msg_9\",\"type\":\"message\",\"role\":\"assistant\",\"model\":\"m\",\"content\":[],\"usage\":{\"input_tokens\":4}}}",
    ),
    (
      "content_block_delta", "{\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"text_delta\",\"text\":\"ok\"}}",
    ),
    (
      "message_delta", "{\"type\":\"message_delta\",\"delta\":{\"stop_reason\":\"end_turn\"},\"usage\":{\"output_tokens\":2}}",
    ),
  ])
  let from_response = decode_anthropic_stream_response(
    HttpResponse::new(200, body),
  )
  let from_frames = decode_anthropic_stream_frames(@stream.parse(body), 200)
  assert_true(same_json(from_response.body, from_frames.body))
  assert_eq(from_frames.stream.unwrap().length(), 3)
}

///|
test "protocol decode keeps non-sse bodies on the ordinary path" {
  let protocol = AnthropicMessages::new("sk-test")
  let response = protocol.decode(
    HttpResponse::new(200, "{\"id\":\"msg_1\",\"content\":[]}"),
  )
  assert_true(response.stream is None)
}
