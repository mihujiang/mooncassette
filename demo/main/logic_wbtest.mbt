// mooncassette Demo —— 白盒测试。
//
// 这里只测**纯逻辑**：转义、解析、状态机与渲染输出。DOM 那一层（`dom.mbt`）
// 不在这里测，它由 `test/smoke.mjs` 在 Node 里用真实构建产物覆盖 —— 两边合起来
// 就是「打开浏览器手动点一遍」的可重复替代品。

///|
test "escape_html covers every character that can break out of HTML" {
  assert_eq(escape_html("<script>"), "&lt;script&gt;")
  assert_eq(escape_html("a & b"), "a &amp; b")
  assert_eq(escape_html("\"quoted\""), "&quot;quoted&quot;")
  assert_eq(escape_html("it's"), "it&#39;s")
  // 顺序很重要：`&` 必须先转，否则会把后面生成的实体再转一次。
  assert_eq(escape_html("&lt;"), "&amp;lt;")
  // 普通文本原样通过，包括中文。
  assert_eq(escape_html("你好 world 123"), "你好 world 123")
  assert_eq(escape_html(""), "")
}

///|
test "parse_int accepts digits only" {
  assert_eq(parse_int("0"), Some(0))
  assert_eq(parse_int("7"), Some(7))
  assert_eq(parse_int("42"), Some(42))
  // 下标允许前导零，不做额外校验：它来自我们自己渲染出的属性。
  assert_eq(parse_int("007"), Some(7))
  assert_eq(parse_int(""), None)
  assert_eq(parse_int("1a"), None)
  assert_eq(parse_int("-1"), None)
  assert_eq(parse_int("1.5"), None)
}

///|
test "view names round-trip" {
  for view in [
    View::Overview,
    View::Detail,
    View::Drift,
    View::Diagnose,
    View::Sanitize,
  ] {
    match view_of(view.name()) {
      Some(parsed) => assert_true(parsed == view)
      None => fail("视图名没有解析回来：" + view.name())
    }
  }
  // 不用 `assert_eq`：它要求被比较的类型实现 `Show`，而本模块刻意不给公开枚举
  // 加 `Show`（展示格式属于细节；要短标识就提供 `name()`）。
  assert_true(view_of("nope") is None)
}

///|
test "an empty state renders a hint instead of a broken table" {
  let html = render_app(AppState::new())
  assert_true(html.contains("还没有载入录制"))
  // 空状态不该出现表格骨架 —— 那会让人以为「有内容但没渲染出来」。
  assert_false(html.contains("<table"))
}

///|
test "loading a cassette switches the overview to real content" {
  let state = AppState::new()
  state.load_primary("自带样例", sample_text())
  let html = render_app(state)
  assert_true(html.contains("自带样例"))
  assert_true(html.contains("记录数 <strong>3</strong>"))
  // 三种形态都要能看出来：整段、流式、以及被限流的状态码。
  assert_true(html.contains("整段"))
  assert_true(html.contains("流式 · 3 帧"))
  assert_true(html.contains(">429<"))
}

///|
test "loading twice replaces the primary instead of piling up" {
  // 早期版本把第二次载入当成「右侧对比」，于是脱敏预览看的是上一份录制 ——
  // 界面显示的内容与用户刚做的事没有关系。这条测试钉住双槽位的语义。
  let state = AppState::new()
  state.load_primary("第一份", sample_text())
  state.load_primary("第二份", leaky_text())
  let html = render_app(state)
  assert_true(html.contains("第二份"))
  assert_false(html.contains("第一份"))
}

///|
test "a decode failure is reported and leaves the previous state intact" {
  let state = AppState::new()
  state.load_primary("好的", sample_text())
  state.load_primary("坏的", "{\"this is\": \"not a cassette\"}")
  // 错误原文要留下 —— 它带着出错路径，用户照着改文件即可。
  assert_true(state.status.contains("载入「坏的」失败"))
  // 之前那份仍然是主录制：一次失败的载入不该把已有内容清空。
  assert_true(render_app(state).contains("好的"))
}

///|
test "the sanitize view hides the raw text until asked" {
  // 脱敏预览的原文可能含真实密钥，而屏幕会被截图、会被投屏。
  let state = AppState::new()
  state.load_primary("含密钥", leaky_text())
  state.view = View::Sanitize
  let hidden = render_app(state)
  assert_true(hidden.contains("已抹除"))
  assert_true(hidden.contains("REDACTED"))
  assert_false(hidden.contains("sk-abcdefgh12345678"))
  state.reveal_raw = true
  let shown = render_app(state)
  assert_true(shown.contains("sk-abcdefgh12345678"))
}

///|
test "the diagnose view explains why a request does not match" {
  let state = AppState::new()
  state.load_primary("自带样例", sample_text())
  state.view = View::Diagnose
  state.query = miss_query_text()
  let html = render_app(state)
  assert_true(html.contains("未命中诊断"))
  // 差异只报路径、不报字段值。
  assert_true(html.contains("$.model"))
  assert_false(html.contains("gpt-4o-mini"))
}

///|
test "an unparsable query is reported instead of raising" {
  let state = AppState::new()
  state.load_primary("自带样例", sample_text())
  state.view = View::Diagnose
  state.query = "这不是 JSON"
  let html = render_app(state)
  assert_true(html.contains("请求解析失败"))
}

///|
test "the drift view needs two recordings and says so" {
  let state = AppState::new()
  state.load_primary("自带样例", sample_text())
  state.view = View::Drift
  assert_true(render_app(state).contains("只有一份录制"))
  state.load_comparison("漂移样例", drifted_text())
  let html = render_app(state)
  // 两份样例只差一处响应，因此报告的应当是「请求没变、响应变了」。
  assert_true(html.contains("Changed"))
  assert_false(html.contains("只有一份录制"))
}

///|
test "identical recordings report no drift" {
  let state = AppState::new()
  state.load_primary("自带样例", sample_text())
  state.load_comparison("同一份", sample_text())
  state.view = View::Drift
  assert_true(render_app(state).contains("没有行为漂移"))
}
