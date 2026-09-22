///|
/// 演示：把 `mizchi/llm` 的一轮对话跑在磁带上，全程零网络。
///
/// 这里手工搭了磁带（真实项目里它是 `mooncassette` 录下来的），重点看两件事：
/// 1. 下游代码用的是 `mizchi/llm` 原样的 `Provider` 接口，一行没改；
/// 2. 拿到的用量是 provider 上报值，不是按字符数猜出来的。
fn main {
  let messages : Array[@llm.Message] = [
    @llm.Message::user("用一句话解释什么是磁带"),
  ]
  let request = @adapter.request_of_messages("openai", "gpt-4o-mini", messages)
  let cassette = @core.Cassette::new("llm-demo", interactions=[
    @core.Interaction::new(request, taped_response()),
  ])
  let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
  let provider = @adapter.CassetteProvider::new(session, "gpt-4o-mini")
  println("== 事件流 ==")
  let handler = @llm.StreamHandler::{
    on_event: fn(event) { println("  " + describe(event)) },
  }
  provider.stream(messages, [], handler)
  let result = @llm.collect(provider, messages)
  println("")
  println("== 结果 ==")
  println("文本：" + result.text)
  println("结束原因：" + result.finish_reason.to_string())
  println("")
  println("== 用量：猜的 vs 报的 ==")
  match provider.token_drift() {
    Some((estimated, reported)) => {
      println("  mizchi/llm 估算输入：" + estimated.to_string())
      println("  provider  上报输入：" + reported.to_string())
      let gap = reported - estimated
      println(
        "  差额：" +
        gap.to_string() +
        (if gap > 0 { "（估算偏低）" } else { "（估算偏高）" }),
      )
    }
    None => println("  这一轮没有用量记录")
  }
}

///|
/// 一段 OpenAI 兼容端点的流式响应。最后那帧只带账目、`choices` 为空 ——
/// 账目永远比内容晚一步到，这是「精确用量」唯一麻烦的地方。
fn taped_response() -> @core.Response {
  let frames : Array[@core.StreamFrame] = [
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{\"content\":\"磁带就是\"},\"index\":0}]}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{\"content\":\"把真实请求录下来，之后照着放。\"},\"index\":0}]}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[{\"delta\":{},\"index\":0,\"finish_reason\":\"stop\"}]}",
    ),
    @core.StreamFrame::new(
      "{\"choices\":[],\"usage\":{\"prompt_tokens\":31,\"completion_tokens\":18,\"total_tokens\":49}}",
    ),
  ]
  @core.Response::ok(
    Json::object(Map([])),
    usage=@core.Usage::new(31, 18),
    stream=frames,
  )
}

///|
/// 把事件翻译成一行给人看的话。
fn describe(event : @llm.StreamEvent) -> String {
  match event {
    @llm.StreamEvent::MessageStart => "MessageStart"
    @llm.StreamEvent::TextDelta(text) => "TextDelta  " + text
    @llm.StreamEvent::ToolCallStart(id~, name~) =>
      "ToolCallStart " + id + " -> " + name
    @llm.StreamEvent::ToolCallDelta(id~, input_delta~) =>
      "ToolCallDelta " + id + " " + input_delta
    @llm.StreamEvent::ToolCallEnd(id~, name~, input~) =>
      "ToolCallEnd " +
      id +
      " -> " +
      name +
      " " +
      @canon.to_canonical_string(input)
    @llm.StreamEvent::MessageEnd(finish_reason~, usage~) => {
      let usage_text = match usage {
        Some(u) =>
          "输入 " +
          u.input_tokens.to_string() +
          " / 输出 " +
          u.output_tokens.to_string()
        None => "无用量记录"
      }
      "MessageEnd " + finish_reason.to_string() + "，" + usage_text
    }
    @llm.StreamEvent::Error(message) => "Error " + message
  }
}
