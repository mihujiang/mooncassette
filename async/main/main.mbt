// mooncassette 异步适配层 —— 骨架。
//
// 先只留一个可运行的占位：这一步的目的是把**依赖解析**打通。`moonbitlang/async`
// 的版本、以及它在 js / wasm-gc 上的可用性，是整个模块最大的未知数，
// 早点让它在编译期暴露，比写完一堆代码再发现要便宜得多。

///|
fn main {
  println("mooncassette async adapter: skeleton")
}
