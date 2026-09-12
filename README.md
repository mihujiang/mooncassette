# mooncassette

**给 LLM 应用做确定性录制与回放 —— 让「调用大模型」这件事变得可以离线、可以复现、可以回归。**

`mooncassette` 记录一次真实的 LLM 交互，把它落成一个可读、可 diff 的
cassette 文件；之后无论在 CI、在同事的电脑上、还是在没有网络的飞机上，
测试都会回放出**逐字节一致**的结果。

---

## 为什么需要它

用 LLM 写应用时，测试是三难的：

| 做法 | 问题 |
|---|---|
| 直接调用真实 API | 慢、贵、不稳定；CI 需要密钥；同一输入两次结果不同 |
| 手写 mock | 每次改 prompt 都要同步改 mock；mock 与真实响应逐渐漂移 |
| 不测 | 改一个 prompt 就得靠手动试，回归无从谈起 |

`mooncassette` 提供第四条路：**录制真实流量，回放确定性结果**。

```text
开发阶段   真实调用 ──▶ 录制 ──▶ demo.cassette.json ──▶ 提交进版本控制
测试 / CI  无网络   ──▶ 回放 ──▶ 逐字节一致的结果，零密钥
```

---

## 30 秒上手

不需要网络，也不需要 API Key：

```bash
moon run examples/offline_demo --target js     # 录制 → 落盘 → 回放 → 漂移检测
moon run examples/openai_protocol --target js  # 真实 provider 报文 → 录制 → 离线回放
moon run cmd/main --target js -- verify examples/demo.cassette.json
moon run cmd/main --target js -- show   examples/demo.cassette.json
moon run cmd/main --target js -- diff   examples/demo.cassette.json examples/demo.drifted.cassette.json
moon test --target wasm-gc
```

---

## 核心保证（不变量）

这些是本项目对外承诺、且有测试守护的性质：

1. **回放模式绝不发起真实调用。** `Mode::Playback` 的会话在构造上就不持有
   `Transport`，因此「不小心打到线上」在类型层面被排除。
2. **落盘内容一定经过脱敏，而真实调用一定保留密钥。** 同一次业务请求被派生为
   两个形态：发给 provider 的保留密钥（否则鉴权会失败），写入 cassette 的已脱敏。
   **录制与回放两侧走同一条派生链**，否则会出现「录得进去、回放不出来」。
3. **规范文本是确定的。** 对象键按 UTF-8 字节序排序，与 Map 迭代顺序无关，
   因此同一份 cassette 在任何后端、任何运行下都产出相同字节。
4. **指纹跨目标稳定。** 不使用标准库 `Hasher`（其实现与后端相关），
   而是自实现 FNV-1a 64 位，并用官方测试向量校验。
5. **指纹相同 ≠ 请求相同。** 指纹只用于索引；最终判据是规范文本全等。
   一旦检出真实碰撞会显式报错，而不是静默返回错误结果。
6. **文件被手工改动一定会被发现 —— 包括响应。** cassette 里保存了两个不同
   覆盖范围的摘要，解码时都会重算比对（详见下文「两个摘要」）。
7. **`Interaction` 完全确定。** 时间戳等非确定字段只允许出现在 `CassetteMeta`，
   从类型结构上杜绝「测试随机挂掉」。

---

## 快速上手

### 1. 定义你的 Transport

`Transport` 是唯一的扩展点，把真实 HTTP 客户端接进来即可。它刻意不含
录制、匹配、脱敏逻辑 —— 那些都由会话引擎负责。

```moonbit nocheck
///|
struct MyHttpTransport {
  client : MyHttpClient
}

///|
fn MyHttpTransport::send(
  self : MyHttpTransport,
  request : @core.Request,
) -> @core.Response raise @core.CassetteError {
  let response = self.client.post(request.model, request.body) catch {
    error => raise @core.CassetteError::TransportFailure(error.to_string())
  }
  @core.Response::ok(response.body, usage=response.usage)
}
```

### 2. 开发时：自动录制

`Auto` 模式 = 「命中就回放、未命中就录制」。首次运行会真实调用并写盘，
之后运行完全离线。

```moonbit nocheck
let session = @mooncassette.auto_session(
  @core.Cassette::new("chat-demo"),
  MyHttpTransport::new(client),
)
let _ = session.send(request)
// 把结果写入 tests/cassettes/chat-demo.cassette.json 并提交进版本控制
@fs.write_string_to_file(path, @mooncassette.save(session))
```

