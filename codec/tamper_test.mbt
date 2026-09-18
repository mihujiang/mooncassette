// mooncassette/codec —— 对抗性测试矩阵（篡改检测）。
//
// 这一族测试的立场是「我们自己攻击自己」：拿着**合法**的 cassette，逐个字段
// 改动，断言解码端必须拒绝，并且**指出是哪个字段**。
//
// 之所以要逐字段覆盖而不是抽样：两个摘要的覆盖范围不同（`fingerprint` 只覆盖
// 请求、`integrity` 覆盖整条记录），漏掉任何一侧都会留下「改了却查不出来」的
// 角落。这里把两类都钉住。
//
// 同时也要钉住**不该报警**的情况（`meta` / `version`）：过度报警会让用户学会
// 忽略警告，那比不报警更糟。
//
// 每个篡改动作都写成具名函数而不是闭包：名字本身就是「这是什么攻击」的文档，
// 而且避免匿名函数在 effect 推断上的歧义。

// ---------------------------------------------------------------------------
// 断言骨架
// ---------------------------------------------------------------------------

///|
/// 在 JSON 视图上做一次改动，返回解码的结果消息。
///
/// `<accepted>` 表示改动没有被拒绝 —— 对「应当检出」的用例来说，这就是失败。
fn message_of_decode(json : Json) -> String {
  let _ = @codec.of_json(json) catch { error => return error.to_string() }
  "<accepted>"
}

///|
/// 应用一次改动，并**断言改动确实生效**。
///
/// 这条守卫是必要的：如果改动因为路径写错而静默失效，那些期望「被接受」的
/// 用例会空过 —— 测了个寂寞却显示绿色。期望「被拒绝」的用例本来就会因此失败，
/// 但这里的断言能让失败信息直接指向「是测试自己写错了路径」。
fn mutated_json(
  source : @core.Cassette,
  mutate : (Json) -> Unit raise,
) -> Json raise {
  let json = @codec.to_json(source)
  let before = @canon.to_canonical_string(json)
  mutate(json)
  if @canon.to_canonical_string(json) == before {
    fail("the mutation changed nothing; this test would pass vacuously")
  }
  json
}

///|
/// 改动一个字段，断言解码被拒绝，且错误消息里出现预期路径。
fn assert_detected(
  source : @core.Cassette,
  mutate : (Json) -> Unit raise,
  expected_fragment : String,
) -> Unit raise {
  let message = message_of_decode(mutated_json(source, mutate))
  if !message.contains(expected_fragment) {
    fail(
      "expected the change to be rejected with " +
      expected_fragment +
      ", but decode said: " +
      message,
    )
  }
}

///|
/// 改动一个字段，断言解码**接受**（该字段不参与摘要）。
fn assert_allowed(
  source : @core.Cassette,
  mutate : (Json) -> Unit raise,
) -> Unit raise {
  let message = message_of_decode(mutated_json(source, mutate))
  if message != "<accepted>" {
    fail("expected the change to be accepted, but decode said: " + message)
  }
}

// ---------------------------------------------------------------------------
// JSON 视图上的定位与改写辅助
// ---------------------------------------------------------------------------

///|
fn root_fields(json : Json) -> Map[String, Json] raise {
  match json {
    Object(fields) => fields
    _ => fail("expected the root to be an object")
  }
}

///|
fn object_field(
  fields : Map[String, Json],
  key : String,
) -> Map[String, Json] raise {
  match fields.get(key) {
    Some(Object(inner)) => inner
    _ => fail("expected an object field: " + key)
  }
}

///|
/// 取出 `$.interactions[index]` 的字段表。
fn interaction_fields(json : Json, index : Int) -> Map[String, Json] raise {
  let root = root_fields(json)
  let items = match root.get("interactions") {
    Some(Array(items)) => items
    _ => fail("expected interactions to be an array")
  }
  match items[index] {
    Object(fields) => fields
    _ => fail("expected an interaction object")
  }
}

///|
fn request_of(json : Json, index : Int) -> Map[String, Json] raise {
  object_field(interaction_fields(json, index), "request")
}

///|
fn response_of(json : Json, index : Int) -> Map[String, Json] raise {
  object_field(interaction_fields(json, index), "response")
}

///|
fn frames_of(json : Json, index : Int) -> Array[Json] raise {
  match response_of(json, index).get("stream") {
    Some(Array(items)) => items
    _ => fail("expected a stream array")
  }
}

