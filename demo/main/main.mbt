// mooncassette Demo —— 入口与事件接线。
//
// 这一层只做三件事：把状态渲染出来、把用户动作翻译成状态变更、变更之后再渲染。
// 规则本身都在 `state.mbt` 与 `render.mbt` 里，因此可以脱离浏览器测试。

///|
fn render_all(state : AppState) -> Unit {
  set_html("app", render_app(state))
  // 诊断输入框留在静态 HTML 里、不参与重渲染：整块替换会把光标顶回开头，
  // 边打字边重渲染等于没法输入。这里只控制它出现与否。
  set_visible("diagnose-controls", state.view == Diagnose)
}

///|
/// 把动作翻译成状态变更。动作与参数来自渲染出的 `data-action` / `data-arg`。
fn handle(state : AppState, action : String, arg : String) -> Unit {
  match action {
    "view" =>
      match view_of(arg) {
        Some(view) => state.view = view
        None => state.status = "未知视图：" + arg
      }
    "open" =>
      match parse_int(arg) {
        Some(index) => {
          state.detail = Some(index)
          state.view = Detail
        }
        None => state.status = "无法识别的记录下标：" + arg
      }
    "load-sample" => {
      state.load_primary("自带样例", sample_text())
      state.view = Overview
    }
    "load-drifted" => {
      // 漂移对比需要两份：基准沿用自带样例，第二份只差一处响应。
      state.load_primary("自带样例", sample_text())
      state.load_comparison("漂移样例（模型换了版本）", drifted_text())
      state.view = Drift
    }
    "load-leaky" => {
      state.load_primary("含密钥的样例（模拟未脱敏的文件）", leaky_text())
      state.view = Sanitize
    }
    "toggle-reveal-raw" => {
      state.reveal_raw = !state.reveal_raw
      state.status = if state.reveal_raw {
        "已显示脱敏前的原文。注意：它可能含有真实密钥。"
      } else {
        "已隐藏脱敏前的原文。"
      }
    }
    "toggle-body-only" => {
      state.body_only = !state.body_only
      state.status = if state.body_only {
        "诊断改为「只比较请求体的 messages 字段」。"
      } else {
        "诊断改回严格匹配：指纹相同且规范请求全等。"
      }
    }
    _ => state.status = "未知动作：" + action
  }
}

///|
fn main {
  let state = AppState::new()
  // 挂在 body 上：工具栏在静态 HTML 里、面板按钮在重渲染区里，
  // 挂在根部就不必关心某个按钮在哪一边。
  on_delegated_click("body", fn(action, arg) {
    handle(state, action, arg)
    render_all(state)
  })
  on_text_input("diagnose-request", fn(text) {
    state.query = text
    // 只重渲染应用区：诊断输入框是静态的，因此光标不会被顶走。
    render_all(state)
  })
  on_file_selected("file-input", fn(name, text) {
    state.load_primary(name, text)
    render_all(state)
  })
  // 两个输入框而不是一个：漂移对比天然需要「左侧」与「右侧」，
  // 用一个输入框反复选择就得靠猜「这次选的是哪一边」。
  on_file_selected("file-input-right", fn(name, text) {
    state.load_comparison(name, text)
    state.view = Drift
    render_all(state)
  })
  // 首屏直接载入自带样例：打开页面就有东西可看，不必先去找文件。
  state.load_primary("自带样例", sample_text())
  state.query = miss_query_text()
  state.status = state.status + "　试试上面的三个样例按钮。"
  render_all(state)
}
