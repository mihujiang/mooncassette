// mooncassette/matcher —— 匹配策略契约测试。

///|
fn interaction(
  model : String,
  body : Json,
  marker : String,
) -> @core.Interaction {
  @core.Interaction::new(
    @core.Request::new("openai", model, body),
    @core.Response::ok(Json::string(marker)),
  )
}

///|
fn marker_of(result : @matcher.MatchResult) -> String {
  match result.interaction.response.body {
    String(text) => text
    _ => "<not a string>"
  }
}

///|
test "Exact matches and reports the index" {
  let items = [
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "first"),
    interaction("gpt-4o", @json.parse("{\"a\":2}"), "second"),
  ]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":2}"))
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  ) catch {
    _ => panic()
  }
  match result {
    Some(found) => {
      assert_eq(found.index, 1)
      assert_eq(marker_of(found), "second")
    }
    None => fail("expected a match")
  }
}

///|
test "Exact returns None when nothing matches" {
  let items = [interaction("gpt-4o", @json.parse("{\"a\":1}"), "only")]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":9}"))
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  ) catch {
    _ => panic()
  }
  assert_true(result is None)
}

///|
test "Exact returns None for an empty cassette" {
  let request = @core.Request::new("openai", "gpt-4o", Json::null())
  let result = @matcher.find_match(
    request,
    ([] : Array[@core.Interaction])[:],
    @matcher.MatchPolicy::Exact,
    0,
  ) catch {
    _ => panic()
  }
  assert_true(result is None)
}

///|
test "cursor advances so repeated identical calls replay in recording order" {
  let items = [
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "one"),
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "two"),
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "three"),
  ]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1}"))
  let first = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    0,
  ) catch {
    _ => panic()
  }
  let second = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    1,
  ) catch {
    _ => panic()
  }
  let third = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    2,
  ) catch {
    _ => panic()
  }
  assert_eq(marker_of(first.unwrap()), "one")
  assert_eq(marker_of(second.unwrap()), "two")
  assert_eq(marker_of(third.unwrap()), "three")
}

///|
test "search wraps around to reuse earlier recordings" {
  let items = [
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "only"),
    interaction("gpt-4o", @json.parse("{\"a\":2}"), "other"),
  ]
  let request = @core.Request::new("openai", "gpt-4o", @json.parse("{\"a\":1}"))
  // 游标已越过唯一匹配项，应回卷到下标 0。
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Exact,
    2,
  ) catch {
    _ => panic()
  }
  assert_eq(marker_of(result.unwrap()), "only")
}

///|
test "FingerprintOnly ignores body differences caused by key order" {
  let items = [interaction("gpt-4o", @json.parse("{\"b\":2,\"a\":1}"), "hit")]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":1,\"b\":2}"),
  )
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::FingerprintOnly,
    0,
  ) catch {
    _ => panic()
  }
  assert_eq(marker_of(result.unwrap()), "hit")
}

///|
test "Subset matches on the projected fields only" {
  let items = [
    @core.Interaction::new(
      @core.Request::new(
        "openai",
        "gpt-4o",
        @json.parse("{\"prompt\":\"hi\",\"temperature\":0.2}"),
      ),
      @core.Response::ok(Json::string("subset-hit")),
    ),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"prompt\":\"hi\",\"temperature\":0.9}"),
  )
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Subset(["prompt"]),
    0,
  ) catch {
    _ => panic()
  }
  assert_eq(marker_of(result.unwrap()), "subset-hit")
}

///|
test "Subset still rejects differences inside the projected fields" {
  let items = [interaction("gpt-4o", @json.parse("{\"prompt\":\"hi\"}"), "hit")]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"prompt\":\"bye\"}"),
  )
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Subset(["prompt"]),
    0,
  ) catch {
    _ => panic()
  }
  assert_true(result is None)
}

///|
test "Sequential consumes recordings in order regardless of content" {
  let items = [
    interaction("gpt-4o", @json.parse("{\"a\":1}"), "first"),
    interaction("gpt-4o", @json.parse("{\"a\":2}"), "second"),
  ]
  let request = @core.Request::new(
    "openai",
    "gpt-4o",
    @json.parse("{\"a\":99}"),
  )
  let first = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Sequential,
    0,
  ) catch {
    _ => panic()
  }
  let second = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Sequential,
    1,
  ) catch {
    _ => panic()
  }
  assert_eq(marker_of(first.unwrap()), "first")
  assert_eq(marker_of(second.unwrap()), "second")
}

///|
test "Sequential returns None once recordings are exhausted" {
  let items = [interaction("gpt-4o", @json.parse("{\"a\":1}"), "only")]
  let request = @core.Request::new("openai", "gpt-4o", Json::null())
  let result = @matcher.find_match(
    request,
    items[:],
    @matcher.MatchPolicy::Sequential,
    1,
  ) catch {
    _ => panic()
  }
  assert_true(result is None)
}