### 3. 测试时：只读回放

```moonbit nocheck
///|
test "chat returns the recorded answer" {
  let session = @mooncassette.replay_session(recorded_text)
  let response = session.send(request)
  assert_eq(response.body, Json::string("录下来的答案"))
}
```

这个测试不需要网络、不需要密钥，且永远稳定。

---

## 接入真实 provider

回放与漂移检测都建立在「统一请求/响应」之上，而真实世界是各家自己的报文格式。
`providers` 包负责这层翻译，且**不依赖任何 HTTP 客户端**（因此仍在全部后端可编译，
并且可以用真实报文做离线测试）。

| 协议 | 路径 | 鉴权头 | usage 字段名 |
|---|---|---|---|
| `OpenAiChat` | `/chat/completions` | `Authorization: Bearer …` | `prompt_tokens` / `completion_tokens` |
| `AnthropicMessages` | `/messages` | `x-api-key` + `anthropic-version` | `input_tokens` / `output_tokens` |

`OpenAiChat` 的 `base_url` 可以指向 DeepSeek、Moonshot、vLLM、Ollama 等兼容端点，
因此一个适配器就能覆盖相当广的范围。

它替你处理掉这些容易出错的地方：

- 各家的路径与鉴权头差异；
- usage 字段命名差异（OpenAI 是 `prompt_tokens`，Anthropic 是 `input_tokens`）；
- **错误响应也要能录下来**——否则「限流时怎么办」没法写回归测试；
- 网关返回 HTML 错误页时不会把响应体丢掉，而是包成 `{"raw_body": "…"}`；
- 报文体中若显式写了 `model`，必须与 `Request.model` 一致，否则直接报错
  （这类静默不一致会同时污染指纹与计费口径，很难排查）。

### 你需要实现的只有「发出去」这一步

```moonbit nocheck
///|
let sender = @providers.FunctionSender::new(fn(request) {
  MyClient::call(request) // (HttpRequest) -> HttpResponse raise CassetteError
})

///|
let transport = @providers.ProviderTransport::new(
  @providers.OpenAiChat::new(api_key, base_url="https://api.deepseek.com/v1"),
  sender,
)

///|
let session = @mooncassette.auto_session(@core.Cassette::new("chat"), transport)
```

`api_key` 只会进入 HTTP 请求头，**永远不会**写进 cassette —— cassette 记录的是
统一请求/响应，而不是抓包结果。

### 关于异步 HTTP 客户端（重要）

`mizchi/x/http` 这类客户端是 **async** 的（`async fn post`），而 `HttpSender` 是同步的。
MoonBit 没有「从同步上下文启动异步任务」的入口（`moonbitlang/async` 只提供 `spawn`，
没有 `block_on` 式的桥接），因此**异步客户端无法直接实现 `HttpSender`**。

两条可行路径：

- **客户端是同步的** → 用上面的 `FunctionSender`，几行搞定；
- **客户端是异步的** → 在 async 上下文里分三步手工完成：
  `protocol.encode(request)`（同步构建）→ 异步发送 → `protocol.decode(response)`（同步解析）。
  协议编解码本身与同步/异步无关，因此这两步可以在任何上下文中复用。

---

## 概念

### cassette

一个 cassette 就是「按录制顺序排列的交互列表」，一个 JSON 文件。它是人类可读的，
可以直接在 code review 里看 diff —— 这正是「键序固定」这一设计的意义。

```json
{
  "format": "mooncassette",
  "version": 1,
  "meta": {
    "generator": "mooncassette/0.1.0",
    "name": "chat-demo",
    "recorded_at": "2026-09-12T08:00:00Z"
  },
  "interactions": [
    {
      "fingerprint": "fnv1a64:9f2c1ab34de5f607",
      "integrity": "fnv1a64:5ae605b113f91e60",
      "request": {
        "body": { "messages": [{ "content": "你好", "role": "user" }] },
        "model": "gpt-4o",
        "provider": "openai"
      },
      "response": {
        "body": { "choices": [] },
        "status": 200,
        "usage": { "input_tokens": 10, "output_tokens": 2 }
      }
    }
  ]
}
```

### 两个摘要，两种职责

