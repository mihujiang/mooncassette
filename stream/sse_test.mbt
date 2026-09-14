// mooncassette/stream —— SSE 解析契约测试。
//
// 这些用例逐条对应 WHATWG HTML 里 Server-Sent Events 的解析规则。
// 之所以要抠这么细：解析少一帧或多一帧，都会让聚合出来的响应体悄悄变形，
// 而那种错误在真实流上极难复现（依赖服务端怎么切包）。

///|
fn render(text : StringView) -> String {
  @stream.render(@stream.parse(text))
}

///|
test "parses a single data frame" {
  let frames = @stream.parse("data: hello\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "hello")
  assert_eq(frames[0].event, None)
}

///|
test "multi-line data is joined with a newline" {
  let frames = @stream.parse("data: a\ndata: b\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "a\nb")
}

///|
test "named events are preserved" {
  let frames = @stream.parse("event: ping\ndata: {}\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].event, Some("ping"))
  assert_eq(frames[0].data, "{}")
}

///|
test "the event type resets after each dispatch" {
  // 否则第二帧会继承第一帧的 `event`，命名事件就失效了。
  let frames = @stream.parse("event: a\ndata: 1\n\ndata: 2\n\n")
  assert_eq(frames.length(), 2)
  assert_eq(frames[0].event, Some("a"))
  assert_eq(frames[1].event, None)
}

///|
test "crlf is a single terminator" {
  let frames = @stream.parse("data: a\r\n\r\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "a")
}

///|
test "carriage-return-only line endings are accepted" {
  let frames = @stream.parse("data: a\rdata: b\r\r")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "a\nb")
}

///|
test "comments and unknown fields are ignored" {
  let frames = @stream.parse(": keep-alive\nid: 42\nretry: 100\ndata: a\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "a")
  assert_eq(frames[0].event, None)
}

///|
test "a blank line without data dispatches nothing" {
  assert_eq(@stream.parse("\n\n\n").length(), 0)
}

///|
test "only one leading space after the colon is stripped" {
  let frames = @stream.parse("data:  two spaces\n\n")
  assert_eq(frames[0].data, " two spaces")
}

///|
test "a value without a leading space is taken verbatim" {
  let frames = @stream.parse("data:no-space\n\n")
  assert_eq(frames[0].data, "no-space")
}

///|
test "a field without a colon carries an empty value" {
  // 规范：没有冒号时整行是字段名，值为空串。因此 `data` 单独一行是合法的
  // 空数据帧，而不是需要被丢弃的畸形输入。
  let frames = @stream.parse("data\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "")
}

///|
test "a trailing frame without a blank line is discarded" {
  // 规范要求：流结束时仍在缓冲的帧应当丢弃。这里刻意做成严格行为——
  // 与其猜「大概只是漏了个终止空行」，不如少一帧让聚合结果对不上，
  // 而不是把一份可能已被截断的流当作完整流转正。
  assert_eq(@stream.parse("data: a\n\ndata: b").length(), 1)
}

///|
test "a leading BOM does not hide the first field" {
  // 若不跳过 BOM，首个字段名会变成 "\u{FEFF}data"，整条流看起来一帧都没有。
  let frames = @stream.parse("\u{FEFF}data: a\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "a")
}

///|
test "a stream whose first line is id or retry is still recognised as SSE" {
  // `id` / `retry` 都是规范允许的起始字段（虽然 OpenAI 与 Anthropic 都不用）。
  // 漏判的后果不是报错：整条流会被当成非流式响应、按原始文本录下来，帧全部丢失，
  // 而回放依然「成功」—— 只是 `replay_stream` 再也拿不到帧。
  assert_true(@stream.looks_like_event_stream("id: 7\ndata: a\n\n"))
  assert_true(@stream.looks_like_event_stream("retry: 1000\n\ndata: a\n\n"))
  // 反向仍须成立：放开判据不能把 JSON / HTML 误判成事件流。
  assert_false(@stream.looks_like_event_stream("{\"a\":1}"))
  assert_false(@stream.looks_like_event_stream("<html>502 Bad Gateway</html>"))
}

///|
test "an empty stream yields no frames" {
  assert_eq(@stream.parse("").length(), 0)
}

///|
test "multiple frames keep their order" {
  let frames = @stream.parse("data: 1\n\ndata: 2\n\ndata: 3\n\n")
  assert_eq(frames.length(), 3)
  assert_eq(@stream.render(frames), "data: 1\n\ndata: 2\n\ndata: 3\n\n")
}

///|
test "render and parse round-trip" {
  // 与 `parse` 构成一对，因此「解析 → 渲染 → 再解析」必须收敛。
  let source = "event: chunk\ndata: {\"a\":1}\n\ndata: [DONE]\n\n"
  let once = @stream.render(@stream.parse(source))
  let twice = @stream.render(@stream.parse(once))
  assert_eq(twice, once)
}

///|
test "non-ascii payloads survive parsing" {
  // 索引与切片全部按字符进行，若混用 UTF-16 码元下标就会在这里错位。
  let frames = @stream.parse("data: 你好，世界 🌍\n\n")
  assert_eq(frames.length(), 1)
  assert_eq(frames[0].data, "你好，世界 🌍")
}

///|
test "event streams are recognised" {
  assert_true(@stream.looks_like_event_stream("data: {}\n\n"))
  assert_true(@stream.looks_like_event_stream("event: x\ndata: {}\n\n"))
  assert_true(@stream.looks_like_event_stream(": comment\n\n"))
  assert_true(@stream.looks_like_event_stream("\n\ndata: x\n\n"))
}

///|
test "json and html responses are not mistaken for event streams" {
  assert_false(@stream.looks_like_event_stream("{\"choices\":[]}"))
  assert_false(@stream.looks_like_event_stream("[1,2]"))
  assert_false(@stream.looks_like_event_stream("<html>502 Bad Gateway</html>"))
  assert_false(@stream.looks_like_event_stream(""))
}

///|
test "a plain-text body starting with data is not misdetected" {
  // 判据要求冒号，否则「database error」这类文本会被当成事件流。
  assert_false(@stream.looks_like_event_stream("database error"))
}

///|
test "render escapes nothing but splits multi-line data" {
  let frames : Array[@core.StreamFrame] = [
    @core.StreamFrame::new("a\nb"),
    @core.StreamFrame::new("{}", event="ping"),
  ]
  assert_eq(render(""), "")
  assert_eq(
    @stream.render(frames),
    "data: a\ndata: b\n\nevent: ping\ndata: {}\n\n",
  )
}
