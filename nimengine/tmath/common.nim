import std/math
export math

template `~=`*[A, B: SomeInteger](a: A, b: B): bool =
  a == b

template `~=`*[A: SomeInteger, B: SomeFloat](a: A, b: B): bool =
  (a.float - b.float).abs <= 0.000001

template `~=`*[A: SomeFloat, B: SomeInteger](a: A, b: B): bool =
  (a.float - b.float).abs <= 0.000001

template asFloat*(a: float): float = a
template asFloat*(a: float32): float32 = a
template asFloat*(a: SomeNumber): float = a.float
template asFloat32*(a: float32): float32 = a
template asFloat32*(a: SomeNumber): float32 = a.float32
template asInt*(a: int): int = a
template asInt*(a: SomeNumber): int = a.int
template asInt64*(a: int64): int64 = a
template asInt64*(a: SomeNumber): int64 = a.int64
template asInt32*(a: int32): int32 = a
template asInt32*(a: SomeNumber): int32 = a.int32
template asInt16*(a: int16): int16 = a
template asInt16*(a: SomeNumber): int16 = a.int16
template asInt8*(a: int8): int8 = a
template asInt8*(a: SomeNumber): int8 = a.int8
template asUInt*(a: uint): uint = a
template asUInt*(a: SomeNumber): uint = a.uint
template asUInt64*(a: uint64): uint64 = a
template asUInt64*(a: SomeNumber): uint64 = a.uint64
template asUInt32*(a: uint32): uint32 = a
template asUInt32*(a: SomeNumber): uint32 = a.uint32
template asUInt16*(a: uint16): uint16 = a
template asUInt16*(a: SomeNumber): uint16 = a.uint16
template asUInt8*(a: uint8): uint8 = a
template asUInt8*(a: SomeNumber): uint8 = a.uint8