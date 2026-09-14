// mooncassette Demo —— 渲染。
//
// 渲染是**纯函数**：状态进去，HTML 字符串出来。没有浏览器也能断言，因此
// 「点一下之后界面变成什么」可以被测试钉住（见 logic_wbtest.mbt）。
// 浏览器里手动点一遍不算验证 —— 它不可重复，也不会在改动后自动重跑。

///|
/// 把文本转义成可以安全放进 HTML 的形式。
///
/// 这不是可选项：页面渲染的是**用户提供的文件内容**。一份含 `<script>` 的
/// cassette 若被直接拼进 `innerHTML`，就会在页面上执行 —— 而 cassette 恰恰是
/// 从外部拿来的文件。
pub fn escape_html(text : String) -> String {
  let out = StringBuilder::new()
  for ch in text.to_array() {
    match ch {
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '&' => out.write_string("&amp;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
/// 把一串十进制数字解析成整数；非数字返回 `None`。
///
/// 手写而不去找库函数：这里只处理 `data-arg` 里的下标，输入完全可控；手写版本
/// 没有区域设置、符号、溢出这些需要额外考虑的分支。
pub fn parse_int(text : String) -> Int? {
  let digits = text.to_array()
  if digits.length() == 0 {
    return None
  }
  let mut value = 0
  for ch in digits {
    let code = ch.to_int()
    if code < 48 || code > 57 {
      return None
    }
    value = value * 10 + (code - 48)
  }
  Some(value)
}

///|
/// 状态码对应的样式类。用颜色区分比逐个读数字快得多。
fn status_class(status : Int) -> String {
  if status >= 200 && status < 300 {
    "ok"
  } else if status == 429 {
    "warn"
  } else if status == 0 {
    "muted"
  } else {
    "bad"
  }
}

///|
fn empty_state(title : String, hint : String) -> String {
  "<div class=\"empty\"><p class=\"empty-title\">" +
  escape_html(title) +
  "</p><p class=\"empty-hint\">" +
  escape_html(hint) +
  "</p></div>"
}

///|
fn code_block(text : String) -> String {
  "<pre class=\"code\">" + escape_html(text) + "</pre>"
}

///|
/// 把若干行拼成一段文本（用于 `<pre>` 内部）。
fn join_lines(items : Array[String]) -> String {
  let out = StringBuilder::new()
  for i = 0; i < items.length(); i = i + 1 {
    if i > 0 {
      out.write_string("\n")
    }
    out.write_string(items[i])
  }
  out.to_string()
}

///|
/// 把若干片段用 `<br>` 连接成一个单元格。
///
/// 转义必须在**拼接之前**逐个做：先拼 `<br>` 再整体转义，会把连接符本身也
/// 转义掉，界面上就会直接显示出 `&lt;br&gt;` 这几个字。
fn join_escaped_html(items : Array[String]) -> String {
  let out = StringBuilder::new()
  for i = 0; i < items.length(); i = i + 1 {
    if i > 0 {
      out.write_string("<br>")
    }
    out.write_string(escape_html(items[i]))
  }
  out.to_string()
}

///|
/// 渲染整块应用区（标签页 + 当前视图 + 状态栏）。
///
/// 整块替换而不是增量更新：状态少、规模小，整块替换没有中间态，也就不存在
/// 「界面与状态不一致」这类缺陷。
pub fn render_app(state : AppState) -> String {
  let out = StringBuilder::new()
  out.write_string(render_tabs(state))
  out.write_string("<section class=\"panel\">")
  out.write_string(
    match state.view {
      Overview => render_overview(state)
      Detail => render_detail(state)
      Drift => render_drift(state)
      Diagnose => render_diagnose(state)
      Sanitize => render_sanitize(state)
    },
  )
  out.write_string("</section>")
  out.write_string("<p class=\"status\">" + escape_html(state.status) + "</p>")
  out.to_string()
}

///|
fn render_tabs(state : AppState) -> String {
  let out = StringBuilder::new()
  out.write_string("<nav class=\"tabs\">")
  for view in [Overview, Detail, Drift, Diagnose, Sanitize] {
    let active = if view == state.view { " active" } else { "" }
    out.write_string(
      "<button class=\"tab" +
      active +
      "\" data-action=\"view\" data-arg=\"" +
      view.name() +
      "\" title=\"" +
      escape_html(view.hint()) +
      "\">" +
      escape_html(view.title()) +
      "</button>",
    )
  }
  out.write_string("</nav>")
  out.to_string()
}

///|
/// 概览：这份录制里有哪些调用。
fn render_overview(state : AppState) -> String {
  let loaded = match state.primary() {
    None =>
      return empty_state(
        "还没有载入录制",
        "点上面的「载入自带样例」，或者选一份 cassette 文件。",
      )
    Some(loaded) => loaded
  }
  let cassette = loaded.cassette
  let out = StringBuilder::new()
  out.write_string("<h2>" + escape_html(loaded.label) + "</h2>")
  out.write_string("<p class=\"meta\">名称 <code>" + escape_html(cassette.meta.name) + "</code>")
  out.write_string("　生成器 <code>" + escape_html(cassette.meta.generator) + "</code>")
  out.write_string("　记录数 <strong>" + cassette.length().to_string() + "</strong>")
  out.write_string("　体积 " + loaded.size.to_string() + " 字符</p>")
  if cassette.length() == 0 {
    out.write_string(empty_state("这份录制里没有记录", "它是一份合法的空 cassette。"))
    return out.to_string()
  }
  out.write_string(
    "<table class=\"rows\"><thead><tr><th>#</th><th>provider / model</th><th>状态</th><th>形态</th><th>tokens</th><th></th></tr></thead><tbody>",
  )
  for i = 0; i < cassette.length(); i = i + 1 {
    let interaction = cassette.interactions[i]
    let response = interaction.response
    let shape = match response.stream {
      Some(frames) => "流式 · " + frames.length().to_string() + " 帧"
      None => "整段"
    }
    let tokens = match response.usage {
      Some(usage) => usage.total().to_string()
      None => "—"
    }
    out.write_string(
      "<tr><td>" +
      i.to_string() +
      "</td><td><code>" +
      escape_html(interaction.request.provider) +
      "</code> / <code>" +
      escape_html(interaction.request.model) +
      "</code></td><td><span class=\"badge " +
      status_class(response.status) +
      "\">" +
      response.status.to_string() +
      "</span></td><td>" +
      escape_html(shape) +
      "</td><td>" +
      escape_html(tokens) +
      "</td><td><button class=\"link\" data-action=\"open\" data-arg=\"" +
      i.to_string() +
      "\">详情</button></td></tr>",
    )
  }
  out.write_string("</tbody></table>")
  out.to_string()
}

///|
/// 单条详情：某一次调用的完整请求与响应。
fn render_detail(state : AppState) -> String {
  let loaded = match state.primary() {
    None =>
      return empty_state("还没有载入录制", "先载入一份录制，再回来看某一条调用的细节。")
    Some(loaded) => loaded
  }
  let cassette = loaded.cassette
  let index = match state.detail {
    Some(index) => index
    None => return empty_state("还没有选择记录", "在「概览」里点某条记录右侧的「详情」。")
  }
  if index < 0 || index >= cassette.length() {
    return empty_state("记录下标越界", "这份录制里只有 " + cassette.length().to_string() + " 条记录。")
  }
  let interaction = cassette.interactions[index]
  let response = interaction.response
  let out = StringBuilder::new()
  out.write_string(
    "<div class=\"row-head\"><h2>#" +
    index.to_string() +
    "</h2><div class=\"nav-buttons\">",
  )
  if index > 0 {
    out.write_string(
      "<button data-action=\"open\" data-arg=\"" + (index - 1).to_string() + "\">上一条</button>",
    )
  }
  if index + 1 < cassette.length() {
    out.write_string(
      "<button data-action=\"open\" data-arg=\"" + (index + 1).to_string() + "\">下一条</button>",
    )
  }
  out.write_string("</div></div>")
  out.write_string("<div class=\"columns\">")
  out.write_string("<div><h3>请求</h3>")
  out.write_string(code_block(@canon.to_pretty_string(interaction.request.to_json())))
  out.write_string("</div>")
  out.write_string("<div><h3>响应 ")
  out.write_string(
    "<span class=\"badge " +
    status_class(response.status) +
    "\">" +
    response.status.to_string() +
    "</span>",
  )
  out.write_string("</h3>")
  out.write_string(code_block(@canon.to_pretty_string(response.body)))
  out.write_string("</div></div>")
  match response.stream {
    None => out.write_string("<p class=\"meta\">这是一次整段响应：没有逐帧记录。</p>")
    Some(frames) => {
      out.write_string(
        "<h3>流式帧（" +
        frames.length().to_string() +
        "）<span class=\"meta\">　回放时会按这个顺序逐帧交付</span></h3>",
      )
      let text = StringBuilder::new()
      for i = 0; i < frames.length(); i = i + 1 {
        let frame = frames[i]
        text.write_string("[" + i.to_string() + "] ")
        match frame.event {
          Some(event) => text.write_string("event: " + event + "　")
          None => ()
        }
        text.write_string(frame.data + "\n")
      }
      out.write_string(code_block(text.to_string()))
    }
  }
  out.to_string()
}

///|
/// 漂移对比：两份录制之间哪里不一样。
fn render_drift(state : AppState) -> String {
  let left = match state.primary() {
    None => return empty_state("还没有载入录制", "先载入两份录制，再来比较。")
    Some(loaded) => loaded
  }
  let right = match state.secondary() {
    None =>
      return empty_state(
        "只有一份录制",
        "漂移对比需要两份：再用文件输入载入第二份，或点「载入漂移样例」。",
      )
    Some(loaded) => loaded
  }
  let report = @mooncassette.compare_recordings(left.cassette, right.cassette)
  let out = StringBuilder::new()
  out.write_string(
    "<h2>漂移对比</h2><p class=\"meta\">左：<code>" +
    escape_html(left.label) +
    "</code>　右：<code>" +
    escape_html(right.label) +
    "</code></p>",
  )
  if report.is_clean() {
    out.write_string(
      "<p class=\"verdict ok\">两份录制完全一致，没有行为漂移。</p>",
    )
  } else {
    out.write_string(
      "<p class=\"verdict bad\">" + escape_html(report.summary()) + "</p>",
    )
    out.write_string(
      "<p class=\"meta\">只有第三类（<code>Changed</code>：请求没变、响应变了）才是真正的行为漂移。前两类只说明调用集合变了。</p>",
    )
  }
  out.write_string(code_block(join_lines(report.lines())))
  out.to_string()
}

///|
/// 未命中诊断：贴一个请求，看它为什么匹配不上。
fn render_diagnose(state : AppState) -> String {
  let loaded = match state.primary() {
    None => return empty_state("还没有载入录制", "先载入一份录制，再来诊断。")
    Some(loaded) => loaded
  }
  if state.query.trim().length() == 0 {
    return empty_state("还没有填写请求", "在下面的输入框里贴一段请求 JSON。")
  }
  let request = @codec.decode_request(state.query) catch {
    error =>
      return "<p class=\"verdict bad\">请求解析失败：<code>" +
        escape_html(error.to_string()) +
        "</code></p><p class=\"meta\">请求的形状是 <code>{\"provider\":…,\"model\":…,\"body\":…}</code>。</p>"
  }
  let policy = if state.body_only {
    @matcher.MatchPolicy::Subset(["messages"])
  } else {
    @matcher.MatchPolicy::Exact
  }
  // 先规范化，与真正的回放路径保持一致。
  //
  // `@matcher.diagnose` 只做比对，不做规范化 —— 那是 `@recorder.Session` 的职责
  // （matcher 的文档里就写着「易变字段会盖住真正的原因，Session::diagnose 已经代劳」）。
  // Demo 直接调用 matcher，所以必须自己补上这一步：否则一条带 `request_id` 之类
  // 易变字段的请求会被判成「不匹配」，而同一份 cassette 在真实回放里其实是命中的 ——
  // 那这个页面就教出了错误的结论。
  let diagnosis = @matcher.diagnose(
    request.normalize(),
    loaded.cassette.interactions[:],
    policy,
    0,
    top=5,
  )
  let out = StringBuilder::new()
  out.write_string("<h2>未命中诊断</h2><p class=\"meta\">对 <code>")
  out.write_string(escape_html(loaded.label))
  out.write_string("</code> 用策略 <code>" + policy.name() + "</code> 匹配</p>")
  out.write_string(
    "<div class=\"actions\"><button data-action=\"toggle-body-only\">" +
    (if state.body_only {
      "改回严格匹配（Exact）"
    } else {
      "改成只比较请求体"
    }) +
    "</button><span class=\"meta\">　换个策略看看结论怎么变</span></div>",
  )
  out.write_string(code_block(join_lines(diagnosis.lines())))
  if diagnosis.candidates.length() > 0 {
    out.write_string("<h3>最接近的记录</h3>")
    out.write_string("<table class=\"rows\"><thead><tr><th>#</th><th>provider / model</th><th>差异路径</th></tr></thead><tbody>")
    for candidate in diagnosis.candidates {
      out.write_string(
        "<tr><td>" +
        candidate.index.to_string() +
        "</td><td><code>" +
        escape_html(candidate.provider) +
        "</code> / <code>" +
        escape_html(candidate.model) +
        "</code></td><td><code>" +
        join_escaped_html(candidate.differing_paths) +
        "</code></td></tr>",
      )
    }
    out.write_string("</tbody></table>")
    out.write_string(
      "<p class=\"meta\">只报告路径、不报告字段值：诊断信息常被贴进 issue 或日志，而其中的请求未必脱敏。</p>",
    )
  }
  out.to_string()
}

///|
/// 脱敏预览：密钥在落盘前被抹成了什么。
fn render_sanitize(state : AppState) -> String {
  let loaded = match state.primary() {
    None => return empty_state("还没有载入录制", "先载入一份录制，再来看脱敏前后的差别。")
    Some(loaded) => loaded
  }
  let policy = @sanitize.SanitizePolicy::default()
  let cleaned = @sanitize.sanitize_cassette(loaded.cassette, policy)
  let out = StringBuilder::new()
  out.write_string("<h2>脱敏预览</h2>")
  out.write_string(
    "<p class=\"meta\">同一份录制，左边是落盘时保留的内容，右边是脱敏之后的内容。<strong>真正被写进 cassette 的是右边这一份</strong>。</p>",
  )
  let before = @codec.encode(loaded.cassette)
  let after = @codec.encode(cleaned)
  out.write_string(
    "<div class=\"actions\"><button data-action=\"toggle-reveal-raw\">" +
    (if state.reveal_raw { "隐藏脱敏前的原文" } else { "显示脱敏前的原文" }) +
    "</button><span class=\"meta\">　原文默认隐藏：它可能含真实密钥</span></div>",
  )
  let before_panel = if state.reveal_raw {
    code_block(before)
  } else {
    "<div class=\"empty\"><p class=\"empty-hint\">原文已隐藏。它可能含有真实密钥 —— 而这份文件之所以要拿来脱敏，正是因为有密钥在里面。<br>需要逐字对照时，再点上面的按钮把它显示出来。</p></div>"
  }
  out.write_string("<div class=\"columns\">")
  out.write_string("<div><h3>脱敏前</h3>" + before_panel + "</div>")
  out.write_string("<div><h3>脱敏后</h3>" + code_block(after) + "</div>")
  out.write_string("</div>")
  if before == after {
    out.write_string(
      "<p class=\"verdict ok\">两份完全一致：这份录制里没有出现敏感字段。</p>",
    )
  } else {
    // 差值可能为负：占位符 `***REDACTED***` 有 14 个字符，比某些短密钥更长。
    // 直接打印差值会得到「已抹除 -13 个字符」—— 它看起来像一个 bug，而这里的确
    // 曾经是。既然展示的是「抹掉了什么」，就得把两个方向都说清楚。
    let delta = before.length() - after.length()
    out.write_string(
      "<p class=\"verdict ok\">已抹除敏感内容：" +
      (if delta > 0 {
        "文本缩短 <strong>" + delta.to_string() + "</strong> 个字符"
      } else {
        "占位符比原值长，文本增加 <strong>" +
        (0 - delta).to_string() +
        "</strong> 个字符"
      }) +
      "。</p>",
    )
  }
  out.to_string()
}
