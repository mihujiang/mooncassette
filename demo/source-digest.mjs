// 算出 Demo 源码的摘要。`build.sh` 用它写 `docs/.built-from`，CI 用它与当前源码比对。
//
// 为什么不是「比较构建产物的字节」：本机工具链与 CI 工具链的版本不同，同一份源码
// 编译出来的 JS **逐字节并不相同**。产物可比性是「同一台机器、同一个编译器」这一
// 前提下的性质，不是跨环境的。我一度把这条检查写成比字节，于是 CI 立刻变红 ——
// 红得毫无价值，因为它比的是编译器版本，不是源码。
//
// 而「docs/ 是不是从当前源码构建出来的」这个问题与工具链无关，用**源码摘要**回答
// 才是对的：源码没变、docs/ 没重建 → 摘要一致（正确）；源码变了、docs/ 没重建 →
// 摘要不一致（正是要抓的那种）。用 node 计算是为了在 Windows 与 Linux 上都能跑。

import { createHash } from "node:crypto";
import { readFileSync, readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));

const packageFiles = readdirSync(join(here, "main"))
  .filter((name) => name.endsWith(".mbt") || name === "moon.pkg")
  .sort()
  .map((name) => join("main", name));

// 顺序固定（已排序），且把文件名也喂进摘要：否则「两个文件内容互换」这类改动
// 会算出同一个摘要。
const files = ["moon.mod", "index.html", ...packageFiles];

const digest = createHash("sha256");
for (const file of files) {
  digest.update(file);
  digest.update("\0");
  digest.update(readFileSync(join(here, file)));
  digest.update("\0");
}

process.stdout.write(digest.digest("hex"));
