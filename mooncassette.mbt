// mooncassette —— 门面包。
//
// 只提供最短上手路径。完整能力（匹配策略、脱敏策略、规范文本、
// 指纹算法）请直接使用对应子包。

///|
/// 创建**只读回放**会话。
///
/// 这是最安全的入口：不会发起任何真实调用，未命中即报错。
/// 适合在 CI 与单元测试中使用。
///
/// 参数是 cassette 的 **JSON 文本**（不是文件路径）。读取文件由调用方完成，
/// 因为本库刻意不依赖 `fs`：任何后端（含浏览器）都能用同一套 API。
///
/// ```text
/// let text = @fs.read_file_to_string("tests/cassettes/chat.json")
/// let session = @mooncassette.replay_session(text)
/// ```
pub fn replay_session(
  text : StringView,
) -> @recorder.Session raise @core.CassetteError {
  let cassette = @codec.decode(text)
  @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
}

///|
/// 创建**自动录制**会话。
///
/// 语义为「命中就回放、未命中就录制」：首次运行会调用真实 Transport
/// 并把结果并入 cassette，之后运行则完全离线。这是推荐的日常开发流程。
pub fn auto_session(
  cassette : @core.Cassette,
  transport : &@recorder.Transport,
) -> @recorder.Session {
  @recorder.Session::new(cassette, mode=@recorder.Mode::Auto, transport~)
}

///|
/// 创建**纯录制**会话。
pub fn record_session(
  cassette : @core.Cassette,
  transport : &@recorder.Transport,
) -> @recorder.Session {
  @recorder.Session::new(cassette, mode=@recorder.Mode::Record, transport~)
}

///|
/// 比较两份录制，返回漂移报告。
///
/// 典型用法：把通过验收的 cassette 提交进版本控制；日后换了模型版本
/// 或在改了 prompt 之后重新录制，跑一次对比就能回答「模型行为变了没有」。
/// 报告区分三类：调用被删（`Removed`）、调用新增（`Added`）、
/// 以及**请求没变但响应变了**（`Changed`）——最后一类才是真正的行为漂移。
pub fn compare_recordings(
  old : @core.Cassette,
  new : @core.Cassette,
) -> @drift.DriftReport {
  @drift.compare(old, new)
}

///|
/// 把会话当前的 cassette 编码为文本。
///
/// `indent` 省略时输出 2 空格缩进（适合提交进版本控制）；
/// 传 `0` 可得到紧凑形式（适合做字节级比对）。
pub fn save(session : @recorder.Session, indent? : Int) -> String {
  @codec.encode(session.cassette(), indent?)
}
