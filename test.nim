import std/math
import std/typetraits
import std/macros

export math

proc recursiveReplaceI*(n: NimNode, with: int): NimNode =
  result = n.copy
  if n.kind notin AtomicNodes:
    for i in 0 ..< n.len:
      if n[i].kind == nnkIdent and n[i].strVal == "i":
        result[i] = newIntLitNode(with)
      else:
        result[i] = recursiveReplaceI(n[i], with)

proc chainInfixes*(count: int, op, code: NimNode): NimNode =
  let i = count - 1
  let codeForI = recursiveReplaceI(code, i)
  if i == 0:
    codeForI
  else:
    nnkInfix.newTree(op, codeForI, chainInfixes(i, op, code))

macro inlineTupleConstr*(count: static[int], code: untyped): untyped =
  result = nnkTupleConstr.newTree()
  for i in 0 ..< count:
    result.add recursiveReplaceI(code, i)

macro inlineInfixChain*(count: static[int], op, code: untyped): untyped =
  chainInfixes(count, op, code)

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

template `+`*(ta: tuple): untyped =
  ta

template `-`*(ta: tuple): untyped =
  let a = ta
  inlineTupleConstr(a.tupleLen, -a[i])

template tupleBinaryOperator(op: untyped): untyped =
  template op*[A, B: tuple](ta: A, tb: B): untyped =
    let a = ta
    let b = tb
    inlineTupleConstr(a.tupleLen, op(a[i], b[i]))

  template op*[A: tuple, B: not tuple](ta: A, tb: B): untyped =
    let a = ta
    let b = tb
    inlineTupleConstr(a.tupleLen, op(a[i], b))

template tupleBinaryEqualsOperator(opEq, op: untyped): untyped =
  template opEq*[A, B: tuple](ta: var A, tb: B) =
    ta = op(ta, tb)

  template opEq*[A: tuple, B: not tuple](ta: var A, tb: B) =
    ta = op(ta, tb)

tupleBinaryOperator(`+`)
tupleBinaryEqualsOperator(`+=`, `+`)
tupleBinaryOperator(`-`)
tupleBinaryEqualsOperator(`-=`, `-`)
tupleBinaryOperator(`*`)
tupleBinaryEqualsOperator(`*=`, `*`)
tupleBinaryOperator(`/`)
tupleBinaryEqualsOperator(`/=`, `/`)
tupleBinaryOperator(`div`)
tupleBinaryOperator(`mod`)

template lengthSquared*(ta: tuple): untyped =
  let a = ta
  inlineInfixChain(a.tupleLen, `+`, a[i] * a[i])

template length*(ta: tuple): untyped =
  ta.lengthSquared.sqrt

template dot*[A, B: tuple](ta: A, tb: B): untyped =
  let a = ta
  let b = tb
  inlineInfixChain(a.tupleLen, `+`, a[i] * b[i])

# var a = (5.0, 5.0)
# let b = (10.0, 10.0)

# a += b

# echo a

# timeIt "Test":
#   for i in 0 ..< 1000000:
#     a = a + b

let a = (5.0, 0.0)
let b = (5.0, 0.0)


expandMacros:
  discard a.dot(b)