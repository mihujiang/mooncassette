// mooncassette Demo —— 端到端冒烟测试。
//
// 在 Node 里跑**真实构建产物**，只把 DOM 换成一个最小的桩。
//
// 为什么值得写：Demo 的价值几乎全在「点一下之后界面变成什么」，而那一部分是纯
// 函数。没有这个测试，唯一的验证方式就剩下「打开浏览器手动点一遍」—— 不可重复，
// 也不会在改动之后自动重跑。桩只需覆盖 dom.mbt 用到的那几个 API，边界很清楚。
//
// 用法：
//   cd demo && moon build --target js --release
//   node test/smoke.mjs

import { strict as assert } from "node:assert";
import { readFileSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const bundle = join(here, "..", "_build", "js", "release", "build", "main", "main.js");

// ── 1. 产物必须是浏览器可以直接加载的 ─────────────────────────────────────
//
// 这一条比它看起来重要：只要产物里出现 `node:`、`require(` 或 `process.`，
// 页面在浏览器里就会直接报错，而本仓库的其它检查都发现不了。
{
  const source = readFileSync(bundle, "utf8");
  for (const forbidden of ["node:", "require(", "process.", "Buffer."]) {
    assert.ok(
      !source.includes(forbidden),
      `产物里出现了 ${forbidden} —— 它无法在浏览器里运行`,
    );
  }
}

// ── 2. 最小 DOM 桩 ────────────────────────────────────────────────────────
//
// 桩刻意是**严格**的：只有 index.html 里真实存在的 id 才会被返回。
//
// 这不是洁癖。若 MoonBit 侧引用了一个 HTML 里没有的 id（两边一起改名时最容易漏的
// 那种），浏览器里的表现是「点了没反应」，而且没有任何报错。放宽的桩会把这种缺陷
// 一起放过去，严格的桩则让它变成一个失败的断言。
const pageHtml = readFileSync(join(here, "..", "..", "docs", "index.html"), "utf8");
const declaredIds = new Set(
  [...pageHtml.matchAll(/id="([^"]+)"/g)].map((match) => match[1]),
);
const undeclaredIds = [];

const elements = new Map();

function makeElement(id) {
  return {
    id,
    innerHTML: "",
    value: "",
    style: { display: "" },
    listeners: {},
    addEventListener(type, fn) {
      (this.listeners[type] ||= []).push(fn);
    },
  };
}

function element(id) {
  if (!elements.has(id)) {
    elements.set(id, makeElement(id));
  }
  return elements.get(id);
}

// 页面会读写地址栏的 hash（让视图可分享、可自动化截图），桩里也要有这两个全局。
globalThis.location = { hash: "", pathname: "/", search: "" };
globalThis.history = {
  replaceState(_state, _title, url) {
    globalThis.location.hash = typeof url === "string" && url.startsWith("#") ? url : "";
  },
};

globalThis.document = {
  body: makeElement("body"),
  getElementById: (id) => {
    if (id === "body") {
      return globalThis.document.body;
    }
    if (!declaredIds.has(id)) {
      if (!undeclaredIds.includes(id)) {
        undeclaredIds.push(id);
      }
      return undefined;
    }
    return element(id);
  },
};

// 页面外壳本身也要守：产物是普通 script 而非 ES 模块，正是这一点让页面能双击打开。
//
// 断言写成「script 标签上不能有 type="module"」而不是「页面里不能出现这个字符串」：
// index.html 的注释里就提到了它（解释为什么不用），全文匹配会被自己的注释绊倒。
assert.match(pageHtml, /<script src="\.\/main\.js" defer><\/script>/, "页面应引用 ./main.js");
assert.ok(
  !/<script[^>]*type="module"/.test(pageHtml),
  '不要用 type="module"：普通 script 在 file:// 下也能加载，页面才不必依赖 HTTP 服务',
);

// main.js 刻意没有 export（架构是「MoonBit 作入口，JS 不能反向调库」），
// 因此 import 它本身就等于运行 main()。
//
// 必须用 file:// URL：Windows 上的绝对路径（`d:\…`）不是合法的 ESM 说明符，
// 直接 import 会报 ERR_UNSUPPORTED_ESM_URL_SCHEME。
await import(pathToFileURL(bundle).href);

const app = () => element("app").innerHTML;

/// 模拟一次点击：事件委托会在 body 上找到带 data-action 的那个元素。
function click(action, arg = "") {
  const target = {
    getAttribute: (name) => (name === "data-action" ? action : arg),
  };
  const event = { target: { closest: () => target } };
  const listeners = globalThis.document.body.listeners.click || [];
  assert.ok(listeners.length > 0, "body 上应当注册了点击委托");
  for (const listener of listeners) {
    listener(event);
  }
}

// ── 3. 首屏：自带样例已载入，概览显示了三种形态 ───────────────────────────
assert.match(app(), /自带样例/, "首屏应已载入自带样例");
assert.match(app(), /概览/, "应渲染出标签页");
assert.match(app(), /gpt-4o/, "概览应列出记录");
assert.match(app(), /429/, "概览应显示被限流的那条记录的状态码");
assert.match(app(), /流式 · 3 帧/, "概览应标出流式记录的帧数");

// ── 4. 未命中诊断：默认输入刻意与录制不一致，应当指出差异路径 ─────────────
click("view", "diagnose");
assert.match(app(), /未命中诊断/);
// 诊断只报告**路径**、不回显字段值（诊断信息会被贴进日志，而请求未必脱敏），
// 因此这里断言的是路径本身。
assert.match(app(), /\$\.model/, "应指出顶层 model 不同");
assert.match(app(), /differs:/, "应给出差异路径列表");
assert.ok(
  element("diagnose-controls").style.display !== "none",
  "诊断视图里应显示请求输入框",
);

// 换策略：改成只比较请求体之后，模型名这一层差异被忽略，结论应当改变。
const beforeSwitch = app();
click("toggle-body-only");
assert.notEqual(app(), beforeSwitch, "换策略后结论应当改变");

// ── 5. 漂移对比：两份样例只差一处响应 ────────────────────────────────────
click("load-drifted");
assert.match(app(), /漂移对比/);
assert.match(app(), /Changed/, "应报告「请求没变、响应变了」这一类");

// ── 6. 脱敏预览：抹掉的密钥绝不能出现在渲染结果里 ────────────────────────
click("load-leaky");
assert.match(app(), /脱敏预览/);
assert.match(app(), /已抹除/, "应显示抹除的字符数");
assert.match(app(), /REDACTED/, "应当显示脱敏标记");
// 默认**不**渲染脱敏前的原文：那份原文可能含真实密钥，而屏幕会被截图、被投屏。
assert.ok(
  !app().includes("sk-abcdefgh12345678"),
  "默认渲染结果里绝不能出现原始密钥",
);
assert.ok(!app().includes("ya29.a0AfH6SMBsecretvalue"), "默认结果里绝不能出现原始令牌");

// 点开之后才显示原文，此时应当能看到密钥本体 —— 这正是「脱敏前」的含义。
click("toggle-reveal-raw");
assert.match(app(), /已显示脱敏前的原文/, "应当提示原文已显示");
assert.ok(
  app().includes("sk-abcdefgh12345678"),
  "点开后才应当显示原始密钥",
);

// ── 7. 单条详情：从概览点进某一条 ────────────────────────────────────────
click("load-sample");
click("open", "1");
assert.match(app(), /单条详情/);
assert.match(app(), /流式帧（3）/, "流式记录应显示帧数与序列");
// 帧里显示的是**载荷**，不是 SSE 线上的 `data:` 前缀 —— 前缀属于传输层，
// 录进 cassette 的只是每一帧的内容。
assert.match(app(), /\[0\]/, "帧应当带序号");
assert.match(app(), /\[DONE\]/, "应当显示最后一帧");

// ── 8. 转义：渲染的是外部文件的内容，注入必须被挡住 ──────────────────────
//
// 直接调解析入口而不是伪造 FileReader：这里要验的是「恶意内容进不了 DOM」，
// 而不是文件选择这条路。
{
  const evil = JSON.stringify({
    format: "mooncassette",
    version: 1,
    meta: { name: "<script>alert(1)</script>", generator: "test" },
    interactions: [],
  });
  const input = element("file-input");
  const listeners = input.listeners.change || [];
  assert.ok(listeners.length > 0, "文件输入框上应当注册了监听");
  // 用一个极小的桩替换 FileReader 与 files。
  globalThis.FileReader = class {
    readAsText() {
      this.result = evil;
      this.onload();
    }
  };
  input.files = [{ name: "evil.cassette.json" }];
  for (const listener of listeners) {
    listener();
  }
  assert.ok(
    !app().includes("载入「evil.cassette.json」失败"),
    "这份 cassette 本身应当是合法的，失败会让转义测试失去意义",
  );
  // 名称显示在概览里，因此先切回去再断言。
  click("view", "overview");
  assert.match(app(), /evil\.cassette\.json/, "应当载入成功");
  assert.ok(
    !app().includes("<script>alert(1)</script>"),
    "原始脚本标签不能出现在渲染结果里",
  );
  assert.match(app(), /&lt;script&gt;/, "应当以转义形式显示");
}

// ── 9. 渲染过程中引用过的每个 id，都必须真实存在于 index.html ─────────────
assert.deepEqual(
  undeclaredIds,
  [],
  `渲染引用了 index.html 里不存在的 id：${undeclaredIds.join(", ")}`,
);

console.log("demo smoke test: ok");