二者不可互相替代，缺一不可：

| 字段 | 覆盖范围 | 用途 |
|---|---|---|
| `fingerprint` | **仅请求** | 回放**匹配**（回放时响应尚不存在，不能纳入）；也便于人工排查「为什么没命中」 |
| `integrity` | **整条记录（含响应）** | **防篡改**。响应是最容易被手工改动的地方 |

只写 `fingerprint` 是不够的：如果只校验请求，那么「为了让失败的测试通过、
直接改掉 cassette 里的期望输出」这种做法会悄无声息地溜过去，测试也就失去了意义。
`integrity` 的存在就是为了堵住这个洞。

### 请求规范化

生成指纹前会剔除易变字段（`request_id`、`timestamp`、`nonce` 等），
否则每次调用指纹都不同，回放永远不会命中。默认列表见
`@core.default_drop_keys`，可自定义。

### 匹配策略

| 策略 | 语义 | 适用场景 |
|---|---|---|
| `Exact` | 指纹相同 **且** 规范文本全等 | 默认，推荐 |
| `FingerprintOnly` | 只比指纹，跳过文本比对 | 确有性能瓶颈时 |
| `Subset(keys)` | 只比请求体顶层指定字段 | 「prompt 一致就算同一次调用」 |
| `Sequential` | 不比内容，按录制顺序消费 | 调用顺序本身即语义 |

查找采用**环形扫描**：从当前游标向后找，找不到再从头回卷。这样既能正确处理
「同一请求被录多次、按次序依次回放」，又能在实际调用次数多于录制次数时复用
最早的一条，而不是直接失败。注意 `Sequential` **不做**回卷：游标越界即代表
录制已耗尽，必须如实报告，否则「录制覆盖不足」会被悄悄掩盖。

### 脱敏

cassette 会被提交进 git、贴进 issue、用于演示，所以**脱敏是默认行为**：

- 精确键名匹配（`authorization`、`x-api-key`、`cookie` …）；
- 后缀匹配（`_key`、`_token`、`_secret` …）——刻意用后缀而非子串，
  以免误伤 `max_tokens` / `total_tokens` 这类计数字段；
- 字符串值中的密钥形状子串扫描（`sk-` 后接 8 位以上）。

### 漂移检测

回放解决的是「不该变的东西别变」；漂移检测解决的是「该变的东西变了没有」。

你更新了 prompt、换了模型版本，重新录制了一份 cassette。直接看 JSON diff 是读不懂的
（指纹变了、键序也会变）。`mooncassette diff` 回答你真正关心的三件事：

| 类型 | 含义 |
|---|---|
| `Removed` | 这个调用在旧录制里有、新的没有 —— 调用被删了，或请求被改动 |
| `Added` | 只出现在新录制里 —— 新增调用，或请求被改动 |
| `Changed` | **请求完全相同，但响应变了** —— 这才是真正的模型行为漂移 |

第三类最关键：**你的代码一行没改，模型的输出却变了。**

两点刻意的设计：

- **请求改动会报成「一条 Removed + 一条 Added」，而不是「一条 Changed」。**
  因为我们无法判断改后的请求「对应」原来哪一条；与其猜错，不如如实报告。
- **比较前会重新规范化请求。** 正常录制出来的请求本就是规范化形态（再规范化是幂等的），
  但对手工构造或被外部工具改过的 cassette，这一步能避免把「易变字段残留」误判为漂移。
  容错方向是「宁可少报」。

`diff` 在有漂移时以退出码 1 结束，因此可以直接当作 CI 的一步。

```text
$ mooncassette diff examples/demo.cassette.json examples/demo.drifted.cassette.json
[changed] gpt-4o #0 -> #0  b862439f
drift detected: removed=0 changed=1 added=0 unchanged=1
```

---

## CLI

```bash
mooncassette verify <cassette.json>              # 解码 + 完整性校验，非零退出码表示失败
mooncassette show   <cassette.json>              # 打印概要（版本、记录数、token、模型）
mooncassette diff   <old.json> <new.json>        # 报告两次录制之间的漂移，有漂移则退出码 1
mooncassette help
```

`verify` 会同时校验两个摘要，因此它可以直接当作 CI 里的一步：
任何被手工改动的 cassette 都会在那里被拦住，并精确定位到
`$.interactions[i].integrity`。

