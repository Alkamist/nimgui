import std/math
export math

template asFloat*(n: float): float = n
template asFloat*(n: float32): float32 = n
template asFloat*(n: int): float = n.float
template asFloat*(n: int64): float = n.float
template asFloat*(n: int32): float = n.float
template asFloat*(n: int16): float = n.float
template asFloat*(n: int8): float = n.float
template asFloat*(n: uint): float = n.float
template asFloat*(n: uint64): float = n.float
template asFloat*(n: uint32): float = n.float
template asFloat*(n: uint16): float = n.float
template asFloat*(n: uint8): float = n.float

template asFloat64*(n: float): float64 = n
template asFloat64*(n: float32): float64 = n.float64
template asFloat64*(n: int): float64 = n.float64
template asFloat64*(n: int64): float64 = n.float64
template asFloat64*(n: int32): float64 = n.float64
template asFloat64*(n: int16): float64 = n.float64
template asFloat64*(n: int8): float64 = n.float64
template asFloat64*(n: uint): float64 = n.float64
template asFloat64*(n: uint64): float64 = n.float64
template asFloat64*(n: uint32): float64 = n.float64
template asFloat64*(n: uint16): float64 = n.float64
template asFloat64*(n: uint8): float64 = n.float64

template asFloat32*(n: float): float32 = n.float32
template asFloat32*(n: float32): float32 = n
template asFloat32*(n: int): float32 = n.float32
template asFloat32*(n: int64): float32 = n.float32
template asFloat32*(n: int32): float32 = n.float32
template asFloat32*(n: int16): float32 = n.float32
template asFloat32*(n: int8): float32 = n.float32
template asFloat32*(n: uint): float32 = n.float32
template asFloat32*(n: uint64): float32 = n.float32
template asFloat32*(n: uint32): float32 = n.float32
template asFloat32*(n: uint16): float32 = n.float32
template asFloat32*(n: uint8): float32 = n.float32

template asInt*(n: float): int = n.int
template asInt*(n: float32): int = n.int
template asInt*(n: int): int = n
template asInt*(n: int64): int = n.int
template asInt*(n: int32): int = n.int
template asInt*(n: int16): int = n.int
template asInt*(n: int8): int = n.int
template asInt*(n: uint): int = n.int
template asInt*(n: uint64): int = n.int
template asInt*(n: uint32): int = n.int
template asInt*(n: uint16): int = n.int
template asInt*(n: uint8): int = n.int

template asInt64*(n: float): int64 = n.int64
template asInt64*(n: float32): int64 = n.int64
template asInt64*(n: int): int64 = n.int64
template asInt64*(n: int64): int64 = n
template asInt64*(n: int32): int64 = n.int64
template asInt64*(n: int16): int64 = n.int64
template asInt64*(n: int8): int64 = n.int64
template asInt64*(n: uint): int64 = n.int64
template asInt64*(n: uint64): int64 = n.int64
template asInt64*(n: uint32): int64 = n.int64
template asInt64*(n: uint16): int64 = n.int64
template asInt64*(n: uint8): int64 = n.int64

template asInt32*(n: float): int32 = n.int32
template asInt32*(n: float32): int32 = n.int32
template asInt32*(n: int): int32 = n.int32
template asInt32*(n: int64): int32 = n.int32
template asInt32*(n: int32): int32 = n
template asInt32*(n: int16): int32 = n.int32
template asInt32*(n: int8): int32 = n.int32
template asInt32*(n: uint): int32 = n.int32
template asInt32*(n: uint64): int32 = n.int32
template asInt32*(n: uint32): int32 = n.int32
template asInt32*(n: uint16): int32 = n.int32
template asInt32*(n: uint8): int32 = n.int32

template asInt16*(n: float): int16 = n.int16
template asInt16*(n: float32): int16 = n.int16
template asInt16*(n: int): int16 = n.int16
template asInt16*(n: int64): int16 = n.int16
template asInt16*(n: int32): int16 = n.int16
template asInt16*(n: int16): int16 = n
template asInt16*(n: int8): int16 = n.int16
template asInt16*(n: uint): int16 = n.int16
template asInt16*(n: uint64): int16 = n.int16
template asInt16*(n: uint32): int16 = n.int16
template asInt16*(n: uint16): int16 = n.int16
template asInt16*(n: uint8): int16 = n.int16

