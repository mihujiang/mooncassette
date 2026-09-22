///|
/// 一个把 mooncassette 的磁带当后端用的 `mizchi/llm` Provider。
///
/// 用它的理由有两个，缺一个都不值得多一层：
///
/// **离线**：`mizchi/llm` 的测试要么打真接口（慢、要密钥、会漂），要么用
/// `MockProvider` 手搓事件序列（快，但搓出来的东西是不是真的长这样，没人知道）。
/// 从磁带回放是第三条路：录的时候是真接口，跑的时候零网络。
///
/// **精确**：`mizchi/llm` 的 `Message::estimate_tokens` 按字符数猜 token。
/// 磁带里存着 provider 亲口报的 `usage`，`token_drift` 把这两个数字并排给出。
///
/// ```text
/// // 测试里
/// let session = @recorder.Session::new(cassette, mode=Playback)
/// let provider = CassetteProvider::new(session, "gpt-4o-mini")
/// let result = @llm.collect(provider, [Message::user("你好")])
/// inspect(result.usage)   // 真实上报值，不是猜的
/// ```
pub(all) struct CassetteProvider {
  session : @recorder.Session
  provider : String
  model : String
  max_tokens : Int
  system_prompt : String
  // 最近一轮的结果。`stream` 的签名里没有返回值（trait 定死了），
  // 而用量是这层最值钱的东西，只能记在身上。
  mut last_usage : @core.Usage?
  mut last_finish_reason : @llm.FinishReason
  mut last_estimated_input_tokens : Int
}

///|
/// `provider` 是协议名（`"openai"` / `"anthropic"` / …），它同时进指纹，
/// 所以录制与回放两边必须给同一个值。
pub fn CassetteProvider::new(
  session : @recorder.Session,
  model : String,
  provider? : String = "openai",
  max_tokens? : Int = 1024,
  system_prompt? : String = "",
) -> CassetteProvider {
  {
    session,
    provider,
    model,
    max_tokens,
    system_prompt,
    last_usage: None,
    last_finish_reason: @llm.FinishReason::Stop,
    last_estimated_input_tokens: 0,
  }
}

///|
pub fn CassetteProvider::session(self : CassetteProvider) -> @recorder.Session {
  self.session
}

///|
pub fn CassetteProvider::model(self : CassetteProvider) -> String {
  self.model
}

///|
/// 最近一轮 provider 上报的用量；没录到就是 `None`。
pub fn CassetteProvider::last_usage(self : CassetteProvider) -> @core.Usage? {
  self.last_usage
}

///|
/// 最近一轮的结束原因。
pub fn CassetteProvider::last_finish_reason(
  self : CassetteProvider,
) -> @llm.FinishReason {
  self.last_finish_reason
}

///|
/// 最近一轮：`(估算输入 token, 上报输入 token)`。
///
/// 两个数字同框才有意义 —— 单看估算值你不知道它离谱在哪，单看上报值你
/// 不知道替代掉的是个什么。没录到用量时返回 `None`。
pub fn CassetteProvider::token_drift(self : CassetteProvider) -> (Int, Int)? {
  match self.last_usage {
    Some(u) => Some((self.last_estimated_input_tokens, u.input_tokens))
    None => None
  }
}

///|
pub impl @llm.Provider for CassetteProvider with fn name(self) {
  self.provider
}

///|
/// 从磁带回放一轮，把帧翻译成 `mizchi/llm` 的流事件。
///
/// 事件序列的形状与原 provider 保持一致：`MessageStart` 开头，中间是增量，
/// 结尾恰好一个 `MessageEnd`。
///
/// 一处刻意的收敛：原 provider 会把协议层的细节漏给下游 —— 比如 OpenAI
/// 的账目帧（`choices` 为空、只带 `usage`）会被翻译成**第二个** `MessageEnd`，
/// 于是下游收到两次"说完了"。这里把帧先收齐再往外发，`MessageEnd` 有且仅有
/// 一个，用量与结束原因在那一刻一起给出。
pub impl @llm.Provider for CassetteProvider with fn stream(
  self,
  messages,
  tools,
  handler,
) {
  let mut estimated = 0
  for message in messages {
    estimated = estimated + message.estimate_tokens()
  }
  self.last_estimated_input_tokens = estimated
  let request = request_of_messages(
    self.provider,
    self.model,
    messages,
    tools~,
    max_tokens=self.max_tokens,
    system_prompt=self.system_prompt,
  )
  let response = self.session.replay(request) catch {
    err => {
      // 回放失败（没录过 / 磁带耗尽 / 指纹对不上）不是崩溃，是一句能读的话。
      // `mizchi/llm` 的 `Error` 事件就是给这个用的。
      (handler.on_event)(@llm.StreamEvent::Error(err.to_string()))
      return
    }
  }
  self.last_usage = response.usage
  self.last_finish_reason = @llm.FinishReason::Stop
  (handler.on_event)(@llm.StreamEvent::MessageStart)
  match response.stream {
    Some(frames) =>
      for frame in frames {
        match parse_frame(frame.data) {
          Some(@llm.StreamEvent::MessageEnd(finish_reason~, usage~)) => {
            match finish_reason {
              @llm.FinishReason::Stop => ()
              _ => self.last_finish_reason = finish_reason
            }
            match usage {
              Some(u) => self.last_usage = Some(to_core_usage(u))
              None => ()
            }
          }
          Some(event) => (handler.on_event)(event)
          None => ()
        }
      }
    None => {
      // 非流式记录（有些端点、有些录制时期不吐帧）：把响应体拆成等价事件，
      // 下游不必关心这一轮到底走的是哪条路。
      let result = collect_result_of_response(response)
      if !result.text.is_empty() {
        (handler.on_event)(@llm.StreamEvent::TextDelta(result.text))
      }
      self.last_finish_reason = result.finish_reason
      match result.usage {
        Some(u) => self.last_usage = Some(to_core_usage(u))
        None => ()
      }
    }
  }
  (handler.on_event)(
    @llm.StreamEvent::MessageEnd(
      finish_reason=self.last_finish_reason,
      usage=match self.last_usage {
        Some(u) => Some(to_llm_usage(u))
        None => None
      },
    ),
  )
}
