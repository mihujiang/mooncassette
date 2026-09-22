# mooncassette-llm

把 [`mizchi/llm`](https://mooncakes.io/docs/mizchi/llm) 的对话跑在 [mooncassette](https://mooncakes.io/docs/weopqrst/mooncassette) 录下来的磁带上。

## 为什么需要这一层

`mizchi/llm` 的测试有两条老路，都不太好：

| 做法 | 问题 |
| --- | --- |
| 打真实接口 | 慢、要密钥、结果会漂，CI 里跑不了 |
| `MockProvider` 手搓事件 | 快，但搓出来的序列是不是真的长这样，没人验证过 |

**回放**是第三条路：录的时候打真实接口，跑的时候零网络，而跑的那份字节是真的。

另一半理由是**计数**。`mizchi/llm` 的 `Message::estimate_tokens` 按 `(字符数 + 3) / 4`
猜 token。而磁带里存着 provider 亲口上报的 `usage`。实测差距不小：

```text
mizchi/llm 估算输入：3
provider  上报输入：31
差额：28（估算偏低）
```

按量计费、按量限额、按量告警，这三件事全都建立在那个数字上。

## 安装

```bash
moon add weopqrst/mooncassette-llm
```

## 用法

下游代码用的是 `mizchi/llm` 原样的 `Provider` 接口，一行都不用改：

```moonbit
// 线上：@llm.collect(openai_provider, messages)
// 测试：换成磁带回放
let session = @recorder.Session::new(cassette, mode=@recorder.Mode::Playback)
let provider = @adapter.CassetteProvider::new(session, "gpt-4o-mini")
let result = @llm.collect(provider, messages)

println(result.text)     // 录下来的原文
println(result.usage)    // 录下来的真实用量
```

也可以只看用量，不必先跑一轮：

```moonbit
let request = @adapter.request_of_messages("openai", "gpt-4o-mini", messages)
match @adapter.reported_usage(cassette, request) {
  Some(usage) => println("这一轮花了 " + usage.input_tokens.to_string() + " 个输入 token")
  None => println("没录过这一轮")   // 不猜，交回 None
}
```

并把估算与上报并排比较：

```moonbit
provider.token_drift()   // Some((估算, 上报))
```

## 请求体形状是对齐的

适配层的 `openai_body` 复刻了 `mizchi/llm/openai` 里 `build_openai_body` 的形状
（始终流式、带 `stream_options.include_usage`、system prompt 前置、无工具时不出
`tools` 字段）。**指纹是从请求体算出来的**，差一个字段就命中不了用它录下来的磁带。

如果你用的是自己拼请求体的 provider，用 `request_of_messages` 生成请求后再录，
两边共用同一份构造逻辑，就不会错位。

## 边界

本包**只依赖 `mizchi/llm` 的顶层包**，不碰 `mizchi/llm/openai` 与 `mizchi/llm/ffi`。

这不是洁癖，是两件实际的事：

- 那两个子包引出 `mizchi/x/http` 与 `moonbitlang/async` 的 socket 实现，而顶层包
  （`Message` / `ContentBlock` / `Usage` / `Provider`）是纯数据与纯转换，零网络依赖；
- 顶层包对工具链的要求很低，因此本模块在「异步适配层因工具链过旧而编译不过」的
  环境里依然可用。

代价是本层自己解析 OpenAI 兼容协议的帧，没有复用上游的 `parse_openai_event`。
测试用真实协议的字节来兜这个底。
