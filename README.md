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
moon run examples/offline_demo --target js     # 完整走一遍录制 → 落盘 → 回放
moon run cmd/main --target js -- verify examples/demo.cassette.json
moon run cmd/main --target js -- show   examples/demo.cassette.json
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

```moonbit
struct MyHttpTransport {
  client : MyHttpClient
}

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

```moonbit
let session = @mooncassette.auto_session(
  @core.Cassette::new("chat-demo"),
  MyHttpTransport::new(client),
)
let _ = session.send(request)
// 把结果写入 tests/cassettes/chat-demo.cassette.json 并提交进版本控制
@fs.write_string_to_file(path, @mooncassette.save(session))
```

### 3. 测试时：只读回放

```moonbit
test "chat returns the recorded answer" {
  let session = @mooncassette.replay_session(recorded_text)
  let response = session.send(request)
  assert_eq(response.body, Json::string("录下来的答案"))
}
```

这个测试不需要网络、不需要密钥，且永远稳定。

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

---

## CLI

```bash
mooncassette verify <cassette.json>   # 解码 + 完整性校验，非零退出码表示失败
mooncassette show   <cassette.json>   # 打印概要（版本、记录数、token、模型）
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
| V0.1 不含耗时断言 | 耗时是非确定字段，先保证确定性 | 计划在 V0.2 以独立元数据形式引入 |
| 库本体不含 `fs`/`http` 依赖 | 保持纯计算、全后端可编译 | 文件读写与网络由使用方接入 |

---

## 测试与验证

```bash
moon test --target wasm-gc   # 默认目标
moon test --target js        # 交叉验证
moon check --target js
moon fmt && moon info
```

当前 **102 个测试全部通过**，覆盖八个包。测试的重点不是行数，而是
**每条不变量都有对应断言**，例如：

- FNV-1a 用官方测试向量校验（空串 / `"a"` / `"foobar"`）；
- 规范文本的键序、转义、幂等性；
- 环形查找的推进与回卷边界（白盒直测私有算术）；
- 篡改**请求体**、**响应体**、**状态码**、**token 用量**都必须被检出；
- 脱敏不能误伤 `max_tokens` / `total_tokens`；
- 真实调用的请求**必须保留密钥**（用记录型 Transport 断言）；
- 带密钥的请求「录制后立刻回放」必须命中（回归测试）；
- 回放模式下 `Transport` 调用次数必须为 0。

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
| `recorder` | `Transport` 抽象、会话引擎、`MockTransport` | 否 |
| `mooncassette` | 门面：最短上手路径 | 否 |

**全部子包都是纯计算包**，可在 `wasm` / `wasm-gc` / `js` / `native` 后端编译。
真实网络与文件系统由使用方通过 `Transport` 与自有 IO 接入
（仓库内的示例与 CLI 使用 `moonbitlang/x`，属于外层壳）。

---

## 路线图

- **V0.1（当前）** —— 数据模型、规范文本、指纹与完整性摘要、匹配、脱敏、
  编解码、会话引擎、CLI、离线示例与文档。
- **V0.2** —— 耗时与 token 用量的独立元数据层（不破坏确定性）；
  cassette 的裁剪与合并命令；漂移检测报告。
- **V0.3** —— 面向主流 provider 的 Transport 适配器与示例工程。
- **V1.0** —— 格式冻结、迁移指南、多后端 CI 矩阵、发布到 mooncakes.io。

---

## 许可

Apache-2.0