参数解析刻意**不依赖位置**（不同后端 `@env.args()` 语义不一致），
而是扫描已知子命令关键字，因此 native 与 js 上行为一致。

---

## 设计取舍（已知边界）

诚实列出，避免误用：

| 取舍 | 原因 | 影响 |
|---|---|---|
| 规范文本不区分 `1` 与 `1.0` | JSON 只有一种数字类型；解析器会归一为 `1` | 若需区分整数/浮点，请自行在业务层编码 |
| 非有限数（NaN/Inf）写成 `null` | JSON 无法表示它们 | 不会产出非法 JSON，但会丢失该值 |
| 指纹用非密码学哈希 | 只做索引，一致性由文本全等兜底 | 无安全影响 |
| `integrity` 用非密码学哈希 | 目的是检出**误改**，不是防**恶意伪造** | 需要防伪造请配合签名/权限控制 |
| 脱敏只按**键名**判断 | 值里混进密钥无法可靠识别 | 已用 `sk-` 形状扫描部分缓解；敏感场景请人工复核 |
| 不记录耗时 | 耗时是非确定字段，进入 `Interaction` 会破坏可复现性 | 需要延迟断言请在业务层另行测量 |
| 库本体不含 `fs`/`http` 依赖 | 保持纯计算、全后端可编译 | 文件读写与网络由使用方接入 |

---

## 测试与验证

```bash
moon test --target wasm-gc   # 默认目标
moon test --target js        # 交叉验证
moon check --target js
moon fmt && moon info
```

当前 **136 个测试全部通过**，覆盖十个包，且在 `wasm-gc` 与 `js` 两个目标上各跑一遍。
测试的重点不是行数，而是**每条不变量都有对应断言**，例如：

- FNV-1a 用官方测试向量校验（空串 / `"a"` / `"foobar"`）；
- 规范文本的键序、转义、幂等性；
- 环形查找的推进与回卷边界（白盒直测私有算术）；
- 篡改**请求体**、**响应体**、**状态码**、**token 用量**都必须被检出；
- 脱敏不能误伤 `max_tokens` / `total_tokens`；
- 真实调用的请求**必须保留密钥**（用记录型 Transport 断言）；
- 带密钥的请求「录制后立刻回放」必须命中（回归测试）；
- 回放模式下 `Transport` 调用次数必须为 0；
- 漂移检测：键序/易变字段变化**不算**漂移，而响应变化**必须**算；
- 漂移检测：重复的同一请求按出现顺序两两配对，报告顺序固定为 Removed → Changed → Added；
- 协议解码用**真实 API 形状的报文**（含 429 错误体、HTML 网关错误页、非整数 token 数）验证。

---

## 包结构

| 包 | 职责 | 是否依赖 IO |
|---|---|---|
| `canon` | 规范 JSON 文本 + 稳定哈希 | 否 |
| `core` | 数据模型、规范 JSON 视图、错误、请求规范化 | 否 |
| `fingerprint` | 请求指纹、完整性摘要、等价判据 | 否 |
| `matcher` | 四种匹配策略与环形查找 | 否 |
| `sanitize` | 脱敏策略与递归脱敏 | 否 |
| `codec` | cassette 编解码与完整性校验 | 否 |
| `drift` | 两次录制之间的漂移检测 | 否 |
| `providers` | OpenAI / Anthropic 协议编解码、HTTP 执行器抽象 | 否 |
| `recorder` | `Transport` 抽象、会话引擎、`MockTransport` | 否 |
| `mooncassette` | 门面：最短上手路径 | 否 |

**全部子包都是纯计算包**，可在 `wasm` / `wasm-gc` / `js` / `native` 后端编译。
真实网络与文件系统由使用方通过 `Transport` 与自有 IO 接入
（仓库内的示例与 CLI 使用 `moonbitlang/x`，属于外层壳）。

---

## 已完成

| 版本 | 内容 |
|---|---|
| `0.1.0` | 数据模型与规范 JSON 文本、跨目标稳定指纹、四种匹配策略、脱敏、cassette 编解码与双摘要完整性校验、会话引擎、`verify`/`show` CLI、离线示例 |
| `0.2.0` | 漂移检测（`drift` 包 + `mooncassette diff`）；示例演示「模型换版本后行为漂移」的完整闭环 |

---

## 许可

Apache-2.0
