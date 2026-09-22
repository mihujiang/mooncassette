name = "weopqrst/mooncassette-llm"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/mihujiang/mooncassette.git"

license = "Apache-2.0"

keywords = [
  "llm",
  "mizchi",
  "adapter",
  "record-replay",
  "cassette",
  "token-usage",
]

preferred_target = "js"

description = "mizchi/llm adapter for mooncassette: drive mizchi/llm conversations from recorded cassettes, and replace its estimated token counts with the exact usage the provider reported."

import {
  "mizchi/llm@0.3.2",
  "weopqrst/mooncassette@0.7.0",
}
