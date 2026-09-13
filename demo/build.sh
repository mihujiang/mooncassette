#!/usr/bin/env bash
#
# 把 Demo 构建到 docs/，供 GitHub Pages 直接托管。
#
# 用法：bash demo/build.sh
#
# 产物路径写死而不用通配符：一旦路径猜错，Pages 上会静默地继续服务旧版本，
# 而那种错误从页面上完全看不出来 —— 页面还能打开，只是内容停在上一次构建。
#
# 顺序也是刻意的：**先跑测试，再产出**。测试失败就不覆盖 docs/，
# 这样「线上那份」永远不会是一个没通过验证的构建。

set -euo pipefail
cd "$(dirname "$0")"

echo "== 更新注册表索引与依赖 =="
moon update

echo "== 编译（js，release）="
moon build --target js --release

echo "== 纯逻辑测试 =="
moon test --target js

echo "== 端到端冒烟测试（Node + 桩 DOM）=="
node test/smoke.mjs

echo "== 产出到 docs/ =="
#
# 只删自己产出的那几个文件，**不要** `rm -rf ../docs`。
#
# `docs/` 里还住着 `screenshots/`（README 的配图，是人工产出、不是构建产物）。
# 整目录删掉会把它一起清空 —— 而那种后果不会在构建时报错，要等到 README 上的图
# 变成裂图才被发现。
mkdir -p ../docs
rm -f ../docs/main.js ../docs/index.html ../docs/.built-from
cp _build/js/release/build/main/main.js ../docs/main.js
cp index.html ../docs/index.html
# .nojekyll：GitHub Pages 默认会过滤掉下划线开头的路径，本页面没有这类文件，
# 但保留它可以让 Pages 完全按静态目录处理，不再做任何 Jekyll 加工。
touch ../docs/.nojekyll

# 记下这份产物是从哪一版源码构建的。
#
# 记源码摘要而不是产物摘要：本机工具链与 CI 工具链版本不同，编译出的 JS 逐字节
# 不可比 —— 用产物摘要做检查，比的是编译器版本，不是源码。CI 也据此判断
# 「docs/ 是不是过期的」。
node source-digest.mjs > ../docs/.built-from

echo "完成：docs/index.html + docs/main.js + docs/.built-from"
