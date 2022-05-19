import ./common
export common

# type
#   SomeVec2* = concept v
#     v.x is SomeNumber
#     v.y is SomeNumber

type
  SomeVec2*[T] = tuple[x, y: T]

template x*(tv: SomeVec2): untyped = tv[0]
template y*(tv: SomeVec2): untyped = tv[1]

template asFloat*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asFloat, y: v.y.asFloat)

template asFloat64*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asFloat64, y: v.y.asFloat64)

template asFloat32*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asFloat32, y: v.y.asFloat32)

template asInt*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asInt, y: v.y.asInt)

template asInt64*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asInt64, y: v.y.asInt64)

template asInt32*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asInt32, y: v.y.asInt32)

template asInt16*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asInt16, y: v.y.asInt16)

template asInt8*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asInt8, y: v.y.asInt8)

template asUInt*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asUInt, y: v.y.asUInt)

template asUInt64*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asUInt64, y: v.y.asUInt64)

template asUInt32*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asUInt32, y: v.y.asUInt32)

template asUInt16*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asUInt16, y: v.y.asUInt16)

template asUInt8*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.asUInt8, y: v.y.asUInt8)

template `+`*(tv: SomeVec2): untyped =
  tv

template `-`*(tv: SomeVec2): untyped =
  let v = tv
  (x: -v.x, y: -v.y)

template vec2BinaryOperator(op: untyped): untyped =
  template op*[A, B: SomeVec2](ta: A, tb: B): untyped =
    let a = ta
    let b = tb
    (x: op(a.x, b.x), y: op(a.y, b.y))

  template op*(ta: SomeVec2, tb: SomeNumber): untyped =
    let a = ta
    let b = tb
    (x: op(a.x, b), y: op(a.y, b))

template vec2BinaryEqualsOperator(opEq, op: untyped): untyped =
  template opEq*[A, B: SomeVec2](ta: var A, tb: B) = ta = op(ta, tb)
  template opEq*(ta: var SomeVec2, tb: SomeNumber) = ta = op(ta, tb)

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

template `+`*(ta: SomeNumber, tb: SomeVec2): untyped =
  let a = ta
  let b = tb
  (x: a + b.x, y: a + b.y)

template `*`*(ta: SomeNumber, tb: SomeVec2): untyped =
  let a = ta
  let b = tb
  (x: a * b.x, y: a * b.y)

template `~=`*[A, B: SomeVec2](ta: A, tb: B): bool =
  let a = ta
  let b = tb
  a.x ~= b.x and a.y ~= b.y

template length*(tv: SomeVec2): untyped =
  let v = tv.asFloat
  (v.x * v.x + v.y * v.y).sqrt

template lengthSquared*(tv: SomeVec2): untyped =
  let v = tv
  v.x * v.x + v.y * v.y

template dot*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta
  let b = tb
  a.x * b.x + a.y * b.y

template cross*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta
  let b = tb
  a.x * b.y - a.y * b.x

template distanceTo*[A, B: SomeVec2](ta: A, tb: B): untyped =
  (a - b).length

template distanceSquaredTo*[A, B: SomeVec2](ta: A, tb: B): untyped =
  (a - b).lengthSquared

template rotate*(tv: SomeVec2, tphi: SomeNumber): untyped =
  let v = tv.asFloat
  let phi = tphi.asFloat
  let sn = sin(phi)
  let cs = cos(phi)
  (x: v.x * cs - v.y * sn,
                 y: v.x * sn + v.y * cs)

template round*(tv: SomeVec2): untyped =
  let v = tv
  (x: v.x.round, y: v.y.round)

template angle*(tv: SomeVec2): untyped =
  let v = tv.asFloat
  arctan2(v.y, v.x)

template isNormalized*(tv: SomeVec2): bool =
  v.lengthSquared ~= 1.0

template normalize*(tv: SomeVec2): untyped =
  var res = tv.asFloat
  let lengthSquared = res.lengthSquared
  if lengthSquared == 0:
    res.x = 0
    res.y = 0
  else:
    let length = lengthSquared.sqrt
    res /= length
  res

template lerp*[A, B: SomeVec2](ta: A, tb: B, tweight: SomeNumber): untyped =
  let a = ta.asFloat
  let b = tb.asFloat
  let weight = tweight.asFloat
  a * (1.0 - weight) + b * weight

template slide*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta.asFloat
  let b = tb.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    a - bNormalized * a.dot(bNormalized)
  else:
    a - b * a.dot(b)

template reflect*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta.asFloat
  let b = tb.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    bNormalized * a.dot(bNormalized) * 2.0 - a
  else:
    b * a.dot(b) * 2.0 - a

template bounce*[A, B: SomeVec2](ta: A, tb: B): untyped =
  -ta.reflect(tb)

template project*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta.asFloat
  let b = tb.asFloat
  b * (a.dot(b) / b.lengthSquared)

template angleTo*[A, B: SomeVec2](ta: A, tb: B): untyped =
  let a = ta.asFloat
  let b = tb.asFloat
  arctan2(a.cross(b), a.dot(b))

template directionTo*[A, B: SomeVec2](ta: A, tb: B): untyped =
  (tb - ta).normalize

template limit*(tv: SomeVec2, tlimit: SomeNumber): untyped =
  var res = tv.asFloat
  let limit = tlimit.asFloat
  let length = res.length
  if length > 0.0 and limit < length:
    res /= length
    res *= limit
  res

when isMainModule:
  let a = (r: 5.0, g: 5.0, b: 5.0)

  echo a + (5.0, 5.0)