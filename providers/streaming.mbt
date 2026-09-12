// mooncassette/providers —— 流式响应的共享工具。
//
// 把一段 SSE 文本变成统一响应分两步：
//   1. `@stream.parse` 把线格式切成帧（与厂商无关）；
//   2. 按各家的增量语义把帧聚合成**与非流式同形**的响应体。
//
// 第 2 步是各厂商自己的事（见 `openai_stream.mbt` / `anthropic_stream.mbt`），
// 本文件只放两边都用得上的小工具。

///|
/// 把一帧的 `data` 解析为 JSON；没有可聚合内容时返回 `None`。
///
/// 三种情况返回 `None`：OpenAI 的 `data: [DONE]` 结束哨兵、空数据帧
/// （规范允许），以及无法解析为 JSON 的行。
///
/// 解析失败刻意不抛错：流里混进一行非 JSON（网关心跳、纯文本提示）不应让
/// 整次录制失败——原始帧已完整保留，排查时看得到。
pub fn frame_payload(frame : @core.StreamFrame) -> Json? {
  let text = frame.data
  if text == "" || text == "[DONE]" {
    return None
  }
  let parsed = @json.parse(text) catch { _ => return None }
  match parsed {
    Object(_) | Array(_) => Some(parsed)
    _ => None
  }
}

///|
/// 取字符串字段；缺失或类型不符时返回 `None`。
pub fn string_field(fields : Map[String, Json], key : String) -> String? {
  match fields.get(key) {
    Some(String(text)) => Some(text)
    _ => None
  }
}

///|
/// 取整数字段，缺失时用 `fallback`。
///
/// 增量协议里的 `index` 之类的字段若缺失，按 0 处理比让整次解码失败更有用：
/// 单路流本来就只有一个 choice。
pub fn int_field_or(
  fields : Map[String, Json],
  key : String,
  fallback : Int,
) -> Int {
  match int_field(fields, key) {
    Some(value) => value
    None => fallback
  }
}

///|
/// 构造一个「看起来像整数」的 JSON 数字，避免输出 `200.0` 这类噪声。
pub fn json_int(value : Int) -> Json {
  Json::number(value.to_double(), repr=value.to_string())
}

///|
/// 解析分片累积出来的 JSON。
///
/// 空串（服务端一个增量片都没发）按 Anthropic 的约定视为空对象；
/// 解析失败时把文本原样包成 JSON 字符串——宁可把畸形的中间结果暴露出来，
/// 也不要静默丢掉，否则「工具参数怎么会是空的」这类问题无从查起。
pub fn parse_partial_json(text : String) -> Json {
  if text == "" {
    return Json::object(Map([]))
  }
  @json.parse(text) catch {
    _ => Json::string(text)
  }
}
