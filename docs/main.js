function _M0DTPB4Json4Null() {}
_M0DTPB4Json4Null.prototype.$tag = 0;
const _M0DTPB4Json4Null__ = new _M0DTPB4Json4Null();
function _M0DTPB4Json4True() {}
_M0DTPB4Json4True.prototype.$tag = 1;
const _M0DTPB4Json4True__ = new _M0DTPB4Json4True();
function _M0DTPB4Json5False() {}
_M0DTPB4Json5False.prototype.$tag = 2;
const _M0DTPB4Json5False__ = new _M0DTPB4Json5False();
function _M0DTPB4Json6Number(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPB4Json6Number.prototype.$tag = 3;
function _M0DTPB4Json6String(param0) {
  this._0 = param0;
}
_M0DTPB4Json6String.prototype.$tag = 4;
function _M0DTPB4Json5Array(param0) {
  this._0 = param0;
}
_M0DTPB4Json5Array.prototype.$tag = 5;
function _M0DTPB4Json6Object(param0) {
  this._0 = param0;
}
_M0DTPB4Json6Object.prototype.$tag = 6;
const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $i64_reinterpret_f64(a) {
  $reinterpret_view.setBigUint64(0, BigInt.asUintN(64, a), false);
  return $reinterpret_view.getFloat64(0, false);
}
function _M0TPC28internal7strconv9FloatInfo(param0, param1, param2) {
  this.mantissa_bits = param0;
  this.exponent_bits = param1;
  this.bias = param2;
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FPB12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
const _M0FPB22uint64__to__string__js = (num, radix) => num.toString(radix);
function _M0TPB4IterGcE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function _M0TPB4IterGsE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function _M0TPB9ArrayViewGkE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function $makebytes(a, b) {
  const arr = new Uint8Array(a);
  if (b !== 0) {
    arr.fill(b);
  }
  return arr;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function $unsafe_make_string(a, b) {
  return String.fromCodePoint(b).repeat(a);
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB4IterGRPC16string10StringViewE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function _M0TPB8MutLocalGORPC16string10StringViewE(param0) {
  this.val = param0;
}
function _M0TPB3MapGsRPB4JsonE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGsRPB5ArrayGiEE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGsiE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGsRPB4JsonE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGsRPB5ArrayGiEE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGsiE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0DTPC16option6OptionGRPB5ArrayGiEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGiEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGiEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGiEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGiEE4Some.prototype.$tag = 1;
function _M0TPB8MutLocalGORPB5EntryGsRPB4JsonEE(param0) {
  this.val = param0;
}
const _M0FPC28encoding4utf816encode__utf8__js = (() => {
   const encoder = new TextEncoder();
   return function(src, start, len, bom) {
     const end = start + len;
     const encoded = encoder.encode(src.slice(start, end));
     if (!bom) {
       return encoded;
     }
     const result = new Uint8Array(encoded.length + 3);
     result[0] = 0xEF;
     result[1] = 0xBB;
     result[2] = 0xBF;
     result.set(encoded, 3);
     return result;
   };
 })();
function _M0DTPC16result6ResultGuRPB7FailureE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPB7FailureE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPB7FailureE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPB7FailureE2Ok.prototype.$tag = 1;
function _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar.prototype.$tag = 14;
function _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof() {}
_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof.prototype.$tag = 13;
const _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__ = new _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof();
function _M0DTPC15error5Error54moonbitlang_2fcore_2fjson_2eParseError_2eInvalidNumber(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC15error5Error54moonbitlang_2fcore_2fjson_2eParseError_2eInvalidNumber.prototype.$tag = 12;
function _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eInvalidIdentEscape(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eInvalidIdentEscape.prototype.$tag = 11;
function _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded() {}
_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded.prototype.$tag = 10;
const _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__ = new _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded();
function _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure.prototype.$tag = 9;
function _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed.prototype.$tag = 8;
function _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation.prototype.$tag = 7;
function _M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eUnsupportedVersion(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eUnsupportedVersion.prototype.$tag = 6;
function _M0DTPC15error5Error69weopqrst_2fmooncassette_2fcore_2eCassetteError_2eFingerprintCollision(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error69weopqrst_2fmooncassette_2fcore_2eCassetteError_2eFingerprintCollision.prototype.$tag = 5;
function _M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eIntegrityViolation(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eIntegrityViolation.prototype.$tag = 4;
function _M0DTPC15error5Error56weopqrst_2fmooncassette_2fcore_2eCassetteError_2eNoMatch(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error56weopqrst_2fmooncassette_2fcore_2eCassetteError_2eNoMatch.prototype.$tag = 3;
function _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eExhausted(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eExhausted.prototype.$tag = 2;
function _M0DTPC15error5Error65weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMissingTransport(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error65weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMissingTransport.prototype.$tag = 1;
function _M0DTPC15error5Error65weopqrst_2fmooncassette_2fcore_2eCassetteError_2eTransportFailure(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error65weopqrst_2fmooncassette_2fcore_2eCassetteError_2eTransportFailure.prototype.$tag = 0;
function _M0DTPC16result6ResultGdRPB7FailureE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPB7FailureE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGdRPB7FailureE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPB7FailureE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPB7FailureE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC28internal7strconv6NumberRPB7FailureE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPB7FailureE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC28internal7strconv6NumberRPB7FailureE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPC16string10StringViewRPB7FailureE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC16string10StringViewRPB7FailureE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC16string10StringViewRPB7FailureE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC16string10StringViewRPB7FailureE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0TPC28internal7strconv6Number(param0, param1, param2, param3) {
  this.exponent = param0;
  this.mantissa = param1;
  this.negative = param2;
  this.many_digits = param3;
}
function _M0DTPC16result6ResultGdRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPC15error5ErrorE2Ok.prototype.$tag = 1;
function $i64_clz(a) {
  a = BigInt.asUintN(64, a);
  if (a === 0n) return 64;
  const hi = Number(a >> 32n);
  if (hi !== 0) {
    return Math.clz32(hi);
  }
  return 32 + Math.clz32(Number(a & 0xffffffffn));
}
function _M0TPC28internal7strconv7Decimal(param0, param1, param2, param3, param4) {
  this.digits = param0;
  this.digits_num = param1;
  this.decimal_point = param2;
  this.negative = param3;
  this.truncated = param4;
}
function _M0DTPC16result6ResultGRPC28internal7strconv7DecimalRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC28internal7strconv7DecimalRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC28internal7strconv7DecimalRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC28internal7strconv7DecimalRPC15error5ErrorE2Ok.prototype.$tag = 1;
function $f64_convert_i64_u(a) {
  return Number(a);
}
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
function _M0TPC14json8Position(param0, param1) {
  this.line = param0;
  this.column = param1;
}
function _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0TPC14json12ParseContext(param0, param1, param2) {
  this.offset = param0;
  this.input = param1;
  this.end_offset = param2;
}
function $f64_convert_i64(a) {
  return Number(BigInt.asIntN(64, a));
}
function _M0TPC14json11LexedNumber(param0, param1) {
  this.repr = param0;
  this.value = param1;
}
function _M0TPC14json14JsonNumberScan(param0, param1, param2, param3, param4) {
  this.negative = param0;
  this.is_integer = param1;
  this.mantissa = param2;
  this.exponent = param3;
  this.many_digits = param4;
}
function _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC14json5Token4Null() {}
_M0DTPC14json5Token4Null.prototype.$tag = 0;
const _M0DTPC14json5Token4Null__ = new _M0DTPC14json5Token4Null();
function _M0DTPC14json5Token4True() {}
_M0DTPC14json5Token4True.prototype.$tag = 1;
const _M0DTPC14json5Token4True__ = new _M0DTPC14json5Token4True();
function _M0DTPC14json5Token5False() {}
_M0DTPC14json5Token5False.prototype.$tag = 2;
const _M0DTPC14json5Token5False__ = new _M0DTPC14json5Token5False();
function _M0DTPC14json5Token6Number(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC14json5Token6Number.prototype.$tag = 3;
function _M0DTPC14json5Token6String(param0) {
  this._0 = param0;
}
_M0DTPC14json5Token6String.prototype.$tag = 4;
function _M0DTPC14json5Token6LBrace() {}
_M0DTPC14json5Token6LBrace.prototype.$tag = 5;
const _M0DTPC14json5Token6LBrace__ = new _M0DTPC14json5Token6LBrace();
function _M0DTPC14json5Token6RBrace() {}
_M0DTPC14json5Token6RBrace.prototype.$tag = 6;
const _M0DTPC14json5Token6RBrace__ = new _M0DTPC14json5Token6RBrace();
function _M0DTPC14json5Token8LBracket() {}
_M0DTPC14json5Token8LBracket.prototype.$tag = 7;
const _M0DTPC14json5Token8LBracket__ = new _M0DTPC14json5Token8LBracket();
function _M0DTPC14json5Token8RBracket() {}
_M0DTPC14json5Token8RBracket.prototype.$tag = 8;
const _M0DTPC14json5Token8RBracket__ = new _M0DTPC14json5Token8RBracket();
function _M0DTPC14json5Token5Comma() {}
_M0DTPC14json5Token5Comma.prototype.$tag = 9;
const _M0DTPC14json5Token5Comma__ = new _M0DTPC14json5Token5Comma();
function _M0TPB9ArrayViewGUsRPB4JsonEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP38weopqrst12mooncassette4core7Request(param0, param1, param2) {
  this.provider = param0;
  this.model = param1;
  this.body = param2;
}
function _M0TP38weopqrst12mooncassette4core5Usage(param0, param1) {
  this.input_tokens = param0;
  this.output_tokens = param1;
}
function _M0TP38weopqrst12mooncassette4core11StreamFrame(param0, param1) {
  this.event = param0;
  this.data = param1;
}
function _M0TP38weopqrst12mooncassette4core8Response(param0, param1, param2, param3) {
  this.status = param0;
  this.body = param1;
  this.usage = param2;
  this.stream = param3;
}
function _M0TP38weopqrst12mooncassette4core11Interaction(param0, param1) {
  this.request = param0;
  this.response = param1;
}
function _M0TP38weopqrst12mooncassette4core8Cassette(param0, param1, param2) {
  this.version = param0;
  this.meta = param1;
  this.interactions = param2;
}
function _M0TP38weopqrst12mooncassette4core12CassetteMeta(param0, param1, param2) {
  this.name = param0;
  this.generator = param1;
  this.recorded_at = param2;
}
function _M0TPB9ArrayViewGsE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameERP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameERP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameERP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core5UsageRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core5UsageRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core5UsageRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core5UsageRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4Some.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8ResponseRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8ResponseRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8ResponseRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8ResponseRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core11InteractionRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core11InteractionRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core11InteractionRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core11InteractionRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core12CassetteMetaRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core12CassetteMetaRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core12CassetteMetaRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core12CassetteMetaRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE2Ok.prototype.$tag = 1;
function _M0TPB9ArrayViewGUsRPB5ArrayGiEEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB9ArrayViewGUsiEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP38weopqrst12mooncassette5drift10DriftEntry(param0, param1, param2, param3, param4) {
  this.kind = param0;
  this.fingerprint = param1;
  this.model = param2;
  this.old_index = param3;
  this.new_index = param4;
}
function _M0TP38weopqrst12mooncassette5drift11DriftReport(param0, param1) {
  this.entries = param0;
  this.unchanged = param1;
}
function _M0TP38weopqrst12mooncassette7matcher9Candidate(param0, param1, param2, param3) {
  this.index = param0;
  this.provider = param1;
  this.model = param2;
  this.differing_paths = param3;
}
function _M0TP38weopqrst12mooncassette7matcher9Diagnosis(param0, param1, param2, param3) {
  this.policy = param0;
  this.cursor = param1;
  this.total = param2;
  this.candidates = param3;
}
function _M0TP38weopqrst12mooncassette8sanitize14SanitizePolicy(param0, param1, param2, param3) {
  this.exact_keys = param0;
  this.key_suffixes = param1;
  this.placeholder = param2;
  this.scan_secret_shapes = param3;
}
function _M0TP38weopqrst19mooncassette_2ddemo4main8AppState(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.primary_tape = param0;
  this.comparison_tape = param1;
  this.view = param2;
  this.detail = param3;
  this.body_only = param4;
  this.reveal_raw = param5;
  this.query = param6;
  this.status = param7;
}
function _M0TP38weopqrst19mooncassette_2ddemo4main6Loaded(param0, param1, param2) {
  this.label = param0;
  this.cassette = param1;
  this.size = param2;
}
function _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4None.prototype.$tag = 0;
function _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4Some.prototype.$tag = 1;
function _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy5Exact() {}
_M0DTP38weopqrst12mooncassette7matcher11MatchPolicy5Exact.prototype.$tag = 0;
const _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy5Exact__ = new _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy5Exact();
function _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy15FingerprintOnly() {}
_M0DTP38weopqrst12mooncassette7matcher11MatchPolicy15FingerprintOnly.prototype.$tag = 1;
function _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy6Subset(param0) {
  this._0 = param0;
}
_M0DTP38weopqrst12mooncassette7matcher11MatchPolicy6Subset.prototype.$tag = 2;
function _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy10Sequential() {}
_M0DTP38weopqrst12mooncassette7matcher11MatchPolicy10Sequential.prototype.$tag = 3;
function _M0TPB9ArrayViewGRP38weopqrst12mooncassette4core11InteractionE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP38weopqrst19mooncassette_2ddemo4main14set__html__ffi = function(element_id, html) {
   const element = document.getElementById(element_id);
   if (element) { element.innerHTML = html; }
 };
const _M0FP38weopqrst19mooncassette_2ddemo4main17set__visible__ffi = function(element_id, visible) {
   const element = document.getElementById(element_id);
   if (element) { element.style.display = visible ? "" : "none"; }
 };
const _M0FP38weopqrst19mooncassette_2ddemo4main25on__delegated__click__ffi = function(container_id, handler) {
   const root = container_id === "body"
     ? document.body
     : document.getElementById(container_id);
   if (!root) { return; }
   root.addEventListener("click", function (event) {
     const target = event.target && event.target.closest("[data-action]");
     if (!target) { return; }
     const action = target.getAttribute("data-action") || "";
     const arg = target.getAttribute("data-arg") || "";
     handler(action, arg);
   });
 };
const _M0FP38weopqrst19mooncassette_2ddemo4main23on__file__selected__ffi = function(input_id, handler) {
   const input = document.getElementById(input_id);
   if (!input) { return; }
   input.addEventListener("change", function () {
     const file = input.files && input.files[0];
     if (!file) { return; }
     const reader = new FileReader();
     reader.onload = function () {
       handler(file.name, String(reader.result));
       input.value = "";
     };
     reader.readAsText(file);
   });
 };
const _M0FP38weopqrst19mooncassette_2ddemo4main20on__text__input__ffi = function(element_id, handler) {
   const element = document.getElementById(element_id);
   if (!element) { return; }
   element.addEventListener("input", function () { handler(element.value); });
 };
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0MPC16string6String4trimN7_2abindS6432 = "\t\n\r ";
const _M0FPB4null = _M0DTPB4Json4Null__;
const _M0MPB4Iter4nextN6constrS9183GcE = 0;
const _M0MPB4Iter4nextN6constrS9184GcE = 0;
const _M0MPB4Iter4nextN6constrS9183GsE = 0;
const _M0MPB4Iter4nextN6constrS9184GsE = 0;
const _M0MPB4Iter3newN6constrS9191GcE = 0;
const _M0MPB4Iter3newN6constrS9191GsE = 0;
const _M0FPC16double14not__a__number = $i64_reinterpret_f64(9221120237041090561n);
const _M0FPC16double8infinity = $i64_reinterpret_f64(9218868437227405312n);
const _M0FPC16double13neg__infinity = $i64_reinterpret_f64(18442240474082181120n);
const _M0FPC28internal7strconv15range__err__str = "value out of range";
const _M0FPC28internal7strconv16syntax__err__str = "invalid syntax";
const _M0FPC28internal7strconv17min__19digit__int = 1000000000000000000n;
const _M0FPC28internal7strconv17parse__scientificN8exp__numS310 = 0n;
const _M0FPC28internal7strconv13parse__numberN11exp__numberS291 = 0n;
const _M0FPC28internal7strconv12double__info = new _M0TPC28internal7strconv9FloatInfo(52, 11, -1023);
const _M0FPC28internal7strconv25min__exponent__fast__path = 18446744073709551594n;
const _M0FPC28internal7strconv25max__exponent__fast__path = 22n;
const _M0FPC28internal7strconv36max__exponent__disguised__fast__path = 37n;
const _M0FPC28internal7strconv25max__mantissa__fast__path = 9007199254740992n;
const _M0FPC28internal7strconv6powtab = [1, 3, 6, 9, 13, 16, 19, 23, 26, 29, 33, 36, 39, 43, 46, 49, 53, 56, 59];
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS942 = { _0: 0, _1: "" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS943 = { _0: 1, _1: "5" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS944 = { _0: 1, _1: "25" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS945 = { _0: 1, _1: "125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS946 = { _0: 2, _1: "625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS947 = { _0: 2, _1: "3125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS948 = { _0: 2, _1: "15625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS949 = { _0: 3, _1: "78125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS950 = { _0: 3, _1: "390625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS951 = { _0: 3, _1: "1953125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS952 = { _0: 4, _1: "9765625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS953 = { _0: 4, _1: "48828125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS954 = { _0: 4, _1: "244140625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS955 = { _0: 4, _1: "1220703125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS956 = { _0: 5, _1: "6103515625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS957 = { _0: 5, _1: "30517578125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS958 = { _0: 5, _1: "152587890625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS959 = { _0: 6, _1: "762939453125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS960 = { _0: 6, _1: "3814697265625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS961 = { _0: 6, _1: "19073486328125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS962 = { _0: 7, _1: "95367431640625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS963 = { _0: 7, _1: "476837158203125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS964 = { _0: 7, _1: "2384185791015625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS965 = { _0: 7, _1: "11920928955078125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS966 = { _0: 8, _1: "59604644775390625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS967 = { _0: 8, _1: "298023223876953125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS968 = { _0: 8, _1: "1490116119384765625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS969 = { _0: 9, _1: "7450580596923828125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS970 = { _0: 9, _1: "37252902984619140625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS971 = { _0: 9, _1: "186264514923095703125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS972 = { _0: 10, _1: "931322574615478515625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS973 = { _0: 10, _1: "4656612873077392578125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS974 = { _0: 10, _1: "23283064365386962890625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS975 = { _0: 10, _1: "116415321826934814453125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS976 = { _0: 11, _1: "582076609134674072265625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS977 = { _0: 11, _1: "2910383045673370361328125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS978 = { _0: 11, _1: "14551915228366851806640625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS979 = { _0: 12, _1: "72759576141834259033203125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS980 = { _0: 12, _1: "363797880709171295166015625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS981 = { _0: 12, _1: "1818989403545856475830078125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS982 = { _0: 13, _1: "9094947017729282379150390625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS983 = { _0: 13, _1: "45474735088646411895751953125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS984 = { _0: 13, _1: "227373675443232059478759765625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS985 = { _0: 13, _1: "1136868377216160297393798828125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS986 = { _0: 14, _1: "5684341886080801486968994140625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS987 = { _0: 14, _1: "28421709430404007434844970703125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS988 = { _0: 14, _1: "142108547152020037174224853515625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS989 = { _0: 15, _1: "710542735760100185871124267578125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS990 = { _0: 15, _1: "3552713678800500929355621337890625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS991 = { _0: 15, _1: "17763568394002504646778106689453125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS992 = { _0: 16, _1: "88817841970012523233890533447265625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS993 = { _0: 16, _1: "444089209850062616169452667236328125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS994 = { _0: 16, _1: "2220446049250313080847263336181640625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS995 = { _0: 16, _1: "11102230246251565404236316680908203125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS996 = { _0: 17, _1: "55511151231257827021181583404541015625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS997 = { _0: 17, _1: "277555756156289135105907917022705078125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS998 = { _0: 17, _1: "1387778780781445675529539585113525390625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS999 = { _0: 18, _1: "6938893903907228377647697925567626953125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1000 = { _0: 18, _1: "34694469519536141888238489627838134765625" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1001 = { _0: 18, _1: "173472347597680709441192448139190673828125" };
const _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1002 = { _0: 19, _1: "867361737988403547205962240695953369140625" };
const _M0FPC28internal7strconv19left__shift__cheats = [_M0FPC28internal7strconv19left__shift__cheatsN5tupleS942, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS943, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS944, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS945, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS946, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS947, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS948, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS949, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS950, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS951, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS952, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS953, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS954, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS955, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS956, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS957, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS958, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS959, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS960, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS961, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS962, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS963, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS964, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS965, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS966, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS967, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS968, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS969, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS970, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS971, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS972, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS973, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS974, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS975, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS976, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS977, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS978, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS979, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS980, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS981, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS982, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS983, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS984, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS985, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS986, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS987, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS988, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS989, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS990, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS991, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS992, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS993, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS994, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS995, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS996, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS997, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS998, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS999, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1000, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1001, _M0FPC28internal7strconv19left__shift__cheatsN5tupleS1002];
const _M0FPC28internal7strconv10int__pow10 = [1n, 10n, 100n, 1000n, 10000n, 100000n, 1000000n, 10000000n, 100000000n, 1000000000n, 10000000000n, 100000000000n, 1000000000000n, 10000000000000n, 100000000000000n, 1000000000000000n];
const _M0FPC28internal7strconv5table = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000, 1e+012, 1e+013, 1e+014, 1e+015, 1e+016, 1e+017, 1e+018, 1e+019, 1e+020, 1e+021, 1e+022, 0, 0, 0, 0, 0, 0, 0, 0, 0];
const _M0FPC28internal7strconv12checked__mulN6constrS1083 = 0n;
const _M0FPC14json17int__pow10__table = [1n, 10n, 100n, 1000n, 10000n, 100000n, 1000000n, 10000000n, 100000000n, 1000000000n, 10000000000n, 100000000000n, 1000000000000n, 10000000000000n, 100000000000000n, 1000000000000000n];
const _M0FPC14json12pow10__table = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000, 1e+012, 1e+013, 1e+014, 1e+015, 1e+016, 1e+017, 1e+018, 1e+019, 1e+020, 1e+021, 1e+022, 0, 0, 0, 0, 0, 0, 0, 0, 0];
const _M0FPC14json12checked__mulN6constrS1776 = 0n;
const _M0FP38weopqrst12mooncassette5canon7fnv1a64N5primeS5 = 1099511628211n;
const _M0FP38weopqrst12mooncassette4core23stream__format__version = 2;
const _M0FP38weopqrst12mooncassette4core13generator__id = "mooncassette/0.4.0";
const _M0FP38weopqrst12mooncassette4core19default__drop__keys = ["request_id", "requestId", "stream_id", "timestamp", "created", "created_at", "nonce"];
const _M0FP38weopqrst12mooncassette11fingerprint9algorithm = "fnv1a64";
const _M0FP38weopqrst12mooncassette5codec11format__tag = "mooncassette";
const _M0FP38weopqrst12mooncassette5drift18short__fingerprintN7_2abindS83 = ":";
const _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS324 = 0;
const _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS325 = 1;
const _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS326 = 2;
const _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS327 = 3;
const _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS328 = 4;
const _M0FPB4seed = _M0FPB12random__seed();
const _M0FP38weopqrst12mooncassette5codec6encodeN6constrS198 = 2;
const _M0FP38weopqrst19mooncassette_2ddemo4main12sample__textN6constrS329 = "2026-09-13T00:00:00Z";
const _M0FPC28internal7strconv17check__underscoreN25_2atransition__table__178S186 = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 5, 5, 5, 5, 5, 0, 1, 2, 5];
const _M0FPC28internal7strconv15parse__inf__nanN25_2atransition__table__260S268 = [14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 3, 4, 14, 14, 14, 14, 14, 14, 14, 7, 14, 14, 14, 14, 5, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 6, 14, 14, 14, 0, 14, 14, 14, 14, 14, 14, 14, 14, 14, 8, 14, 14, 14, 14, 14, 1, 14, 14, 9, 14, 14, 14, 14, 14, 14, 14, 14, 10, 14, 14, 14, 14, 14, 14, 11, 14, 14, 14, 14, 14, 14, 14, 14, 14, 12, 14, 14, 14, 14, 14, 14, 14, 14, 13, 14, 1, 14, 14, 14, 14, 14, 14, 14];
const _M0FP38weopqrst19mooncassette_2ddemo4main16render__diagnoseN6constrS332 = 5;
const _M0FPB18brute__force__findN6constrS9194 = 0;
const _M0FPB28boyer__moore__horspool__findN6constrS9193 = 0;
const _M0FP38weopqrst12mooncassette5drift18short__fingerprintN6constrS108 = 8;
const _M0FP38weopqrst19mooncassette_2ddemo4main11leaky__textN6constrS330 = "2026-09-13T00:00:00Z";
const _M0FP38weopqrst19mooncassette_2ddemo4main13drifted__textN6constrS331 = "2026-09-13T00:00:00Z";
function _M0FPC15abort5abortGRPB4JsonE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGuE(msg) {
  $panic();
}
function _M0FPC15abort5abortGOiE(msg) {
  return $panic();
}
function _M0FPB13consume4__acc(acc, input) {
  const _p = (acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0;
  const _p$2 = 17;
  return Math.imul(_p << _p$2 | (_p >>> (32 - _p$2 | 0) | 0), 668265263) | 0;
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1622is__leading__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 55296) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 56319);
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0FPB32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MPC16string6String16unsafe__char__at(self, index) {
  const c1 = self.charCodeAt(index);
  if (_M0MPC16uint166UInt1622is__leading__surrogate(c1)) {
    const c2 = self.charCodeAt(index + 1 | 0);
    return _M0FPB32code__point__of__surrogate__pair(c1, c2);
  } else {
    return c1;
  }
}
function _M0MPC16string10StringView11sub_2einner(self, start, end) {
  const str_len = self.str.length;
  let abs_end;
  if (end === undefined) {
    abs_end = self.end;
  } else {
    const _Some = end;
    const _end = _Some;
    abs_end = self.start + _end | 0;
  }
  const abs_start = self.start + start | 0;
  if (abs_start >= self.start && (abs_start <= abs_end && abs_end <= self.end)) {
    if (abs_start < str_len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.str.charCodeAt(abs_start))) {
      } else {
        $panic();
      }
    }
    if (abs_end < str_len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.str.charCodeAt(abs_end))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self.str, abs_start, abs_end);
  } else {
    return $panic();
  }
}
function _M0MPC16string10StringView12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.end - self.start | 0;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= (self.end - self.start | 0)) ? new _M0TPC16string10StringView(self.str, self.start + start_offset | 0, self.start + end_offset$2 | 0) : _M0FPC15abort5abortGRPB4JsonE("Invalid index for View");
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IP016_24default__implPB2Eq10not__equalGRPB4JsonE(x, y) {
  return !_M0IPC14json4JsonPB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB7Compare6op__ltGkE(x, y) {
  return $compare_int(x, y) < 0;
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return $compare_int(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return $compare_int(x, y) >= 0;
}
function _M0FPB14avalanche__acc(acc) {
  let acc$2 = acc;
  acc$2 = acc$2 ^ (acc$2 >>> 15 | 0);
  acc$2 = Math.imul(acc$2, -2048144777) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 13 | 0);
  acc$2 = Math.imul(acc$2, -1028477379) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 16 | 0);
  return acc$2;
}
function _M0FPB13finalize__acc(acc) {
  return _M0FPB14avalanche__acc(acc);
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    end$2 = _Some;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    if (start < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, self);
}
function _M0IP016_24default__implPB4Show10to__stringGRP38weopqrst12mooncassette4core13CassetteErrorE(self) {
  const logger = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IP38weopqrst12mooncassette4core13CassetteErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return logger.val;
}
function _M0MPB4Iter4nextGcE(self) {
  const _func = self.f;
  const result = _func();
  const _bind = self.size_hint;
  if (result === -1) {
    self.size_hint = _M0MPB4Iter4nextN6constrS9184GcE;
  } else {
    if (_bind === undefined) {
    } else {
      const _Some = _bind;
      const _n = _Some;
      self.size_hint = _n > 0 ? _n - 1 | 0 : _M0MPB4Iter4nextN6constrS9183GcE;
    }
  }
  return result;
}
function _M0MPB4Iter4nextGsE(self) {
  const _func = self.f;
  const result = _func();
  const _bind = self.size_hint;
  if (result === undefined) {
    self.size_hint = _M0MPB4Iter4nextN6constrS9184GsE;
  } else {
    if (_bind === undefined) {
    } else {
      const _Some = _bind;
      const _n = _Some;
      self.size_hint = _n > 0 ? _n - 1 | 0 : _M0MPB4Iter4nextN6constrS9183GsE;
    }
  }
  return result;
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16uint646UInt6418to__string_2einner(self, radix) {
  return _M0FPB22uint64__to__string__js(self, radix);
}
function _M0MPB4Iter3newGcE(f, size_hint) {
  let size_hint$2;
  if (size_hint === undefined) {
    size_hint$2 = undefined;
  } else {
    const _Some = size_hint;
    const _n = _Some;
    size_hint$2 = _n > 0 ? _n : _M0MPB4Iter3newN6constrS9191GcE;
  }
  return new _M0TPB4IterGcE(f, size_hint$2);
}
function _M0MPB4Iter3newGsE(f, size_hint) {
  let size_hint$2;
  if (size_hint === undefined) {
    size_hint$2 = undefined;
  } else {
    const _Some = size_hint;
    const _n = _Some;
    size_hint$2 = _n > 0 ? _n : _M0MPB4Iter3newN6constrS9191GsE;
  }
  return new _M0TPB4IterGsE(f, size_hint$2);
}
function _M0MPC15array10FixedArray12view_2einnerGkE(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    end$2 = _Some;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    const _bind = self;
    const _bind$2 = end$2 - start | 0;
    return new _M0TPB9ArrayViewGkE(_bind, start, start + _bind$2 | 0);
  } else {
    return _M0FPC15abort5abortGRPB4JsonE("View index out of bounds");
  }
}
function _M0MPC16string10StringView11code__units(self) {
  const _p = self.str.length;
  let _tmp;
  if (_p <= 0) {
    _tmp = [];
  } else {
    const _p$2 = 0;
    const _p$3 = $make_array_len_and_init(_p, self.str.charCodeAt(_p$2));
    let _tmp$2 = 1;
    while (true) {
      const _p$4 = _tmp$2;
      if (_p$4 < _p) {
        $bound_check(_p$3, _p$4);
        _p$3[_p$4] = self.str.charCodeAt(_p$4);
        _tmp$2 = _p$4 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _tmp = _p$3;
  }
  return _M0MPC15array10FixedArray12view_2einnerGkE(_tmp, self.start, self.end);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string10StringView4iter(self) {
  const start = self.start;
  const end = self.end;
  const index = new _M0TPB8MutLocalGiE(start);
  return _M0MPB4Iter3newGcE(() => {
    if (index.val < end) {
      const c1 = self.str.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < self.end) {
        const c2 = self.str.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          index.val = index.val + 2 | 0;
          return _M0FPB32code__point__of__surrogate__pair(c1, c2);
        }
      }
      index.val = index.val + 1 | 0;
      return c1;
    } else {
      return -1;
    }
  }, undefined);
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPC15abort5abortGRPB4JsonE("Invalid index for View");
}
function _M0MPC16string6String24char__length__ge_2einner(self, len, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  let _tmp = start_offset;
  let _tmp$2 = 0;
  while (true) {
    const index = _tmp;
    const count = _tmp$2;
    if (index < end_offset$2 && count < len) {
      const c1 = self.charCodeAt(index);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index + 1 | 0) < end_offset$2) {
        const c2 = self.charCodeAt(index + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          _tmp = index + 2 | 0;
          _tmp$2 = count + 1 | 0;
          continue;
        } else {
          _M0FPC15abort5abortGuE("invalid surrogate pair");
        }
      }
      _tmp = index + 1 | 0;
      _tmp$2 = count + 1 | 0;
      continue;
    } else {
      return count >= len;
    }
  }
}
function _M0MPC16string6String31offset__of__nth__char__backward(self, n, start_offset, end_offset) {
  let _tmp = end_offset;
  let _tmp$2 = 0;
  while (true) {
    const utf16_offset = _tmp;
    const char_count = _tmp$2;
    if ((utf16_offset - 1 | 0) >= start_offset && char_count < n) {
      const c = self.charCodeAt(utf16_offset - 1 | 0);
      if (_M0MPC16uint166UInt1623is__trailing__surrogate(c)) {
        _tmp = utf16_offset - 2 | 0;
        _tmp$2 = char_count + 1 | 0;
        continue;
      } else {
        _tmp = utf16_offset - 1 | 0;
        _tmp$2 = char_count + 1 | 0;
        continue;
      }
    } else {
      return char_count < n || utf16_offset < start_offset ? undefined : utf16_offset;
    }
  }
}
function _M0MPC16string6String30offset__of__nth__char__forward(self, n, start_offset, end_offset) {
  if (start_offset >= 0 && start_offset <= end_offset) {
    let _tmp = start_offset;
    let _tmp$2 = 0;
    while (true) {
      const utf16_offset = _tmp;
      const char_count = _tmp$2;
      if (utf16_offset < end_offset && char_count < n) {
        const c = self.charCodeAt(utf16_offset);
        if (_M0MPC16uint166UInt1622is__leading__surrogate(c)) {
          _tmp = utf16_offset + 2 | 0;
          _tmp$2 = char_count + 1 | 0;
          continue;
        } else {
          _tmp = utf16_offset + 1 | 0;
          _tmp$2 = char_count + 1 | 0;
          continue;
        }
      } else {
        return char_count < n || utf16_offset >= end_offset ? undefined : utf16_offset;
      }
    }
  } else {
    return _M0FPC15abort5abortGOiE("Invalid start index");
  }
}
function _M0MPC16string6String29offset__of__nth__char_2einner(self, i, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return i >= 0 ? _M0MPC16string6String30offset__of__nth__char__forward(self, i, start_offset, end_offset$2) : _M0MPC16string6String31offset__of__nth__char__backward(self, -i | 0, start_offset, end_offset$2);
}
function _M0FPB20unsafe__make__string(_tmp, _tmp$2) {
  return $unsafe_make_string(_tmp, _tmp$2);
}
function _M0MPC16string6String4make(length, value) {
  if (length >= 0) {
    if (value <= 65535) {
      return _M0FPB20unsafe__make__string(length, value);
    } else {
      const buf = _M0MPB13StringBuilder21StringBuilder_2einner(Math.imul(2, length) | 0);
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < length) {
          _M0IPB13StringBuilderPB6Logger11write__char(buf, value);
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return buf.val;
    }
  } else {
    return _M0FPC15abort5abortGRPB4JsonE("invalid length");
  }
}
function _M0MPB13StringBuilder11write__iter(self, iter) {
  while (true) {
    const _bind = _M0MPB4Iter4nextGcE(iter);
    if (_bind === -1) {
      return;
    } else {
      const _Some = _bind;
      const _ch = _Some;
      _M0IPB13StringBuilderPB6Logger11write__char(self, _ch);
      continue;
    }
  }
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0FPB28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _bind = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _bind) {
          const _tmp$2 = needle.str.charCodeAt(needle.start + i | 0) & 255;
          $bound_check(skip_table, _tmp$2);
          skip_table[_tmp$2] = (needle_len - 1 | 0) - i | 0;
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i <= (haystack_len - needle_len | 0)) {
          const _bind$2 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _bind$2) {
              const _p = haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0);
              const _p$2 = needle.str.charCodeAt(needle.start + j | 0);
              if (_p !== _p$2) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = haystack.str.charCodeAt(haystack.start + ((i + needle_len | 0) - 1 | 0) | 0) & 255;
          $bound_check(skip_table, _tmp$4);
          _tmp$2 = i + skip_table[_tmp$4] | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB28boyer__moore__horspool__findN6constrS9193;
  }
}
function _M0FPB18brute__force__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = needle.str.charCodeAt(needle.start);
      const forward_len = haystack_len - needle_len | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i <= forward_len) {
          _L: {
            const _p = haystack.str.charCodeAt(haystack.start + i | 0);
            if (_p !== needle_first) {
              break _L;
            }
            let _tmp$2 = 1;
            while (true) {
              const j = _tmp$2;
              if (j < needle_len) {
                const _p$2 = haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0);
                const _p$3 = needle.str.charCodeAt(needle.start + j | 0);
                if (_p$2 !== _p$3) {
                  break;
                }
                _tmp$2 = j + 1 | 0;
                continue;
              } else {
                return i;
              }
            }
            break _L;
          }
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB18brute__force__findN6constrS9194;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return (str.end - str.start | 0) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0FPB33boyer__moore__horspool__rev__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      let _tmp = needle_len - 1 | 0;
      while (true) {
        const i = _tmp;
        if (i >= 1) {
          const _tmp$2 = needle.str.charCodeAt(needle.start + i | 0) & 255;
          $bound_check(skip_table, _tmp$2);
          skip_table[_tmp$2] = i;
          _tmp = i - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$2 = haystack_len - needle_len | 0;
      while (true) {
        const i = _tmp$2;
        if (i >= 0) {
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j < needle_len) {
              const _p = haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0);
              const _p$2 = needle.str.charCodeAt(needle.start + j | 0);
              if (_p !== _p$2) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = haystack.str.charCodeAt(haystack.start + i | 0) & 255;
          $bound_check(skip_table, _tmp$4);
          _tmp$2 = i - skip_table[_tmp$4] | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return haystack_len;
  }
}
function _M0FPB23brute__force__rev__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = needle.str.charCodeAt(needle.start);
      const _bind = haystack_len - needle_len | 0;
      let _tmp = _bind;
      while (true) {
        const i = _tmp;
        if (i >= 0) {
          _L: {
            const _p = haystack.str.charCodeAt(haystack.start + i | 0);
            if (_p !== needle_first) {
              break _L;
            }
            let _tmp$2 = 1;
            while (true) {
              const j = _tmp$2;
              if (j < needle_len) {
                const _p$2 = haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0);
                const _p$3 = needle.str.charCodeAt(needle.start + j | 0);
                if (_p$2 !== _p$3) {
                  break;
                }
                _tmp$2 = j + 1 | 0;
                continue;
              } else {
                return i;
              }
            }
            break _L;
          }
          _tmp = i - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return haystack_len;
  }
}
function _M0MPC16string10StringView9rev__find(self, str) {
  return (str.end - str.start | 0) <= 4 ? _M0FPB23brute__force__rev__find(self, str) : _M0FPB33boyer__moore__horspool__rev__find(self, str);
}
function _M0MPC16string10StringView11has__suffix(self, str) {
  const _bind = _M0MPC16string10StringView9rev__find(self, str);
  if (_bind === undefined) {
    return false;
  } else {
    const _Some = _bind;
    const _i = _Some;
    return _i === ((self.end - self.start | 0) - (str.end - str.start | 0) | 0);
  }
}
function _M0MPC16string6String11has__suffix(self, str) {
  return _M0MPC16string10StringView11has__suffix(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC15array5Array11new_2einnerGcE(capacity) {
  return [];
}
function _M0MPC15array5Array11new_2einnerGRPC16string10StringViewE(capacity) {
  return [];
}
function _M0MPC15array5Array4pushGcE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGRPB4JsonE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string10StringView20contains__code__unit(self, code) {
  const _bind = self.end - self.start | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      const _p = self.str.charCodeAt(self.start + i | 0);
      if (_p === code) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0MPC16string10StringView14contains__char(self, c) {
  const len = self.end - self.start | 0;
  if (len > 0) {
    const c$2 = c;
    if (c$2 >= 0 && c$2 <= 65535) {
      return _M0MPC16string10StringView20contains__code__unit(self, c$2 & 65535);
    } else {
      if (c$2 < 0) {
        return false;
      } else {
        if (len >= 2) {
          const adj = c$2 - 65536 | 0;
          const high = 55296 + (adj >> 10) | 0;
          if (high <= 65535) {
            const high$2 = high & 65535;
            const low = (56320 + (adj & 1023) | 0) & 65535;
            let _tmp = 0;
            while (true) {
              const i = _tmp;
              if (i < (len - 1 | 0)) {
                const _p = self.str.charCodeAt(self.start + i | 0);
                if (_p === high$2) {
                  const _p$2 = self.str.charCodeAt(self.start + (i + 1 | 0) | 0);
                  if (_p$2 === low) {
                    return true;
                  }
                  _tmp = i + 2 | 0;
                  continue;
                }
                _tmp = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    }
    return false;
  } else {
    return false;
  }
}
function _M0MPC16string10StringView19trim__start_2einner(self, chars) {
  let _tmp = self;
  while (true) {
    const x = _tmp;
    if ((x.end - x.start | 0) === 0) {
      return x;
    } else {
      const _c = _M0MPC16string6String16unsafe__char__at(x.str, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, 0, x.start, x.end));
      const _tmp$2 = x.str;
      const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(x.str, 1, x.start, x.end);
      let _tmp$3;
      if (_bind === undefined) {
        _tmp$3 = x.end;
      } else {
        const _Some = _bind;
        _tmp$3 = _Some;
      }
      const _x = new _M0TPC16string10StringView(_tmp$2, _tmp$3, x.end);
      if (_M0MPC16string10StringView14contains__char(chars, _c)) {
        _tmp = _x;
        continue;
      } else {
        return x;
      }
    }
  }
}
function _M0MPC16string10StringView17trim__end_2einner(self, chars) {
  let _tmp = self;
  while (true) {
    const x = _tmp;
    if ((x.end - x.start | 0) === 0) {
      return x;
    } else {
      const _c = _M0MPC16string6String16unsafe__char__at(x.str, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, -1, x.start, x.end));
      const _x = new _M0TPC16string10StringView(x.str, x.start, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, -1, x.start, x.end));
      if (_M0MPC16string10StringView14contains__char(chars, _c)) {
        _tmp = _x;
        continue;
      } else {
        return x;
      }
    }
  }
}
function _M0MPC16string10StringView12trim_2einner(self, chars) {
  return _M0MPC16string10StringView17trim__end_2einner(_M0MPC16string10StringView19trim__start_2einner(self, chars), chars);
}
function _M0MPC16string6String12trim_2einner(self, chars) {
  return _M0MPC16string10StringView12trim_2einner(new _M0TPC16string10StringView(self, 0, self.length), chars);
}
function _M0MPC16string6String4trim(self, chars$46$opt) {
  let chars;
  if (chars$46$opt === undefined) {
    chars = new _M0TPC16string10StringView(_M0MPC16string6String4trimN7_2abindS6432, 0, _M0MPC16string6String4trimN7_2abindS6432.length);
  } else {
    const _Some = chars$46$opt;
    chars = _Some;
  }
  return _M0MPC16string6String12trim_2einner(self, chars);
}
function _M0MPC16string6String4iter(self) {
  const len = self.length;
  const index = new _M0TPB8MutLocalGiE(0);
  return _M0MPB4Iter3newGcE(() => {
    if (index.val < len) {
      const c1 = self.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < len) {
        const c2 = self.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          const c = _M0FPB32code__point__of__surrogate__pair(c1, c2);
          index.val = index.val + 2 | 0;
          return c;
        }
      }
      index.val = index.val + 1 | 0;
      return c1;
    } else {
      return -1;
    }
  }, undefined);
}
function _M0MPC16string6String10pad__start(self, total_width, padding_char) {
  const len = self.length;
  if (len < total_width) {
    const padding = _M0MPC16string6String4make(total_width - len | 0, padding_char);
    const _self = _M0MPB13StringBuilder21StringBuilder_2einner(0);
    _M0MPB13StringBuilder11write__iter(_self, _M0MPC16string6String4iter(padding));
    _M0MPB13StringBuilder11write__iter(_self, _M0MPC16string6String4iter(self));
    const _p = _self;
    return _p.val;
  } else {
    return self;
  }
}
function _M0MPB4Iter3mapGcRPC16string10StringViewE(self, f) {
  return new _M0TPB4IterGRPC16string10StringViewE(() => {
    const _bind = _M0MPB4Iter4nextGcE(self);
    if (_bind === -1) {
      return undefined;
    } else {
      const _Some = _bind;
      const _x = _Some;
      return f(_x);
    }
  }, self.size_hint);
}
function _M0IPC14char4CharPB4Show10to__string(self) {
  return String.fromCodePoint(self);
}
function _M0MPC16string10StringView5split(self, sep) {
  const sep_len = sep.end - sep.start | 0;
  if (sep_len === 0) {
    return _M0MPB4Iter3mapGcRPC16string10StringViewE(_M0MPC16string10StringView4iter(self), (c) => _M0MPC16string6String12view_2einner(_M0IPC14char4CharPB4Show10to__string(c), 0, undefined));
  }
  const remaining = new _M0TPB8MutLocalGORPC16string10StringViewE(self);
  return _M0MPB4Iter3newGsE(() => {
    const _bind = remaining.val;
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _view = _Some;
      const _bind$2 = _M0MPC16string10StringView4find(_view, sep);
      if (_bind$2 === undefined) {
        remaining.val = undefined;
        return _view;
      } else {
        const _Some$2 = _bind$2;
        const _end = _Some$2;
        remaining.val = _M0MPC16string10StringView12view_2einner(_view, _end + sep_len | 0, undefined);
        return _M0MPC16string10StringView12view_2einner(_view, 0, _end);
      }
    }
  }, undefined);
}
function _M0MPC16string6String5split(self, sep) {
  return _M0MPC16string10StringView5split(new _M0TPC16string10StringView(self, 0, self.length), sep);
}
function _M0MPB4Iter9to__arrayGRPC16string10StringViewE(self) {
  const _bind = self.size_hint;
  let result;
  if (_bind === undefined) {
    result = [];
  } else {
    const _Some = _bind;
    const _n = _Some;
    result = _M0MPC15array5Array11new_2einnerGRPC16string10StringViewE(_n);
  }
  while (true) {
    const _bind$2 = _M0MPB4Iter4nextGsE(self);
    if (_bind$2 === undefined) {
      break;
    } else {
      const _Some = _bind$2;
      const _x = _Some;
      _M0MPC15array5Array4pushGRPB4JsonE(result, _x);
      continue;
    }
  }
  return result;
}
function _M0MPC14char4Char20is__ascii__uppercase(self) {
  return self >= 65 && self <= 90;
}
function _M0MPC16string10StringView9get__char(self, idx) {
  if (idx >= 0 && idx < (self.end - self.start | 0)) {
    const c = self.str.charCodeAt(self.start + idx | 0);
    if (_M0MPC16uint166UInt1622is__leading__surrogate(c)) {
      if ((idx + 1 | 0) < (self.end - self.start | 0)) {
        const next = self.str.charCodeAt(self.start + (idx + 1 | 0) | 0);
        return _M0MPC16uint166UInt1623is__trailing__surrogate(next) ? _M0FPB32code__point__of__surrogate__pair(c, next) : -1;
      } else {
        return -1;
      }
    } else {
      return _M0MPC16uint166UInt1623is__trailing__surrogate(c) ? -1 : c;
    }
  } else {
    return -1;
  }
}
function _M0MPC16string6String9to__array(self) {
  const _p = _M0MPC16string6String4iter(self);
  const _p$2 = _M0MPC15array5Array11new_2einnerGcE(self.length);
  let _p$3 = _p$2;
  while (true) {
    const _p$4 = _M0MPB4Iter4nextGcE(_p);
    if (_p$4 === -1) {
      break;
    } else {
      const _p$5 = _p$4;
      const _p$6 = _p$5;
      const _p$7 = _p$3;
      _M0MPC15array5Array4pushGcE(_p$7, _p$6);
      _p$3 = _p$7;
      continue;
    }
  }
  return _p$3;
}
function _M0MPC15array9ArrayView12view_2einnerGkE(self, start, end) {
  const len = self.end - self.start | 0;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    end$2 = _Some;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    const _bind = self.buf;
    const _bind$2 = self.start + start | 0;
    const _bind$3 = end$2 - start | 0;
    return new _M0TPB9ArrayViewGkE(_bind, _bind$2, _bind$2 + _bind$3 | 0);
  } else {
    return _M0FPC15abort5abortGRPB4JsonE("View index out of bounds");
  }
}
function _M0MPC16option6Option3mapGRPC16string10StringViewsE(self, f) {
  if (self === undefined) {
    return undefined;
  } else {
    const _Some = self;
    const _t = _Some;
    return f(_t);
  }
}
function _M0MPC13int3Int20next__power__of__two(self) {
  if (self >= 0) {
    if (self <= 1) {
      return 1;
    }
    if (self > 1073741824) {
      return 1073741824;
    }
    return (2147483647 >> (Math.clz32(self - 1 | 0) - 1 | 0)) + 1 | 0;
  } else {
    return $panic();
  }
}
function _M0FPB8new__mapGsRPB4JsonE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = (Math.imul(capacity$2, 13) | 0) / 16 | 0;
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsRPB4JsonE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB8new__mapGsRPB5ArrayGiEE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = (Math.imul(capacity$2, 13) | 0) / 16 | 0;
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsRPB5ArrayGiEE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB8new__mapGsiE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = (Math.imul(capacity$2, 13) | 0) / 16 | 0;
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsiE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB21capacity__for__length(length) {
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  const _p = capacity;
  if (length > ((Math.imul(_p, 13) | 0) / 16 | 0)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  return capacity;
}
function _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    const _p = _tmp[_bind];
    let _tmp$2;
    if (_p === undefined) {
      _tmp$2 = $panic();
    } else {
      const _p$2 = _p;
      _tmp$2 = _p$2;
    }
    _tmp$2.next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGsRPB5ArrayGiEE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    const _p = _tmp[_bind];
    let _tmp$2;
    if (_p === undefined) {
      _tmp$2 = $panic();
    } else {
      const _p$2 = _p;
      _tmp$2 = _p$2;
    }
    _tmp$2.next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    const _p = _tmp[_bind];
    let _tmp$2;
    if (_p === undefined) {
      _tmp$2 = $panic();
    } else {
      const _p$2 = _p;
      _tmp$2 = _p$2;
    }
    _tmp$2.next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGsRPB4JsonE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10set__entryGsRPB5ArrayGiEE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10set__entryGsiE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10push__awayGsRPB4JsonE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = idx + 1 & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsRPB4JsonE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsRPB4JsonE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map10push__awayGsRPB5ArrayGiEE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = idx + 1 & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsRPB5ArrayGiEE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsRPB5ArrayGiEE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map10push__awayGsiE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = idx + 1 & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsiE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsiE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGsRPB4JsonE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGsRPB4JsonE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGsRPB5ArrayGiEE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGsRPB5ArrayGiEE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGsRPB5ArrayGiEE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGsRPB5ArrayGiEE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGsiE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGsiE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGsiE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGsiE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map4growGsRPB4JsonE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  const _p = self.capacity;
  self.grow_at = (Math.imul(_p, 13) | 0) / 16 | 0;
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGsRPB4JsonE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map4growGsRPB5ArrayGiEE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  const _p = self.capacity;
  self.grow_at = (Math.imul(_p, 13) | 0) / 16 | 0;
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGsRPB5ArrayGiEE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map4growGsiE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  const _p = self.capacity;
  self.grow_at = (Math.imul(_p, 13) | 0) / 16 | 0;
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGsiE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsRPB4JsonE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsRPB4JsonE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsRPB4JsonE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsRPB4JsonE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsRPB4JsonE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsRPB4JsonE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsRPB5ArrayGiEE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsRPB5ArrayGiEE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsRPB5ArrayGiEE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsRPB5ArrayGiEE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsRPB5ArrayGiEE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsRPB5ArrayGiEE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsRPB5ArrayGiEE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsRPB5ArrayGiEE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsiE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsiE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsiE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsiE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsiE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsiE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3setGsRPB4JsonE(self, key, value) {
  _M0MPB3Map15set__with__hashGsRPB4JsonE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3setGsRPB5ArrayGiEE(self, key, value) {
  _M0MPB3Map15set__with__hashGsRPB5ArrayGiEE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3setGsiE(self, key, value) {
  _M0MPB3Map15set__with__hashGsiE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3MapGsRPB4JsonE(arr, capacity) {
  const length = arr.end - arr.start | 0;
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    const _p = _M0FPB21capacity__for__length(length);
    capacity$2 = _capacity > _p ? _capacity : _p;
  }
  const m = _M0FPB8new__mapGsRPB4JsonE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsRPB4JsonE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3MapGsRPB5ArrayGiEE(arr, capacity) {
  const length = arr.end - arr.start | 0;
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    const _p = _M0FPB21capacity__for__length(length);
    capacity$2 = _capacity > _p ? _capacity : _p;
  }
  const m = _M0FPB8new__mapGsRPB5ArrayGiEE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsRPB5ArrayGiEE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3MapGsiE(arr, capacity) {
  const length = arr.end - arr.start | 0;
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    const _p = _M0FPB21capacity__for__length(length);
    capacity$2 = _capacity > _p ? _capacity : _p;
  }
  const m = _M0FPB8new__mapGsiE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsiE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3getGsRPB4JsonE(self, key) {
  const hash = _M0IPC16string6StringPB4Hash4hash(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return undefined;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3getGsRPB5ArrayGiEE(self, key) {
  const hash = _M0IPC16string6StringPB4Hash4hash(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return new _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(_entry.value);
      }
      if (i > _entry.psl) {
        return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map16get__or__defaultGsiE(self, key, default_) {
  const hash = _M0IPC16string6StringPB4Hash4hash(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return default_;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return default_;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map12contains__kvGsRPB4JsonE(self, key, value) {
  const hash = _M0IPC16string6StringPB4Hash4hash(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return false;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && (_entry.key === key && _M0IPC14json4JsonPB2Eq5equal(_entry.value, value))) {
        return true;
      }
      if (i > _entry.psl) {
        return false;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map4iterGsRPB4JsonE(self) {
  const curr_entry = new _M0TPB8MutLocalGORPB5EntryGsRPB4JsonEE(self.head);
  const len = self.size;
  const remaining = new _M0TPB8MutLocalGiE(len);
  return _M0MPB4Iter3newGsE(() => {
    _L: {
      if (remaining.val > 0) {
        const _bind = curr_entry.val;
        if (_bind === undefined) {
          break _L;
        } else {
          const _Some = _bind;
          const _x = _Some;
          const _key = _x.key;
          const _value = _x.value;
          const _next = _x.next;
          curr_entry.val = _next;
          remaining.val = remaining.val - 1 | 0;
          return { _0: _key, _1: _value };
        }
      } else {
        break _L;
      }
    }
    return undefined;
  }, len);
}
function _M0MPB3Map5iter2GsRPB4JsonE(self) {
  return _M0MPB3Map4iterGsRPB4JsonE(self);
}
function _M0MPB3Map4keysGsRPB4JsonE(self) {
  const curr_entry = new _M0TPB8MutLocalGORPB5EntryGsRPB4JsonEE(self.head);
  const len = self.size;
  const remaining = new _M0TPB8MutLocalGiE(len);
  return _M0MPB4Iter3newGsE(() => {
    _L: {
      if (remaining.val > 0) {
        const _bind = curr_entry.val;
        if (_bind === undefined) {
          break _L;
        } else {
          const _Some = _bind;
          const _x = _Some;
          const _key = _x.key;
          const _next = _x.next;
          curr_entry.val = _next;
          remaining.val = remaining.val - 1 | 0;
          return _key;
        }
      } else {
        break _L;
      }
    }
    return undefined;
  }, len);
}
function _M0IPB3MapPB2Eq5equalGsRPB4JsonE(self, that) {
  if (self.size === that.size) {
    const _it = _M0MPB3Map5iter2GsRPB4JsonE(self);
    while (true) {
      const _bind = _M0MPB5Iter24nextGsRPB4JsonE(_it);
      if (_bind === undefined) {
        return true;
      } else {
        const _Some = _bind;
        const _x = _Some;
        const _k = _x._0;
        const _v = _x._1;
        if (_M0MPB3Map12contains__kvGsRPB4JsonE(that, _k, _v)) {
        } else {
          return false;
        }
        continue;
      }
    }
  } else {
    return false;
  }
}
function _M0IPC14json4JsonPB2Eq5equal(a, b) {
  switch (a.$tag) {
    case 0: {
      if (b.$tag === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (b.$tag === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (b.$tag === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      const _Number = a;
      const _a_num = _Number._0;
      if (b.$tag === 3) {
        const _Number$2 = b;
        const _b_num = _Number$2._0;
        return _a_num === _b_num;
      } else {
        return false;
      }
    }
    case 4: {
      const _String = a;
      const _a_str = _String._0;
      if (b.$tag === 4) {
        const _String$2 = b;
        const _b_str = _String$2._0;
        return _a_str === _b_str;
      } else {
        return false;
      }
    }
    case 5: {
      const _Array = a;
      const _a_arr = _Array._0;
      if (b.$tag === 5) {
        const _Array$2 = b;
        const _b_arr = _Array$2._0;
        return _M0IPC15array5ArrayPB2Eq5equalGRPB4JsonE(_a_arr, _b_arr);
      } else {
        return false;
      }
    }
    default: {
      const _Object = a;
      const _a_obj = _Object._0;
      if (b.$tag === 6) {
        const _Object$2 = b;
        const _b_obj = _Object$2._0;
        return _M0IPB3MapPB2Eq5equalGsRPB4JsonE(_a_obj, _b_obj);
      } else {
        return false;
      }
    }
  }
}
function _M0MPB5Iter24nextGsRPB4JsonE(self) {
  return _M0MPB4Iter4nextGsE(self);
}
function _M0IPC16string6StringPB4Hash4hash(self) {
  let acc = (_M0FPB4seed >>> 0) + (374761393 >>> 0) | 0;
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      acc = (acc >>> 0) + (4 >>> 0) | 0;
      const v = self.charCodeAt(i);
      acc = _M0FPB13consume4__acc(acc, v);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FPB13finalize__acc(acc);
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0MPC14char4Char21is__ascii__alphabetic(self) {
  return self >= 65 && self <= 90 ? true : self >= 97 && self <= 122;
}
function _M0MPC14char4Char16is__ascii__digit(self) {
  return self >= 48 && self <= 57;
}
function _M0MPC14char4Char20to__ascii__lowercase(self) {
  if (_M0MPC14char4Char20is__ascii__uppercase(self)) {
    return self + 32 | 0;
  }
  return self;
}
function _M0MPC14byte4Byte10to__uint64(self) {
  const _p = self;
  return BigInt.asUintN(64, BigInt(_p >>> 0));
}
function _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGiE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGbE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGcE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array3setGsE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGbE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array4makeGbE(len, elem) {
  const arr = new Array(len);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      arr[i] = elem;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0IPC15array5ArrayPB2Eq5equalGRPB4JsonE(self, other) {
  const self_len = self.length;
  const other_len = other.length;
  if (self_len === other_len) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < self_len) {
        if (_M0IPC14json4JsonPB2Eq5equal(self[i], other[i])) {
        } else {
          return false;
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return true;
      }
    }
  } else {
    return false;
  }
}
function _M0FPC28encoding4utf814encode_2einner(str, bom) {
  return _M0FPC28encoding4utf816encode__utf8__js(str.str, str.start, str.end - str.start | 0, bom);
}
function _M0FPC28internal7strconv10range__errGuE() {
  return new _M0DTPC16result6ResultGuRPB7FailureE3Err(new _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(_M0FPC28internal7strconv15range__err__str));
}
function _M0FPC28internal7strconv11syntax__errGdE() {
  return new _M0DTPC16result6ResultGdRPB7FailureE3Err(new _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(_M0FPC28internal7strconv16syntax__err__str));
}
function _M0FPC28internal7strconv11syntax__errGORPC28internal7strconv6NumberE() {
  return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPB7FailureE3Err(new _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(_M0FPC28internal7strconv16syntax__err__str));
}
function _M0FPC28internal7strconv11syntax__errGuE() {
  return new _M0DTPC16result6ResultGuRPB7FailureE3Err(new _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(_M0FPC28internal7strconv16syntax__err__str));
}
function _M0FPC28internal7strconv11syntax__errGRPC16string10StringViewE() {
  return new _M0DTPC16result6ResultGRPC16string10StringViewRPB7FailureE3Err(new _M0DTPC15error5Error48moonbitlang_2fcore_2fbuiltin_2eFailure_2eFailure(_M0FPC28internal7strconv16syntax__err__str));
}
function _M0EPC16string10StringViewPC28internal7strconv12fold__digitsGmE(self, init, f) {
  let _tmp = self;
  let _tmp$2 = init;
  let _tmp$3 = 0;
  while (true) {
    const str = _tmp;
    const ret = _tmp$2;
    const len = _tmp$3;
    _L: {
      if ((str.end - str.start | 0) >= 1) {
        const _x = str.str.charCodeAt(str.start);
        if (_x >= 48 && _x <= 57) {
          const _x$2 = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
          _tmp = _x$2;
          _tmp$2 = f(_x - 48 | 0, ret);
          _tmp$3 = len + 1 | 0;
          continue;
        } else {
          if (_x === 95) {
            const _x$2 = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
            _tmp = _x$2;
            continue;
          } else {
            break _L;
          }
        }
      } else {
        break _L;
      }
    }
    return { _0: str, _1: ret, _2: len };
  }
}
function _M0FPC28internal7strconv13parse__digits(s, x) {
  return _M0EPC16string10StringViewPC28internal7strconv12fold__digitsGmE(s, x, (digit, acc) => BigInt.asUintN(64, BigInt.asUintN(64, acc * 10n) + BigInt.asUintN(64, BigInt(digit >>> 0))));
}
function _M0FPC28internal7strconv20try__parse__19digits(s, x) {
  let x$2 = x;
  let len = 0;
  let _tmp = s;
  while (true) {
    const s$2 = _tmp;
    let s$3;
    _L: {
      if ((s$2.end - s$2.start | 0) >= 1) {
        const _x = s$2.str.charCodeAt(s$2.start);
        if (_x >= 48 && _x <= 57) {
          const _x$2 = new _M0TPC16string10StringView(s$2.str, s$2.start + 1 | 0, s$2.end);
          if (BigInt.asUintN(64, x$2) < BigInt.asUintN(64, _M0FPC28internal7strconv17min__19digit__int)) {
            len = len + 1 | 0;
            x$2 = BigInt.asUintN(64, BigInt.asUintN(64, x$2 * 10n) + BigInt.asUintN(64, BigInt((_x - 48 | 0) >>> 0)));
            _tmp = _x$2;
            continue;
          } else {
            s$3 = s$2;
            break _L;
          }
        } else {
          if (_x === 95) {
            const _x$2 = new _M0TPC16string10StringView(s$2.str, s$2.start + 1 | 0, s$2.end);
            _tmp = _x$2;
            continue;
          } else {
            s$3 = s$2;
            break _L;
          }
        }
      } else {
        s$3 = s$2;
        break _L;
      }
    }
    return { _0: s$3, _1: x$2, _2: len };
  }
}
function _M0FPC28internal7strconv17parse__scientific(s) {
  let s$2 = s;
  let neg_exp = false;
  let rest;
  let ch;
  _L: {
    _L$2: {
      const _bind = s$2;
      if ((_bind.end - _bind.start | 0) >= 1) {
        const _x = _bind.str.charCodeAt(_bind.start);
        switch (_x) {
          case 43: {
            const _x$2 = new _M0TPC16string10StringView(_bind.str, _bind.start + 1 | 0, _bind.end);
            rest = _x$2;
            ch = _x;
            break _L$2;
          }
          case 45: {
            const _x$3 = new _M0TPC16string10StringView(_bind.str, _bind.start + 1 | 0, _bind.end);
            rest = _x$3;
            ch = _x;
            break _L$2;
          }
        }
      }
      break _L;
    }
    neg_exp = ch === 45;
    s$2 = rest;
  }
  _L$2: {
    const _bind = s$2;
    if ((_bind.end - _bind.start | 0) >= 1) {
      const _x = _bind.str.charCodeAt(_bind.start);
      if (_x >= 48 && _x <= 57) {
        const _bind$2 = _M0EPC16string10StringViewPC28internal7strconv12fold__digitsGmE(s$2, _M0FPC28internal7strconv17parse__scientificN8exp__numS310, (digit, exp_num) => BigInt.asIntN(64, exp_num) < BigInt.asIntN(64, 65536n) ? BigInt.asUintN(64, BigInt.asUintN(64, 10n * exp_num) + BigInt.asUintN(64, BigInt(digit))) : exp_num);
        const _s = _bind$2._0;
        const _exp_num = _bind$2._1;
        return neg_exp ? { _0: _s, _1: BigInt.asUintN(64, -_exp_num) } : { _0: _s, _1: _exp_num };
      } else {
        break _L$2;
      }
    } else {
      break _L$2;
    }
  }
  return undefined;
}
function _M0FPC28internal7strconv13parse__number(s) {
  let s$2;
  let negative;
  _L: {
    let rest;
    _L$2: {
      if ((s.end - s.start | 0) >= 1) {
        const _x = s.str.charCodeAt(s.start);
        switch (_x) {
          case 45: {
            const _x$2 = new _M0TPC16string10StringView(s.str, s.start + 1 | 0, s.end);
            s$2 = _x$2;
            negative = true;
            break _L;
          }
          case 43: {
            const _x$3 = new _M0TPC16string10StringView(s.str, s.start + 1 | 0, s.end);
            rest = _x$3;
            break _L$2;
          }
          default: {
            rest = s;
            break _L$2;
          }
        }
      } else {
        rest = s;
        break _L$2;
      }
    }
    s$2 = rest;
    negative = false;
    break _L;
  }
  if ((s$2.end - s$2.start | 0) === 0) {
    return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(undefined);
  }
  const _bind = _M0FPC28internal7strconv13parse__digits(s$2, 0n);
  const _s = _bind._0;
  const _mantissa = _bind._1;
  const _consumed = _bind._2;
  let mantissa = _mantissa;
  let s$3 = _s;
  let n_digits = _consumed;
  let n_after_dot = 0;
  let exponent = 0n;
  const _bind$2 = s$3;
  if ((_bind$2.end - _bind$2.start | 0) >= 1) {
    const _x = _bind$2.str.charCodeAt(_bind$2.start);
    if (_x === 46) {
      const _x$2 = new _M0TPC16string10StringView(_bind$2.str, _bind$2.start + 1 | 0, _bind$2.end);
      s$3 = _x$2;
      const _bind$3 = _M0FPC28internal7strconv13parse__digits(s$3, mantissa);
      const _new_s = _bind$3._0;
      const _new_mantissa = _bind$3._1;
      const _consumed_digit = _bind$3._2;
      s$3 = _new_s;
      mantissa = _new_mantissa;
      n_after_dot = _consumed_digit;
      exponent = BigInt.asUintN(64, -BigInt.asUintN(64, BigInt(n_after_dot)));
    }
  }
  n_digits = n_digits + n_after_dot | 0;
  if (n_digits === 0) {
    return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(undefined);
  }
  let rest;
  _L$2: {
    _L$3: {
      const _bind$3 = s$3;
      if ((_bind$3.end - _bind$3.start | 0) >= 1) {
        const _x = _bind$3.str.charCodeAt(_bind$3.start);
        switch (_x) {
          case 101: {
            const _x$2 = new _M0TPC16string10StringView(_bind$3.str, _bind$3.start + 1 | 0, _bind$3.end);
            rest = _x$2;
            break _L$3;
          }
          case 69: {
            const _x$3 = new _M0TPC16string10StringView(_bind$3.str, _bind$3.start + 1 | 0, _bind$3.end);
            rest = _x$3;
            break _L$3;
          }
        }
      }
      break _L$2;
    }
    const _bind$3 = _M0FPC28internal7strconv17parse__scientific(rest);
    let _bind$4;
    if (_bind$3 === undefined) {
      return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(undefined);
    } else {
      const _Some = _bind$3;
      _bind$4 = _Some;
    }
    const _new_s = _bind$4._0;
    const _exp_number = _bind$4._1;
    s$3 = _new_s;
    exponent = BigInt.asUintN(64, exponent + _exp_number);
  }
  const _bind$3 = s$3;
  if ((_bind$3.end - _bind$3.start | 0) === 0) {
    if (n_digits <= 19) {
      return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(new _M0TPC28internal7strconv6Number(exponent, mantissa, negative, false));
    }
    n_digits = n_digits - 19 | 0;
    let many_digits = false;
    let _tmp = s;
    while (true) {
      const s$4 = _tmp;
      _L$3: {
        let rest$2;
        let ch;
        _L$4: {
          if ((s$4.end - s$4.start | 0) >= 1) {
            const _x = s$4.str.charCodeAt(s$4.start);
            switch (_x) {
              case 48: {
                const _x$2 = new _M0TPC16string10StringView(s$4.str, s$4.start + 1 | 0, s$4.end);
                rest$2 = _x$2;
                ch = _x;
                break _L$4;
              }
              case 46: {
                const _x$3 = new _M0TPC16string10StringView(s$4.str, s$4.start + 1 | 0, s$4.end);
                rest$2 = _x$3;
                ch = _x;
                break _L$4;
              }
              default: {
                break _L$3;
              }
            }
          } else {
            break _L$3;
          }
        }
        n_digits = n_digits - ((ch - 46 | 0) / 2 | 0) | 0;
        _tmp = rest$2;
        continue;
      }
      break;
    }
    let mantissa$2 = mantissa;
    if (n_digits > 0) {
      many_digits = true;
      mantissa$2 = 0n;
      const _bind$4 = _M0FPC28internal7strconv20try__parse__19digits(s, mantissa$2);
      const _s$2 = _bind$4._0;
      const _new_mantissa = _bind$4._1;
      const _consumed_digit = _bind$4._2;
      mantissa$2 = _new_mantissa;
      let _tmp$2;
      if (BigInt.asUintN(64, mantissa$2) >= BigInt.asUintN(64, _M0FPC28internal7strconv17min__19digit__int)) {
        _tmp$2 = _consumed_digit;
      } else {
        if (_M0MPC16string6String24char__length__ge_2einner(_s$2.str, 1, _s$2.start, _s$2.end)) {
          const _tmp$3 = _s$2.str;
          const _bind$5 = _M0MPC16string6String29offset__of__nth__char_2einner(_s$2.str, 1, _s$2.start, _s$2.end);
          let _tmp$4;
          if (_bind$5 === undefined) {
            _tmp$4 = _s$2.end;
          } else {
            const _Some = _bind$5;
            _tmp$4 = _Some;
          }
          const _x = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _s$2.end);
          const _bind$6 = _M0FPC28internal7strconv20try__parse__19digits(_x, mantissa$2);
          const _new_mantissa$2 = _bind$6._1;
          const _consumed_digit$2 = _bind$6._2;
          mantissa$2 = _new_mantissa$2;
          _tmp$2 = _consumed_digit$2;
        } else {
          return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(undefined);
        }
      }
      exponent = BigInt.asUintN(64, BigInt(_tmp$2));
      exponent = BigInt.asUintN(64, exponent + _M0FPC28internal7strconv13parse__numberN11exp__numberS291);
    }
    return new _M0DTPC16result6ResultGORPC28internal7strconv6NumberRPC15error5ErrorE2Ok(new _M0TPC28internal7strconv6Number(exponent, mantissa$2, negative, many_digits));
  } else {
    return _M0FPC28internal7strconv11syntax__errGORPC28internal7strconv6NumberE();
  }
}
function _M0FPC28internal7strconv15parse__inf__nan(rest) {
  let pos;
  let rest$2;
  _L: {
    let rest$3;
    _L$2: {
      if ((rest.end - rest.start | 0) >= 1) {
        const _x = rest.str.charCodeAt(rest.start);
        switch (_x) {
          case 45: {
            const _x$2 = new _M0TPC16string10StringView(rest.str, rest.start + 1 | 0, rest.end);
            pos = false;
            rest$2 = _x$2;
            break _L;
          }
          case 43: {
            const _x$3 = new _M0TPC16string10StringView(rest.str, rest.start + 1 | 0, rest.end);
            rest$3 = _x$3;
            break _L$2;
          }
          default: {
            rest$3 = rest;
            break _L$2;
          }
        }
      } else {
        rest$3 = rest;
        break _L$2;
      }
    }
    pos = true;
    rest$2 = rest$3;
    break _L;
  }
  let _cursor_251 = 0;
  const _input_end_253 = rest$2.end - rest$2.start | 0;
  const _start_252 = _cursor_251;
  let _accept_state_254 = -1;
  let _match_end_255 = -1;
  let _state_256 = 2;
  while (true) {
    if (_state_256 !== 14) {
      if (_state_256 < 2) {
        _accept_state_254 = _state_256;
        _match_end_255 = _cursor_251;
      }
      const _tmp = Math.imul(_state_256, 8) | 0;
      let _next_char_259;
      if (_cursor_251 < _input_end_253) {
        const _char_258 = rest$2.str.charCodeAt(rest$2.start + _cursor_251 | 0);
        _cursor_251 = _cursor_251 + 1 | 0;
        _next_char_259 = _char_258;
      } else {
        _next_char_259 = -1;
      }
      const _p = _tmp + (_next_char_259 < 90 ? (_next_char_259 < 73 ? (_next_char_259 < 66 ? (_next_char_259 < 0 ? 0 : _next_char_259 > 64 ? 1 : 7) : _next_char_259 > 69 ? (_next_char_259 < 71 ? 2 : 7) : 7) : _next_char_259 > 73 ? (_next_char_259 < 84 ? (_next_char_259 < 78 ? 7 : _next_char_259 > 78 ? 7 : 4) : _next_char_259 > 84 ? (_next_char_259 < 89 ? 7 : 6) : 5) : 3) : _next_char_259 > 96 ? (_next_char_259 < 110 ? (_next_char_259 < 103 ? (_next_char_259 < 98 ? 1 : _next_char_259 > 101 ? 2 : 7) : _next_char_259 > 104 ? (_next_char_259 < 106 ? 3 : 7) : 7) : _next_char_259 > 110 ? (_next_char_259 < 117 ? (_next_char_259 < 116 ? 7 : 5) : _next_char_259 > 120 ? (_next_char_259 < 122 ? 6 : 7) : 7) : 4) : 7) | 0;
      _state_256 = _M0FPC28internal7strconv15parse__inf__nanN25_2atransition__table__260S268[_p];
      continue;
    } else {
      break;
    }
  }
  const _bind = _accept_state_254;
  switch (_bind) {
    case 0: {
      _cursor_251 = _match_end_255;
      return new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok(_M0FPC16double14not__a__number);
    }
    case 1: {
      _cursor_251 = _match_end_255;
      return pos ? new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok(_M0FPC16double8infinity) : new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok(_M0FPC16double13neg__infinity);
    }
    default: {
      _cursor_251 = _start_252;
      return _M0FPC28internal7strconv11syntax__errGdE();
    }
  }
}
function _M0FPC28internal7strconv12checked__mul(a, b) {
  if (BigInt.asUintN(64, a) === BigInt.asUintN(64, 0n) || BigInt.asUintN(64, b) === BigInt.asUintN(64, 0n)) {
    return _M0FPC28internal7strconv12checked__mulN6constrS1083;
  }
  if (BigInt.asUintN(64, a) === BigInt.asUintN(64, 1n)) {
    return b;
  }
  if (BigInt.asUintN(64, b) === BigInt.asUintN(64, 1n)) {
    return a;
  }
  if ($i64_clz(b) === 0 || $i64_clz(a) === 0) {
    return undefined;
  }
  if (b === 0n) {
    $panic();
  }
  const quotient = BigInt.asUintN(64, BigInt.asUintN(64, 18446744073709551615n) / BigInt.asUintN(64, b));
  if (BigInt.asUintN(64, a) > BigInt.asUintN(64, quotient)) {
    return undefined;
  }
  return BigInt.asUintN(64, a * b);
}
function _M0FPC28internal7strconv17check__underscore(str) {
  if (_M0MPC16string10StringView20contains__code__unit(str, 95)) {
    let rest;
    if ((str.end - str.start | 0) >= 1) {
      const _x = str.str.charCodeAt(str.start);
      switch (_x) {
        case 43: {
          const _x$2 = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
          rest = _x$2;
          break;
        }
        case 45: {
          const _x$3 = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
          rest = _x$3;
          break;
        }
        default: {
          rest = str;
        }
      }
    } else {
      rest = str;
    }
    let rest$2;
    let allow_underscore;
    let hex;
    _L: {
      let _cursor_169 = 0;
      const _input_end_171 = rest.end - rest.start | 0;
      const _start_170 = _cursor_169;
      let _accept_state_172 = -1;
      let _match_end_173 = -1;
      let _state_174 = 3;
      while (true) {
        if (_state_174 !== 5) {
          if (_state_174 < 3) {
            _accept_state_172 = _state_174;
            _match_end_173 = _cursor_169;
          }
          const _tmp = Math.imul(_state_174, 5) | 0;
          let _next_char_177;
          if (_cursor_169 < _input_end_171) {
            const _char_176 = rest.str.charCodeAt(rest.start + _cursor_169 | 0);
            _cursor_169 = _cursor_169 + 1 | 0;
            _next_char_177 = _char_176;
          } else {
            _next_char_177 = -1;
          }
          const _p = _tmp + (_next_char_177 < 88 ? (_next_char_177 < 66 ? (_next_char_177 < 48 ? 4 : _next_char_177 > 48 ? 4 : 0) : _next_char_177 > 66 ? (_next_char_177 < 79 ? 4 : _next_char_177 > 79 ? 4 : 2) : 1) : _next_char_177 > 88 ? (_next_char_177 < 111 ? (_next_char_177 < 98 ? 4 : _next_char_177 > 98 ? 4 : 1) : _next_char_177 > 111 ? (_next_char_177 < 120 ? 4 : _next_char_177 > 120 ? 4 : 3) : 2) : 3) | 0;
          _state_174 = _M0FPC28internal7strconv17check__underscoreN25_2atransition__table__178S186[_p];
          continue;
        } else {
          break;
        }
      }
      const _bind = _accept_state_172;
      switch (_bind) {
        case 0: {
          _cursor_169 = _match_end_173;
          const rest$3 = _M0MPC16string10StringView12view_2einner(rest, _match_end_173, _input_end_171);
          rest$2 = rest$3;
          allow_underscore = true;
          hex = false;
          break _L;
        }
        case 1: {
          _cursor_169 = _match_end_173;
          const rest$4 = _M0MPC16string10StringView12view_2einner(rest, _match_end_173, _input_end_171);
          rest$2 = rest$4;
          allow_underscore = true;
          hex = false;
          break _L;
        }
        case 2: {
          _cursor_169 = _match_end_173;
          const rest$5 = _M0MPC16string10StringView12view_2einner(rest, _match_end_173, _input_end_171);
          rest$2 = rest$5;
          allow_underscore = true;
          hex = true;
          break _L;
        }
        default: {
          _cursor_169 = _start_170;
          rest$2 = rest;
          allow_underscore = false;
          hex = false;
          break _L;
        }
      }
    }
    let _tmp = rest$2;
    let _tmp$2 = allow_underscore;
    let _tmp$3 = false;
    while (true) {
      const rest$3 = _tmp;
      const allow_underscore$2 = _tmp$2;
      const follow_underscore = _tmp$3;
      let rest$4;
      _L$2: {
        _L$3: {
          let rest$5;
          _L$4: {
            _L$5: {
              let rest$6;
              _L$6: {
                let rest$7;
                _L$7: {
                  if ((rest$3.end - rest$3.start | 0) === 0) {
                    return true;
                  } else {
                    if ((rest$3.end - rest$3.start | 0) === 1) {
                      const _x = rest$3.str.charCodeAt(rest$3.start);
                      if (_x === 95) {
                        return false;
                      } else {
                        if (_x >= 48 && _x <= 57) {
                          const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                          rest$7 = _x$2;
                          break _L$7;
                        } else {
                          if (_x >= 97 && _x <= 102) {
                            const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                            if (hex) {
                              rest$6 = _x$2;
                              break _L$6;
                            } else {
                              if (_x === 101) {
                                if (follow_underscore === true) {
                                  break _L$5;
                                } else {
                                  rest$5 = _x$2;
                                  break _L$4;
                                }
                              } else {
                                if (follow_underscore === true) {
                                  break _L$3;
                                } else {
                                  rest$4 = _x$2;
                                  break _L$2;
                                }
                              }
                            }
                          } else {
                            if (_x >= 65 && _x <= 70) {
                              const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                              if (hex) {
                                rest$6 = _x$2;
                                break _L$6;
                              } else {
                                if (_x === 69) {
                                  if (follow_underscore === true) {
                                    break _L$5;
                                  } else {
                                    rest$5 = _x$2;
                                    break _L$4;
                                  }
                                } else {
                                  if (follow_underscore === true) {
                                    break _L$3;
                                  } else {
                                    rest$4 = _x$2;
                                    break _L$2;
                                  }
                                }
                              }
                            } else {
                              if (_x === 46) {
                                if (follow_underscore === true) {
                                  break _L$5;
                                } else {
                                  const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                  rest$5 = _x$2;
                                  break _L$4;
                                }
                              } else {
                                if (_x === 43) {
                                  if (follow_underscore === true) {
                                    break _L$5;
                                  } else {
                                    const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                    rest$5 = _x$2;
                                    break _L$4;
                                  }
                                } else {
                                  if (_x === 45) {
                                    if (follow_underscore === true) {
                                      break _L$5;
                                    } else {
                                      const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                      rest$5 = _x$2;
                                      break _L$4;
                                    }
                                  } else {
                                    if (follow_underscore === true) {
                                      break _L$3;
                                    } else {
                                      const _tmp$4 = rest$3.str;
                                      const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(rest$3.str, 1, rest$3.start, rest$3.end);
                                      let _tmp$5;
                                      if (_bind === undefined) {
                                        _tmp$5 = rest$3.end;
                                      } else {
                                        const _Some = _bind;
                                        _tmp$5 = _Some;
                                      }
                                      const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, rest$3.end);
                                      rest$4 = _x$2;
                                      break _L$2;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      const _x = rest$3.str.charCodeAt(rest$3.start);
                      if (_x === 95) {
                        if (allow_underscore$2 === false) {
                          return false;
                        } else {
                          const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                          _tmp = _x$2;
                          _tmp$2 = false;
                          _tmp$3 = true;
                          continue;
                        }
                      } else {
                        if (_x >= 48 && _x <= 57) {
                          const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                          rest$7 = _x$2;
                          break _L$7;
                        } else {
                          if (_x >= 97 && _x <= 102) {
                            const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                            if (hex) {
                              rest$6 = _x$2;
                              break _L$6;
                            } else {
                              if (_x === 101) {
                                if (follow_underscore === true) {
                                  break _L$5;
                                } else {
                                  rest$5 = _x$2;
                                  break _L$4;
                                }
                              } else {
                                if (follow_underscore === true) {
                                  break _L$3;
                                } else {
                                  rest$4 = _x$2;
                                  break _L$2;
                                }
                              }
                            }
                          } else {
                            if (_x >= 65 && _x <= 70) {
                              const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                              if (hex) {
                                rest$6 = _x$2;
                                break _L$6;
                              } else {
                                if (_x === 69) {
                                  if (follow_underscore === true) {
                                    break _L$5;
                                  } else {
                                    rest$5 = _x$2;
                                    break _L$4;
                                  }
                                } else {
                                  if (follow_underscore === true) {
                                    break _L$3;
                                  } else {
                                    rest$4 = _x$2;
                                    break _L$2;
                                  }
                                }
                              }
                            } else {
                              if (_x === 46) {
                                if (follow_underscore === true) {
                                  break _L$5;
                                } else {
                                  const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                  rest$5 = _x$2;
                                  break _L$4;
                                }
                              } else {
                                if (_x === 43) {
                                  if (follow_underscore === true) {
                                    break _L$5;
                                  } else {
                                    const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                    rest$5 = _x$2;
                                    break _L$4;
                                  }
                                } else {
                                  if (_x === 45) {
                                    if (follow_underscore === true) {
                                      break _L$5;
                                    } else {
                                      const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                                      rest$5 = _x$2;
                                      break _L$4;
                                    }
                                  } else {
                                    if (follow_underscore === true) {
                                      break _L$3;
                                    } else {
                                      const _tmp$4 = rest$3.str;
                                      const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(rest$3.str, 1, rest$3.start, rest$3.end);
                                      let _tmp$5;
                                      if (_bind === undefined) {
                                        _tmp$5 = rest$3.end;
                                      } else {
                                        const _Some = _bind;
                                        _tmp$5 = _Some;
                                      }
                                      const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, rest$3.end);
                                      rest$4 = _x$2;
                                      break _L$2;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
                _tmp = rest$7;
                _tmp$2 = true;
                _tmp$3 = false;
                continue;
              }
              _tmp = rest$6;
              _tmp$2 = true;
              _tmp$3 = false;
              continue;
            }
            return false;
          }
          _tmp = rest$5;
          _tmp$2 = false;
          _tmp$3 = false;
          continue;
        }
        return false;
      }
      _tmp = rest$4;
      _tmp$2 = false;
      _tmp$3 = false;
      continue;
    }
  } else {
    return true;
  }
}
function _M0MPC28internal7strconv7Decimal9new__priv() {
  return new _M0TPC28internal7strconv7Decimal($makebytes(800, 0), 0, 0, false, false);
}
function _M0MPC28internal7strconv7Decimal4trim(self) {
  while (true) {
    let _tmp;
    if (self.digits_num > 0) {
      const _tmp$2 = self.digits;
      const _tmp$3 = self.digits_num - 1 | 0;
      $bound_check(_tmp$2, _tmp$3);
      const _p = _tmp$2[_tmp$3];
      const _p$2 = 0;
      _tmp = _p === _p$2;
    } else {
      _tmp = false;
    }
    if (_tmp) {
      self.digits_num = self.digits_num - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (self.digits_num === 0) {
    self.decimal_point = 0;
    return;
  } else {
    return;
  }
}
function _M0FPC28internal7strconv26parse__decimal__from__view(str) {
  const d = _M0MPC28internal7strconv7Decimal9new__priv();
  let has_dp = false;
  let has_digits = false;
  let rest;
  _L: {
    _L$2: {
      if ((str.end - str.start | 0) >= 1) {
        const _x = str.str.charCodeAt(str.start);
        switch (_x) {
          case 45: {
            const _x$2 = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
            d.negative = true;
            rest = _x$2;
            break;
          }
          case 43: {
            rest = new _M0TPC16string10StringView(str.str, str.start + 1 | 0, str.end);
            break;
          }
          default: {
            break _L$2;
          }
        }
      } else {
        break _L$2;
      }
      break _L;
    }
    rest = str;
  }
  let rest$2;
  let _tmp = rest;
  while (true) {
    const rest$3 = _tmp;
    let rest$4;
    _L$2: {
      _L$3: {
        if ((rest$3.end - rest$3.start | 0) >= 1) {
          const _x = rest$3.str.charCodeAt(rest$3.start);
          if (_x === 95) {
            const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
            _tmp = _x$2;
            continue;
          } else {
            if (_x === 46) {
              const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
              if (!has_dp) {
                has_dp = true;
                d.decimal_point = d.digits_num;
                _tmp = _x$2;
                continue;
              } else {
                const _bind = _M0FPC28internal7strconv11syntax__errGuE();
                if (_bind.$tag === 1) {
                  const _ok = _bind;
                  _ok._0;
                } else {
                  return _bind;
                }
              }
            } else {
              if (_x >= 48 && _x <= 57) {
                const _x$2 = new _M0TPC16string10StringView(rest$3.str, rest$3.start + 1 | 0, rest$3.end);
                has_digits = true;
                if (_x === 48 && d.digits_num === 0) {
                  d.decimal_point = d.decimal_point - 1 | 0;
                  _tmp = _x$2;
                  continue;
                }
                if (d.digits_num < d.digits.length) {
                  const _tmp$2 = d.digits;
                  const _tmp$3 = d.digits_num;
                  $bound_check(_tmp$2, _tmp$3);
                  _tmp$2[_tmp$3] = (_x - 48 | 0) & 255;
                  d.digits_num = d.digits_num + 1 | 0;
                } else {
                  if (_x !== 48) {
                    d.truncated = true;
                  }
                }
                _tmp = _x$2;
                continue;
              } else {
                rest$4 = rest$3;
                break _L$3;
              }
            }
          }
        } else {
          rest$4 = rest$3;
          break _L$3;
        }
        break _L$2;
      }
      rest$2 = rest$4;
      break;
    }
    continue;
  }
  if (has_digits) {
    if (!has_dp) {
      d.decimal_point = d.digits_num;
    }
    let rest$3;
    let rest$4;
    _L$2: {
      _L$3: {
        if ((rest$2.end - rest$2.start | 0) >= 1) {
          const _x = rest$2.str.charCodeAt(rest$2.start);
          switch (_x) {
            case 101: {
              const _x$2 = new _M0TPC16string10StringView(rest$2.str, rest$2.start + 1 | 0, rest$2.end);
              rest$4 = _x$2;
              break _L$3;
            }
            case 69: {
              const _x$3 = new _M0TPC16string10StringView(rest$2.str, rest$2.start + 1 | 0, rest$2.end);
              rest$4 = _x$3;
              break _L$3;
            }
            default: {
              rest$3 = rest$2;
            }
          }
        } else {
          rest$3 = rest$2;
        }
        break _L$2;
      }
      let exp_sign = 1;
      let rest$5;
      if ((rest$4.end - rest$4.start | 0) >= 1) {
        const _x = rest$4.str.charCodeAt(rest$4.start);
        switch (_x) {
          case 43: {
            rest$5 = new _M0TPC16string10StringView(rest$4.str, rest$4.start + 1 | 0, rest$4.end);
            break;
          }
          case 45: {
            const _x$2 = new _M0TPC16string10StringView(rest$4.str, rest$4.start + 1 | 0, rest$4.end);
            exp_sign = -1;
            rest$5 = _x$2;
            break;
          }
          default: {
            rest$5 = rest$4;
          }
        }
      } else {
        rest$5 = rest$4;
      }
      _L$4: {
        _L$5: {
          if ((rest$5.end - rest$5.start | 0) >= 1) {
            const _x = rest$5.str.charCodeAt(rest$5.start);
            if (_x >= 48 && _x <= 57) {
              const exp_limit = exp_sign > 0 ? (d.decimal_point < 311 ? 311 - d.decimal_point | 0 : 0) : d.decimal_point > -331 ? d.decimal_point + 331 | 0 : 0;
              let exp = 0;
              let rest$6;
              let _tmp$2 = rest$5;
              while (true) {
                const rest$7 = _tmp$2;
                let rest$8;
                _L$6: {
                  if ((rest$7.end - rest$7.start | 0) >= 1) {
                    const _x$2 = rest$7.str.charCodeAt(rest$7.start);
                    if (_x$2 === 95) {
                      const _x$3 = new _M0TPC16string10StringView(rest$7.str, rest$7.start + 1 | 0, rest$7.end);
                      _tmp$2 = _x$3;
                      continue;
                    } else {
                      if (_x$2 >= 48 && _x$2 <= 57) {
                        const _x$3 = new _M0TPC16string10StringView(rest$7.str, rest$7.start + 1 | 0, rest$7.end);
                        if (exp < exp_limit) {
                          exp = (Math.imul(exp, 10) | 0) + (_x$2 - 48 | 0) | 0;
                          if (exp > exp_limit) {
                            exp = exp_limit;
                          }
                        }
                        _tmp$2 = _x$3;
                        continue;
                      } else {
                        rest$8 = rest$7;
                        break _L$6;
                      }
                    }
                  } else {
                    rest$8 = rest$7;
                    break _L$6;
                  }
                }
                rest$6 = rest$8;
                break;
              }
              d.decimal_point = d.decimal_point + (Math.imul(exp_sign, exp) | 0) | 0;
              rest$3 = rest$6;
            } else {
              break _L$5;
            }
          } else {
            break _L$5;
          }
          break _L$4;
        }
        const _bind = _M0FPC28internal7strconv11syntax__errGRPC16string10StringViewE();
        if (_bind.$tag === 1) {
          const _ok = _bind;
          rest$3 = _ok._0;
        } else {
          return _bind;
        }
      }
    }
    if ((rest$3.end - rest$3.start | 0) === 0) {
      _M0MPC28internal7strconv7Decimal4trim(d);
      return new _M0DTPC16result6ResultGRPC28internal7strconv7DecimalRPC15error5ErrorE2Ok(d);
    } else {
      return _M0FPC28internal7strconv11syntax__errGRPC16string10StringViewE();
    }
  } else {
    return _M0FPC28internal7strconv11syntax__errGRPC16string10StringViewE();
  }
}
function _M0FPC28internal7strconv20parse__decimal__priv(str) {
  return _M0FPC28internal7strconv26parse__decimal__from__view(str);
}
function _M0FPC28internal7strconv14assemble__bits(mantissa, exponent, negative) {
  const biased_exp = exponent - _M0FPC28internal7strconv12double__info.bias | 0;
  let bits = BigInt.asUintN(64, mantissa & BigInt.asUintN(64, BigInt.asUintN(64, 1n << BigInt(_M0FPC28internal7strconv12double__info.mantissa_bits & 63)) - 1n));
  const exp_bits = BigInt.asUintN(64, BigInt(biased_exp & ((1 << _M0FPC28internal7strconv12double__info.exponent_bits) - 1 | 0)));
  bits = BigInt.asUintN(64, bits | BigInt.asUintN(64, exp_bits << BigInt(_M0FPC28internal7strconv12double__info.mantissa_bits & 63)));
  if (negative) {
    bits = BigInt.asUintN(64, bits | BigInt.asUintN(64, BigInt.asUintN(64, 1n << BigInt(_M0FPC28internal7strconv12double__info.mantissa_bits & 63)) << BigInt(_M0FPC28internal7strconv12double__info.exponent_bits & 63)));
  }
  return bits;
}
function _M0MPC28internal7strconv7Decimal17should__round__up(self, d) {
  if (d < 0 || d >= self.digits_num) {
    return false;
  }
  let _tmp;
  const _tmp$2 = self.digits;
  $bound_check(_tmp$2, d);
  if (_tmp$2[d] === 5) {
    _tmp = (d + 1 | 0) === self.digits_num;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    if (self.truncated) {
      return true;
    }
    let _tmp$3;
    if (d > 0) {
      const _tmp$4 = self.digits;
      const _tmp$5 = d - 1 | 0;
      $bound_check(_tmp$4, _tmp$5);
      _tmp$3 = (_tmp$4[_tmp$5] % 2 | 0) !== 0;
    } else {
      _tmp$3 = false;
    }
    return _tmp$3;
  }
  const _tmp$3 = self.digits;
  $bound_check(_tmp$3, d);
  return _tmp$3[d] >= 5;
}
function _M0MPC28internal7strconv7Decimal16rounded__integer(self) {
  if (self.decimal_point > 20) {
    return 18446744073709551615n;
  }
  let _tmp = 0n;
  let _tmp$2 = 0;
  while (true) {
    const n = _tmp;
    const i = _tmp$2;
    if (i < self.decimal_point && i < self.digits_num) {
      const _tmp$3 = BigInt.asUintN(64, n * 10n);
      const _tmp$4 = self.digits;
      $bound_check(_tmp$4, i);
      const _p = _tmp$4[i];
      _tmp = BigInt.asUintN(64, _tmp$3 + BigInt.asUintN(64, BigInt(_p)));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      let n$2;
      let _tmp$3 = n;
      let _tmp$4 = i;
      while (true) {
        const n$3 = _tmp$3;
        const i$2 = _tmp$4;
        if (i$2 < self.decimal_point) {
          _tmp$3 = BigInt.asUintN(64, n$3 * 10n);
          _tmp$4 = i$2 + 1 | 0;
          continue;
        } else {
          n$2 = n$3;
          break;
        }
      }
      return _M0MPC28internal7strconv7Decimal17should__round__up(self, self.decimal_point) ? BigInt.asUintN(64, n$2 + 1n) : n$2;
    }
  }
}
function _M0MPC28internal7strconv7Decimal11new__digits(self, s) {
  $bound_check(_M0FPC28internal7strconv19left__shift__cheats, s);
  const new_digits = _M0FPC28internal7strconv19left__shift__cheats[s]._0;
  $bound_check(_M0FPC28internal7strconv19left__shift__cheats, s);
  const cheat_num = _M0FPC28internal7strconv19left__shift__cheats[s]._1;
  const _bind = cheat_num.length;
  let less;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      const code_unit = cheat_num.charCodeAt(i);
      if (i >= self.digits_num) {
        less = true;
        break;
      }
      const d = code_unit - 48 | 0;
      const _tmp$2 = self.digits;
      $bound_check(_tmp$2, i);
      if (_tmp$2[i] !== d) {
        const _tmp$3 = self.digits;
        $bound_check(_tmp$3, i);
        less = _tmp$3[i] < d;
        break;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      less = false;
      break;
    }
  }
  return less ? new_digits - 1 | 0 : new_digits;
}
function _M0MPC28internal7strconv7Decimal11left__shift(self, s) {
  const new_digits = _M0MPC28internal7strconv7Decimal11new__digits(self, s);
  let read_index = self.digits_num;
  let write_index = self.digits_num + new_digits | 0;
  let acc = 0n;
  read_index = read_index - 1 | 0;
  while (true) {
    if (read_index >= 0) {
      const _tmp = self.digits;
      const _tmp$2 = read_index;
      $bound_check(_tmp, _tmp$2);
      const _p = _tmp[_tmp$2];
      const d = BigInt.asUintN(64, BigInt(_p));
      acc = BigInt.asUintN(64, acc + BigInt.asUintN(64, d << BigInt(s & 63)));
      if (10n === 0n) {
        $panic();
      }
      const quo = BigInt.asUintN(64, BigInt.asIntN(64, acc) / BigInt.asIntN(64, 10n));
      const rem = Number(BigInt.asIntN(32, BigInt.asUintN(64, acc - BigInt.asUintN(64, quo * 10n)))) | 0;
      write_index = write_index - 1 | 0;
      if (write_index < self.digits.length) {
        const _tmp$3 = self.digits;
        const _tmp$4 = write_index;
        $bound_check(_tmp$3, _tmp$4);
        _tmp$3[_tmp$4] = rem & 255;
      } else {
        if (rem !== 0) {
          self.truncated = true;
        }
      }
      acc = quo;
      read_index = read_index - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    if (BigInt.asIntN(64, acc) > BigInt.asIntN(64, 0n)) {
      if (10n === 0n) {
        $panic();
      }
      const quo = BigInt.asUintN(64, BigInt.asIntN(64, acc) / BigInt.asIntN(64, 10n));
      const rem = Number(BigInt.asIntN(32, BigInt.asUintN(64, acc - BigInt.asUintN(64, 10n * quo)))) | 0;
      write_index = write_index - 1 | 0;
      if (write_index < self.digits.length) {
        const _tmp = self.digits;
        const _tmp$2 = write_index;
        $bound_check(_tmp, _tmp$2);
        _tmp[_tmp$2] = rem & 255;
      } else {
        if (rem !== 0) {
          self.truncated = true;
        }
      }
      acc = quo;
      continue;
    } else {
      break;
    }
  }
  self.digits_num = self.digits_num + new_digits | 0;
  if (self.digits_num > self.digits.length) {
    self.digits_num = self.digits.length;
  }
  self.decimal_point = self.decimal_point + new_digits | 0;
  _M0MPC28internal7strconv7Decimal4trim(self);
}
function _M0MPC28internal7strconv7Decimal12right__shift(self, s) {
  let read_index = 0;
  let write_index = 0;
  let acc = 0n;
  while (true) {
    if (BigInt.asUintN(64, BigInt.asUintN(64, BigInt.asUintN(64, acc) >> BigInt(s & 63))) === BigInt.asUintN(64, 0n)) {
      if (read_index >= self.digits_num) {
        while (true) {
          if (BigInt.asUintN(64, BigInt.asUintN(64, BigInt.asUintN(64, acc) >> BigInt(s & 63))) === BigInt.asUintN(64, 0n)) {
            acc = BigInt.asUintN(64, acc * 10n);
            read_index = read_index + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break;
      }
      const _tmp = self.digits;
      const _tmp$2 = read_index;
      $bound_check(_tmp, _tmp$2);
      const d = _tmp[_tmp$2];
      acc = BigInt.asUintN(64, BigInt.asUintN(64, acc * 10n) + BigInt.asUintN(64, BigInt(d)));
      read_index = read_index + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.decimal_point = self.decimal_point - (read_index - 1 | 0) | 0;
  const mask = BigInt.asUintN(64, BigInt.asUintN(64, 1n << BigInt(s & 63)) - 1n);
  while (true) {
    if (read_index < self.digits_num) {
      const out = BigInt.asUintN(64, BigInt.asUintN(64, acc) >> BigInt(s & 63));
      const _tmp = self.digits;
      const _tmp$2 = write_index;
      $bound_check(_tmp, _tmp$2);
      _tmp[_tmp$2] = (Number(BigInt.asIntN(32, out)) | 0) & 255;
      write_index = write_index + 1 | 0;
      acc = BigInt.asUintN(64, acc & mask);
      const _tmp$3 = self.digits;
      const _tmp$4 = read_index;
      $bound_check(_tmp$3, _tmp$4);
      const d = _tmp$3[_tmp$4];
      acc = BigInt.asUintN(64, BigInt.asUintN(64, acc * 10n) + BigInt.asUintN(64, BigInt(d)));
      read_index = read_index + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    if (BigInt.asUintN(64, acc) > BigInt.asUintN(64, 0n)) {
      const out = BigInt.asUintN(64, BigInt.asUintN(64, acc) >> BigInt(s & 63));
      if (write_index < self.digits.length) {
        const _tmp = self.digits;
        const _tmp$2 = write_index;
        $bound_check(_tmp, _tmp$2);
        _tmp[_tmp$2] = (Number(BigInt.asIntN(32, out)) | 0) & 255;
        write_index = write_index + 1 | 0;
      } else {
        if (BigInt.asUintN(64, out) > BigInt.asUintN(64, 0n)) {
          self.truncated = true;
        }
      }
      acc = BigInt.asUintN(64, acc & mask);
      acc = BigInt.asUintN(64, acc * 10n);
      continue;
    } else {
      break;
    }
  }
  self.digits_num = write_index;
  _M0MPC28internal7strconv7Decimal4trim(self);
}
function _M0MPC28internal7strconv7Decimal11shift__priv(self, s) {
  if (self.digits_num === 0) {
    return undefined;
  }
  let s$2 = s;
  if (s$2 > 0) {
    while (true) {
      if (s$2 > 59) {
        _M0MPC28internal7strconv7Decimal11left__shift(self, 59);
        s$2 = s$2 - 59 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC28internal7strconv7Decimal11left__shift(self, s$2);
  }
  if (s$2 < 0) {
    while (true) {
      if (s$2 < -59) {
        _M0MPC28internal7strconv7Decimal12right__shift(self, 59);
        s$2 = s$2 + 59 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC28internal7strconv7Decimal12right__shift(self, -s$2 | 0);
    return;
  } else {
    return;
  }
}
function _M0MPC28internal7strconv7Decimal16to__double__priv(self) {
  let exponent = 0;
  let mantissa = 0n;
  if (self.digits_num === 0 || self.decimal_point < -330) {
    mantissa = 0n;
    exponent = _M0FPC28internal7strconv12double__info.bias;
    const bits = _M0FPC28internal7strconv14assemble__bits(mantissa, exponent, self.negative);
    return new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok($i64_reinterpret_f64(bits));
  }
  if (self.decimal_point > 310) {
    const _bind = _M0FPC28internal7strconv10range__errGuE();
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _ok._0;
    } else {
      return _bind;
    }
  }
  while (true) {
    if (self.decimal_point > 0) {
      let n = 0;
      if (self.decimal_point >= _M0FPC28internal7strconv6powtab.length) {
        n = 60;
      } else {
        const _p = self.decimal_point;
        $bound_check(_M0FPC28internal7strconv6powtab, _p);
        n = _M0FPC28internal7strconv6powtab[_p];
      }
      _M0MPC28internal7strconv7Decimal11shift__priv(self, -n | 0);
      exponent = exponent + n | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    let _tmp;
    if (self.decimal_point < 0) {
      _tmp = true;
    } else {
      let _tmp$2;
      if (self.decimal_point === 0) {
        const _tmp$3 = self.digits;
        $bound_check(_tmp$3, 0);
        _tmp$2 = _tmp$3[0] < 5;
      } else {
        _tmp$2 = false;
      }
      _tmp = _tmp$2;
    }
    if (_tmp) {
      let n = 0;
      if ((-self.decimal_point | 0) >= _M0FPC28internal7strconv6powtab.length) {
        n = 60;
      } else {
        const _p = -self.decimal_point | 0;
        $bound_check(_M0FPC28internal7strconv6powtab, _p);
        n = _M0FPC28internal7strconv6powtab[_p];
      }
      _M0MPC28internal7strconv7Decimal11shift__priv(self, n);
      exponent = exponent - n | 0;
      continue;
    } else {
      break;
    }
  }
  exponent = exponent - 1 | 0;
  if (exponent < (_M0FPC28internal7strconv12double__info.bias + 1 | 0)) {
    const n = (_M0FPC28internal7strconv12double__info.bias + 1 | 0) - exponent | 0;
    _M0MPC28internal7strconv7Decimal11shift__priv(self, -n | 0);
    exponent = exponent + n | 0;
  }
  if ((exponent - _M0FPC28internal7strconv12double__info.bias | 0) >= ((1 << _M0FPC28internal7strconv12double__info.exponent_bits) - 1 | 0)) {
    const _bind = _M0FPC28internal7strconv10range__errGuE();
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _ok._0;
    } else {
      return _bind;
    }
  }
  _M0MPC28internal7strconv7Decimal11shift__priv(self, _M0FPC28internal7strconv12double__info.mantissa_bits + 1 | 0);
  mantissa = _M0MPC28internal7strconv7Decimal16rounded__integer(self);
  if (BigInt.asUintN(64, mantissa) === BigInt.asUintN(64, BigInt.asUintN(64, 2n << BigInt(_M0FPC28internal7strconv12double__info.mantissa_bits & 63)))) {
    mantissa = BigInt.asUintN(64, BigInt.asIntN(64, mantissa) >> BigInt(1 & 63));
    exponent = exponent + 1 | 0;
    if ((exponent - _M0FPC28internal7strconv12double__info.bias | 0) >= ((1 << _M0FPC28internal7strconv12double__info.exponent_bits) - 1 | 0)) {
      const _bind = _M0FPC28internal7strconv10range__errGuE();
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        return _bind;
      }
    }
  }
  if (BigInt.asUintN(64, BigInt.asUintN(64, mantissa & BigInt.asUintN(64, 1n << BigInt(_M0FPC28internal7strconv12double__info.mantissa_bits & 63)))) === BigInt.asUintN(64, 0n)) {
    exponent = _M0FPC28internal7strconv12double__info.bias;
  }
  const bits = _M0FPC28internal7strconv14assemble__bits(mantissa, exponent, self.negative);
  return new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok($i64_reinterpret_f64(bits));
}
function _M0FPC28internal7strconv17pow10__fast__path(exponent) {
  const _p = exponent & 31;
  $bound_check(_M0FPC28internal7strconv5table, _p);
  return _M0FPC28internal7strconv5table[_p];
}
function _M0MPC28internal7strconv6Number14is__fast__path(self) {
  return BigInt.asIntN(64, _M0FPC28internal7strconv25min__exponent__fast__path) <= BigInt.asIntN(64, self.exponent) && (BigInt.asIntN(64, self.exponent) <= BigInt.asIntN(64, _M0FPC28internal7strconv36max__exponent__disguised__fast__path) && (BigInt.asUintN(64, self.mantissa) <= BigInt.asUintN(64, _M0FPC28internal7strconv25max__mantissa__fast__path) && !self.many_digits));
}
function _M0MPC28internal7strconv6Number15try__fast__path(self) {
  if (_M0MPC28internal7strconv6Number14is__fast__path(self)) {
    let value;
    if (BigInt.asIntN(64, self.exponent) <= BigInt.asIntN(64, _M0FPC28internal7strconv25max__exponent__fast__path)) {
      const value$2 = $f64_convert_i64_u(BigInt.asUintN(64, self.mantissa));
      value = BigInt.asIntN(64, self.exponent) < BigInt.asIntN(64, 0n) ? value$2 / _M0FPC28internal7strconv17pow10__fast__path(-(Number(BigInt.asIntN(32, self.exponent)) | 0) | 0) : value$2 * _M0FPC28internal7strconv17pow10__fast__path(Number(BigInt.asIntN(32, self.exponent)) | 0);
    } else {
      const shift = BigInt.asUintN(64, self.exponent - _M0FPC28internal7strconv25max__exponent__fast__path);
      const _tmp = self.mantissa;
      const _p = Number(BigInt.asIntN(32, shift)) | 0;
      $bound_check(_M0FPC28internal7strconv10int__pow10, _p);
      const _bind = _M0FPC28internal7strconv12checked__mul(_tmp, _M0FPC28internal7strconv10int__pow10[_p]);
      let mantissa;
      if (_bind === undefined) {
        return _M0DTPC16option6OptionGdE4None__;
      } else {
        const _Some = _bind;
        mantissa = _Some;
      }
      if (BigInt.asUintN(64, mantissa) > BigInt.asUintN(64, _M0FPC28internal7strconv25max__mantissa__fast__path)) {
        return _M0DTPC16option6OptionGdE4None__;
      }
      value = $f64_convert_i64_u(BigInt.asUintN(64, mantissa)) * _M0FPC28internal7strconv17pow10__fast__path(Number(BigInt.asIntN(32, _M0FPC28internal7strconv25max__exponent__fast__path)) | 0);
    }
    if (self.negative) {
      value = -value;
    }
    return new _M0DTPC16option6OptionGdE4Some(value);
  } else {
    return _M0DTPC16option6OptionGdE4None__;
  }
}
function _M0FPC28internal7strconv13parse__double(str) {
  if ((str.end - str.start | 0) > 0) {
    if (_M0FPC28internal7strconv17check__underscore(str)) {
      const _bind = _M0FPC28internal7strconv13parse__number(str);
      let _bind$2;
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _bind$2 = _ok._0;
      } else {
        return _bind;
      }
      if (_bind$2 === undefined) {
        return _M0FPC28internal7strconv15parse__inf__nan(str);
      } else {
        const _Some = _bind$2;
        const _num = _Some;
        const _bind$3 = _M0MPC28internal7strconv6Number15try__fast__path(_num);
        if (_bind$3.$tag === 1) {
          const _Some$2 = _bind$3;
          const _value = _Some$2._0;
          return new _M0DTPC16result6ResultGdRPC15error5ErrorE2Ok(_value);
        } else {
          const _bind$4 = _M0FPC28internal7strconv20parse__decimal__priv(str);
          let _tmp;
          if (_bind$4.$tag === 1) {
            const _ok = _bind$4;
            _tmp = _ok._0;
          } else {
            return _bind$4;
          }
          return _M0MPC28internal7strconv7Decimal16to__double__priv(_tmp);
        }
      }
    } else {
      return _M0FPC28internal7strconv11syntax__errGdE();
    }
  } else {
    return _M0FPC28internal7strconv11syntax__errGdE();
  }
}
function _M0FPC14json20offset__to__position(input, offset) {
  const _bind = _M0MPC15array9ArrayView12view_2einnerGkE(_M0MPC16string10StringView11code__units(input), 0, offset);
  const _bind$2 = _bind.end - _bind.start | 0;
  let _tmp = 0;
  let _tmp$2 = 1;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp;
    const line = _tmp$2;
    const column = _tmp$3;
    if (_ < _bind$2) {
      const code_unit = _bind.buf[_bind.start + _ | 0];
      const _p = 10;
      if (code_unit === _p) {
        _tmp = _ + 1 | 0;
        _tmp$2 = line + 1 | 0;
        _tmp$3 = 0;
        continue;
      } else {
        _tmp = _ + 1 | 0;
        _tmp$3 = column + 1 | 0;
        continue;
      }
    } else {
      return new _M0TPC14json8Position(line, column);
    }
  }
}
function _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, shift) {
  const offset = ctx.offset + shift | 0;
  const _p = _M0MPC16string10StringView9get__char(ctx.input, offset);
  const _p$2 = 65533;
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(new _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(_M0FPC14json20offset__to__position(ctx.input, offset), _p === -1 ? _p$2 : _p));
}
function _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, shift) {
  const offset = ctx.offset + shift | 0;
  const _p = _M0MPC16string10StringView9get__char(ctx.input, offset);
  const _p$2 = 65533;
  return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(new _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(_M0FPC14json20offset__to__position(ctx.input, offset), _p === -1 ? _p$2 : _p));
}
function _M0MPC14json12ParseContext21invalid__char_2einnerGiE(ctx, shift) {
  const offset = ctx.offset + shift | 0;
  const _p = _M0MPC16string10StringView9get__char(ctx.input, offset);
  const _p$2 = 65533;
  return new _M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err(new _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(_M0FPC14json20offset__to__position(ctx.input, offset), _p === -1 ? _p$2 : _p));
}
function _M0MPC14json12ParseContext21lex__skip__whitespace(ctx) {
  const end = ctx.end_offset;
  let _tmp;
  let _tmp$2 = ctx.offset;
  _L: while (true) {
    const offset = _tmp$2;
    if (offset >= end) {
      _tmp = offset;
      break;
    }
    _L$2: {
      const _bind = ctx.input;
      const _bind$2 = _bind.str.charCodeAt(_bind.start + offset | 0);
      switch (_bind$2) {
        case 32: {
          break _L$2;
        }
        case 9: {
          break _L$2;
        }
        case 13: {
          break _L$2;
        }
        case 10: {
          break _L$2;
        }
        default: {
          _tmp = offset;
          break _L;
        }
      }
    }
    _tmp$2 = offset + 1 | 0;
    continue;
  }
  ctx.offset = _tmp;
}
function _M0MPC14json12ParseContext4make(input) {
  return new _M0TPC14json12ParseContext(0, input, input.end - input.start | 0);
}
function _M0MPC14json12ParseContext19expect__ascii__char(ctx, c) {
  if (ctx.offset < ctx.end_offset) {
    const _bind = ctx.input;
    const c1 = _bind.str.charCodeAt(_bind.start + ctx.offset | 0);
    ctx.offset = ctx.offset + 1 | 0;
    return c !== c1 ? _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1) : new _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(undefined);
  } else {
    return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  }
}
function _M0FPC14json12checked__mul(a, b) {
  if (BigInt.asUintN(64, a) === BigInt.asUintN(64, 0n) || BigInt.asUintN(64, b) === BigInt.asUintN(64, 0n)) {
    return _M0FPC14json12checked__mulN6constrS1776;
  }
  if (BigInt.asUintN(64, a) === BigInt.asUintN(64, 1n)) {
    return b;
  }
  if (BigInt.asUintN(64, b) === BigInt.asUintN(64, 1n)) {
    return a;
  }
  if ($i64_clz(b) === 0 || $i64_clz(a) === 0) {
    return undefined;
  }
  if (b === 0n) {
    $panic();
  }
  const quotient = BigInt.asUintN(64, BigInt.asUintN(64, 18446744073709551615n) / BigInt.asUintN(64, b));
  return BigInt.asUintN(64, a) > BigInt.asUintN(64, quotient) ? undefined : BigInt.asUintN(64, a * b);
}
function _M0FPC14json23json__pow10__fast__path(exponent) {
  const _p = exponent & 31;
  $bound_check(_M0FPC14json12pow10__table, _p);
  return _M0FPC14json12pow10__table[_p];
}
function _M0MPC14json14JsonNumberScan17try__fast__double(self) {
  if (BigInt.asUintN(64, self.mantissa) === BigInt.asUintN(64, 0n)) {
    return self.negative ? -0 : 0;
  }
  if (self.many_digits || (BigInt.asIntN(64, self.exponent) < BigInt.asIntN(64, 18446744073709551594n) || (BigInt.asIntN(64, self.exponent) > BigInt.asIntN(64, 37n) || BigInt.asUintN(64, self.mantissa) > BigInt.asUintN(64, 9007199254740992n)))) {
    return _M0FPC16double14not__a__number;
  }
  let value;
  if (BigInt.asIntN(64, self.exponent) <= BigInt.asIntN(64, 22n)) {
    const value$2 = $f64_convert_i64_u(BigInt.asUintN(64, self.mantissa));
    value = BigInt.asIntN(64, self.exponent) < BigInt.asIntN(64, 0n) ? value$2 / _M0FPC14json23json__pow10__fast__path(-(Number(BigInt.asIntN(32, self.exponent)) | 0) | 0) : value$2 * _M0FPC14json23json__pow10__fast__path(Number(BigInt.asIntN(32, self.exponent)) | 0);
  } else {
    const shift = BigInt.asUintN(64, self.exponent - 22n);
    const _tmp = self.mantissa;
    const _p = Number(BigInt.asIntN(32, shift)) | 0;
    $bound_check(_M0FPC14json17int__pow10__table, _p);
    const _bind = _M0FPC14json12checked__mul(_tmp, _M0FPC14json17int__pow10__table[_p]);
    let mantissa;
    if (_bind === undefined) {
      return _M0FPC16double14not__a__number;
    } else {
      const _Some = _bind;
      mantissa = _Some;
    }
    if (BigInt.asUintN(64, mantissa) > BigInt.asUintN(64, 9007199254740992n)) {
      return _M0FPC16double14not__a__number;
    }
    value = $f64_convert_i64_u(BigInt.asUintN(64, mantissa)) * _M0FPC14json23json__pow10__fast__path(22);
  }
  return self.negative ? -value : value;
}
function _M0MPC14json12ParseContext17lex__integer__end(ctx, start, end) {
  const _bind = ctx.input;
  const _p = _bind.str.charCodeAt(_bind.start + start | 0);
  const _p$2 = 45;
  const negative = _p === _p$2;
  const number_start = negative ? start + 1 | 0 : start;
  let _tmp = number_start;
  let _tmp$2 = 0n;
  while (true) {
    const i = _tmp;
    const acc = _tmp$2;
    if (i >= end) {
      const value = negative ? BigInt.asUintN(64, -acc) : acc;
      const _bind$2 = $f64_convert_i64(BigInt.asIntN(64, value));
      const _bind$3 = undefined;
      return new _M0TPC14json11LexedNumber(_bind$3, _bind$2);
    }
    const _bind$2 = ctx.input;
    const digit = BigInt.asUintN(64, BigInt(_bind$2.str.charCodeAt(_bind$2.start + i | 0) - 48 | 0));
    if (10n === 0n) {
      $panic();
    }
    if (BigInt.asIntN(64, acc) > BigInt.asIntN(64, BigInt.asUintN(64, BigInt.asIntN(64, BigInt.asUintN(64, 9007199254740991n - digit)) / BigInt.asIntN(64, 10n)))) {
      const s = _M0MPC16string10StringView12view_2einner(ctx.input, start, end);
      let _tmp$3;
      if (negative) {
        const _bind$3 = s;
        _tmp$3 = new _M0TPC14json11LexedNumber(_bind$3, _M0FPC16double13neg__infinity);
      } else {
        const _bind$3 = s;
        _tmp$3 = new _M0TPC14json11LexedNumber(_bind$3, _M0FPC16double8infinity);
      }
      return _tmp$3;
    }
    _tmp = i + 1 | 0;
    _tmp$2 = BigInt.asUintN(64, BigInt.asUintN(64, acc * 10n) + digit);
    continue;
  }
}
function _M0MPC14json12ParseContext18scan__json__number(ctx, start, end) {
  const _bind = ctx.input;
  const _p = _bind.str.charCodeAt(_bind.start + start | 0);
  const _p$2 = 45;
  const negative = _p === _p$2;
  let has_decimal = false;
  let has_exponent = false;
  let exponent_negative = false;
  let exponent_part = 0n;
  let fractional_digits = 0;
  let mantissa = 0n;
  let significant_digits = 0;
  let seen_nonzero = false;
  let _tmp = negative ? start + 1 | 0 : start;
  while (true) {
    const i = _tmp;
    if (i < end) {
      _L: {
        _L$2: {
          const _bind$2 = ctx.input;
          const _bind$3 = _bind$2.str.charCodeAt(_bind$2.start + i | 0);
          if (_bind$3 >= 48 && _bind$3 <= 57) {
            const digit = _bind$3 - 48 | 0;
            if (has_exponent) {
              if (BigInt.asIntN(64, exponent_part) < BigInt.asIntN(64, 100000n)) {
                const next_exponent = BigInt.asUintN(64, BigInt.asUintN(64, exponent_part * 10n) + BigInt.asUintN(64, BigInt(digit)));
                exponent_part = BigInt.asIntN(64, next_exponent) > BigInt.asIntN(64, 100000n) ? 100000n : next_exponent;
              }
            } else {
              if (has_decimal) {
                fractional_digits = fractional_digits + 1 | 0;
              }
              if (digit !== 0 || seen_nonzero) {
                seen_nonzero = true;
                significant_digits = significant_digits + 1 | 0;
                if (significant_digits <= 19) {
                  mantissa = BigInt.asUintN(64, BigInt.asUintN(64, mantissa * 10n) + BigInt.asUintN(64, BigInt(digit >>> 0)));
                }
              }
            }
          } else {
            if (_bind$3 === 46) {
              has_decimal = true;
            } else {
              if (_bind$3 === 101) {
                break _L$2;
              } else {
                if (_bind$3 === 69) {
                  break _L$2;
                }
              }
            }
          }
          break _L;
        }
        has_exponent = true;
        if ((i + 1 | 0) < end) {
          const _bind$2 = ctx.input;
          const next = _bind$2.str.charCodeAt(_bind$2.start + (i + 1 | 0) | 0);
          const _p$3 = 45;
          if (next === _p$3) {
            exponent_negative = true;
          }
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const exponent_part$2 = exponent_negative ? BigInt.asUintN(64, -exponent_part) : exponent_part;
  return new _M0TPC14json14JsonNumberScan(negative, !has_decimal && !has_exponent, mantissa, BigInt.asUintN(64, exponent_part$2 - BigInt.asUintN(64, BigInt(fractional_digits))), significant_digits > 19);
}
function _M0MPC14json12ParseContext16lex__number__end(ctx, start, end) {
  const scan = _M0MPC14json12ParseContext18scan__json__number(ctx, start, end);
  if (scan.is_integer) {
    if (!scan.many_digits && (BigInt.asUintN(64, scan.exponent) === BigInt.asUintN(64, 0n) && BigInt.asUintN(64, scan.mantissa) <= BigInt.asUintN(64, 9007199254740991n))) {
      const v = scan.mantissa;
      const signed = scan.negative ? BigInt.asUintN(64, -v) : v;
      const _bind = $f64_convert_i64(BigInt.asIntN(64, signed));
      const _bind$2 = undefined;
      return new _M0TPC14json11LexedNumber(_bind$2, _bind);
    }
    return _M0MPC14json12ParseContext17lex__integer__end(ctx, start, end);
  }
  const fast = _M0MPC14json14JsonNumberScan17try__fast__double(scan);
  if (!(fast !== fast)) {
    const _bind = undefined;
    return new _M0TPC14json11LexedNumber(_bind, fast);
  }
  const s = _M0MPC16string10StringView12view_2einner(ctx.input, start, end);
  let _try_err;
  _L: {
    const _bind = _M0FPC28internal7strconv13parse__double(s);
    let d;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      d = _ok._0;
    } else {
      const _err = _bind;
      _try_err = _err._0;
      break _L;
    }
    const _bind$2 = undefined;
    return new _M0TPC14json11LexedNumber(_bind$2, d);
  }
  if (scan.negative) {
    const _bind = s;
    return new _M0TPC14json11LexedNumber(_bind, _M0FPC16double13neg__infinity);
  } else {
    const _bind = s;
    return new _M0TPC14json11LexedNumber(_bind, _M0FPC16double8infinity);
  }
}
function _M0MPC14json12ParseContext10read__char(ctx) {
  if (ctx.offset < ctx.end_offset) {
    const _bind = ctx.input;
    const c1 = _bind.str.charCodeAt(_bind.start + ctx.offset | 0);
    ctx.offset = ctx.offset + 1 | 0;
    if (c1 >= 55296 && c1 <= 56319) {
      if (ctx.offset < ctx.end_offset) {
        const _bind$2 = ctx.input;
        const c2 = _bind$2.str.charCodeAt(_bind$2.start + ctx.offset | 0);
        if (c2 >= 56320 && c2 <= 57343) {
          ctx.offset = ctx.offset + 1 | 0;
          const c3 = ((c1 << 10) + c2 | 0) - 56613888 | 0;
          return c3;
        }
      }
    }
    return c1;
  } else {
    return -1;
  }
}
function _M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start) {
  while (true) {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return _M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset);
    } else {
      const _Some = _bind;
      const _x = _Some;
      if (_x >= 48 && _x <= 57) {
        continue;
      } else {
        ctx.offset = ctx.offset - 1 | 0;
        return _M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset);
      }
    }
  }
}
function _M0MPC14json12ParseContext28lex__decimal__exponent__sign(ctx, start) {
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x >= 48 && _x <= 57) {
      return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start));
    } else {
      ctx.offset = ctx.offset - 1 | 0;
      return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
    }
  }
}
function _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start) {
  _L: {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
    } else {
      const _Some = _bind;
      const _x = _Some;
      if (_x === 43) {
        break _L;
      } else {
        if (_x === 45) {
          break _L;
        } else {
          if (_x >= 48 && _x <= 57) {
            return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start));
          } else {
            ctx.offset = ctx.offset - 1 | 0;
            return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
          }
        }
      }
    }
  }
  const _bind = _M0MPC14json12ParseContext28lex__decimal__exponent__sign(ctx, start);
  let _tmp;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp = _ok._0;
  } else {
    return _bind;
  }
  return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext22lex__decimal__fraction(ctx, start) {
  while (true) {
    _L: {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
      } else {
        const _Some = _bind;
        const _x = _Some;
        if (_x === 101) {
          break _L;
        } else {
          if (_x === 69) {
            break _L;
          } else {
            if (_x >= 48 && _x <= 57) {
              continue;
            } else {
              ctx.offset = ctx.offset - 1 | 0;
              return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
            }
          }
        }
      }
    }
    const _bind = _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
    let _tmp;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _tmp = _ok._0;
    } else {
      return _bind;
    }
    return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_tmp);
  }
}
function _M0MPC14json12ParseContext19lex__decimal__point(ctx, start) {
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    return _x >= 48 && _x <= 57 ? _M0MPC14json12ParseContext22lex__decimal__fraction(ctx, start) : _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
  }
}
function _M0MPC14json12ParseContext21lex__decimal__integer(ctx, start) {
  while (true) {
    _L: {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
      } else {
        const _Some = _bind;
        const _x = _Some;
        if (_x === 46) {
          const _bind$2 = _M0MPC14json12ParseContext19lex__decimal__point(ctx, start);
          let _tmp;
          if (_bind$2.$tag === 1) {
            const _ok = _bind$2;
            _tmp = _ok._0;
          } else {
            return _bind$2;
          }
          return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_tmp);
        } else {
          if (_x === 101) {
            break _L;
          } else {
            if (_x === 69) {
              break _L;
            } else {
              if (_x >= 48 && _x <= 57) {
                continue;
              } else {
                ctx.offset = ctx.offset - 1 | 0;
                return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
              }
            }
          }
        }
      }
    }
    const _bind = _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
    let _tmp;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _tmp = _ok._0;
    } else {
      return _bind;
    }
    return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_tmp);
  }
}
function _M0MPC14json12ParseContext16lex__hex__digits(ctx, n) {
  let _tmp;
  let _tmp$2 = 0;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$2;
    const r = _tmp$3;
    if (_ < n) {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      let d;
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
      } else {
        const _Some = _bind;
        const _x = _Some;
        if (_x >= 48 && _x <= 57) {
          d = _x - 48 | 0;
        } else {
          if (_x >= 65 && _x <= 70) {
            d = (_x - 65 | 0) + 10 | 0;
          } else {
            if (_x >= 97 && _x <= 102) {
              d = (_x - 97 | 0) + 10 | 0;
            } else {
              const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGiE(ctx, -1);
              if (_bind$2.$tag === 1) {
                const _ok = _bind$2;
                d = _ok._0;
              } else {
                return _bind$2;
              }
            }
          }
        }
      }
      _tmp$2 = _ + 1 | 0;
      _tmp$3 = r << 4 | d;
      continue;
    } else {
      _tmp = r;
      break;
    }
  }
  return new _M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext17lex__string__slowN5flushS317(_env, end) {
  const start = _env._2;
  const ctx = _env._1;
  const buf = _env._0;
  if (start.val > 0 && end > start.val) {
    _M0IPB13StringBuilderPB6Logger11write__view(buf, _M0MPC16string10StringView11sub_2einner(ctx.input, start.val, end));
    return;
  } else {
    return;
  }
}
function _M0MPC14json12ParseContext17lex__string__slow(ctx) {
  const buf = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const start = new _M0TPB8MutLocalGiE(ctx.offset);
  const _env = { _0: buf, _1: ctx, _2: start };
  _L: while (true) {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
    } else {
      const _Some = _bind;
      const _x = _Some;
      switch (_x) {
        case 34: {
          _M0MPC14json12ParseContext17lex__string__slowN5flushS317(_env, ctx.offset - 1 | 0);
          break _L;
        }
        case 92: {
          _M0MPC14json12ParseContext17lex__string__slowN5flushS317(_env, ctx.offset - 1 | 0);
          const _bind$2 = _M0MPC14json12ParseContext10read__char(ctx);
          if (_bind$2 === -1) {
            return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
          } else {
            const _Some$2 = _bind$2;
            const _x$2 = _Some$2;
            switch (_x$2) {
              case 98: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 8);
                break;
              }
              case 102: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 12);
                break;
              }
              case 110: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 10);
                break;
              }
              case 114: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 13);
                break;
              }
              case 116: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 9);
                break;
              }
              case 34: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 34);
                break;
              }
              case 92: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 92);
                break;
              }
              case 47: {
                _M0IPB13StringBuilderPB6Logger11write__char(buf, 47);
                break;
              }
              case 117: {
                const _bind$3 = _M0MPC14json12ParseContext16lex__hex__digits(ctx, 4);
                let c;
                if (_bind$3.$tag === 1) {
                  const _ok = _bind$3;
                  c = _ok._0;
                } else {
                  return _bind$3;
                }
                _M0IPB13StringBuilderPB6Logger11write__char(buf, c);
                break;
              }
              default: {
                const _bind$4 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
                if (_bind$4.$tag === 1) {
                  const _ok = _bind$4;
                  _ok._0;
                } else {
                  return _bind$4;
                }
              }
            }
          }
          start.val = ctx.offset;
          break;
        }
        default: {
          if (_x < 32) {
            const _bind$3 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
            if (_bind$3.$tag === 1) {
              const _ok = _bind$3;
              _ok._0;
            } else {
              return _bind$3;
            }
          } else {
            continue _L;
          }
        }
      }
    }
    continue;
  }
  return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(buf.val);
}
function _M0MPC14json12ParseContext11lex__string(ctx) {
  const string_start = ctx.offset;
  let _tmp = string_start;
  while (true) {
    const i = _tmp;
    if (i < ctx.end_offset) {
      const _bind = ctx.input;
      const c = _bind.str.charCodeAt(_bind.start + i | 0);
      const _p = 34;
      if (c === _p) {
        ctx.offset = i + 1 | 0;
        return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(_M0MPC16string10StringView9to__owned(_M0MPC16string10StringView12view_2einner(ctx.input, string_start, i)));
      } else {
        const _p$2 = 92;
        if (c === _p$2) {
          const _bind$2 = _M0MPC14json12ParseContext17lex__string__slow(ctx);
          let _tmp$2;
          if (_bind$2.$tag === 1) {
            const _ok = _bind$2;
            _tmp$2 = _ok._0;
          } else {
            return _bind$2;
          }
          return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(_tmp$2);
        } else {
          if (_M0IP016_24default__implPB7Compare6op__ltGkE(c, 32)) {
            ctx.offset = i + 1 | 0;
            const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
          }
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
}
function _M0MPC14json12ParseContext9lex__zero(ctx, start) {
  _L: {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
    } else {
      const _Some = _bind;
      const _x = _Some;
      if (_x === 46) {
        return _M0MPC14json12ParseContext19lex__decimal__point(ctx, start);
      } else {
        if (_x === 101) {
          break _L;
        } else {
          if (_x === 69) {
            break _L;
          } else {
            if (_x >= 48 && _x <= 57) {
              ctx.offset = ctx.offset - 1 | 0;
              return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
            } else {
              ctx.offset = ctx.offset - 1 | 0;
              return new _M0DTPC16result6ResultGRPC14json11LexedNumberRPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
            }
          }
        }
      }
    }
  }
  return _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
}
function _M0MPC14json12ParseContext10lex__value(ctx, allow_rbracket) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 123) {
      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6LBrace__);
    } else {
      if (_x === 91) {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8LBracket__);
      } else {
        if (_x === 93) {
          if (allow_rbracket) {
            return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8RBracket__);
          } else {
            return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
          }
        } else {
          if (_x === 110) {
            const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 117);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
            const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
            if (_bind$3.$tag === 1) {
              const _ok = _bind$3;
              _ok._0;
            } else {
              return _bind$3;
            }
            const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
            if (_bind$4.$tag === 1) {
              const _ok = _bind$4;
              _ok._0;
            } else {
              return _bind$4;
            }
            return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token4Null__);
          } else {
            if (_x === 116) {
              const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 114);
              if (_bind$2.$tag === 1) {
                const _ok = _bind$2;
                _ok._0;
              } else {
                return _bind$2;
              }
              const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 117);
              if (_bind$3.$tag === 1) {
                const _ok = _bind$3;
                _ok._0;
              } else {
                return _bind$3;
              }
              const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 101);
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                _ok._0;
              } else {
                return _bind$4;
              }
              return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token4True__);
            } else {
              if (_x === 102) {
                const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 97);
                if (_bind$2.$tag === 1) {
                  const _ok = _bind$2;
                  _ok._0;
                } else {
                  return _bind$2;
                }
                const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
                if (_bind$3.$tag === 1) {
                  const _ok = _bind$3;
                  _ok._0;
                } else {
                  return _bind$3;
                }
                const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 115);
                if (_bind$4.$tag === 1) {
                  const _ok = _bind$4;
                  _ok._0;
                } else {
                  return _bind$4;
                }
                const _bind$5 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 101);
                if (_bind$5.$tag === 1) {
                  const _ok = _bind$5;
                  _ok._0;
                } else {
                  return _bind$5;
                }
                return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5False__);
              } else {
                if (_x === 45) {
                  const _bind$2 = _M0MPC14json12ParseContext10read__char(ctx);
                  if (_bind$2 === -1) {
                    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
                  } else {
                    const _Some$2 = _bind$2;
                    const _x$2 = _Some$2;
                    if (_x$2 === 48) {
                      const _bind$3 = _M0MPC14json12ParseContext9lex__zero(ctx, ctx.offset - 2 | 0);
                      let _bind$4;
                      if (_bind$3.$tag === 1) {
                        const _ok = _bind$3;
                        _bind$4 = _ok._0;
                      } else {
                        return _bind$3;
                      }
                      const _n = _bind$4.value;
                      const _repr = _bind$4.repr;
                      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0MPC16string10StringView9to__owned(repr))));
                    } else {
                      if (_x$2 >= 49 && _x$2 <= 57) {
                        const _bind$3 = _M0MPC14json12ParseContext21lex__decimal__integer(ctx, ctx.offset - 2 | 0);
                        let _bind$4;
                        if (_bind$3.$tag === 1) {
                          const _ok = _bind$3;
                          _bind$4 = _ok._0;
                        } else {
                          return _bind$3;
                        }
                        const _n = _bind$4.value;
                        const _repr = _bind$4.repr;
                        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0MPC16string10StringView9to__owned(repr))));
                      } else {
                        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
                      }
                    }
                  }
                } else {
                  if (_x === 48) {
                    const _bind$2 = _M0MPC14json12ParseContext9lex__zero(ctx, ctx.offset - 1 | 0);
                    let _bind$3;
                    if (_bind$2.$tag === 1) {
                      const _ok = _bind$2;
                      _bind$3 = _ok._0;
                    } else {
                      return _bind$2;
                    }
                    const _n = _bind$3.value;
                    const _repr = _bind$3.repr;
                    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0MPC16string10StringView9to__owned(repr))));
                  } else {
                    if (_x >= 49 && _x <= 57) {
                      const _bind$2 = _M0MPC14json12ParseContext21lex__decimal__integer(ctx, ctx.offset - 1 | 0);
                      let _bind$3;
                      if (_bind$2.$tag === 1) {
                        const _ok = _bind$2;
                        _bind$3 = _ok._0;
                      } else {
                        return _bind$2;
                      }
                      const _n = _bind$3.value;
                      const _repr = _bind$3.repr;
                      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0MPC16string10StringView9to__owned(repr))));
                    } else {
                      if (_x === 34) {
                        const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
                        let s;
                        if (_bind$2.$tag === 1) {
                          const _ok = _bind$2;
                          s = _ok._0;
                        } else {
                          return _bind$2;
                        }
                        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
                      } else {
                        const _p = _x;
                        const shift = -(_p <= 65535 ? 1 : 2) | 0;
                        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, shift);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
function _M0MPC14json12ParseContext24lex__after__array__value(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 93: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8RBracket__);
      }
      case 44: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5Comma__);
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext25lex__after__object__value(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 125: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6RBrace__);
      }
      case 44: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5Comma__);
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext26lex__after__property__name(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 58) {
      return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(undefined);
    } else {
      return _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
    }
  }
}
function _M0MPC14json12ParseContext19lex__property__name(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 125: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6RBrace__);
      }
      case 34: {
        const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
        let s;
        if (_bind$2.$tag === 1) {
          const _ok = _bind$2;
          s = _ok._0;
        } else {
          return _bind$2;
        }
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext20lex__property__name2(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 34) {
      const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
      let s;
      if (_bind$2.$tag === 1) {
        const _ok = _bind$2;
        s = _ok._0;
      } else {
        return _bind$2;
      }
      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
    } else {
      return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
    }
  }
}
function _M0MPC14json12ParseContext12parse__value(ctx, remaining_available_depth) {
  const _bind = _M0MPC14json12ParseContext10lex__value(ctx, false);
  let tok;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    tok = _ok._0;
  } else {
    return _bind;
  }
  return _M0MPC14json12ParseContext13parse__value2(ctx, tok, remaining_available_depth);
}
function _M0MPC14json12ParseContext13parse__value2(ctx, tok, remaining_available_depth) {
  _L: {
    switch (tok.$tag) {
      case 0: {
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0FPB4null);
      }
      case 1: {
        const _p = true;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_p ? _M0DTPB4Json4True__ : _M0DTPB4Json5False__);
      }
      case 2: {
        const _p$2 = false;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_p$2 ? _M0DTPB4Json4True__ : _M0DTPB4Json5False__);
      }
      case 3: {
        const _Number = tok;
        const _n = _Number._0;
        const _repr = _Number._1;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(new _M0DTPB4Json6Number(_n, _repr));
      }
      case 4: {
        const _String = tok;
        const _s = _String._0;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(new _M0DTPB4Json6String(_s));
      }
      case 5: {
        return _M0MPC14json12ParseContext13parse__object(ctx, remaining_available_depth);
      }
      case 7: {
        return _M0MPC14json12ParseContext12parse__array(ctx, remaining_available_depth);
      }
      case 8: {
        break _L;
      }
      case 6: {
        break _L;
      }
      default: {
        break _L;
      }
    }
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0FPC15abort5abortGRPB4JsonE("unreachable"));
}
function _M0MPC14json12ParseContext12parse__array(ctx, remaining_available_depth) {
  if (remaining_available_depth <= 0) {
    return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__);
  }
  const child_remaining_available_depth = remaining_available_depth - 1 | 0;
  const vec = [];
  let _tmp;
  const _bind = _M0MPC14json12ParseContext10lex__value(ctx, true);
  let _tmp$2;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp$2 = _ok._0;
  } else {
    return _bind;
  }
  let _tmp$3 = _tmp$2;
  _L: while (true) {
    const x = _tmp$3;
    if (x.$tag === 8) {
      _tmp = new _M0DTPB4Json5Array(vec);
      break;
    } else {
      const _bind$2 = _M0MPC14json12ParseContext13parse__value2(ctx, x, child_remaining_available_depth);
      let _tmp$4;
      if (_bind$2.$tag === 1) {
        const _ok = _bind$2;
        _tmp$4 = _ok._0;
      } else {
        return _bind$2;
      }
      _M0MPC15array5Array4pushGRPB4JsonE(vec, _tmp$4);
      const _bind$3 = _M0MPC14json12ParseContext24lex__after__array__value(ctx);
      let tok2;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        tok2 = _ok._0;
      } else {
        return _bind$3;
      }
      switch (tok2.$tag) {
        case 9: {
          const _bind$4 = _M0MPC14json12ParseContext10lex__value(ctx, false);
          if (_bind$4.$tag === 1) {
            const _ok = _bind$4;
            _tmp$3 = _ok._0;
          } else {
            return _bind$4;
          }
          continue _L;
        }
        case 8: {
          _tmp = new _M0DTPB4Json5Array(vec);
          break _L;
        }
        default: {
          _M0FPC15abort5abortGuE("unreachable");
        }
      }
    }
    continue;
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext13parse__object(ctx, remaining_available_depth) {
  if (remaining_available_depth <= 0) {
    return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__);
  }
  const child_remaining_available_depth = remaining_available_depth - 1 | 0;
  const _bind = [];
  const map = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  let _tmp;
  const _bind$2 = _M0MPC14json12ParseContext19lex__property__name(ctx);
  let _tmp$2;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp$2 = _ok._0;
  } else {
    return _bind$2;
  }
  let _tmp$3 = _tmp$2;
  _L: while (true) {
    const x = _tmp$3;
    switch (x.$tag) {
      case 6: {
        _tmp = new _M0DTPB4Json6Object(map);
        break _L;
      }
      case 4: {
        const _String = x;
        const _name = _String._0;
        const _bind$3 = _M0MPC14json12ParseContext26lex__after__property__name(ctx);
        if (_bind$3.$tag === 1) {
          const _ok = _bind$3;
          _ok._0;
        } else {
          return _bind$3;
        }
        const _bind$4 = _M0MPC14json12ParseContext12parse__value(ctx, child_remaining_available_depth);
        let _tmp$4;
        if (_bind$4.$tag === 1) {
          const _ok = _bind$4;
          _tmp$4 = _ok._0;
        } else {
          return _bind$4;
        }
        _M0MPB3Map3setGsRPB4JsonE(map, _name, _tmp$4);
        const _bind$5 = _M0MPC14json12ParseContext25lex__after__object__value(ctx);
        let _bind$6;
        if (_bind$5.$tag === 1) {
          const _ok = _bind$5;
          _bind$6 = _ok._0;
        } else {
          return _bind$5;
        }
        switch (_bind$6.$tag) {
          case 9: {
            const _bind$7 = _M0MPC14json12ParseContext20lex__property__name2(ctx);
            if (_bind$7.$tag === 1) {
              const _ok = _bind$7;
              _tmp$3 = _ok._0;
            } else {
              return _bind$7;
            }
            continue _L;
          }
          case 6: {
            _tmp = new _M0DTPB4Json6Object(map);
            break _L;
          }
          default: {
            _M0FPC15abort5abortGuE("unreachable");
          }
        }
        break;
      }
      default: {
        _M0FPC15abort5abortGuE("unreachable");
      }
    }
    continue;
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0FPC14json13parse_2einner(input, max_nesting_depth) {
  const ctx = _M0MPC14json12ParseContext4make(input);
  const _bind = _M0MPC14json12ParseContext12parse__value(ctx, max_nesting_depth);
  let val;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    val = _ok._0;
  } else {
    return _bind;
  }
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  return ctx.offset >= ctx.end_offset ? new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(val) : _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
}
function _M0FP38weopqrst12mooncassette5canon13compare__utf8(left, right) {
  const left_bytes = _M0FPC28encoding4utf814encode_2einner(new _M0TPC16string10StringView(left, 0, left.length), false);
  const right_bytes = _M0FPC28encoding4utf814encode_2einner(new _M0TPC16string10StringView(right, 0, right.length), false);
  const left_len = left_bytes.length;
  const right_len = right_bytes.length;
  const limit = left_len < right_len ? left_len : right_len;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < limit) {
      $bound_check(left_bytes, i);
      const x = left_bytes[i];
      $bound_check(right_bytes, i);
      const y = right_bytes[i];
      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (left_len < right_len) {
    return -1;
  }
  if (left_len > right_len) {
    return 1;
  }
  return 0;
}
function _M0FP38weopqrst12mooncassette5canon12sorted__keys(fields) {
  const keys = [];
  const _it = _M0MPB3Map4keysGsRPB4JsonE(fields);
  while (true) {
    const _bind = _M0MPB4Iter4nextGsE(_it);
    if (_bind === undefined) {
      break;
    } else {
      const _Some = _bind;
      const _key = _Some;
      _M0MPC15array5Array4pushGRPB4JsonE(keys, _key);
      continue;
    }
  }
  const count = keys.length;
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < count) {
      const current = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(keys, i);
      let j = i - 1 | 0;
      while (true) {
        if (j >= 0 && _M0FP38weopqrst12mooncassette5canon13compare__utf8(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(keys, j), current) > 0) {
          _M0MPC15array5Array3setGsE(keys, j + 1 | 0, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(keys, j));
          j = j - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0MPC15array5Array3setGsE(keys, j + 1 | 0, current);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return keys;
}
function _M0FP38weopqrst12mooncassette5canon4hex4(code) {
  const digits = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  let _tmp = 12;
  while (true) {
    const shift = _tmp;
    if (shift >= 0) {
      _M0IPB13StringBuilderPB6Logger11write__char(sb, _M0MPC15array5Array2atGcE(digits, code >> shift & 15));
      _tmp = shift - 4 | 0;
      continue;
    } else {
      break;
    }
  }
  return sb.val;
}
function _M0FP38weopqrst12mooncassette5canon14write__escaped(sb, text) {
  _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"");
  const _bind = text.length;
  let _tmp = 0;
  while (true) {
    const _string_index = _tmp;
    if (_string_index < _bind) {
      let _decoded_next_string_index;
      let _decoded_char;
      _L: {
        const _bind$2 = text.charCodeAt(_string_index);
        if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
          const _bind$3 = text.charCodeAt(_string_index + 1 | 0);
          if (_bind$3 >= 56320 && _bind$3 <= 57343) {
            const _tmp$2 = _string_index + 2 | 0;
            const _p = (((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$2;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        } else {
          const _tmp$2 = _string_index + 1 | 0;
          const _p = _bind$2;
          _decoded_next_string_index = _tmp$2;
          _decoded_char = _p;
          break _L;
        }
      }
      if (_decoded_char === 34) {
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\\"");
      } else {
        if (_decoded_char === 92) {
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\\\");
        } else {
          if (_decoded_char === 10) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\n");
          } else {
            if (_decoded_char === 13) {
              _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\r");
            } else {
              if (_decoded_char === 9) {
                _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\t");
              } else {
                if (_decoded_char === 8) {
                  _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\b");
                } else {
                  if (_decoded_char === 12) {
                    _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\f");
                  } else {
                    if (_decoded_char < 32) {
                      _M0IPB13StringBuilderPB6Logger13write__string(sb, "\\u");
                      _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0FP38weopqrst12mooncassette5canon4hex4(_decoded_char));
                    } else {
                      _M0IPB13StringBuilderPB6Logger11write__char(sb, _decoded_char);
                    }
                  }
                }
              }
            }
          }
        }
      }
      _tmp = _decoded_next_string_index;
      continue;
    } else {
      break;
    }
  }
  _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"");
}
function _M0FP38weopqrst12mooncassette5canon13write__number(sb, value) {
  if (value !== value) {
    _M0IPB13StringBuilderPB6Logger13write__string(sb, "null");
    return;
  } else {
    if (value === _M0FPC16double8infinity || value === _M0FPC16double13neg__infinity) {
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "null");
      return;
    } else {
      _M0IPB13StringBuilderPB6Logger13write__string(sb, String(value));
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette5canon14write__compact(sb, value) {
  switch (value.$tag) {
    case 0: {
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "null");
      return;
    }
    case 1: {
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "true");
      return;
    }
    case 2: {
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "false");
      return;
    }
    case 3: {
      const _Number = value;
      const _number = _Number._0;
      const _repr = _Number._1;
      if (_repr === undefined) {
        _M0FP38weopqrst12mooncassette5canon13write__number(sb, _number);
        return;
      } else {
        const _Some = _repr;
        const _text = _Some;
        _M0IPB13StringBuilderPB6Logger13write__string(sb, _text);
        return;
      }
    }
    case 4: {
      const _String = value;
      const _text = _String._0;
      _M0FP38weopqrst12mooncassette5canon14write__escaped(sb, _text);
      return;
    }
    case 5: {
      const _Array = value;
      const _items = _Array._0;
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "[");
      let index = 0;
      const _bind = _items.length;
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < _bind) {
          const item = _items[_];
          if (index > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          index = index + 1 | 0;
          _M0FP38weopqrst12mooncassette5canon14write__compact(sb, item);
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
      return;
    }
    default: {
      const _Object = value;
      const _fields = _Object._0;
      const keys = _M0FP38weopqrst12mooncassette5canon12sorted__keys(_fields);
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "{");
      let index$2 = 0;
      const _bind$2 = keys.length;
      let _tmp$2 = 0;
      while (true) {
        const _ = _tmp$2;
        if (_ < _bind$2) {
          const key = keys[_];
          if (index$2 > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          index$2 = index$2 + 1 | 0;
          _M0FP38weopqrst12mooncassette5canon14write__escaped(sb, key);
          _M0IPB13StringBuilderPB6Logger13write__string(sb, ":");
          const _bind$3 = _M0MPB3Map3getGsRPB4JsonE(_fields, key);
          if (_bind$3 === undefined) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, "null");
          } else {
            const _Some = _bind$3;
            const _child = _Some;
            _M0FP38weopqrst12mooncassette5canon14write__compact(sb, _child);
          }
          _tmp$2 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "}");
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette5canon21to__canonical__string(value) {
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0FP38weopqrst12mooncassette5canon14write__compact(sb, value);
  return sb.val;
}
function _M0FP38weopqrst12mooncassette5canon13write__indent(sb, width, depth) {
  const total = Math.imul(width, depth) | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < total) {
      _M0IPB13StringBuilderPB6Logger11write__char(sb, 32);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette5canon13write__pretty(sb, value, width, depth) {
  switch (value.$tag) {
    case 5: {
      const _Array = value;
      const _items = _Array._0;
      if (_items.length === 0) {
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "[]");
        return;
      } else {
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "[\n");
        let index = 0;
        const _bind = _items.length;
        let _tmp = 0;
        while (true) {
          const _ = _tmp;
          if (_ < _bind) {
            const item = _items[_];
            if (index > 0) {
              _M0IPB13StringBuilderPB6Logger13write__string(sb, ",\n");
            }
            index = index + 1 | 0;
            _M0FP38weopqrst12mooncassette5canon13write__indent(sb, width, depth + 1 | 0);
            _M0FP38weopqrst12mooncassette5canon13write__pretty(sb, item, width, depth + 1 | 0);
            _tmp = _ + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "\n");
        _M0FP38weopqrst12mooncassette5canon13write__indent(sb, width, depth);
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
        return;
      }
    }
    case 6: {
      const _Object = value;
      const _fields = _Object._0;
      if (_fields.size === 0) {
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "{}");
        return;
      } else {
        const keys = _M0FP38weopqrst12mooncassette5canon12sorted__keys(_fields);
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "{\n");
        let index = 0;
        const _bind = keys.length;
        let _tmp = 0;
        while (true) {
          const _ = _tmp;
          if (_ < _bind) {
            const key = keys[_];
            if (index > 0) {
              _M0IPB13StringBuilderPB6Logger13write__string(sb, ",\n");
            }
            index = index + 1 | 0;
            _M0FP38weopqrst12mooncassette5canon13write__indent(sb, width, depth + 1 | 0);
            _M0FP38weopqrst12mooncassette5canon14write__escaped(sb, key);
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ": ");
            const _bind$2 = _M0MPB3Map3getGsRPB4JsonE(_fields, key);
            if (_bind$2 === undefined) {
              _M0IPB13StringBuilderPB6Logger13write__string(sb, "null");
            } else {
              const _Some = _bind$2;
              const _child = _Some;
              _M0FP38weopqrst12mooncassette5canon13write__pretty(sb, _child, width, depth + 1 | 0);
            }
            _tmp = _ + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "\n");
        _M0FP38weopqrst12mooncassette5canon13write__indent(sb, width, depth);
        _M0IPB13StringBuilderPB6Logger13write__string(sb, "}");
        return;
      }
    }
    default: {
      _M0FP38weopqrst12mooncassette5canon14write__compact(sb, value);
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette5canon18to__pretty__string(value, indent) {
  let width;
  if (indent === undefined) {
    width = 2;
  } else {
    const _Some = indent;
    width = _Some;
  }
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0FP38weopqrst12mooncassette5canon13write__pretty(sb, value, width, 0);
  return sb.val;
}
function _M0FP38weopqrst12mooncassette5canon7fnv1a64(bytes) {
  let hash = 14695981039346656037n;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < bytes.length) {
      const _tmp$2 = hash;
      $bound_check(bytes, i);
      hash = BigInt.asUintN(64, BigInt.asUintN(64, _tmp$2 ^ _M0MPC14byte4Byte10to__uint64(bytes[i])) * _M0FP38weopqrst12mooncassette5canon7fnv1a64N5primeS5);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return hash;
}
function _M0FP38weopqrst12mooncassette5canon15fnv1a64__string(text) {
  return _M0FP38weopqrst12mooncassette5canon7fnv1a64(_M0FPC28encoding4utf814encode_2einner(new _M0TPC16string10StringView(text, 0, text.length), false));
}
function _M0FP38weopqrst12mooncassette5canon8hex__u64(value) {
  return _M0MPC16string6String10pad__start(_M0MPC16uint646UInt6418to__string_2einner(value, 16), 16, 48);
}
function _M0MP38weopqrst12mooncassette4core7Request3new(provider, model, body) {
  return new _M0TP38weopqrst12mooncassette4core7Request(provider, model, body);
}
function _M0MP38weopqrst12mooncassette4core5Usage3new(input_tokens, output_tokens) {
  return new _M0TP38weopqrst12mooncassette4core5Usage(input_tokens, output_tokens);
}
function _M0MP38weopqrst12mooncassette4core11StreamFrame3new(data, event) {
  return new _M0TP38weopqrst12mooncassette4core11StreamFrame(event, data);
}
function _M0MP38weopqrst12mooncassette4core8Response3new(status, body, usage, stream) {
  return new _M0TP38weopqrst12mooncassette4core8Response(status, body, usage, stream);
}
function _M0MP38weopqrst12mooncassette4core8Response2ok(body, usage, stream) {
  return new _M0TP38weopqrst12mooncassette4core8Response(200, body, usage, stream);
}
function _M0MP38weopqrst12mooncassette4core11Interaction3new(request, response) {
  return new _M0TP38weopqrst12mooncassette4core11Interaction(request, response);
}
function _M0MP38weopqrst12mooncassette4core8Cassette3new(name, recorded_at, interactions) {
  const _tmp = new _M0TP38weopqrst12mooncassette4core12CassetteMeta(name, _M0FP38weopqrst12mooncassette4core13generator__id, recorded_at);
  let _tmp$2;
  if (interactions.$tag === 1) {
    const _Some = interactions;
    _tmp$2 = _Some._0;
  } else {
    _tmp$2 = [];
  }
  return new _M0TP38weopqrst12mooncassette4core8Cassette(2, _tmp, _tmp$2);
}
function _M0IP38weopqrst12mooncassette4core13CassetteErrorPB4Show6output(self, logger) {
  switch (self.$tag) {
    case 8: {
      const _Malformed = self;
      const _message = _Malformed._0;
      logger.method_table.method_0(logger.self, `mooncassette: malformed cassette: ${_message}`);
      return;
    }
    case 7: {
      const _SchemaViolation = self;
      const _message$2 = _SchemaViolation._0;
      logger.method_table.method_0(logger.self, `mooncassette: schema violation: ${_message$2}`);
      return;
    }
    case 6: {
      const _UnsupportedVersion = self;
      const _version = _UnsupportedVersion._0;
      logger.method_table.method_0(logger.self, `mooncassette: unsupported cassette format version ${_M0MPC13int3Int18to__string_2einner(_version, 10)}; this build reads versions 1 to ${_M0MPC13int3Int18to__string_2einner(2, 10)}`);
      return;
    }
    case 5: {
      const _FingerprintCollision = self;
      const _fingerprint = _FingerprintCollision._0;
      const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(85);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "mooncassette: fingerprint collision on ");
      _M0MPB13StringBuilder13write__objectGsE(_string_builder, _fingerprint);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ": two different requests share one fingerprint");
      logger.method_table.method_0(logger.self, _string_builder.val);
      return;
    }
    case 4: {
      const _IntegrityViolation = self;
      const _message$3 = _IntegrityViolation._0;
      logger.method_table.method_0(logger.self, `mooncassette: integrity violation: ${_message$3}`);
      return;
    }
    case 3: {
      const _NoMatch = self;
      const _detail = _NoMatch._0;
      logger.method_table.method_0(logger.self, `mooncassette: no recorded interaction matches request ${_detail}`);
      return;
    }
    case 2: {
      const _Exhausted = self;
      const _message$4 = _Exhausted._0;
      logger.method_table.method_0(logger.self, `mooncassette: recording exhausted: ${_message$4}`);
      return;
    }
    case 1: {
      const _MissingTransport = self;
      const _message$5 = _MissingTransport._0;
      logger.method_table.method_0(logger.self, `mooncassette: missing transport: ${_message$5}`);
      return;
    }
    default: {
      const _TransportFailure = self;
      const _message$6 = _TransportFailure._0;
      logger.method_table.method_0(logger.self, `mooncassette: transport failure: ${_message$6}`);
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette4core9json__int(value) {
  const _p = value + 0;
  const _p$2 = _M0MPC13int3Int18to__string_2einner(value, 10);
  return new _M0DTPB4Json6Number(_p, _p$2);
}
function _M0FP38weopqrst12mooncassette4core13request__json(provider, model, body) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(fields, "provider", new _M0DTPB4Json6String(provider));
  _M0MPB3Map3setGsRPB4JsonE(fields, "model", new _M0DTPB4Json6String(model));
  _M0MPB3Map3setGsRPB4JsonE(fields, "body", body);
  return new _M0DTPB4Json6Object(fields);
}
function _M0MP38weopqrst12mooncassette4core7Request8to__json(self) {
  return _M0FP38weopqrst12mooncassette4core13request__json(self.provider, self.model, self.body);
}
function _M0MP38weopqrst12mooncassette4core5Usage8to__json(self) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(fields, "input_tokens", _M0FP38weopqrst12mooncassette4core9json__int(self.input_tokens));
  _M0MPB3Map3setGsRPB4JsonE(fields, "output_tokens", _M0FP38weopqrst12mooncassette4core9json__int(self.output_tokens));
  return new _M0DTPB4Json6Object(fields);
}
function _M0MP38weopqrst12mooncassette4core11StreamFrame8to__json(self) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _bind$2 = self.event;
  if (_bind$2 === undefined) {
  } else {
    const _Some = _bind$2;
    const _name = _Some;
    _M0MPB3Map3setGsRPB4JsonE(fields, "event", new _M0DTPB4Json6String(_name));
  }
  const _p = self.data;
  _M0MPB3Map3setGsRPB4JsonE(fields, "data", new _M0DTPB4Json6String(_p));
  return new _M0DTPB4Json6Object(fields);
}
function _M0FP38weopqrst12mooncassette4core24stream__frames__to__json(frames) {
  const items = [];
  const _bind = frames.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const frame = frames[_];
      _M0MPC15array5Array4pushGRPB4JsonE(items, _M0MP38weopqrst12mooncassette4core11StreamFrame8to__json(frame));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPB4Json5Array(items);
}
function _M0MP38weopqrst12mooncassette4core8Response8to__json(self) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(fields, "status", _M0FP38weopqrst12mooncassette4core9json__int(self.status));
  _M0MPB3Map3setGsRPB4JsonE(fields, "body", self.body);
  const _bind$2 = self.usage;
  if (_bind$2 === undefined) {
  } else {
    const _Some = _bind$2;
    const _usage = _Some;
    _M0MPB3Map3setGsRPB4JsonE(fields, "usage", _M0MP38weopqrst12mooncassette4core5Usage8to__json(_usage));
  }
  const _bind$3 = self.stream;
  if (_bind$3.$tag === 1) {
    const _Some = _bind$3;
    const _frames = _Some._0;
    _M0MPB3Map3setGsRPB4JsonE(fields, "stream", _M0FP38weopqrst12mooncassette4core24stream__frames__to__json(_frames));
  }
  return new _M0DTPB4Json6Object(fields);
}
function _M0MP38weopqrst12mooncassette4core11Interaction8to__json(self) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(fields, "request", _M0MP38weopqrst12mooncassette4core7Request8to__json(self.request));
  _M0MPB3Map3setGsRPB4JsonE(fields, "response", _M0MP38weopqrst12mooncassette4core8Response8to__json(self.response));
  return new _M0DTPB4Json6Object(fields);
}
function _M0FP38weopqrst12mooncassette4core13contains__key(keys, target) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < (keys.end - keys.start | 0)) {
      if (i < 0 || i >= (keys.end - keys.start | 0)) {
        $panic();
      }
      if (keys.buf[keys.start + i | 0] === target) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP38weopqrst12mooncassette4core11prune__json(value, drop_keys) {
  switch (value.$tag) {
    case 6: {
      const _Object = value;
      const _fields = _Object._0;
      const _bind = [];
      const kept = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
      const _it = _M0MPB3Map4keysGsRPB4JsonE(_fields);
      while (true) {
        const _bind$2 = _M0MPB4Iter4nextGsE(_it);
        if (_bind$2 === undefined) {
          break;
        } else {
          const _Some = _bind$2;
          const _key = _Some;
          if (!_M0FP38weopqrst12mooncassette4core13contains__key(drop_keys, _key)) {
            const _bind$3 = _M0MPB3Map3getGsRPB4JsonE(_fields, _key);
            if (_bind$3 === undefined) {
            } else {
              const _Some$2 = _bind$3;
              const _child = _Some$2;
              _M0MPB3Map3setGsRPB4JsonE(kept, _key, _M0FP38weopqrst12mooncassette4core11prune__json(_child, drop_keys));
            }
          }
          continue;
        }
      }
      return new _M0DTPB4Json6Object(kept);
    }
    case 5: {
      const _Array = value;
      const _items = _Array._0;
      const kept$2 = [];
      const _bind$2 = _items.length;
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < _bind$2) {
          const item = _items[_];
          _M0MPC15array5Array4pushGRPB4JsonE(kept$2, _M0FP38weopqrst12mooncassette4core11prune__json(item, drop_keys));
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return new _M0DTPB4Json5Array(kept$2);
    }
    default: {
      return value;
    }
  }
}
function _M0MP38weopqrst12mooncassette4core7Request9normalize(self, drop_keys) {
  let keys;
  if (drop_keys === undefined) {
    keys = new _M0TPB9ArrayViewGsE(_M0FP38weopqrst12mooncassette4core19default__drop__keys, 0, _M0FP38weopqrst12mooncassette4core19default__drop__keys.length);
  } else {
    const _Some = drop_keys;
    keys = _Some;
  }
  return new _M0TP38weopqrst12mooncassette4core7Request(self.provider, self.model, _M0FP38weopqrst12mooncassette4core11prune__json(self.body, keys));
}
function _M0FP38weopqrst12mooncassette11fingerprint15canonical__text(provider, model, body) {
  return _M0FP38weopqrst12mooncassette5canon21to__canonical__string(_M0FP38weopqrst12mooncassette4core13request__json(provider, model, body));
}
function _M0FP38weopqrst12mooncassette11fingerprint18canonical__request(request) {
  return _M0FP38weopqrst12mooncassette11fingerprint15canonical__text(request.provider, request.model, request.body);
}
function _M0FP38weopqrst12mooncassette11fingerprint11fingerprint(request) {
  return `${_M0FP38weopqrst12mooncassette11fingerprint9algorithm}:${_M0FP38weopqrst12mooncassette5canon8hex__u64(_M0FP38weopqrst12mooncassette5canon15fnv1a64__string(_M0FP38weopqrst12mooncassette11fingerprint18canonical__request(request)))}`;
}
function _M0FP38weopqrst12mooncassette11fingerprint17integrity__digest(interaction) {
  return `${_M0FP38weopqrst12mooncassette11fingerprint9algorithm}:${_M0FP38weopqrst12mooncassette5canon8hex__u64(_M0FP38weopqrst12mooncassette5canon15fnv1a64__string(_M0FP38weopqrst12mooncassette5canon21to__canonical__string(_M0MP38weopqrst12mooncassette4core11Interaction8to__json(interaction))))}`;
}
function _M0FP38weopqrst12mooncassette5codec11has__stream(cassette) {
  const _bind = cassette.interactions;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const item = _bind[_];
      const _bind$3 = item.response.stream;
      if (_bind$3.$tag === 1) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP38weopqrst12mooncassette5codec18effective__version(cassette) {
  const required = _M0FP38weopqrst12mooncassette5codec11has__stream(cassette) ? _M0FP38weopqrst12mooncassette4core23stream__format__version : 1;
  return cassette.version > required ? cassette.version : required;
}
function _M0FP38weopqrst12mooncassette5codec21interaction__to__json(item) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = _M0FP38weopqrst12mooncassette11fingerprint11fingerprint(item.request);
  _M0MPB3Map3setGsRPB4JsonE(fields, "fingerprint", new _M0DTPB4Json6String(_p));
  const _p$2 = _M0FP38weopqrst12mooncassette11fingerprint17integrity__digest(item);
  _M0MPB3Map3setGsRPB4JsonE(fields, "integrity", new _M0DTPB4Json6String(_p$2));
  _M0MPB3Map3setGsRPB4JsonE(fields, "request", _M0MP38weopqrst12mooncassette4core7Request8to__json(item.request));
  _M0MPB3Map3setGsRPB4JsonE(fields, "response", _M0MP38weopqrst12mooncassette4core8Response8to__json(item.response));
  return new _M0DTPB4Json6Object(fields);
}
function _M0FP38weopqrst12mooncassette5codec9json__int(value) {
  const _p = value + 0;
  const _p$2 = _M0MPC13int3Int18to__string_2einner(value, 10);
  return new _M0DTPB4Json6Number(_p, _p$2);
}
function _M0FP38weopqrst12mooncassette5codec14meta__to__json(meta) {
  const _bind = [];
  const fields = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = meta.name;
  _M0MPB3Map3setGsRPB4JsonE(fields, "name", new _M0DTPB4Json6String(_p));
  const _p$2 = meta.generator;
  _M0MPB3Map3setGsRPB4JsonE(fields, "generator", new _M0DTPB4Json6String(_p$2));
  const _bind$2 = meta.recorded_at;
  if (_bind$2 === undefined) {
  } else {
    const _Some = _bind$2;
    const _text = _Some;
    _M0MPB3Map3setGsRPB4JsonE(fields, "recorded_at", new _M0DTPB4Json6String(_text));
  }
  return new _M0DTPB4Json6Object(fields);
}
function _M0FP38weopqrst12mooncassette5codec8to__json(cassette) {
  const _bind = [];
  const root = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(root, "format", new _M0DTPB4Json6String(_M0FP38weopqrst12mooncassette5codec11format__tag));
  _M0MPB3Map3setGsRPB4JsonE(root, "version", _M0FP38weopqrst12mooncassette5codec9json__int(_M0FP38weopqrst12mooncassette5codec18effective__version(cassette)));
  _M0MPB3Map3setGsRPB4JsonE(root, "meta", _M0FP38weopqrst12mooncassette5codec14meta__to__json(cassette.meta));
  const interactions = [];
  const _bind$2 = cassette.interactions;
  const _bind$3 = _bind$2.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$3) {
      const item = _bind$2[_];
      _M0MPC15array5Array4pushGRPB4JsonE(interactions, _M0FP38weopqrst12mooncassette5codec21interaction__to__json(item));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MPB3Map3setGsRPB4JsonE(root, "interactions", new _M0DTPB4Json5Array(interactions));
  return new _M0DTPB4Json6Object(root);
}
function _M0FP38weopqrst12mooncassette5codec6encode(cassette, indent) {
  const value = _M0FP38weopqrst12mooncassette5codec8to__json(cassette);
  if (indent === undefined) {
    return _M0FP38weopqrst12mooncassette5canon18to__pretty__string(value, _M0FP38weopqrst12mooncassette5codec6encodeN6constrS198);
  } else {
    const _Some = indent;
    const _width = _Some;
    return _width <= 0 ? _M0FP38weopqrst12mooncassette5canon21to__canonical__string(value) : _M0FP38weopqrst12mooncassette5canon18to__pretty__string(value, _width);
  }
}
function _M0FP38weopqrst12mooncassette5codec13expect__array(value, path) {
  if (value.$tag === 5) {
    const _Array = value;
    const _items = _Array._0;
    return new _M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(_items);
  } else {
    return new _M0DTPC16result6ResultGRPB5ArrayGRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}: expected a JSON array`));
  }
}
function _M0FP38weopqrst12mooncassette5codec11expect__int(value, path) {
  if (value.$tag === 3) {
    const _Number = value;
    const _number = _Number._0;
    if (_number === _M0MPC16double6Double7to__int(_number) + 0) {
      return new _M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(_M0MPC16double6Double7to__int(_number));
    } else {
      return new _M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}: expected an integer`));
    }
  } else {
    return new _M0DTPC16result6ResultGiRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}: expected an integer`));
  }
}
function _M0FP38weopqrst12mooncassette5codec14expect__object(value, path) {
  if (value.$tag === 6) {
    const _Object = value;
    const _fields = _Object._0;
    return new _M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(_fields);
  } else {
    return new _M0DTPC16result6ResultGRPB3MapGsRPB4JsonERP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}: expected a JSON object`));
  }
}
function _M0FP38weopqrst12mooncassette5codec14expect__string(value, path) {
  if (value.$tag === 4) {
    const _String = value;
    const _text = _String._0;
    return new _M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(_text);
  } else {
    return new _M0DTPC16result6ResultGsRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}: expected a string`));
  }
}
function _M0FP38weopqrst12mooncassette5codec14require__field(fields, key, path) {
  const _bind = _M0MPB3Map3getGsRPB4JsonE(fields, key);
  if (_bind === undefined) {
    return new _M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error64weopqrst_2fmooncassette_2fcore_2eCassetteError_2eSchemaViolation(`${path}.${key}: missing required field`));
  } else {
    const _Some = _bind;
    const _value = _Some;
    return new _M0DTPC16result6ResultGRPB4JsonRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(_value);
  }
}
function _M0FP38weopqrst12mooncassette5codec13check__digest(fields, path, key, recomputed) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14require__field(fields, key, path);
  let _tmp;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp, `${path}.${key}`);
  let stored;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    stored = _ok._0;
  } else {
    return _bind$2;
  }
  if (!(stored === recomputed)) {
    return new _M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eIntegrityViolation(`${path}.${key}: stored ${stored} does not match recomputed ${recomputed}`));
  } else {
    return new _M0DTPC16result6ResultGuRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(undefined);
  }
}
function _M0FP38weopqrst12mooncassette5codec17request__of__json(value, path) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, path);
  let fields;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    fields = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "provider", path);
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp, `${path}.provider`);
  let provider;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    provider = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "model", path);
  let _tmp$2;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$2 = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp$2, `${path}.model`);
  let model;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    model = _ok._0;
  } else {
    return _bind$5;
  }
  const _bind$6 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "body", path);
  let body;
  if (_bind$6.$tag === 1) {
    const _ok = _bind$6;
    body = _ok._0;
  } else {
    return _bind$6;
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(new _M0TP38weopqrst12mooncassette4core7Request(provider, model, body));
}
function _M0FP38weopqrst12mooncassette5codec24stream__frames__of__json(value, path) {
  const _bind = _M0FP38weopqrst12mooncassette5codec13expect__array(value, path);
  let items;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    items = _ok._0;
  } else {
    return _bind;
  }
  const frames = [];
  let index = 0;
  const _bind$2 = items.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const item = items[_];
      const frame_path = `${path}[${_M0MPC13int3Int18to__string_2einner(index, 10)}]`;
      const _bind$3 = _M0FP38weopqrst12mooncassette5codec14expect__object(item, frame_path);
      let fields;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        fields = _ok._0;
      } else {
        return _bind$3;
      }
      const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "data", frame_path);
      let _tmp$2;
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        _tmp$2 = _ok._0;
      } else {
        return _bind$4;
      }
      const _bind$5 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp$2, `${frame_path}.data`);
      let data;
      if (_bind$5.$tag === 1) {
        const _ok = _bind$5;
        data = _ok._0;
      } else {
        return _bind$5;
      }
      const _bind$6 = _M0MPB3Map3getGsRPB4JsonE(fields, "event");
      let event;
      if (_bind$6 === undefined) {
        event = undefined;
      } else {
        const _Some = _bind$6;
        const _event_value = _Some;
        const _bind$7 = _M0FP38weopqrst12mooncassette5codec14expect__string(_event_value, `${frame_path}.event`);
        if (_bind$7.$tag === 1) {
          const _ok = _bind$7;
          event = _ok._0;
        } else {
          return _bind$7;
        }
      }
      _M0MPC15array5Array4pushGRPB4JsonE(frames, new _M0TP38weopqrst12mooncassette4core11StreamFrame(event, data));
      index = index + 1 | 0;
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameERP38weopqrst12mooncassette4core13CassetteErrorE2Ok(frames);
}
function _M0FP38weopqrst12mooncassette5codec15usage__of__json(value, path) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, path);
  let fields;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    fields = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "input_tokens", path);
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec11expect__int(_tmp, `${path}.input_tokens`);
  let input_tokens;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    input_tokens = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "output_tokens", path);
  let _tmp$2;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$2 = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0FP38weopqrst12mooncassette5codec11expect__int(_tmp$2, `${path}.output_tokens`);
  let output_tokens;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    output_tokens = _ok._0;
  } else {
    return _bind$5;
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core5UsageRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(new _M0TP38weopqrst12mooncassette4core5Usage(input_tokens, output_tokens));
}
function _M0FP38weopqrst12mooncassette5codec18response__of__json(value, path) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, path);
  let fields;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    fields = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "status", path);
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec11expect__int(_tmp, `${path}.status`);
  let status;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    status = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "body", path);
  let body;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    body = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0MPB3Map3getGsRPB4JsonE(fields, "usage");
  let usage;
  if (_bind$5 === undefined) {
    usage = undefined;
  } else {
    const _Some = _bind$5;
    const _usage_value = _Some;
    const _bind$6 = _M0FP38weopqrst12mooncassette5codec15usage__of__json(_usage_value, `${path}.usage`);
    if (_bind$6.$tag === 1) {
      const _ok = _bind$6;
      usage = _ok._0;
    } else {
      return _bind$6;
    }
  }
  const _bind$6 = _M0MPB3Map3getGsRPB4JsonE(fields, "stream");
  let stream;
  if (_bind$6 === undefined) {
    stream = _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__;
  } else {
    const _Some = _bind$6;
    const _stream_value = _Some;
    const _bind$7 = _M0FP38weopqrst12mooncassette5codec24stream__frames__of__json(_stream_value, `${path}.stream`);
    let _tmp$2;
    if (_bind$7.$tag === 1) {
      const _ok = _bind$7;
      _tmp$2 = _ok._0;
    } else {
      return _bind$7;
    }
    stream = new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4Some(_tmp$2);
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8ResponseRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(new _M0TP38weopqrst12mooncassette4core8Response(status, body, usage, stream));
}
function _M0FP38weopqrst12mooncassette5codec21interaction__of__json(value, path, verify) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, path);
  let fields;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    fields = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "request", path);
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec17request__of__json(_tmp, `${path}.request`);
  let request;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    request = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "response", path);
  let _tmp$2;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$2 = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0FP38weopqrst12mooncassette5codec18response__of__json(_tmp$2, `${path}.response`);
  let response;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    response = _ok._0;
  } else {
    return _bind$5;
  }
  const interaction = new _M0TP38weopqrst12mooncassette4core11Interaction(request, response);
  if (verify) {
    const _bind$6 = _M0FP38weopqrst12mooncassette5codec13check__digest(fields, path, "fingerprint", _M0FP38weopqrst12mooncassette11fingerprint11fingerprint(request));
    if (_bind$6.$tag === 1) {
      const _ok = _bind$6;
      _ok._0;
    } else {
      return _bind$6;
    }
    const _bind$7 = _M0FP38weopqrst12mooncassette5codec13check__digest(fields, path, "integrity", _M0FP38weopqrst12mooncassette11fingerprint17integrity__digest(interaction));
    if (_bind$7.$tag === 1) {
      const _ok = _bind$7;
      _ok._0;
    } else {
      return _bind$7;
    }
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core11InteractionRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(interaction);
}
function _M0FP38weopqrst12mooncassette5codec14meta__of__json(value) {
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, "$.meta");
  let fields;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    fields = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "name", "$.meta");
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp, "$.meta.name");
  let name;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    name = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(fields, "generator", "$.meta");
  let _tmp$2;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$2 = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp$2, "$.meta.generator");
  let generator;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    generator = _ok._0;
  } else {
    return _bind$5;
  }
  const _bind$6 = _M0MPB3Map3getGsRPB4JsonE(fields, "recorded_at");
  let recorded_at;
  if (_bind$6 === undefined) {
    recorded_at = undefined;
  } else {
    const _Some = _bind$6;
    const _text = _Some;
    const _bind$7 = _M0FP38weopqrst12mooncassette5codec14expect__string(_text, "$.meta.recorded_at");
    if (_bind$7.$tag === 1) {
      const _ok = _bind$7;
      recorded_at = _ok._0;
    } else {
      return _bind$7;
    }
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core12CassetteMetaRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(new _M0TP38weopqrst12mooncassette4core12CassetteMeta(name, generator, recorded_at));
}
function _M0FP38weopqrst12mooncassette5codec8of__json(value, verify) {
  const should_verify = verify === -1 ? true : verify;
  const _bind = _M0FP38weopqrst12mooncassette5codec14expect__object(value, "$");
  let root;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    root = _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = _M0FP38weopqrst12mooncassette5codec14require__field(root, "format", "$");
  let _tmp;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    _tmp = _ok._0;
  } else {
    return _bind$2;
  }
  const _bind$3 = _M0FP38weopqrst12mooncassette5codec14expect__string(_tmp, "$.format");
  let tag;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    tag = _ok._0;
  } else {
    return _bind$3;
  }
  if (!(tag === _M0FP38weopqrst12mooncassette5codec11format__tag)) {
    return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed(`$.format: expected \"${_M0FP38weopqrst12mooncassette5codec11format__tag}\", got \"${tag}\"`));
  }
  const _bind$4 = _M0FP38weopqrst12mooncassette5codec14require__field(root, "version", "$");
  let _tmp$2;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$2 = _ok._0;
  } else {
    return _bind$4;
  }
  const _bind$5 = _M0FP38weopqrst12mooncassette5codec11expect__int(_tmp$2, "$.version");
  let version;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    version = _ok._0;
  } else {
    return _bind$5;
  }
  if (!(version >= 1 && version <= 2)) {
    return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error67weopqrst_2fmooncassette_2fcore_2eCassetteError_2eUnsupportedVersion(version));
  }
  const _bind$6 = _M0FP38weopqrst12mooncassette5codec14require__field(root, "meta", "$");
  let _tmp$3;
  if (_bind$6.$tag === 1) {
    const _ok = _bind$6;
    _tmp$3 = _ok._0;
  } else {
    return _bind$6;
  }
  const _bind$7 = _M0FP38weopqrst12mooncassette5codec14meta__of__json(_tmp$3);
  let meta;
  if (_bind$7.$tag === 1) {
    const _ok = _bind$7;
    meta = _ok._0;
  } else {
    return _bind$7;
  }
  const _bind$8 = _M0FP38weopqrst12mooncassette5codec14require__field(root, "interactions", "$");
  let _tmp$4;
  if (_bind$8.$tag === 1) {
    const _ok = _bind$8;
    _tmp$4 = _ok._0;
  } else {
    return _bind$8;
  }
  const _bind$9 = _M0FP38weopqrst12mooncassette5codec13expect__array(_tmp$4, "$.interactions");
  let items;
  if (_bind$9.$tag === 1) {
    const _ok = _bind$9;
    items = _ok._0;
  } else {
    return _bind$9;
  }
  const interactions = [];
  let index = 0;
  const _bind$10 = items.length;
  let _tmp$5 = 0;
  while (true) {
    const _ = _tmp$5;
    if (_ < _bind$10) {
      const item = items[_];
      const path = `$.interactions[${_M0MPC13int3Int18to__string_2einner(index, 10)}]`;
      const _bind$11 = _M0FP38weopqrst12mooncassette5codec21interaction__of__json(item, path, should_verify);
      let _tmp$6;
      if (_bind$11.$tag === 1) {
        const _ok = _bind$11;
        _tmp$6 = _ok._0;
      } else {
        return _bind$11;
      }
      _M0MPC15array5Array4pushGRPB4JsonE(interactions, _tmp$6);
      index = index + 1 | 0;
      _tmp$5 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE2Ok(new _M0TP38weopqrst12mooncassette4core8Cassette(version, meta, interactions));
}
function _M0FP38weopqrst12mooncassette5codec6decode(text, verify) {
  const should_verify = verify === -1 ? true : verify;
  let value;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0FPC14json13parse_2einner(text, 1024);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        value = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed("input is not valid JSON"));
  }
  if (value.$tag === 6) {
    return _M0FP38weopqrst12mooncassette5codec8of__json(value, should_verify);
  } else {
    return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core8CassetteRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed("top-level value must be a JSON object"));
  }
}
function _M0FP38weopqrst12mooncassette5codec15decode__request(text) {
  let value;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0FPC14json13parse_2einner(text, 1024);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        value = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP38weopqrst12mooncassette4core7RequestRP38weopqrst12mooncassette4core13CassetteErrorE3Err(new _M0DTPC15error5Error58weopqrst_2fmooncassette_2fcore_2eCassetteError_2eMalformed("request: input is not valid JSON"));
  }
  return _M0FP38weopqrst12mooncassette5codec17request__of__json(value, "$");
}
function _M0IP38weopqrst12mooncassette5drift9DriftKindPB2Eq5equal(_x_44, _x_45) {
  switch (_x_44) {
    case 0: {
      if (_x_45 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_45 === 1) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_45 === 2) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0MP38weopqrst12mooncassette5drift11DriftReport9count__of(self, kind) {
  let total = 0;
  const _bind = self.entries;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind[_];
      if (_M0IP38weopqrst12mooncassette5drift9DriftKindPB2Eq5equal(entry.kind, kind)) {
        total = total + 1 | 0;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return total;
}
function _M0MP38weopqrst12mooncassette5drift11DriftReport7summary(self) {
  if (self.entries.length === 0) {
    return `no drift: ${_M0MPC13int3Int18to__string_2einner(self.unchanged, 10)} interaction(s) identical`;
  }
  return `drift detected: removed=${_M0MPC13int3Int18to__string_2einner(_M0MP38weopqrst12mooncassette5drift11DriftReport9count__of(self, 0), 10)} changed=${_M0MPC13int3Int18to__string_2einner(_M0MP38weopqrst12mooncassette5drift11DriftReport9count__of(self, 2), 10)} added=${_M0MPC13int3Int18to__string_2einner(_M0MP38weopqrst12mooncassette5drift11DriftReport9count__of(self, 1), 10)} unchanged=${_M0MPC13int3Int18to__string_2einner(self.unchanged, 10)}`;
}
function _M0FP38weopqrst12mooncassette5drift11index__text(index) {
  if (index === undefined) {
    return "-";
  } else {
    const _Some = index;
    const _value = _Some;
    return _M0MPC13int3Int18to__string_2einner(_value, 10);
  }
}
function _M0FP38weopqrst12mooncassette5drift13render__entry(entry) {
  const _bind = entry.kind;
  switch (_bind) {
    case 0: {
      return `[removed] ${entry.model} #${_M0FP38weopqrst12mooncassette5drift11index__text(entry.old_index)}  ${entry.fingerprint}`;
    }
    case 1: {
      return `[added]   ${entry.model} #${_M0FP38weopqrst12mooncassette5drift11index__text(entry.new_index)}  ${entry.fingerprint}`;
    }
    default: {
      return `[changed] ${entry.model} #${_M0FP38weopqrst12mooncassette5drift11index__text(entry.old_index)} -> #${_M0FP38weopqrst12mooncassette5drift11index__text(entry.new_index)}  ${entry.fingerprint}`;
    }
  }
}
function _M0MP38weopqrst12mooncassette5drift11DriftReport5lines(self) {
  const out = [];
  const _bind = self.entries;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind[_];
      _M0MPC15array5Array4pushGRPB4JsonE(out, _M0FP38weopqrst12mooncassette5drift13render__entry(entry));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP38weopqrst12mooncassette5drift11append__all(target, source) {
  const _bind = source.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const item = source[_];
      _M0MPC15array5Array4pushGRPB4JsonE(target, item);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette5drift12request__key(interaction) {
  return _M0FP38weopqrst12mooncassette11fingerprint11fingerprint(_M0MP38weopqrst12mooncassette4core7Request9normalize(interaction.request, undefined));
}
function _M0FP38weopqrst12mooncassette5drift14response__text(interaction) {
  return _M0FP38weopqrst12mooncassette5canon21to__canonical__string(_M0MP38weopqrst12mooncassette4core8Response8to__json(interaction.response));
}
function _M0FP38weopqrst12mooncassette5drift18short__fingerprint(fingerprint) {
  const parts = _M0MPB4Iter9to__arrayGRPC16string10StringViewE(_M0MPC16string6String5split(fingerprint, new _M0TPC16string10StringView(_M0FP38weopqrst12mooncassette5drift18short__fingerprintN7_2abindS83, 0, _M0FP38weopqrst12mooncassette5drift18short__fingerprintN7_2abindS83.length)));
  if (parts.length !== 2) {
    return fingerprint;
  }
  const digest = _M0MPC16string10StringView9to__owned(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(parts, 1));
  return digest.length <= 8 ? digest : _M0MPC16string10StringView9to__owned(_M0MPC16string6String11sub_2einner(digest, 0, _M0FP38weopqrst12mooncassette5drift18short__fingerprintN6constrS108));
}
function _M0FP38weopqrst12mooncassette5drift7compare(old, new_) {
  const _bind = [];
  const new_buckets = _M0MPB3Map3MapGsRPB5ArrayGiEE(new _M0TPB9ArrayViewGUsRPB5ArrayGiEEE(_bind, 0, 0), undefined);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < new_.interactions.length) {
      const key = _M0FP38weopqrst12mooncassette5drift12request__key(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(new_.interactions, i));
      const _bind$2 = _M0MPB3Map3getGsRPB5ArrayGiEE(new_buckets, key);
      if (_bind$2.$tag === 1) {
        const _Some = _bind$2;
        const _bucket = _Some._0;
        _M0MPC15array5Array4pushGiE(_bucket, i);
      } else {
        const bucket = [i];
        _M0MPB3Map3setGsRPB5ArrayGiEE(new_buckets, key, bucket);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$2 = [];
  const consumed = _M0MPB3Map3MapGsiE(new _M0TPB9ArrayViewGUsiEE(_bind$2, 0, 0), undefined);
  const taken = _M0MPC15array5Array4makeGbE(new_.interactions.length, false);
  const removed = [];
  const changed = [];
  let unchanged = 0;
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < old.interactions.length) {
      const item = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(old.interactions, i);
      const key = _M0FP38weopqrst12mooncassette5drift12request__key(item);
      const offset = _M0MPB3Map16get__or__defaultGsiE(consumed, key, 0);
      const _bind$3 = _M0MPB3Map3getGsRPB5ArrayGiEE(new_buckets, key);
      let candidate;
      if (_bind$3.$tag === 1) {
        const _Some = _bind$3;
        const _bucket = _Some._0;
        candidate = offset < _bucket.length ? _M0MPC15array5Array2atGiE(_bucket, offset) : undefined;
      } else {
        candidate = undefined;
      }
      if (candidate === undefined) {
        _M0MPC15array5Array4pushGRPB4JsonE(removed, new _M0TP38weopqrst12mooncassette5drift10DriftEntry(0, _M0FP38weopqrst12mooncassette5drift18short__fingerprint(key), item.request.model, i, undefined));
      } else {
        const _Some = candidate;
        const _j = _Some;
        _M0MPB3Map3setGsiE(consumed, key, offset + 1 | 0);
        _M0MPC15array5Array3setGbE(taken, _j, true);
        if (_M0FP38weopqrst12mooncassette5drift14response__text(item) === _M0FP38weopqrst12mooncassette5drift14response__text(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(new_.interactions, _j))) {
          unchanged = unchanged + 1 | 0;
        } else {
          _M0MPC15array5Array4pushGRPB4JsonE(changed, new _M0TP38weopqrst12mooncassette5drift10DriftEntry(2, _M0FP38weopqrst12mooncassette5drift18short__fingerprint(key), item.request.model, i, _j));
        }
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const added = [];
  let _tmp$3 = 0;
  while (true) {
    const j = _tmp$3;
    if (j < new_.interactions.length) {
      if (!_M0MPC15array5Array2atGbE(taken, j)) {
        const item = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(new_.interactions, j);
        _M0MPC15array5Array4pushGRPB4JsonE(added, new _M0TP38weopqrst12mooncassette5drift10DriftEntry(1, _M0FP38weopqrst12mooncassette5drift18short__fingerprint(_M0FP38weopqrst12mooncassette5drift12request__key(item)), item.request.model, undefined, j));
      }
      _tmp$3 = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const entries = [];
  _M0FP38weopqrst12mooncassette5drift11append__all(entries, removed);
  _M0FP38weopqrst12mooncassette5drift11append__all(entries, changed);
  _M0FP38weopqrst12mooncassette5drift11append__all(entries, added);
  return new _M0TP38weopqrst12mooncassette5drift11DriftReport(entries, unchanged);
}
function _M0MP38weopqrst12mooncassette7matcher11MatchPolicy4name(self) {
  switch (self.$tag) {
    case 0: {
      return "Exact";
    }
    case 1: {
      return "FingerprintOnly";
    }
    case 2: {
      return "Subset";
    }
    default: {
      return "Sequential";
    }
  }
}
function _M0FP38weopqrst12mooncassette7matcher10push__path(out, value, limit) {
  if (out.length < limit) {
    _M0MPC15array5Array4pushGRPB4JsonE(out, value);
    return;
  } else {
    return;
  }
}
function _M0FP38weopqrst12mooncassette7matcher13contains__key(keys, target) {
  const _bind = keys.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const key = keys[_];
      if (key === target) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP38weopqrst12mooncassette7matcher16compare__strings(left, right) {
  const a = _M0MPC16string6String9to__array(left);
  const b = _M0MPC16string6String9to__array(right);
  const limit = a.length < b.length ? a.length : b.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < limit) {
      const x = _M0MPC15array5Array2atGcE(a, i);
      const y = _M0MPC15array5Array2atGcE(b, i);
      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (a.length < b.length) {
    return -1;
  }
  if (a.length > b.length) {
    return 1;
  }
  return 0;
}
function _M0FP38weopqrst12mooncassette7matcher13sort__strings(items) {
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < items.length) {
      const value = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, i);
      let j = i - 1 | 0;
      while (true) {
        if (j >= 0 && _M0FP38weopqrst12mooncassette7matcher16compare__strings(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, j), value) > 0) {
          _M0MPC15array5Array3setGsE(items, j + 1 | 0, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, j));
          j = j - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0MPC15array5Array3setGsE(items, j + 1 | 0, value);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette7matcher18sorted__key__union(left, right) {
  const keys = [];
  const _it = _M0MPB3Map4keysGsRPB4JsonE(left);
  while (true) {
    const _bind = _M0MPB4Iter4nextGsE(_it);
    if (_bind === undefined) {
      break;
    } else {
      const _Some = _bind;
      const _key = _Some;
      _M0MPC15array5Array4pushGRPB4JsonE(keys, _key);
      continue;
    }
  }
  const _it$2 = _M0MPB3Map4keysGsRPB4JsonE(right);
  while (true) {
    const _bind = _M0MPB4Iter4nextGsE(_it$2);
    if (_bind === undefined) {
      break;
    } else {
      const _Some = _bind;
      const _key = _Some;
      if (!_M0FP38weopqrst12mooncassette7matcher13contains__key(keys, _key)) {
        _M0MPC15array5Array4pushGRPB4JsonE(keys, _key);
      }
      continue;
    }
  }
  _M0FP38weopqrst12mooncassette7matcher13sort__strings(keys);
  return keys;
}
function _M0FP38weopqrst12mooncassette7matcher20collect__differences(recorded, incoming, path, out, limit) {
  if (out.length >= limit) {
    return undefined;
  }
  let a;
  let b;
  _L: {
    switch (recorded.$tag) {
      case 6: {
        const _Object = recorded;
        const _left = _Object._0;
        if (incoming.$tag === 6) {
          const _Object$2 = incoming;
          const _right = _Object$2._0;
          const _bind = _M0FP38weopqrst12mooncassette7matcher18sorted__key__union(_left, _right);
          const _bind$2 = _bind.length;
          let _tmp = 0;
          while (true) {
            const _ = _tmp;
            if (_ < _bind$2) {
              const key = _bind[_];
              const field_path = `${path}.${key}`;
              const _bind$3 = _M0MPB3Map3getGsRPB4JsonE(_left, key);
              const _bind$4 = _M0MPB3Map3getGsRPB4JsonE(_right, key);
              if (_bind$3 === undefined) {
                if (_bind$4 === undefined) {
                } else {
                  _M0FP38weopqrst12mooncassette7matcher10push__path(out, `${field_path} (only in the request)`, limit);
                }
              } else {
                const _Some = _bind$3;
                const _a = _Some;
                if (_bind$4 === undefined) {
                  _M0FP38weopqrst12mooncassette7matcher10push__path(out, `${field_path} (only in the recording)`, limit);
                } else {
                  const _Some$2 = _bind$4;
                  const _b = _Some$2;
                  _M0FP38weopqrst12mooncassette7matcher20collect__differences(_a, _b, field_path, out, limit);
                }
              }
              _tmp = _ + 1 | 0;
              continue;
            } else {
              return;
            }
          }
        } else {
          a = recorded;
          b = incoming;
          break _L;
        }
      }
      case 5: {
        const _Array = recorded;
        const _left$2 = _Array._0;
        if (incoming.$tag === 5) {
          const _Array$2 = incoming;
          const _right = _Array$2._0;
          const common = _left$2.length < _right.length ? _left$2.length : _right.length;
          let _tmp = 0;
          while (true) {
            const i = _tmp;
            if (i < common) {
              _M0FP38weopqrst12mooncassette7matcher20collect__differences(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(_left$2, i), _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(_right, i), `${path}[${_M0MPC13int3Int18to__string_2einner(i, 10)}]`, out, limit);
              _tmp = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          if (_left$2.length !== _right.length) {
            _M0FP38weopqrst12mooncassette7matcher10push__path(out, `${path}.length (${_M0MPC13int3Int18to__string_2einner(_left$2.length, 10)} recorded vs ${_M0MPC13int3Int18to__string_2einner(_right.length, 10)} requested)`, limit);
            return;
          } else {
            return;
          }
        } else {
          a = recorded;
          b = incoming;
          break _L;
        }
      }
      default: {
        a = recorded;
        b = incoming;
        break _L;
      }
    }
  }
  if (_M0IP016_24default__implPB2Eq10not__equalGRPB4JsonE(a, b)) {
    _M0FP38weopqrst12mooncassette7matcher10push__path(out, path, limit);
    return;
  } else {
    return;
  }
}
function _M0FP38weopqrst12mooncassette7matcher18sort__by__distance(items) {
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < items.length) {
      const value = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, i);
      let j = i - 1 | 0;
      while (true) {
        if (j >= 0 && _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, j).differing_paths.length > value.differing_paths.length) {
          _M0MPC15array5Array3setGsE(items, j + 1 | 0, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, j));
          j = j - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0MPC15array5Array3setGsE(items, j + 1 | 0, value);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP38weopqrst12mooncassette7matcher8diagnose(request, interactions, policy, cursor, top) {
  let limit;
  if (top === undefined) {
    limit = 3;
  } else {
    const _Some = top;
    limit = _Some;
  }
  const total = interactions.end - interactions.start | 0;
  const request_view = _M0MP38weopqrst12mooncassette4core7Request8to__json(request);
  const collected = [];
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < total) {
      if (i < 0 || i >= (interactions.end - interactions.start | 0)) {
        $panic();
      }
      const recorded = interactions.buf[interactions.start + i | 0].request;
      const paths = [];
      _M0FP38weopqrst12mooncassette7matcher20collect__differences(_M0MP38weopqrst12mooncassette4core7Request8to__json(recorded), request_view, "$", paths, 5);
      _M0MPC15array5Array4pushGRPB4JsonE(collected, new _M0TP38weopqrst12mooncassette7matcher9Candidate(i, recorded.provider, recorded.model, paths));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP38weopqrst12mooncassette7matcher18sort__by__distance(collected);
  const ranked = [];
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < collected.length && i < limit) {
      _M0MPC15array5Array4pushGRPB4JsonE(ranked, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(collected, i));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP38weopqrst12mooncassette7matcher9Diagnosis(policy, cursor, total, ranked);
}
function _M0FP38weopqrst12mooncassette7matcher13render__paths(paths) {
  if (paths.length === 0) {
    return "(no field-level difference; check the matching policy)";
  }
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < paths.length) {
      if (i > 0) {
        _M0IPB13StringBuilderPB6Logger13write__string(sb, ", ");
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(paths, i));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return sb.val;
}
function _M0MP38weopqrst12mooncassette7matcher9Diagnosis5lines(self) {
  const out = [];
  _M0MPC15array5Array4pushGRPB4JsonE(out, `policy=${_M0MP38weopqrst12mooncassette7matcher11MatchPolicy4name(self.policy)}  cursor=${_M0MPC13int3Int18to__string_2einner(self.cursor, 10)}  interactions=${_M0MPC13int3Int18to__string_2einner(self.total, 10)}`);
  if (self.candidates.length === 0) {
    _M0MPC15array5Array4pushGRPB4JsonE(out, "no candidate available for comparison");
  }
  const _bind = self.candidates;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const candidate = _bind[_];
      _M0MPC15array5Array4pushGRPB4JsonE(out, `  #${_M0MPC13int3Int18to__string_2einner(candidate.index, 10)}  provider=${candidate.provider}  model=${candidate.model}  differs: ${_M0FP38weopqrst12mooncassette7matcher13render__paths(candidate.differing_paths)}`);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0MP38weopqrst12mooncassette8sanitize14SanitizePolicy7default() {
  return new _M0TP38weopqrst12mooncassette8sanitize14SanitizePolicy(["authorization", "proxy-authorization", "api-key", "x-api-key", "api_key", "apikey", "token", "cookie", "set-cookie", "password"], ["_key", "_token", "_secret", "_password", "_credential"], "***REDACTED***", true);
}
function _M0FP38weopqrst12mooncassette8sanitize16ascii__lowercase(text) {
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const _bind = text.length;
  let _tmp = 0;
  while (true) {
    const _string_index = _tmp;
    if (_string_index < _bind) {
      let _decoded_next_string_index;
      let _decoded_char;
      _L: {
        const _bind$2 = text.charCodeAt(_string_index);
        if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
          const _bind$3 = text.charCodeAt(_string_index + 1 | 0);
          if (_bind$3 >= 56320 && _bind$3 <= 57343) {
            const _tmp$2 = _string_index + 2 | 0;
            const _p = (((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$2;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        } else {
          const _tmp$2 = _string_index + 1 | 0;
          const _p = _bind$2;
          _decoded_next_string_index = _tmp$2;
          _decoded_char = _p;
          break _L;
        }
      }
      _M0IPB13StringBuilderPB6Logger11write__char(sb, _M0MPC14char4Char20to__ascii__lowercase(_decoded_char));
      _tmp = _decoded_next_string_index;
      continue;
    } else {
      break;
    }
  }
  return sb.val;
}
function _M0FP38weopqrst12mooncassette8sanitize18is__sensitive__key(key, policy) {
  const lowered = _M0FP38weopqrst12mooncassette8sanitize16ascii__lowercase(key);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < policy.exact_keys.length) {
      if (lowered === _M0FP38weopqrst12mooncassette8sanitize16ascii__lowercase(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(policy.exact_keys, i))) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < policy.key_suffixes.length) {
      const suffix = _M0FP38weopqrst12mooncassette8sanitize16ascii__lowercase(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(policy.key_suffixes, i));
      if (lowered.length >= suffix.length && _M0MPC16string6String11has__suffix(lowered, new _M0TPC16string10StringView(suffix, 0, suffix.length))) {
        return true;
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP38weopqrst12mooncassette8sanitize22is__secret__body__char(ch) {
  return _M0MPC14char4Char21is__ascii__alphabetic(ch) || (_M0MPC14char4Char16is__ascii__digit(ch) || (ch === 45 || ch === 95));
}
function _M0FP38weopqrst12mooncassette8sanitize18secret__shape__end(chars, start) {
  const total = chars.length;
  if ((start + 3 | 0) > total) {
    return undefined;
  }
  if (!(_M0MPC15array5Array2atGcE(chars, start) === 115 && (_M0MPC15array5Array2atGcE(chars, start + 1 | 0) === 107 && _M0MPC15array5Array2atGcE(chars, start + 2 | 0) === 45))) {
    return undefined;
  }
  let end = start + 3 | 0;
  while (true) {
    if (end < total && _M0FP38weopqrst12mooncassette8sanitize22is__secret__body__char(_M0MPC15array5Array2atGcE(chars, end))) {
      end = end + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return (end - (start + 3 | 0) | 0) >= 8 ? end : undefined;
}
function _M0FP38weopqrst12mooncassette8sanitize22redact__secret__shapes(text, placeholder) {
  const chars = [];
  const _bind = text.length;
  let _tmp = 0;
  while (true) {
    const _string_index = _tmp;
    if (_string_index < _bind) {
      let _decoded_next_string_index;
      let _decoded_char;
      _L: {
        const _bind$2 = text.charCodeAt(_string_index);
        if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
          const _bind$3 = text.charCodeAt(_string_index + 1 | 0);
          if (_bind$3 >= 56320 && _bind$3 <= 57343) {
            const _tmp$2 = _string_index + 2 | 0;
            const _p = (((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$2;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        } else {
          const _tmp$2 = _string_index + 1 | 0;
          const _p = _bind$2;
          _decoded_next_string_index = _tmp$2;
          _decoded_char = _p;
          break _L;
        }
      }
      _M0MPC15array5Array4pushGcE(chars, _decoded_char);
      _tmp = _decoded_next_string_index;
      continue;
    } else {
      break;
    }
  }
  const total = chars.length;
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  let index = 0;
  while (true) {
    if (index < total) {
      const _bind$2 = _M0FP38weopqrst12mooncassette8sanitize18secret__shape__end(chars, index);
      if (_bind$2 === undefined) {
        _M0IPB13StringBuilderPB6Logger11write__char(out, _M0MPC15array5Array2atGcE(chars, index));
        index = index + 1 | 0;
      } else {
        const _Some = _bind$2;
        const _end = _Some;
        _M0IPB13StringBuilderPB6Logger13write__string(out, placeholder);
        index = _end;
      }
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(value, policy) {
  switch (value.$tag) {
    case 6: {
      const _Object = value;
      const _fields = _Object._0;
      const _bind = [];
      const out = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
      const _it = _M0MPB3Map4keysGsRPB4JsonE(_fields);
      while (true) {
        const _bind$2 = _M0MPB4Iter4nextGsE(_it);
        if (_bind$2 === undefined) {
          break;
        } else {
          const _Some = _bind$2;
          const _key = _Some;
          const _bind$3 = _M0MPB3Map3getGsRPB4JsonE(_fields, _key);
          if (_bind$3 === undefined) {
          } else {
            const _Some$2 = _bind$3;
            const _child = _Some$2;
            if (_M0FP38weopqrst12mooncassette8sanitize18is__sensitive__key(_key, policy)) {
              const _p = policy.placeholder;
              _M0MPB3Map3setGsRPB4JsonE(out, _key, new _M0DTPB4Json6String(_p));
            } else {
              _M0MPB3Map3setGsRPB4JsonE(out, _key, _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(_child, policy));
            }
          }
          continue;
        }
      }
      return new _M0DTPB4Json6Object(out);
    }
    case 5: {
      const _Array = value;
      const _items = _Array._0;
      const out$2 = [];
      const _bind$2 = _items.length;
      let _tmp = 0;
      while (true) {
        const _ = _tmp;
        if (_ < _bind$2) {
          const item = _items[_];
          _M0MPC15array5Array4pushGRPB4JsonE(out$2, _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(item, policy));
          _tmp = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return new _M0DTPB4Json5Array(out$2);
    }
    case 4: {
      const _String = value;
      const _text = _String._0;
      if (policy.scan_secret_shapes) {
        const _p = _M0FP38weopqrst12mooncassette8sanitize22redact__secret__shapes(_text, policy.placeholder);
        return new _M0DTPB4Json6String(_p);
      } else {
        return value;
      }
    }
    default: {
      return value;
    }
  }
}
function _M0FP38weopqrst12mooncassette8sanitize17sanitize__request(request, policy) {
  return new _M0TP38weopqrst12mooncassette4core7Request(request.provider, request.model, _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(request.body, policy));
}
function _M0FP38weopqrst12mooncassette8sanitize14sanitize__text(text, policy) {
  const _bind = _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(new _M0DTPB4Json6String(text), policy);
  if (_bind.$tag === 4) {
    const _String = _bind;
    return _String._0;
  } else {
    return text;
  }
}
function _M0FP38weopqrst12mooncassette8sanitize21sanitize__frame__data(data, policy) {
  let parsed;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0FPC14json13parse_2einner(new _M0TPC16string10StringView(data, 0, data.length), 1024);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        parsed = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return _M0FP38weopqrst12mooncassette8sanitize14sanitize__text(data, policy);
  }
  _L$2: {
    switch (parsed.$tag) {
      case 6: {
        break _L$2;
      }
      case 5: {
        break _L$2;
      }
      default: {
        return _M0FP38weopqrst12mooncassette8sanitize14sanitize__text(data, policy);
      }
    }
  }
  return _M0FP38weopqrst12mooncassette5canon21to__canonical__string(_M0FP38weopqrst12mooncassette8sanitize14sanitize__json(parsed, policy));
}
function _M0FP38weopqrst12mooncassette8sanitize16sanitize__frames(frames, policy) {
  const out = [];
  const _bind = frames.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const frame = frames[_];
      _M0MPC15array5Array4pushGRPB4JsonE(out, new _M0TP38weopqrst12mooncassette4core11StreamFrame(frame.event, _M0FP38weopqrst12mooncassette8sanitize21sanitize__frame__data(frame.data, policy)));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP38weopqrst12mooncassette8sanitize18sanitize__response(response, policy) {
  const _tmp = response.status;
  const _tmp$2 = _M0FP38weopqrst12mooncassette8sanitize14sanitize__json(response.body, policy);
  const _tmp$3 = response.usage;
  const _bind = response.stream;
  let _tmp$4;
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _frames = _Some._0;
    _tmp$4 = new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4Some(_M0FP38weopqrst12mooncassette8sanitize16sanitize__frames(_frames, policy));
  } else {
    _tmp$4 = _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__;
  }
  return new _M0TP38weopqrst12mooncassette4core8Response(_tmp, _tmp$2, _tmp$3, _tmp$4);
}
function _M0FP38weopqrst12mooncassette8sanitize21sanitize__interaction(interaction, policy) {
  return new _M0TP38weopqrst12mooncassette4core11Interaction(_M0FP38weopqrst12mooncassette8sanitize17sanitize__request(interaction.request, policy), _M0FP38weopqrst12mooncassette8sanitize18sanitize__response(interaction.response, policy));
}
function _M0FP38weopqrst12mooncassette8sanitize18sanitize__cassette(cassette, policy) {
  const interactions = [];
  const _bind = cassette.interactions;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const item = _bind[_];
      _M0MPC15array5Array4pushGRPB4JsonE(interactions, _M0FP38weopqrst12mooncassette8sanitize21sanitize__interaction(item, policy));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP38weopqrst12mooncassette4core8Cassette(cassette.version, cassette.meta, interactions);
}
function _M0FP28weopqrst12mooncassette19compare__recordings(old, new_) {
  return _M0FP38weopqrst12mooncassette5drift7compare(old, new_);
}
function _M0IP38weopqrst19mooncassette_2ddemo4main4ViewPB2Eq5equal(_x_148, _x_149) {
  switch (_x_148) {
    case 0: {
      if (_x_149 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_149 === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (_x_149 === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      if (_x_149 === 3) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_149 === 4) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0MP38weopqrst19mooncassette_2ddemo4main4View4name(self) {
  switch (self) {
    case 0: {
      return "overview";
    }
    case 1: {
      return "detail";
    }
    case 2: {
      return "drift";
    }
    case 3: {
      return "diagnose";
    }
    default: {
      return "sanitize";
    }
  }
}
function _M0MP38weopqrst19mooncassette_2ddemo4main4View5title(self) {
  switch (self) {
    case 0: {
      return "概览";
    }
    case 1: {
      return "单条详情";
    }
    case 2: {
      return "漂移对比";
    }
    case 3: {
      return "未命中诊断";
    }
    default: {
      return "脱敏预览";
    }
  }
}
function _M0MP38weopqrst19mooncassette_2ddemo4main4View4hint(self) {
  switch (self) {
    case 0: {
      return "这份录制里有哪些调用、各是什么形态";
    }
    case 1: {
      return "某一次调用的完整请求与响应";
    }
    case 2: {
      return "两份录制之间，哪些调用变了";
    }
    case 3: {
      return "贴一个请求，看它为什么匹配不上";
    }
    default: {
      return "密钥在落盘前被抹成了什么";
    }
  }
}
function _M0FP38weopqrst19mooncassette_2ddemo4main8view__of(name) {
  switch (name) {
    case "overview": {
      return _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS324;
    }
    case "detail": {
      return _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS325;
    }
    case "drift": {
      return _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS326;
    }
    case "diagnose": {
      return _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS327;
    }
    case "sanitize": {
      return _M0FP38weopqrst19mooncassette_2ddemo4main8view__ofN6constrS328;
    }
    default: {
      return undefined;
    }
  }
}
function _M0MP38weopqrst19mooncassette_2ddemo4main8AppState3new() {
  return new _M0TP38weopqrst19mooncassette_2ddemo4main8AppState(undefined, undefined, 0, undefined, false, false, "", "还没有载入录制。点「载入自带样例」，或选择一份 cassette 文件。");
}
function _M0MP38weopqrst19mooncassette_2ddemo4main8AppState6decode(self, label, text) {
  let cassette;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0FP38weopqrst12mooncassette5codec6decode(new _M0TPC16string10StringView(text, 0, text.length), -1);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        cassette = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    self.status = `载入「${label}」失败：${_M0IP016_24default__implPB4Show10to__stringGRP38weopqrst12mooncassette4core13CassetteErrorE(_try_err)}　（错误里的路径可以直接拿去对照文件）`;
    return undefined;
  }
  return new _M0TP38weopqrst19mooncassette_2ddemo4main6Loaded(label, cassette, text.length);
}
function _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(self, label, text) {
  const _bind = _M0MP38weopqrst19mooncassette_2ddemo4main8AppState6decode(self, label, text);
  if (_bind === undefined) {
    return;
  } else {
    const _Some = _bind;
    const _loaded = _Some;
    self.primary_tape = _loaded;
    self.detail = undefined;
    const _p = _loaded.cassette;
    self.status = `主录制已换成「${label}」：${_M0MPC13int3Int18to__string_2einner(_p.interactions.length, 10)} 条记录，${_M0MPC13int3Int18to__string_2einner(_loaded.size, 10)} 字符。`;
    return;
  }
}
function _M0MP38weopqrst19mooncassette_2ddemo4main8AppState16load__comparison(self, label, text) {
  const _bind = _M0MP38weopqrst19mooncassette_2ddemo4main8AppState6decode(self, label, text);
  if (_bind === undefined) {
    return;
  } else {
    const _Some = _bind;
    const _loaded = _Some;
    self.comparison_tape = _loaded;
    const _p = _loaded.cassette;
    self.status = `对比录制已换成「${label}」：${_M0MPC13int3Int18to__string_2einner(_p.interactions.length, 10)} 条记录。`;
    return;
  }
}
function _M0FP38weopqrst19mooncassette_2ddemo4main13user__message(role, content) {
  const _bind = [];
  const message = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(message, "role", new _M0DTPB4Json6String(role));
  _M0MPB3Map3setGsRPB4JsonE(message, "content", new _M0DTPB4Json6String(content));
  return new _M0DTPB4Json6Object(message);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main13chat__request(prompt) {
  const _bind = [];
  const body = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = "gpt-4o";
  _M0MPB3Map3setGsRPB4JsonE(body, "model", new _M0DTPB4Json6String(_p));
  const _p$2 = 0.2;
  const _p$3 = undefined;
  _M0MPB3Map3setGsRPB4JsonE(body, "temperature", new _M0DTPB4Json6Number(_p$2, _p$3));
  const _p$4 = [_M0FP38weopqrst19mooncassette_2ddemo4main13user__message("user", prompt)];
  _M0MPB3Map3setGsRPB4JsonE(body, "messages", new _M0DTPB4Json5Array(_p$4));
  return _M0MP38weopqrst12mooncassette4core7Request3new("openai", "gpt-4o", new _M0DTPB4Json6Object(body));
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12chat__answer(id, content) {
  const _bind = [];
  const choice = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = 0;
  const _p$2 = undefined;
  _M0MPB3Map3setGsRPB4JsonE(choice, "index", new _M0DTPB4Json6Number(_p, _p$2));
  const _p$3 = "assistant";
  const _bind$2 = [{ _0: "role", _1: new _M0DTPB4Json6String(_p$3) }, { _0: "content", _1: new _M0DTPB4Json6String(content) }];
  const _p$4 = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind$2, 0, 2), undefined);
  _M0MPB3Map3setGsRPB4JsonE(choice, "message", new _M0DTPB4Json6Object(_p$4));
  const _p$5 = "stop";
  _M0MPB3Map3setGsRPB4JsonE(choice, "finish_reason", new _M0DTPB4Json6String(_p$5));
  const _bind$3 = [];
  const body = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind$3, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(body, "id", new _M0DTPB4Json6String(id));
  const _p$6 = "gpt-4o";
  _M0MPB3Map3setGsRPB4JsonE(body, "model", new _M0DTPB4Json6String(_p$6));
  const _p$7 = [new _M0DTPB4Json6Object(choice)];
  _M0MPB3Map3setGsRPB4JsonE(body, "choices", new _M0DTPB4Json5Array(_p$7));
  return new _M0DTPB4Json6Object(body);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main18plain__interaction(answer) {
  return _M0MP38weopqrst12mooncassette4core11Interaction3new(_M0FP38weopqrst19mooncassette_2ddemo4main13chat__request("用一句话说明什么是确定性回放。"), _M0MP38weopqrst12mooncassette4core8Response2ok(_M0FP38weopqrst19mooncassette_2ddemo4main12chat__answer("chatcmpl-plain", answer), _M0MP38weopqrst12mooncassette4core5Usage3new(38, 24), _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__));
}
function _M0FP38weopqrst19mooncassette_2ddemo4main22streaming__interaction(prefix) {
  const frames = [_M0MP38weopqrst12mooncassette4core11StreamFrame3new(`{\"choices\":[{\"delta\":{\"content\":\"${prefix}\"}}]}`, undefined), _M0MP38weopqrst12mooncassette4core11StreamFrame3new("{\"choices\":[{\"delta\":{\"content\":\"。\"}}]}", undefined), _M0MP38weopqrst12mooncassette4core11StreamFrame3new("[DONE]", undefined)];
  return _M0MP38weopqrst12mooncassette4core11Interaction3new(_M0FP38weopqrst19mooncassette_2ddemo4main13chat__request("请分两步说明：先给结论，再给理由。"), _M0MP38weopqrst12mooncassette4core8Response2ok(_M0FP38weopqrst19mooncassette_2ddemo4main12chat__answer("chatcmpl-stream", `${prefix}。`), _M0MP38weopqrst12mooncassette4core5Usage3new(41, 96), new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4Some(frames)));
}
function _M0FP38weopqrst19mooncassette_2ddemo4main26rate__limited__interaction() {
  const _bind = [];
  const error = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = "Rate limit reached for gpt-4o";
  _M0MPB3Map3setGsRPB4JsonE(error, "message", new _M0DTPB4Json6String(_p));
  const _p$2 = "rate_limit_error";
  _M0MPB3Map3setGsRPB4JsonE(error, "type", new _M0DTPB4Json6String(_p$2));
  const _p$3 = "rate_limit_exceeded";
  _M0MPB3Map3setGsRPB4JsonE(error, "code", new _M0DTPB4Json6String(_p$3));
  const _bind$2 = [];
  const body = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind$2, 0, 0), undefined);
  _M0MPB3Map3setGsRPB4JsonE(body, "error", new _M0DTPB4Json6Object(error));
  return _M0MP38weopqrst12mooncassette4core11Interaction3new(_M0FP38weopqrst19mooncassette_2ddemo4main13chat__request("再问一次同样的问题。"), _M0MP38weopqrst12mooncassette4core8Response3new(429, new _M0DTPB4Json6Object(body), undefined, _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__));
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12sample__text() {
  return _M0FP38weopqrst12mooncassette5codec6encode(_M0MP38weopqrst12mooncassette4core8Cassette3new("demo", _M0FP38weopqrst19mooncassette_2ddemo4main12sample__textN6constrS329, new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4Some([_M0FP38weopqrst19mooncassette_2ddemo4main18plain__interaction("确定性回放指的是：不重新调用模型，只按录制好的响应逐字节重演。"), _M0FP38weopqrst19mooncassette_2ddemo4main22streaming__interaction("结论：它把外部依赖变成可离线运行的测试"), _M0FP38weopqrst19mooncassette_2ddemo4main26rate__limited__interaction()])), undefined);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main17miss__query__text() {
  const _bind = [];
  const body = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = "gpt-4o-mini";
  _M0MPB3Map3setGsRPB4JsonE(body, "model", new _M0DTPB4Json6String(_p));
  const _p$2 = 0.2;
  const _p$3 = undefined;
  _M0MPB3Map3setGsRPB4JsonE(body, "temperature", new _M0DTPB4Json6Number(_p$2, _p$3));
  const _p$4 = [_M0FP38weopqrst19mooncassette_2ddemo4main13user__message("user", "用一句话说明什么是确定性回放。")];
  _M0MPB3Map3setGsRPB4JsonE(body, "messages", new _M0DTPB4Json5Array(_p$4));
  return _M0FP38weopqrst12mooncassette5canon18to__pretty__string(_M0MP38weopqrst12mooncassette4core7Request8to__json(_M0MP38weopqrst12mooncassette4core7Request3new("openai", "gpt-4o-mini", new _M0DTPB4Json6Object(body))), undefined);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main11leaky__text() {
  const _bind = [];
  const body = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind, 0, 0), undefined);
  const _p = "gpt-4o";
  _M0MPB3Map3setGsRPB4JsonE(body, "model", new _M0DTPB4Json6String(_p));
  const _p$2 = "sk-abcdefgh12345678";
  _M0MPB3Map3setGsRPB4JsonE(body, "api_key", new _M0DTPB4Json6String(_p$2));
  const _p$3 = "Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig";
  _M0MPB3Map3setGsRPB4JsonE(body, "authorization", new _M0DTPB4Json6String(_p$3));
  const _p$4 = [_M0FP38weopqrst19mooncassette_2ddemo4main13user__message("user", "帮我查一下订单。")];
  _M0MPB3Map3setGsRPB4JsonE(body, "messages", new _M0DTPB4Json5Array(_p$4));
  const _bind$2 = [];
  const answer = _M0MPB3Map3MapGsRPB4JsonE(new _M0TPB9ArrayViewGUsRPB4JsonEE(_bind$2, 0, 0), undefined);
  const _p$5 = "ya29.a0AfH6SMBsecretvalue";
  _M0MPB3Map3setGsRPB4JsonE(answer, "access_token", new _M0DTPB4Json6String(_p$5));
  const _p$6 = "已查询，安全字段会保留。";
  _M0MPB3Map3setGsRPB4JsonE(answer, "content", new _M0DTPB4Json6String(_p$6));
  return _M0FP38weopqrst12mooncassette5codec6encode(_M0MP38weopqrst12mooncassette4core8Cassette3new("leaky", _M0FP38weopqrst19mooncassette_2ddemo4main11leaky__textN6constrS330, new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4Some([_M0MP38weopqrst12mooncassette4core11Interaction3new(_M0MP38weopqrst12mooncassette4core7Request3new("openai", "gpt-4o", new _M0DTPB4Json6Object(body)), _M0MP38weopqrst12mooncassette4core8Response2ok(new _M0DTPB4Json6Object(answer), undefined, _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11StreamFrameEE4None__))])), undefined);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main13drifted__text() {
  return _M0FP38weopqrst12mooncassette5codec6encode(_M0MP38weopqrst12mooncassette4core8Cassette3new("demo", _M0FP38weopqrst19mooncassette_2ddemo4main13drifted__textN6constrS331, new _M0DTPC16option6OptionGRPB5ArrayGRP38weopqrst12mooncassette4core11InteractionEE4Some([_M0FP38weopqrst19mooncassette_2ddemo4main18plain__interaction("确定性回放指的是：不重新调用模型，只按录制好的响应逐字节重演。"), _M0FP38weopqrst19mooncassette_2ddemo4main22streaming__interaction("结论：它把外部依赖变成了可离线运行、且可复现的测试"), _M0FP38weopqrst19mooncassette_2ddemo4main26rate__limited__interaction()])), undefined);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(text) {
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const _bind = _M0MPC16string6String9to__array(text);
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const ch = _bind[_];
      switch (ch) {
        case 60: {
          _M0IPB13StringBuilderPB6Logger13write__string(out, "&lt;");
          break;
        }
        case 62: {
          _M0IPB13StringBuilderPB6Logger13write__string(out, "&gt;");
          break;
        }
        case 38: {
          _M0IPB13StringBuilderPB6Logger13write__string(out, "&amp;");
          break;
        }
        case 34: {
          _M0IPB13StringBuilderPB6Logger13write__string(out, "&quot;");
          break;
        }
        case 39: {
          _M0IPB13StringBuilderPB6Logger13write__string(out, "&#39;");
          break;
        }
        default: {
          _M0IPB13StringBuilderPB6Logger11write__char(out, ch);
        }
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main10parse__int(text) {
  const digits = _M0MPC16string6String9to__array(text);
  if (digits.length === 0) {
    return undefined;
  }
  let value = 0;
  const _bind = digits.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const ch = digits[_];
      const code = ch;
      if (code < 48 || code > 57) {
        return undefined;
      }
      value = (Math.imul(value, 10) | 0) + (code - 48 | 0) | 0;
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return value;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main13status__class(status) {
  return status >= 200 && status < 300 ? "ok" : status === 429 ? "warn" : status === 0 ? "muted" : "bad";
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state(title, hint) {
  return `<div class=\"empty\"><p class=\"empty-title\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(title)}</p><p class=\"empty-hint\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(hint)}</p></div>`;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(text) {
  return `<pre class=\"code\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(text)}</pre>`;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main11join__lines(items) {
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < items.length) {
      if (i > 0) {
        _M0IPB13StringBuilderPB6Logger13write__string(out, "\n");
      }
      _M0IPB13StringBuilderPB6Logger13write__string(out, _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, i));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main19join__escaped__html(items) {
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < items.length) {
      if (i > 0) {
        _M0IPB13StringBuilderPB6Logger13write__string(out, "<br>");
      }
      _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(_M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(items, i)));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main14render__detail(state) {
  const _bind = state.primary_tape;
  let loaded;
  if (_bind === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有载入录制", "先载入一份录制，再回来看某一条调用的细节。");
  } else {
    const _Some = _bind;
    loaded = _Some;
  }
  const cassette = loaded.cassette;
  const _bind$2 = state.detail;
  let index;
  if (_bind$2 === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有选择记录", "在「概览」里点某条记录右侧的「详情」。");
  } else {
    const _Some = _bind$2;
    index = _Some;
  }
  if (index < 0 || index >= cassette.interactions.length) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("记录下标越界", `这份录制里只有 ${_M0MPC13int3Int18to__string_2einner(cassette.interactions.length, 10)} 条记录。`);
  }
  const interaction = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(cassette.interactions, index);
  const response = interaction.response;
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<div class=\"row-head\"><h2>#${_M0MPC13int3Int18to__string_2einner(index, 10)}</h2><div class=\"nav-buttons\">`);
  if (index > 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, `<button data-action=\"open\" data-arg=\"${_M0MPC13int3Int18to__string_2einner(index - 1 | 0, 10)}\">上一条</button>`);
  }
  if ((index + 1 | 0) < cassette.interactions.length) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, `<button data-action=\"open\" data-arg=\"${_M0MPC13int3Int18to__string_2einner(index + 1 | 0, 10)}\">下一条</button>`);
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</div></div>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<div class=\"columns\">");
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<div><h3>请求</h3>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(_M0FP38weopqrst12mooncassette5canon18to__pretty__string(_M0MP38weopqrst12mooncassette4core7Request8to__json(interaction.request), undefined)));
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</div>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<div><h3>响应 ");
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<span class=\"badge ${_M0FP38weopqrst19mooncassette_2ddemo4main13status__class(response.status)}\">${_M0MPC13int3Int18to__string_2einner(response.status, 10)}</span>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</h3>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(_M0FP38weopqrst12mooncassette5canon18to__pretty__string(response.body, undefined)));
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</div></div>");
  const _bind$3 = response.stream;
  if (_bind$3.$tag === 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"meta\">这是一次整段响应：没有逐帧记录。</p>");
  } else {
    const _Some = _bind$3;
    const _frames = _Some._0;
    _M0IPB13StringBuilderPB6Logger13write__string(out, `<h3>流式帧（${_M0MPC13int3Int18to__string_2einner(_frames.length, 10)}）<span class=\"meta\">　回放时会按这个顺序逐帧交付</span></h3>`);
    const text = _M0MPB13StringBuilder21StringBuilder_2einner(0);
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < _frames.length) {
        const frame = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(_frames, i);
        _M0IPB13StringBuilderPB6Logger13write__string(text, `[${_M0MPC13int3Int18to__string_2einner(i, 10)}] `);
        const _bind$4 = frame.event;
        if (_bind$4 === undefined) {
        } else {
          const _Some$2 = _bind$4;
          const _event = _Some$2;
          _M0IPB13StringBuilderPB6Logger13write__string(text, `event: ${_event}　`);
        }
        _M0IPB13StringBuilderPB6Logger13write__string(text, `${frame.data}\n`);
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(text.val));
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main16render__diagnose(state) {
  const _bind = state.primary_tape;
  let loaded;
  if (_bind === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有载入录制", "先载入一份录制，再来诊断。");
  } else {
    const _Some = _bind;
    loaded = _Some;
  }
  const _bind$2 = _M0MPC16string6String4trim(state.query, undefined);
  if ((_bind$2.end - _bind$2.start | 0) === 0) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有填写请求", "在下面的输入框里贴一段请求 JSON。");
  }
  let request;
  let _try_err;
  _L: {
    _L$2: {
      const _bind$3 = state.query;
      const _bind$4 = _M0FP38weopqrst12mooncassette5codec15decode__request(new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length));
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        request = _ok._0;
      } else {
        const _err = _bind$4;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return `<p class=\"verdict bad\">请求解析失败：<code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(_M0IP016_24default__implPB4Show10to__stringGRP38weopqrst12mooncassette4core13CassetteErrorE(_try_err))}</code></p><p class=\"meta\">请求的形状是 <code>{\"provider\":…,\"model\":…,\"body\":…}</code>。</p>`;
  }
  const policy = state.body_only ? new _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy6Subset(["messages"]) : _M0DTP38weopqrst12mooncassette7matcher11MatchPolicy5Exact__;
  const _bind$3 = loaded.cassette.interactions;
  const diagnosis = _M0FP38weopqrst12mooncassette7matcher8diagnose(request, new _M0TPB9ArrayViewGRP38weopqrst12mooncassette4core11InteractionE(_bind$3, 0, _bind$3.length), policy, 0, _M0FP38weopqrst19mooncassette_2ddemo4main16render__diagnoseN6constrS332);
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<h2>未命中诊断</h2><p class=\"meta\">对 <code>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(loaded.label));
  _M0IPB13StringBuilderPB6Logger13write__string(out, `</code> 用策略 <code>${_M0MP38weopqrst12mooncassette7matcher11MatchPolicy4name(policy)}</code> 匹配</p>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<div class=\"actions\"><button data-action=\"toggle-body-only\">${state.body_only ? "改回严格匹配（Exact）" : "改成只比较请求体"}</button><span class=\"meta\">　换个策略看看结论怎么变</span></div>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(_M0FP38weopqrst19mooncassette_2ddemo4main11join__lines(_M0MP38weopqrst12mooncassette7matcher9Diagnosis5lines(diagnosis))));
  if (diagnosis.candidates.length > 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<h3>最接近的记录</h3>");
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<table class=\"rows\"><thead><tr><th>#</th><th>provider / model</th><th>差异路径</th></tr></thead><tbody>");
    const _bind$4 = diagnosis.candidates;
    const _bind$5 = _bind$4.length;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$5) {
        const candidate = _bind$4[_];
        _M0IPB13StringBuilderPB6Logger13write__string(out, `<tr><td>${_M0MPC13int3Int18to__string_2einner(candidate.index, 10)}</td><td><code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(candidate.provider)}</code> / <code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(candidate.model)}</code></td><td><code>${_M0FP38weopqrst19mooncassette_2ddemo4main19join__escaped__html(candidate.differing_paths)}</code></td></tr>`);
        _tmp = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0IPB13StringBuilderPB6Logger13write__string(out, "</tbody></table>");
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"meta\">只报告路径、不报告字段值：诊断信息常被贴进 issue 或日志，而其中的请求未必脱敏。</p>");
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main13render__drift(state) {
  const _bind = state.primary_tape;
  let left;
  if (_bind === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有载入录制", "先载入两份录制，再来比较。");
  } else {
    const _Some = _bind;
    left = _Some;
  }
  const _bind$2 = state.comparison_tape;
  let right;
  if (_bind$2 === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("只有一份录制", "漂移对比需要两份：再用文件输入载入第二份，或点「载入漂移样例」。");
  } else {
    const _Some = _bind$2;
    right = _Some;
  }
  const report = _M0FP28weopqrst12mooncassette19compare__recordings(left.cassette, right.cassette);
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<h2>漂移对比</h2><p class=\"meta\">左：<code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(left.label)}</code>　右：<code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(right.label)}</code></p>`);
  if (report.entries.length === 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"verdict ok\">两份录制完全一致，没有行为漂移。</p>");
  } else {
    _M0IPB13StringBuilderPB6Logger13write__string(out, `<p class=\"verdict bad\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(_M0MP38weopqrst12mooncassette5drift11DriftReport7summary(report))}</p>`);
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"meta\">只有第三类（<code>Changed</code>：请求没变、响应变了）才是真正的行为漂移。前两类只说明调用集合变了。</p>");
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(_M0FP38weopqrst19mooncassette_2ddemo4main11join__lines(_M0MP38weopqrst12mooncassette5drift11DriftReport5lines(report))));
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main16render__overview(state) {
  const _bind = state.primary_tape;
  let loaded;
  if (_bind === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有载入录制", "点上面的「载入自带样例」，或者选一份 cassette 文件。");
  } else {
    const _Some = _bind;
    loaded = _Some;
  }
  const cassette = loaded.cassette;
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<h2>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(loaded.label)}</h2>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<p class=\"meta\">名称 <code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(cassette.meta.name)}</code>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `　生成器 <code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(cassette.meta.generator)}</code>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `　记录数 <strong>${_M0MPC13int3Int18to__string_2einner(cassette.interactions.length, 10)}</strong>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `　体积 ${_M0MPC13int3Int18to__string_2einner(loaded.size, 10)} 字符</p>`);
  if (cassette.interactions.length === 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("这份录制里没有记录", "它是一份合法的空 cassette。"));
    return out.val;
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<table class=\"rows\"><thead><tr><th>#</th><th>provider / model</th><th>状态</th><th>形态</th><th>tokens</th><th></th></tr></thead><tbody>");
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < cassette.interactions.length) {
      const interaction = _M0MPC15array5Array2atGRP38weopqrst12mooncassette4core11InteractionE(cassette.interactions, i);
      const response = interaction.response;
      const _bind$2 = response.stream;
      let shape;
      if (_bind$2.$tag === 1) {
        const _Some = _bind$2;
        const _frames = _Some._0;
        shape = `流式 · ${_M0MPC13int3Int18to__string_2einner(_frames.length, 10)} 帧`;
      } else {
        shape = "整段";
      }
      const _bind$3 = response.usage;
      let tokens;
      if (_bind$3 === undefined) {
        tokens = "—";
      } else {
        const _Some = _bind$3;
        const _usage = _Some;
        tokens = _M0MPC13int3Int18to__string_2einner(_usage.input_tokens + _usage.output_tokens | 0, 10);
      }
      _M0IPB13StringBuilderPB6Logger13write__string(out, `<tr><td>${_M0MPC13int3Int18to__string_2einner(i, 10)}</td><td><code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(interaction.request.provider)}</code> / <code>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(interaction.request.model)}</code></td><td><span class=\"badge ${_M0FP38weopqrst19mooncassette_2ddemo4main13status__class(response.status)}\">${_M0MPC13int3Int18to__string_2einner(response.status, 10)}</span></td><td>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(shape)}</td><td>${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(tokens)}</td><td><button class=\"link\" data-action=\"open\" data-arg=\"${_M0MPC13int3Int18to__string_2einner(i, 10)}\">详情</button></td></tr>`);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</tbody></table>");
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main16render__sanitize(state) {
  const _bind = state.primary_tape;
  let loaded;
  if (_bind === undefined) {
    return _M0FP38weopqrst19mooncassette_2ddemo4main12empty__state("还没有载入录制", "先载入一份录制，再来看脱敏前后的差别。");
  } else {
    const _Some = _bind;
    loaded = _Some;
  }
  const policy = _M0MP38weopqrst12mooncassette8sanitize14SanitizePolicy7default();
  const cleaned = _M0FP38weopqrst12mooncassette8sanitize18sanitize__cassette(loaded.cassette, policy);
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<h2>脱敏预览</h2>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"meta\">同一份录制，左边是落盘时保留的内容，右边是脱敏之后的内容。<strong>真正被写进 cassette 的是右边这一份</strong>。</p>");
  const before = _M0FP38weopqrst12mooncassette5codec6encode(loaded.cassette, undefined);
  const after = _M0FP38weopqrst12mooncassette5codec6encode(cleaned, undefined);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<div class=\"actions\"><button data-action=\"toggle-reveal-raw\">${state.reveal_raw ? "隐藏脱敏前的原文" : "显示脱敏前的原文"}</button><span class=\"meta\">　原文默认隐藏：它可能含真实密钥</span></div>`);
  const before_panel = state.reveal_raw ? _M0FP38weopqrst19mooncassette_2ddemo4main11code__block(before) : "<div class=\"empty\"><p class=\"empty-hint\">原文已隐藏。它可能含有真实密钥 —— 而这份文件之所以要拿来脱敏，正是因为有密钥在里面。<br>需要逐字对照时，再点上面的按钮把它显示出来。</p></div>";
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<div class=\"columns\">");
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<div><h3>脱敏前</h3>${before_panel}</div>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<div><h3>脱敏后</h3>${_M0FP38weopqrst19mooncassette_2ddemo4main11code__block(after)}</div>`);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</div>");
  if (before === after) {
    _M0IPB13StringBuilderPB6Logger13write__string(out, "<p class=\"verdict ok\">两份完全一致：这份录制里没有出现敏感字段。</p>");
  } else {
    _M0IPB13StringBuilderPB6Logger13write__string(out, `<p class=\"verdict ok\">已抹除 <strong>${_M0MPC13int3Int18to__string_2einner(before.length - after.length | 0, 10)}</strong> 个字符的敏感内容。</p>`);
  }
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12render__tabs(state) {
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<nav class=\"tabs\">");
  const _bind = [0, 1, 2, 3, 4];
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const view = _bind[_];
      const active = _M0IP38weopqrst19mooncassette_2ddemo4main4ViewPB2Eq5equal(view, state.view) ? " active" : "";
      _M0IPB13StringBuilderPB6Logger13write__string(out, `<button class=\"tab${active}\" data-action=\"view\" data-arg=\"${_M0MP38weopqrst19mooncassette_2ddemo4main4View4name(view)}\" title=\"${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(_M0MP38weopqrst19mooncassette_2ddemo4main4View4hint(view))}\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(_M0MP38weopqrst19mooncassette_2ddemo4main4View5title(view))}</button>`);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</nav>");
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main11render__app(state) {
  const out = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(out, _M0FP38weopqrst19mooncassette_2ddemo4main12render__tabs(state));
  _M0IPB13StringBuilderPB6Logger13write__string(out, "<section class=\"panel\">");
  const _bind = state.view;
  let _tmp;
  switch (_bind) {
    case 0: {
      _tmp = _M0FP38weopqrst19mooncassette_2ddemo4main16render__overview(state);
      break;
    }
    case 1: {
      _tmp = _M0FP38weopqrst19mooncassette_2ddemo4main14render__detail(state);
      break;
    }
    case 2: {
      _tmp = _M0FP38weopqrst19mooncassette_2ddemo4main13render__drift(state);
      break;
    }
    case 3: {
      _tmp = _M0FP38weopqrst19mooncassette_2ddemo4main16render__diagnose(state);
      break;
    }
    default: {
      _tmp = _M0FP38weopqrst19mooncassette_2ddemo4main16render__sanitize(state);
    }
  }
  _M0IPB13StringBuilderPB6Logger13write__string(out, _tmp);
  _M0IPB13StringBuilderPB6Logger13write__string(out, "</section>");
  _M0IPB13StringBuilderPB6Logger13write__string(out, `<p class=\"status\">${_M0FP38weopqrst19mooncassette_2ddemo4main12escape__html(state.status)}</p>`);
  return out.val;
}
function _M0FP38weopqrst19mooncassette_2ddemo4main9set__html(element_id, html) {
  _M0FP38weopqrst19mooncassette_2ddemo4main14set__html__ffi(element_id, html);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main12set__visible(element_id, visible) {
  _M0FP38weopqrst19mooncassette_2ddemo4main17set__visible__ffi(element_id, visible);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state) {
  _M0FP38weopqrst19mooncassette_2ddemo4main9set__html("app", _M0FP38weopqrst19mooncassette_2ddemo4main11render__app(state));
  _M0FP38weopqrst19mooncassette_2ddemo4main12set__visible("diagnose-controls", _M0IP38weopqrst19mooncassette_2ddemo4main4ViewPB2Eq5equal(state.view, 3));
}
function _M0FP38weopqrst19mooncassette_2ddemo4main6handle(state, action, arg) {
  switch (action) {
    case "view": {
      const _bind = _M0FP38weopqrst19mooncassette_2ddemo4main8view__of(arg);
      if (_bind === undefined) {
        state.status = `未知视图：${arg}`;
        return;
      } else {
        const _Some = _bind;
        const _view = _Some;
        state.view = _view;
        return;
      }
    }
    case "open": {
      const _bind$2 = _M0FP38weopqrst19mooncassette_2ddemo4main10parse__int(arg);
      if (_bind$2 === undefined) {
        state.status = `无法识别的记录下标：${arg}`;
        return;
      } else {
        const _Some = _bind$2;
        const _index = _Some;
        state.detail = _index;
        state.view = 1;
        return;
      }
    }
    case "load-sample": {
      _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(state, "自带样例", _M0FP38weopqrst19mooncassette_2ddemo4main12sample__text());
      state.view = 0;
      return;
    }
    case "load-drifted": {
      _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(state, "自带样例", _M0FP38weopqrst19mooncassette_2ddemo4main12sample__text());
      _M0MP38weopqrst19mooncassette_2ddemo4main8AppState16load__comparison(state, "漂移样例（模型换了版本）", _M0FP38weopqrst19mooncassette_2ddemo4main13drifted__text());
      state.view = 2;
      return;
    }
    case "load-leaky": {
      _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(state, "含密钥的样例（模拟未脱敏的文件）", _M0FP38weopqrst19mooncassette_2ddemo4main11leaky__text());
      state.view = 4;
      return;
    }
    case "toggle-reveal-raw": {
      state.reveal_raw = !state.reveal_raw;
      state.status = state.reveal_raw ? "已显示脱敏前的原文。注意：它可能含有真实密钥。" : "已隐藏脱敏前的原文。";
      return;
    }
    case "toggle-body-only": {
      state.body_only = !state.body_only;
      state.status = state.body_only ? "诊断改为「只比较请求体的 messages 字段」。" : "诊断改回严格匹配：指纹相同且规范请求全等。";
      return;
    }
    default: {
      state.status = `未知动作：${action}`;
      return;
    }
  }
}
function _M0FP38weopqrst19mooncassette_2ddemo4main20on__delegated__click(container_id, handler) {
  _M0FP38weopqrst19mooncassette_2ddemo4main25on__delegated__click__ffi(container_id, handler);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main18on__file__selected(input_id, handler) {
  _M0FP38weopqrst19mooncassette_2ddemo4main23on__file__selected__ffi(input_id, handler);
}
function _M0FP38weopqrst19mooncassette_2ddemo4main15on__text__input(element_id, handler) {
  _M0FP38weopqrst19mooncassette_2ddemo4main20on__text__input__ffi(element_id, handler);
}
(() => {
  const state = _M0MP38weopqrst19mooncassette_2ddemo4main8AppState3new();
  _M0FP38weopqrst19mooncassette_2ddemo4main20on__delegated__click("body", (action, arg) => {
    _M0FP38weopqrst19mooncassette_2ddemo4main6handle(state, action, arg);
    _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state);
  });
  _M0FP38weopqrst19mooncassette_2ddemo4main15on__text__input("diagnose-request", (text) => {
    state.query = text;
    _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state);
  });
  _M0FP38weopqrst19mooncassette_2ddemo4main18on__file__selected("file-input", (name, text) => {
    _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(state, name, text);
    _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state);
  });
  _M0FP38weopqrst19mooncassette_2ddemo4main18on__file__selected("file-input-right", (name, text) => {
    _M0MP38weopqrst19mooncassette_2ddemo4main8AppState16load__comparison(state, name, text);
    state.view = 2;
    _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state);
  });
  _M0MP38weopqrst19mooncassette_2ddemo4main8AppState13load__primary(state, "自带样例", _M0FP38weopqrst19mooncassette_2ddemo4main12sample__text());
  state.query = _M0FP38weopqrst19mooncassette_2ddemo4main17miss__query__text();
  state.status = `${state.status}　试试上面的三个样例按钮。`;
  _M0FP38weopqrst19mooncassette_2ddemo4main11render__all(state);
})();