///|
fn frame_of(json : Json, index : Int, frame : Int) -> Map[String, Json] raise {
  match frames_of(json, index)[frame] {
    Object(fields) => fields
    _ => fail("expected a frame object")
  }
}

///|
/// 删掉响应里的一个字段（重建一个不含该键的对象）。
fn drop_response_field(json : Json, index : Int, key : String) -> Unit raise {
  let fields = interaction_fields(json, index)
  let response = response_of(json, index)
  let kept : Map[String, Json] = Map([])
  for existing in response.keys() {
    if existing != key {
      match response.get(existing) {
        Some(value) => kept.set(existing, value)
        None => ()
      }
    }
  }
  fields.set("response", Json::object(kept))
}

///|
fn set_meta_field(json : Json, key : String, value : Json) -> Unit raise {
  object_field(root_fields(json), "meta").set(key, value)
}

// ---------------------------------------------------------------------------
// 样本：含流式记录的一份合法 cassette
// ---------------------------------------------------------------------------

///|
fn stream_cassette() -> @core.Cassette raise {
  @core.Cassette::new("stream", recorded_at="2026-09-13T00:00:00Z", interactions=[
    @core.Interaction::new(
      @core.Request::new("openai", "gpt-4o", @json.parse("{\"stream\":true}")),
      @core.Response::ok(
        @json.parse("{\"choices\":[]}"),
        usage=@core.Usage::new(3, 1),
        stream=[
          @core.StreamFrame::new("{\"i\":1}", event="chunk"),
          @core.StreamFrame::new("[DONE]"),
        ],
      ),
    ),
  ])
}

// ---------------------------------------------------------------------------
// 篡改动作（每个都是一个具名的攻击）
// ---------------------------------------------------------------------------

///|
fn mutate_request_body(json : Json) -> Unit raise {
  request_of(json, 0).set("body", @json.parse("{\"x\":1}"))
}

///|
fn mutate_model(json : Json) -> Unit raise {
  request_of(json, 0).set("model", Json::string("gpt-4o-mini"))
}

///|
fn mutate_provider(json : Json) -> Unit raise {
  request_of(json, 0).set("provider", Json::string("anthropic"))
}

///|
fn mutate_fingerprint(json : Json) -> Unit raise {
  interaction_fields(json, 0).set(
    "fingerprint",
    Json::string("fnv1a64:0000000000000000"),
  )
}

///|
fn mutate_integrity(json : Json) -> Unit raise {
  interaction_fields(json, 0).set(
    "integrity",
    Json::string("fnv1a64:0000000000000000"),
  )
}

///|
fn mutate_response_body(json : Json) -> Unit raise {
  response_of(json, 0).set("body", @json.parse("{\"ok\":true}"))
}

///|
fn mutate_status(json : Json) -> Unit raise {
  response_of(json, 0).set("status", @json.parse("500"))
}

///|
fn mutate_input_tokens(json : Json) -> Unit raise {
  object_field(response_of(json, 0), "usage").set(
    "input_tokens",
    @json.parse("0"),
  )
}

///|
fn mutate_output_tokens(json : Json) -> Unit raise {
  object_field(response_of(json, 0), "usage").set(
    "output_tokens",
    @json.parse("999999"),
  )
}

///|
fn drop_usage(json : Json) -> Unit raise {
  drop_response_field(json, 0, "usage")
}

///|
/// 给一条非流式记录挂上几个帧，让回放时多吐分片。
fn add_stream_frame(json : Json) -> Unit raise {
  response_of(json, 0).set(
    "stream",
    Json::array([@core.StreamFrame::new("{\"i\":1}").to_json()]),
  )
}

///|
fn mutate_frame_data(json : Json) -> Unit raise {
  frame_of(json, 0, 0).set("data", Json::string("{\"i\":999}"))
}

///|
fn mutate_frame_event(json : Json) -> Unit raise {
  frame_of(json, 0, 0).set("event", Json::string("other"))
}

///|
fn drop_stream(json : Json) -> Unit raise {
  drop_response_field(json, 0, "stream")
}

///|
/// 交换两帧：顺序是语义，分片顺序变了聚合结果就可能不同。
fn swap_frames(json : Json) -> Unit raise {
  let items = frames_of(json, 0)
  let first = items[0]
  items[0] = items[1]
  items[1] = first
}

///|
fn break_stream_type(json : Json) -> Unit raise {
  response_of(json, 0).set("stream", Json::string("nope"))
}

///|
fn break_frame_type(json : Json) -> Unit raise {
  frames_of(json, 0)[1] = Json::string("nope")
}

