import std/math
export math

const epsilon = 0.000001

{.push inline.}

func asFloat*(a: float): float = a
func asFloat*(a: float32): float32 = a
func asFloat*(a: SomeNumber): float = a.float
func asFloat32*(a: float32): float32 = a
func asFloat32*(a: SomeNumber): float32 = a.float32
func asInt*(a: int): int = a
func asInt*(a: SomeNumber): int = a.int
func asInt64*(a: int64): int64 = a
func asInt64*(a: SomeNumber): int64 = a.int64
func asInt32*(a: int32): int32 = a
func asInt32*(a: SomeNumber): int32 = a.int32
func asInt16*(a: int16): int16 = a
func asInt16*(a: SomeNumber): int16 = a.int16
func asInt8*(a: int8): int8 = a
func asInt8*(a: SomeNumber): int8 = a.int8
func asUInt*(a: uint): uint = a
func asUInt*(a: SomeNumber): uint = a.uint
func asUInt64*(a: uint64): uint64 = a
func asUInt64*(a: SomeNumber): uint64 = a.uint64
func asUInt32*(a: uint32): uint32 = a
func asUInt32*(a: SomeNumber): uint32 = a.uint32
func asUInt16*(a: uint16): uint16 = a
func asUInt16*(a: SomeNumber): uint16 = a.uint16
func asUInt8*(a: uint8): uint8 = a
func asUInt8*(a: SomeNumber): uint8 = a.uint8

func `~=`*[A, B: SomeInteger](a: A, b: B): bool =
  a == b

func `~=`*[A: SomeInteger, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon

func `~=`*[A: SomeFloat, B: SomeInteger](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon

func `~=`*[A, B: SomeFloat](a: A, b: B): bool =
  (a.asFloat - b.asFloat).abs <= epsilon

{.pop.}