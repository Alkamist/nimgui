import ./common
export common

type
  SomeVec2* = tuple[x, y: float] or tuple[x, y: float64] or tuple[x, y: float32] or
              tuple[x, y: int] or tuple[x, y: int64] or tuple[x, y: int32] or tuple[x, y: int16] or tuple[x, y: int8] or
              tuple[x, y: uint] or tuple[x, y: uint64] or tuple[x, y: uint32] or tuple[x, y: uint16] or tuple[x, y: uint8]

template mapIt*(a: SomeVec2, code: untyped): auto =
  block:
    var it {.inject.} = a[0]
    let x = code
    it = a[1]
    let y = code
    (x: x, y: y)

template asFloat*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asFloat, y: aT[1].asFloat)

template asFloat32*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asFloat32, y: aT[1].asFloat32)

template asInt*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asInt, y: aT[1].asInt)

template asInt32*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asInt32, y: aT[1].asInt32)

template asInt16*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asInt16, y: aT[1].asInt16)

template asInt8*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asInt8, y: aT[1].asInt8)

template asUInt*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asUInt, y: aT[1].asUInt)

template asUInt32*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asUInt32, y: aT[1].asUInt32)

template asUInt16*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asUInt16, y: aT[1].asUInt16)

template asUInt8*(a: SomeVec2): auto =
  let aT = a
  (x: aT[0].asUInt8, y: aT[1].asUInt8)

template `+`*(a: SomeVec2): auto = a
template `-`*(a: SomeVec2): auto =
  let aT = a
  (x: -aT[0], y: -aT[1])

template vec2BinaryOperator(op: untyped): untyped =
  template op*[A, B: SomeVec2](a: A, b: B): auto =
    let aT = a
    let bT = b
    (x: op(aT[0], bT[0]), y: op(aT[1], bT[1]))

  template op*(a: SomeVec2, b: SomeNumber): auto =
    let aT = a
    let bT = b
    (x: op(aT[0], bT), y: op(aT[1], bT))

template vec2BinaryEqualsOperator(opEq, op: untyped): untyped =
  template opEq*[A, B: SomeVec2](a: A, b: B) =
    a = op(a, b)

  template opEq*(a: SomeVec2, b: SomeNumber) =
    a = op(a, b)

vec2BinaryOperator(`+`)
vec2BinaryEqualsOperator(`+=`, `+`)
vec2BinaryOperator(`-`)
vec2BinaryEqualsOperator(`-=`, `-`)
vec2BinaryOperator(`*`)
vec2BinaryEqualsOperator(`*=`, `*`)
vec2BinaryOperator(`/`)
vec2BinaryEqualsOperator(`/=`, `/`)
vec2BinaryOperator(`div`)
vec2BinaryOperator(`mod`)

template `+`*(a: SomeNumber, b: SomeVec2): auto =
  let aT = a
  let bT = b
  (x: aT + bT[0], y: aT + bT[1])

template `*`*(a: SomeNumber, b: SomeVec2): auto =
  let aT = a
  let bT = b
  (x: aT * bT[0], y: aT * bT[1])

template `~=`*[A, B: SomeVec2](a: A, b: B): bool =
  let aT = a
  let bT = b
  aT[0] ~= bT[0] and aT[1] ~= bT[1]

template length*(a: SomeVec2): auto =
  let aT = a.asFloat
  (aT[0] * aT[0] + aT[1] * aT[1]).sqrt

template lengthSquared*(a: SomeVec2): auto =
  let aT = a
  aT[0] * aT[0] + aT[1] * aT[1]

template dot*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a
  let bT = b
  aT[0] * bT[0] + aT[1] * bT[1]

template cross*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a
  let bT = b
  aT[0] * bT[1] - aT[1] * bT[0]

template distanceTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).length

template distanceSquaredTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).lengthSquared

template rotate*(a: SomeVec2, phi: SomeNumber): auto =
  let aT = a.asFloat
  let phiT = phi.asFloat
  let sn = sin(phiT)
  let cs = cos(phiT)
  (x: aT[0] * cs - aT[1] * sn,
   y: aT[0] * sn + aT[1] * cs)

template angle*(a: SomeVec2): auto =
  let aT = a.asFloat
  arctan2(aT[1], aT[0])

template isNormalized*(a: SomeVec2): bool =
  a.lengthSquared ~= 1.0

func normalize*(a: SomeVec2): auto =
  var aT = a.asFloat
  let lengthSquared = aT.lengthSquared
  if lengthSquared == 0:
    aT[0] = 0
    aT[1] = 0
  else:
    let length = lengthSquared.sqrt
    aT /= length
  aT

template lerp*[A, B: SomeVec2](a: A, b: B, weight: SomeNumber): auto =
  let aT = a.asFloat
  let bT = b.asFloat
  let weightT = weight.asFloat
  aT * (1.0 - weightT) + bT * weightT

template slide*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a.asFloat
  let bT = b.asFloat
  if not bT.isNormalized:
    let bTNormalized = bT.normalize
    aT - bTNormalized * aT.dot(bTNormalized)
  else:
    aT - bT * aT.dot(bT)

template reflect*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a.asFloat
  let bT = b.asFloat
  if not bT.isNormalized:
    let bTNormalized = bT.normalize
    bTNormalized * aT.dot(bTNormalized) * 2.0 - aT
  else:
    bT * aT.dot(bT) * 2.0 - aT

template bounce*[A, B: SomeVec2](a: A, b: B): auto =
  -a.reflect(b)

template project*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a.asFloat
  let bT = b.asFloat
  bT * (aT.dot(bT) / bT.lengthSquared)

template angleTo*[A, B: SomeVec2](a: A, b: B): auto =
  let aT = a.asFloat
  let bT = b.asFloat
  arctan2(aT.cross(bT), aT.dot(bT))

template directionTo*[A, B: SomeVec2](a: A, b: B): auto =
  (b - a).normalize

template limit*(a: SomeVec2, limit: SomeNumber): auto =
  var aT = a.asFloat
  let limitT = limit.asFloat
  let length = aT.length
  if length > 0.0 and limitT < length:
    aT /= length
    aT *= limitT
  aT