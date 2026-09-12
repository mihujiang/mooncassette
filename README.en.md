# mooncassette

[中文](https://github.com/mihujiang/mooncassette/blob/main/README.mbt.md) · **English**

[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-weopqrst%2Fmooncassette-blue)](https://mooncakes.io/docs/weopqrst/mooncassette)
[![license](https://img.shields.io/badge/license-Apache--2.0-green)](https://github.com/mihujiang/mooncassette/blob/main/LICENSE)

**Deterministic record-and-replay for LLM interactions — make model calls offline, reproducible and regression-testable.**

`mooncassette` records one real LLM interaction into a readable, diffable cassette file.
Afterwards — in CI, on a colleague's machine, or on a plane without network — tests replay
**byte-identical** results.

---

## Why

Testing an application that calls an LLM leaves three options, and all three are bad:

| Approach | Problem |
|---|---|
| Call the real API | Slow, expensive, flaky; CI needs a secret; the same input gives a different answer twice |
| Hand-written mocks | Every prompt edit needs a matching mock edit; mocks drift away from real responses |
| Don't test | Changing a prompt means verifying by hand; regressions are invisible |

`mooncassette` adds a fourth: **record real traffic, replay deterministic results.**

```text
Development   real call ──▶ record ──▶ demo.cassette.json ──▶ commit to version control
Test / CI     no network ─▶ replay ──▶ byte-identical results, zero secrets
```

---

## Install

```bash
moon add weopqrst/mooncassette
```

Then reference the packages you need from `moon.pkg`:

```text
import {
  "weopqrst/mooncassette",
  "weopqrst/mooncassette/core",
  "weopqrst/mooncassette/providers",
}
```

Published on [mooncakes.io](https://mooncakes.io/docs/weopqrst/mooncassette).

---

## 30-second quickstart

No network and no API key required:

```bash
moon run examples/offline_demo --target js     # record → save → replay → drift detection
moon run examples/openai_protocol --target js  # real provider payloads → record → offline replay
moon run cmd/main --target js -- verify examples/demo.cassette.json
moon run cmd/main --target js -- show   examples/demo.cassette.json
moon run cmd/main --target js -- diff   examples/demo.cassette.json examples/demo.drifted.cassette.json
moon test --target wasm-gc
```

---

## Core guarantees

These are properties the project promises and that the test suite guards:

1. **Playback never performs a real call.** A session in `Mode::Playback` does not hold a
   `Transport` at all, so "accidentally hitting production" is ruled out at the type level.
2. **Anything written to disk is sanitized; real calls keep their secrets.** One logical request
   is derived into two forms: the one sent to the provider keeps the key (otherwise authentication
   fails), the one stored in the cassette is sanitized. **Both sides go through the same
   derivation chain**, otherwise you get the classic "it records fine but never replays".
3. **Canonical text is deterministic.** Object keys are sorted by UTF-8 byte order, independent of
   map iteration order, so the same cassette produces the same bytes on any backend and any run.
4. **Fingerprints are stable across targets.** Rather than the standard library `Hasher`
   (whose implementation is backend-dependent), the project implements FNV-1a 64-bit itself and
   verifies it against the official test vectors.
5. **Equal fingerprints do not imply equal requests.** A fingerprint is only an index; the final
   decision is exact equality of canonical text. A real collision raises an explicit error instead
   of silently returning the wrong result.
6. **Hand edits to a cassette are always detected — including edits to responses.** Two digests
   with different coverage are stored and both are recomputed on decode (see "Two digests" below).
7. **`Interaction` is fully deterministic.** Non-deterministic fields such as timestamps may only
   appear in `CassetteMeta`, which rules out flaky tests by construction.

---

## Getting started

### 1. Define your Transport

`Transport` is the single extension point — plug your HTTP client in here. It deliberately contains
no recording, matching or sanitizing logic; the session engine owns all of that.

```moonbit
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

### 2. During development: record automatically

`Auto` mode means "replay on hit, record on miss". The first run makes a real call and writes the
cassette; every later run is fully offline.

```moonbit
let session = @mooncassette.auto_session(
  @core.Cassette::new("chat-demo"),
  MyHttpTransport::new(client),
)
let _ = session.send(request)
// Write the result to tests/cassettes/chat-demo.cassette.json and commit it.
@fs.write_string_to_file(path, @mooncassette.save(session))
```

### 3. In tests: replay only

```moonbit
///|
test "chat returns the recorded answer" {
  let session = @mooncassette.replay_session(recorded_text)
  let response = session.send(request)
  assert_eq(response.body, Json::string("the recorded answer"))
}
```

This test needs no network, no secret, and never becomes flaky.

---

## Talking to real providers

Replay and drift detection are built on a unified request/response model, but the real world has one
wire format per vendor. The `providers` package performs that translation and **depends on no HTTP
client** — so it still compiles on every backend and can be tested offline against real payloads.

| Protocol | Path | Auth header | usage field names |
|---|---|---|---|
| `OpenAiChat` | `/chat/completions` | `Authorization: Bearer …` | `prompt_tokens` / `completion_tokens` |
| `AnthropicMessages` | `/messages` | `x-api-key` + `anthropic-version` | `input_tokens` / `output_tokens` |

`OpenAiChat`'s `base_url` can point at DeepSeek, Moonshot, vLLM, Ollama and other compatible
endpoints, so a single adapter covers a wide range.

It takes care of the parts that are easy to get wrong:

- different paths and auth headers per vendor;
- different usage field names (OpenAI uses `prompt_tokens`, Anthropic uses `input_tokens`);
- **error responses must be recordable too** — otherwise "what happens when we get rate limited?"
  cannot be a regression test;
- an HTML error page from a gateway is not silently dropped; it is wrapped as `{"raw_body": "…"}`;
- if the payload explicitly carries `model`, it must match `Request.model`, otherwise the call fails
  loudly (such silent mismatches corrupt both fingerprints and billing, and are painful to debug).

### The only thing you implement is "send it"

```moonbit
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

`api_key` only ever goes into an HTTP header and is **never** written to a cassette — what gets
recorded is the unified request/response, not a network capture.

### A note on async HTTP clients

Clients such as `mizchi/x/http` are **async** (`async fn post`), while `HttpSender` is synchronous.
MoonBit has no entry point for starting an async task from a synchronous context
(`moonbitlang/async` offers `spawn` but no `block_on`-style bridge), so **an async client cannot
implement `HttpSender` directly**.

Two workable paths:

- **Synchronous client** → use `FunctionSender` above, a few lines.
- **Async client** → do it in three steps inside an async context:
  `protocol.encode(request)` (synchronous) → send asynchronously → `protocol.decode(response)`
  (synchronous). Protocol encoding and decoding have nothing to do with sync vs. async, so both
  steps can be reused from any context.

---

## Concepts

### cassette

A cassette is a list of interactions in recording order — a single JSON file. It is human readable
and can be reviewed as a diff in code review, which is exactly why canonical key ordering matters.

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
        "body": { "messages": [{ "content": "hello", "role": "user" }] },
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

### Two digests, two responsibilities

Neither can replace the other:

| Field | Coverage | Purpose |
|---|---|---|
| `fingerprint` | **request only** | replay **matching** (a response does not exist yet during replay); also helps explain "why didn't this match?" |
| `integrity` | **the whole record, response included** | **tamper detection**. The response is the easiest thing to edit by hand |

`fingerprint` alone is not enough: validating only the request would let "just edit the expected
output in the cassette so the failing test passes" slip through unnoticed, and the test would lose
its meaning. `integrity` exists to close that hole.

### Request normalization

Before a fingerprint is computed, volatile fields (`request_id`, `timestamp`, `nonce`, …) are
dropped — otherwise the fingerprint differs on every call and replay could never hit. The default
list lives in `@core.default_drop_keys` and can be customized.

### Matching strategies

| Strategy | Semantics | When to use |
|---|---|---|
| `Exact` | Same fingerprint **and** identical canonical text | Default, recommended |
| `FingerprintOnly` | Compare fingerprints only, skip the text comparison | Only with a measured performance need |
| `Subset(keys)` | Compare only the given top-level body fields | "Same prompt means same call" |
| `Sequential` | Ignore content, consume in recording order | Call order is itself the semantics |

Lookup uses **ring scanning**: search forward from the current cursor, then wrap around to the
beginning. That handles both "the same request was recorded several times, replay them in order"
and "more calls than recordings, reuse the earliest one" instead of failing outright. Note that
`Sequential` deliberately does **not** wrap: running past the end means the recording is exhausted
and must be reported, otherwise insufficient coverage gets silently hidden.

### Sanitization

Cassettes get committed to git, pasted into issues and used in demos, so **sanitizing is the
default**:

- exact key-name matching (`authorization`, `x-api-key`, `cookie`, …);
- suffix matching (`_key`, `_token`, `_secret`, …) — deliberately a suffix rather than a substring,
  so counting fields such as `max_tokens` / `total_tokens` are not caught by accident;
- scanning string values for secret-shaped substrings (`sk-` followed by 8+ characters).

### Drift detection

Replay answers "did the things that must not change, change?". Drift detection answers "did the
things that were supposed to change, change?".

You edit a prompt or bump a model version and record a fresh cassette. Reading the JSON diff
directly tells you nothing (fingerprints changed, key order moved). `mooncassette diff` answers the
three questions you actually care about:

| Kind | Meaning |
|---|---|
| `Removed` | Present in the old recording only — the call was deleted, or its request changed |
| `Added` | Present in the new recording only — a new call, or a request changed |
| `Changed` | **Identical request, different response** — this is genuine model behaviour drift |

The third kind matters most: **you did not touch a single line of code, yet the model's output
changed.**

Two deliberate design decisions:

- **A changed request is reported as one `Removed` plus one `Added`, never as one `Changed`.**
  There is no way to tell which old entry a modified request "corresponds" to; reporting honestly
  beats guessing.
- **Requests are re-normalized before comparison.** Normally recorded requests are already in
  normalized form (re-normalizing is idempotent), but for hand-built cassettes or ones edited by
  external tools this avoids mistaking leftover volatile fields for drift. The bias is towards
  under-reporting.

`diff` exits with code 1 when drift is found, so it can be used directly as a CI step.

```text
$ mooncassette diff examples/demo.cassette.json examples/demo.drifted.cassette.json
[changed] gpt-4o #0 -> #0  b862439f
drift detected: removed=0 changed=1 added=0 unchanged=1
```

---

## CLI

```bash
mooncassette verify <cassette.json>              # decode + integrity check; non-zero exit on failure
mooncassette show   <cassette.json>              # print a summary (version, records, tokens, models)
mooncassette diff   <old.json> <new.json>        # report drift between two recordings; exit 1 if any
mooncassette help
```

`verify` checks both digests, so it can be a CI step on its own: any hand-edited cassette is
rejected there, pinpointed to `$.interactions[i].integrity`.

Argument parsing deliberately **does not rely on position** (different backends give different
semantics to `@env.args()`); it scans for known subcommand keywords instead, so native and js
behave identically.

---

## Design trade-offs

Listed honestly to prevent misuse:

| Trade-off | Reason | Consequence |
|---|---|---|
| Canonical text does not distinguish `1` from `1.0` | JSON has a single number type; the parser normalizes to `1` | Encode integer/float distinctions in your own layer if you need them |
| Non-finite numbers (NaN/Inf) are written as `null` | JSON cannot represent them | Never emits illegal JSON, but the value is lost |
| Fingerprints use a non-cryptographic hash | Used only as an index; equality of canonical text is the real test | No security impact |
| `integrity` uses a non-cryptographic hash | It detects **accidental edits**, not **forgery** | Pair with signing or access control if you need that |
| Sanitizing keys off **key names** only | A secret embedded in a value cannot be reliably identified | Partly mitigated by the `sk-` shape scan; review sensitive cassettes by hand |
| No timing recorded | Timing is non-deterministic and would break reproducibility if it entered `Interaction` | Measure latencies in your own layer if you need assertions on them |
| The library has no `fs`/`http` dependency | Keeps it pure and compilable on every backend | File and network IO are supplied by the caller |

---

## Tests and verification

```bash
moon test --target wasm-gc   # default target
moon test --target js        # cross-check
moon check --target js
moon fmt && moon info
```

**All 136 tests pass**, covering ten packages, each run on both `wasm-gc` and `js`. The point is not
the line count but that **every invariant above has a matching assertion**:

- FNV-1a is verified against the official vectors (empty string / `"a"` / `"foobar"`);
- key order, escaping and idempotence of canonical text;
- ring-scan advance and wrap-around boundaries (white-box tests of the private arithmetic);
- tampering with the **request body**, **response body**, **status code** and **token usage** must
  all be detected;
- sanitizing must not damage `max_tokens` / `total_tokens`;
- a real call's request **must keep its secret** (asserted with a recording Transport);
- a request carrying a secret must hit immediately when recorded and then replayed (regression);
- in playback mode the number of `Transport` calls must be 0;
- drift detection: key order and volatile fields are **not** drift, a changed response **is**;
- drift detection: duplicates of the same request are paired up in order, and the report order is
  fixed as Removed → Changed → Added;
- protocol decoding is exercised with **real-API-shaped payloads** (429 error bodies, HTML gateway
  error pages, non-integer token counts).

---

## Package layout

| Package | Responsibility | IO dependency |
|---|---|---|
| `canon` | Canonical JSON text + stable hashing | No |
| `core` | Data model, canonical JSON view, errors, request normalization | No |
| `fingerprint` | Request fingerprint, integrity digest, equivalence predicate | No |
| `matcher` | Four matching strategies and ring lookup | No |
| `sanitize` | Sanitizing policy and recursive sanitizing | No |
| `codec` | Cassette encoding/decoding and integrity verification | No |
| `drift` | Drift detection between two recordings | No |
| `providers` | OpenAI / Anthropic protocol codecs, HTTP executor abstraction | No |
| `recorder` | `Transport` abstraction, session engine, `MockTransport` | No |
| `mooncassette` | Facade: the shortest path to getting started | No |

**Every package is pure computation** and compiles on the `wasm` / `wasm-gc` / `js` / `native`
backends. Real network and file system access is supplied by the caller through `Transport` and
their own IO (the examples and CLI in this repository use `moonbitlang/x`, which is an outer shell).

---

## Released

| Version | Contents |
|---|---|
| `0.1.0` | Data model and canonical JSON text, cross-target stable fingerprints, four matching strategies, sanitizing, cassette codec with dual-digest integrity checking, session engine, `verify`/`show` CLI, offline examples |
| `0.2.0` | Drift detection (`drift` package plus `mooncassette diff`); examples demonstrating the full loop from "model version changed" to a readable drift report |

---

## License

Apache-2.0