template asInt8*(n: float): int8 = n.int8
template asInt8*(n: float32): int8 = n.int8
template asInt8*(n: int): int8 = n.int8
template asInt8*(n: int64): int8 = n.int8
template asInt8*(n: int32): int8 = n.int8
template asInt8*(n: int16): int8 = n.int8
template asInt8*(n: int8): int8 = n
template asInt8*(n: uint): int8 = n.int8
template asInt8*(n: uint64): int8 = n.int8
template asInt8*(n: uint32): int8 = n.int8
template asInt8*(n: uint16): int8 = n.int8
template asInt8*(n: uint8): int8 = n.int8

template asUInt*(n: float): uint = n.uint
template asUInt*(n: float32): uint = n.uint
template asUInt*(n: int): uint = n.uint
template asUInt*(n: int64): uint = n.uint
template asUInt*(n: int32): uint = n.uint
template asUInt*(n: int16): uint = n.uint
template asUInt*(n: int8): uint = n.uint
template asUInt*(n: uint): uint = n
template asUInt*(n: uint64): uint = n.uint
template asUInt*(n: uint32): uint = n.uint
template asUInt*(n: uint16): uint = n.uint
template asUInt*(n: uint8): uint = n.uint

template asUInt64*(n: float): uint64 = n.uint64
template asUInt64*(n: float32): uint64 = n.uint64
template asUInt64*(n: int): uint64 = n.uint64
template asUInt64*(n: int64): uint64 = n.uint64
template asUInt64*(n: int32): uint64 = n.uint64
template asUInt64*(n: int16): uint64 = n.uint64
template asUInt64*(n: int8): uint64 = n.uint64
template asUInt64*(n: uint): uint64 = n.uint64
template asUInt64*(n: uint64): uint64 = n
template asUInt64*(n: uint32): uint64 = n.uint64
template asUInt64*(n: uint16): uint64 = n.uint64
template asUInt64*(n: uint8): uint64 = n.uint64

template asUInt32*(n: float): uint32 = n.uint32
template asUInt32*(n: float32): uint32 = n.uint32
template asUInt32*(n: int): uint32 = n.uint32
template asUInt32*(n: int64): uint32 = n.uint32
template asUInt32*(n: int32): uint32 = n.uint32
template asUInt32*(n: int16): uint32 = n.uint32
template asUInt32*(n: int8): uint32 = n.uint32
template asUInt32*(n: uint): uint32 = n.uint32
template asUInt32*(n: uint64): uint32 = n.uint32
template asUInt32*(n: uint32): uint32 = n
template asUInt32*(n: uint16): uint32 = n.uint32
template asUInt32*(n: uint8): uint32 = n.uint32

template asUInt16*(n: float): uint16 = n.uint16
template asUInt16*(n: float32): uint16 = n.uint16
template asUInt16*(n: int): uint16 = n.uint16
template asUInt16*(n: int64): uint16 = n.uint16
template asUInt16*(n: int32): uint16 = n.uint16
template asUInt16*(n: int16): uint16 = n.uint16
template asUInt16*(n: int8): uint16 = n.uint16
template asUInt16*(n: uint): uint16 = n.uint16
template asUInt16*(n: uint64): uint16 = n.uint16
template asUInt16*(n: uint32): uint16 = n.uint16
template asUInt16*(n: uint16): uint16 = n
template asUInt16*(n: uint8): uint16 = n.uint16

template asUInt8*(n: float): uint8 = n.uint8
template asUInt8*(n: float32): uint8 = n.uint8
template asUInt8*(n: int): uint8 = n.uint8
template asUInt8*(n: int64): uint8 = n.uint8
template asUInt8*(n: int32): uint8 = n.uint8
template asUInt8*(n: int16): uint8 = n.uint8
template asUInt8*(n: int8): uint8 = n.uint8
template asUInt8*(n: uint): uint8 = n.uint8
template asUInt8*(n: uint64): uint8 = n.uint8
template asUInt8*(n: uint32): uint8 = n.uint8
template asUInt8*(n: uint16): uint8 = n.uint8
template asUInt8*(n: uint8): uint8 = n

const epsilon = 0.000001

func `~=`*[A, B: SomeInteger](a: A, b: B): bool =
  a == b

func `~=`*[A: SomeInteger, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon

func `~=`*[A: SomeFloat, B: SomeInteger](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon

func `~=`*[A, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon