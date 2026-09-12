// mooncassette —— 门面包。
//
// 只提供最短上手路径。完整能力（匹配策略、脱敏策略、规范文本、
// 指纹算法）请直接使用对应子包。

///|
/// 创建**只读回放**会话。
///
/// 这是最安全的入口：不会发起任何真实调用，未命中即报错。
/// 适合在 CI 与单元测试中使用。
pub fn replay_session(
  location : StringView,
) -> @recorder.Session raise @core.CassetteError {
  let cassette = @codec.decode(location)
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
/// 把会话当前的 cassette 编码为文本。
///
/// `indent` 省略时输出 2 空格缩进（适合提交进版本控制）；
/// 传 `0` 可得到紧凑形式（适合做字节级比对）。
pub fn save(session : @recorder.Session, indent? : Int) -> String {
  @codec.encode(session.cassette(), indent?)
}
