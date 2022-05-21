import std/math
export math

template asFloat*(n: float): float = n
template asFloat*(n: float32): float32 = n
template asFloat*(n: SomeNumber): float = n.float
template asFloat64*(n: SomeNumber): float64 = n.float64
template asFloat32*(n: float32): float32 = n
template asFloat32*(n: SomeNumber): float32 = n.float32
template asInt*(n: int): int = n
template asInt*(n: SomeNumber): int = n.int
template asInt64*(n: int64): int64 = n
template asInt64*(n: SomeNumber): int64 = n.int64
template asInt32*(n: int32): int32 = n
template asInt32*(n: SomeNumber): int32 = n.int32
template asInt16*(n: int16): int16 = n
template asInt16*(n: SomeNumber): int16 = n.int16
template asInt8*(n: int8): int8 = n
template asInt8*(n: SomeNumber): int8 = n.int8
template asUInt*(n: uint): uint = n
template asUInt*(n: SomeNumber): uint = n.uint
template asUInt64*(n: uint64): uint64 = n
template asUInt64*(n: SomeNumber): uint64 = n.uint64
template asUInt32*(n: uint32): uint32 = n
template asUInt32*(n: SomeNumber): uint32 = n.uint32
template asUInt16*(n: uint16): uint16 = n
template asUInt16*(n: SomeNumber): uint16 = n.uint16
template asUInt8*(n: uint8): uint8 = n
template asUInt8*(n: SomeNumber): uint8 = n.uint8

template `~=`*[A, B: SomeInteger](a: A, b: B): bool =
  a == b

template `~=`*[A: SomeInteger, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= 0.000001

template `~=`*[A: SomeFloat, B: SomeInteger](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= 0.000001

template `~=`*[A, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= 0.000001