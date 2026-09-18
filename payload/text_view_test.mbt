// mooncassette/payload —— 「这份字节到底是不是文本」的判定。
//
// 判据是**往返**而不是「能不能解码」：有损解码永远能返回一个字符串，
// 但它会把非法字节换成 U+FFFD，那样得到的文本再编码回去已经是另一串字节。
// 一旦用错判据，二进制响应就会被当成文本存进 cassette，
// 「录下来的响应」与「真发出去的响应」不再逐字节相等。

///|
test "is_text accepts exactly what round-trips losslessly" {
  assert_true(
    @payload.is_text(@utf8.encode("你好，世界")),
    msg="合法 UTF-8 文本应当被接受",
  )
  assert_true(
    @payload.is_text(Bytes::new(0)),
    msg="空字节是合法的空文本",
  )
  // 控制字节（制表 / 换行 / 回车）仍是文本：它们编码回去逐字节相等。
  assert_true(
    @payload.is_text(Bytes::from_array([9, 10, 13])),
    msg="控制字节也是文本",
  )
}

///|
test "is_text rejects bytes that would be mangled by a text carrier" {
  // 单独的 0xFF 在 UTF-8 里非法。
  assert_false(
    @payload.is_text(Bytes::from_array([255])),
    msg="非法 UTF-8 字节不能被当作文本",
  )
  // PNG 魔数：前八个字节合法，但后面是任意二进制。
  assert_false(
    @payload.is_text(
      Bytes::from_array([137, 80, 78, 71, 13, 10, 26, 10, 255, 0, 1]),
    ),
    msg="二进制响应体不能被当作文本",
  )
  // 截断的 UTF-8 序列（多字节字符只剩开头）同样非法。
  assert_false(
    @payload.is_text(Bytes::from_array([228, 189])),
    msg="截断的 UTF-8 序列不能被当作文本",
  )
}

///|
test "text_view shows text as-is and falls back to canonical base64" {
  assert_eq(@payload.text_view(@utf8.encode("hi")), "hi")
  assert_eq(@payload.text_view(@utf8.encode("你好")), "你好")
  // `0xFF 0xFE` 不是文本，退回规范 base64 —— 至少还能被读出来。
  assert_eq(@payload.text_view(Bytes::from_array([255, 254])), "//4=")
  assert_true(
    @payload.is_canonical(@payload.text_view(Bytes::from_array([255, 254]))),
  )
}
