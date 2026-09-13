// mooncassette Demo —— 宿主能力层（浏览器）。
//
// 这一层有意保持**极薄**，并且只传递字符串与闭包，不把 JS 对象长期保存在
// MoonBit 侧：跨语言引用一旦被持有，生命周期、相等性与垃圾回收都会变成难查的
// 问题，而这里根本不需要它们。
//
// 界面本身是纯函数（状态 → HTML 字符串，见 `render.mbt`），因此绝大部分逻辑可以
// 在没有浏览器的环境里断言（`moon test` 只调用渲染函数，不碰下面这些函数）。
// 本文件是唯一需要浏览器的部分。
//
// `extern "js"` 在 wasm-gc 后端不受支持 —— 这正是 Demo 必须作为**独立模块**存在
// 的原因：它不能出现在父模块的包树里，否则父模块的 `moon check --target wasm-gc`
// 会直接失败。

///|
/// 把一段 HTML 写进指定元素。
///
/// 渲染策略是「整块替换」而不是增量更新：状态少、规模小，整块替换的实现没有
/// 中间态，也就不存在「界面与状态不一致」这类缺陷。
///
/// 正因如此，所有进入 HTML 的文本都必须先经 `escape_html`：这里写的是
/// **用户提供的文件内容**，直接拼接等于给注入留门。
pub fn set_html(element_id : String, html : String) -> Unit {
  set_html_ffi(element_id, html)
}

///|
extern "js" fn set_html_ffi(element_id : String, html : String) -> Unit =
  #| function(element_id, html) {
  #|   const element = document.getElementById(element_id);
  #|   if (element) { element.innerHTML = html; }
  #| }

///|
/// 在容器上注册**一次**点击监听，按 `data-action` 分派。
///
/// 用事件委托而不是「渲染后再逐个绑定」：整块重渲染会丢弃所有已绑定的监听，
/// 若每次渲染都重新绑定，监听器会随渲染次数不断堆积。
///
/// 处理函数收到被点击元素（或其最近的祖先）上的 `data-action` 与 `data-arg`。
///
/// 动作与参数分成两个属性，而不是拼成一个 `view:overview`：字符串解析是
/// 一类完全不必要的出错来源，而 DOM 本来就能带两个属性。
/// `data-arg` 缺省时传空串。
pub fn on_delegated_click(
  container_id : String,
  handler : (String, String) -> Unit,
) -> Unit {
  on_delegated_click_ffi(container_id, handler)
}

///|
extern "js" fn on_delegated_click_ffi(
  container_id : String,
  handler : (String, String) -> Unit,
) -> Unit =
  #| function(container_id, handler) {
  // 特殊值 "body"：监听整个文档。工具栏与标签页分处静态 HTML 与重渲染区，
  // 挂在根部就不必关心某个按钮在哪一边。
  #|   const root = container_id === "body"
  #|     ? document.body
  #|     : document.getElementById(container_id);
  #|   if (!root) { return; }
  #|   root.addEventListener("click", function (event) {
  #|     const target = event.target && event.target.closest("[data-action]");
  #|     if (!target) { return; }
  #|     const action = target.getAttribute("data-action") || "";
  #|     const arg = target.getAttribute("data-arg") || "";
  #|     handler(action, arg);
  #|   });
  #| }

///|
/// 读取用户一次选择的文本。
///
/// 浏览器里不能直接读路径（沙箱限制），只能由用户选择文件后拿到内容：
/// `<input type="file">` → `FileReader` → 回调。因此本函数一次只交付一份文本，
/// 调用方靠「两个独立的输入框」来区分「左侧」与「右侧」。
pub fn on_file_selected(
  input_id : String,
  handler : (String, String) -> Unit,
) -> Unit {
  on_file_selected_ffi(input_id, handler)
}

///|
extern "js" fn on_file_selected_ffi(
  input_id : String,
  handler : (String, String) -> Unit,
) -> Unit =
  #| function(input_id, handler) {
  #|   const input = document.getElementById(input_id);
  #|   if (!input) { return; }
  #|   input.addEventListener("change", function () {
  #|     const file = input.files && input.files[0];
  #|     if (!file) { return; }
  #|     const reader = new FileReader();
  #|     reader.onload = function () {
  #|       handler(file.name, String(reader.result));
  // 清空 value：否则连续选择同一个文件不会再触发 change。
  #|       input.value = "";
  #|     };
  #|     reader.readAsText(file);
  #|   });
  #| }

///|
/// 监听一个静态文本域的输入。
///
/// 文本域刻意放在静态 HTML 里而不是由渲染生成：整块重渲染会把光标顶回开头，
/// 边打字边重渲染等于没法输入。
pub fn on_text_input(element_id : String, handler : (String) -> Unit) -> Unit {
  on_text_input_ffi(element_id, handler)
}

///|
extern "js" fn on_text_input_ffi(
  element_id : String,
  handler : (String) -> Unit,
) -> Unit =
  #| function(element_id, handler) {
  #|   const element = document.getElementById(element_id);
  #|   if (!element) { return; }
  #|   element.addEventListener("input", function () { handler(element.value); });
  #| }

///|
/// 显示或隐藏一个静态元素。
///
/// 只给**不参与重渲染**的元素用（例如诊断输入框）：那些元素必须留在静态 HTML
/// 里，因此它们「什么时候出现」只能靠单独切换，而不能靠重渲染。
pub fn set_visible(element_id : String, visible : Bool) -> Unit {
  set_visible_ffi(element_id, visible)
}

///|
extern "js" fn set_visible_ffi(element_id : String, visible : Bool) -> Unit =
  #| function(element_id, visible) {
  #|   const element = document.getElementById(element_id);
  #|   if (element) { element.style.display = visible ? "" : "none"; }
  #| }

///|
/// 打印到浏览器控制台。诊断失败原因时比在页面上显示更方便（不占版面）。
pub fn console_log(message : String) -> Unit {
  console_log_ffi(message)
}

///|
extern "js" fn console_log_ffi(message : String) -> Unit =
  #| function(message) { console.log(message); }