///|
fn rename_meta(json : Json) -> Unit raise {
  set_meta_field(json, "name", Json::string("renamed"))
}

///|
fn change_generator(json : Json) -> Unit raise {
  set_meta_field(json, "generator", Json::string("mooncassette/9.9.9"))
}

///|
fn downgrade_version(json : Json) -> Unit raise {
  root_fields(json).set("version", @json.parse("1"))
}

// ---------------------------------------------------------------------------
// 矩阵：请求侧（由 `fingerprint` 覆盖，先于 `integrity` 被检查）
// ---------------------------------------------------------------------------

///|
test "tampering with the request body is detected" {
  assert_detected(
    sample_cassette(),
    mutate_request_body,
    "$.interactions[0].fingerprint",
  )
}

///|
test "tampering with the model is detected" {
  assert_detected(
    sample_cassette(),
    mutate_model,
    "$.interactions[0].fingerprint",
  )
}

///|
test "tampering with the provider is detected" {
  assert_detected(
    sample_cassette(),
    mutate_provider,
    "$.interactions[0].fingerprint",
  )
}

///|
test "tampering with the stored fingerprint itself is detected" {
  assert_detected(
    sample_cassette(),
    mutate_fingerprint,
    "$.interactions[0].fingerprint",
  )
}

// ---------------------------------------------------------------------------
// 矩阵：响应侧与用量（由 `integrity` 覆盖）
// ---------------------------------------------------------------------------

///|
test "tampering with the response body is detected" {
  assert_detected(
    sample_cassette(),
    mutate_response_body,
    "$.interactions[0].integrity",
  )
}

///|
test "tampering with the status code is detected" {
  assert_detected(
    sample_cassette(),
    mutate_status,
    "$.interactions[0].integrity",
  )
}

///|
test "tampering with the input token count is detected" {
  assert_detected(
    sample_cassette(),
    mutate_input_tokens,
    "$.interactions[0].integrity",
  )
}

///|
test "tampering with the output token count is detected" {
  assert_detected(
    sample_cassette(),
    mutate_output_tokens,
    "$.interactions[0].integrity",
  )
}

///|
test "dropping the usage field is detected" {
  // 删字段与改字段是两类不同的攻击，都要挡住。
  assert_detected(sample_cassette(), drop_usage, "$.interactions[0].integrity")
}

///|
test "tampering with the stored integrity digest itself is detected" {
  assert_detected(
    sample_cassette(),
    mutate_integrity,
    "$.interactions[0].integrity",
  )
}

///|
test "adding a stream to a plain response is detected" {
  assert_detected(
    sample_cassette(),
    add_stream_frame,
    "$.interactions[0].integrity",
  )
}

// ---------------------------------------------------------------------------
// 矩阵：流式记录（帧序列也在摘要覆盖范围内）
// ---------------------------------------------------------------------------

///|
test "tampering with a frame payload is detected" {
  assert_detected(
    stream_cassette(),
    mutate_frame_data,
    "$.interactions[0].integrity",
  )
}

///|
test "tampering with a frame event name is detected" {
  assert_detected(
    stream_cassette(),
    mutate_frame_event,
    "$.interactions[0].integrity",
  )
}

///|
test "dropping the whole stream is detected" {
  assert_detected(stream_cassette(), drop_stream, "$.interactions[0].integrity")
}

///|
test "reordering frames is detected" {
  assert_detected(stream_cassette(), swap_frames, "$.interactions[0].integrity")
}

///|
test "a malformed stream is rejected with its path" {
  assert_detected(
    stream_cassette(),
    break_stream_type,
    "$.interactions[0].response.stream",
  )
}

///|
test "a malformed frame inside the stream is rejected with its path" {
  assert_detected(
    stream_cassette(),
    break_frame_type,
    "$.interactions[0].response.stream[1]",
  )
}

// ---------------------------------------------------------------------------
// 反例：这些字段**不该**被摘要覆盖
// ---------------------------------------------------------------------------

///|
test "changing the cassette name is accepted" {
  // `meta` 由调用方掌控，不来自模型或网络；对它报警只会制造噪声。
  assert_allowed(sample_cassette(), rename_meta)
}

///|
test "changing the generator id is accepted" {
  assert_allowed(sample_cassette(), change_generator)
}

///|
test "downgrading the declared version is accepted" {
  // 读取端兼容所有已发布版本；而且写出时会按内容把版本升回去
  // （见 `effective_version`），所以这不构成「文件被改坏」。
  assert_allowed(stream_cassette(), downgrade_version)
}
