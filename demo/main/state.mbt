// mooncassette Demo —— 界面状态。
//
// 全部可变状态集中在这里，渲染是它的**纯函数**（见 `render.mbt`）。这样
// 「点一下之后界面变成什么」就能脱离浏览器断言 —— 浏览器里手动点一遍不算验证，
// 因为它不可重复、也不会在改动后自动重跑。

///|
/// 五个视图。
pub(all) enum View {
  /// 概览：这份录制里都有什么。
  Overview
  /// 单条详情：某一次调用的请求与响应。
  Detail
  /// 漂移对比：两份录制哪里不一样。
  Drift
  /// 未命中诊断：为什么这条请求匹配不上。
  Diagnose
  /// 脱敏预览：脱敏抹掉了什么。
  Sanitize
} derive(Eq)

///|
/// 视图名，用于 `data-arg` 与标签页。
pub fn View::name(self : View) -> String {
  match self {
    Overview => "overview"
    Detail => "detail"
    Drift => "drift"
    Diagnose => "diagnose"
    Sanitize => "sanitize"
  }
}

///|
/// 视图的中文标题。
pub fn View::title(self : View) -> String {
  match self {
    Overview => "概览"
    Detail => "单条详情"
    Drift => "漂移对比"
    Diagnose => "未命中诊断"
    Sanitize => "脱敏预览"
  }
}

///|
/// 标签页的提示文字。
pub fn View::hint(self : View) -> String {
  match self {
    Overview => "这份录制里有哪些调用、各是什么形态"
    Detail => "某一次调用的完整请求与响应"
    Drift => "两份录制之间，哪些调用变了"
    Diagnose => "贴一个请求，看它为什么匹配不上"
    Sanitize => "密钥在落盘前被抹成了什么"
  }
}

///|
/// 从名字解析视图；不认识的值返回 `None`。
pub fn view_of(name : String) -> View? {
  match name {
    "overview" => Some(Overview)
    "detail" => Some(Detail)
    "drift" => Some(Drift)
    "diagnose" => Some(Diagnose)
    "sanitize" => Some(Sanitize)
    _ => None
  }
}

///|
/// 一份已载入的录制。
pub(all) struct Loaded {
  /// 界面上用来区分两份录制的名字（文件名，或「自带样例」）。
  label : String
  cassette : @core.Cassette
  /// 原始文本的字符数。用它而不是重新编码的结果：界面上要显示的是
  /// 「你交进来的东西有多大」，重新编码会掩盖差异。
  size : Int
}

///|
/// 界面状态。
///
/// 只有两个录制槽位，而不是一个可增长的列表：界面上每一处都明确是「看这一份」，
/// 或者「比较这两份」。允许列表则要回答「详情看的是哪一份」这类问题，
/// 而那类问题没有好答案 —— 它只会让用户猜。
pub(all) struct AppState {
  /// 主录制：概览、详情、诊断、脱敏都看这一份。
  mut primary_tape : Loaded?
  /// 用于漂移对比的第二份。
  mut comparison_tape : Loaded?
  mut view : View
  /// 概览里展开的那条记录；`None` 表示没有展开。
  mut detail : Int?
  /// 诊断是否只比较请求体（演示匹配策略会改变结论）。
  mut body_only : Bool
  /// 脱敏预览是否显示脱敏**前**的原文。
  ///
  /// 默认为 `false`：那份原文可能含真实密钥，而用户载入的正是「还没脱敏的文件」。
  /// 页面本身不出网，但屏幕会被截图、会被投屏，因此默认不显示，需要时再点开。
  mut reveal_raw : Bool
  /// 诊断视图里用户贴进来的请求文本。
  mut query : String
  /// 状态栏文字。
  mut status : String
}

///|
/// 初始状态。
pub fn AppState::new() -> AppState {
  {
    primary_tape: None,
    comparison_tape: None,
    view: Overview,
    detail: None,
    body_only: false,
    reveal_raw: false,
    query: "",
    status: "还没有载入录制。点「载入自带样例」，或选择一份 cassette 文件。",
  }
}

///|
/// 主录制。
pub fn AppState::primary(self : AppState) -> Loaded? {
  self.primary_tape
}

///|
/// 用于漂移对比的第二份录制。
pub fn AppState::secondary(self : AppState) -> Loaded? {
  self.comparison_tape
}

///|
/// 解码一段文本。失败时把错误写进状态栏并返回 `None`。
///
/// 解码失败不算异常情况：用户完全可能选错文件。此时把错误原样显示出来即可 ——
/// 错误信息本身就带出错路径（如 `$.interactions[3].response.status`），比一句
/// 「载入失败」有用得多。
fn AppState::decode(self : AppState, label : String, text : String) -> Loaded? {
  let cassette = @codec.decode(text) catch {
    error => {
      self.status = "载入「" +
        label +
        "」失败：" +
        error.to_string() +
        "　（错误里的路径可以直接拿去对照文件）"
      return None
    }
  }
  Some({ label, cassette, size: text.length() })
}

///|
/// 载入主录制：概览、详情、诊断、脱敏都会看它。
pub fn AppState::load_primary(
  self : AppState,
  label : String,
  text : String,
) -> Unit {
  match self.decode(label, text) {
    None => ()
    Some(loaded) => {
      self.primary_tape = Some(loaded)
      self.detail = None
      self.status = "主录制已换成「" +
        label +
        "」：" +
        loaded.cassette.length().to_string() +
        " 条记录，" +
        loaded.size.to_string() +
        " 字符。"
    }
  }
}

///|
/// 载入用于对比的第二份录制。
pub fn AppState::load_comparison(
  self : AppState,
  label : String,
  text : String,
) -> Unit {
  match self.decode(label, text) {
    None => ()
    Some(loaded) => {
      self.comparison_tape = Some(loaded)
      self.status = "对比录制已换成「" +
        label +
        "」：" +
        loaded.cassette.length().to_string() +
        " 条记录。"
    }
  }
}
