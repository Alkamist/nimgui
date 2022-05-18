import ./common
export common

type
  SomeVec2* = tuple[x, y: float] or tuple[x, y: float64] or tuple[x, y: float32] or
              tuple[x, y: int] or tuple[x, y: int64] or tuple[x, y: int32] or tuple[x, y: int16] or tuple[x, y: int8] or
              tuple[x, y: uint] or tuple[x, y: uint64] or tuple[x, y: uint32] or tuple[x, y: uint16] or tuple[x, y: uint8]

template x*(a: SomeVec2): untyped = a[0]
template y*(a: SomeVec2): untyped = a[1]

{.push inline.}

func asFloat*(a: SomeVec2): auto = (x: a.x.asFloat, y: a.y.asFloat)
func asFloat32*(a: SomeVec2): auto = (x: a.x.asFloat32, y: a.y.asFloat32)
func asInt*(a: SomeVec2): auto = (x: a.x.asInt, y: a.y.asInt)
func asInt32*(a: SomeVec2): auto = (x: a.x.asInt32, y: a.y.asInt32)
func asInt16*(a: SomeVec2): auto = (x: a.x.asInt16, y: a.y.asInt16)
func asInt8*(a: SomeVec2): auto = (x: a.x.asInt8, y: a.y.asInt8)
func asUInt*(a: SomeVec2): auto = (x: a.x.asUInt, y: a.y.asUInt)
func asUInt32*(a: SomeVec2): auto = (x: a.x.asUInt32, y: a.y.asUInt32)
func asUInt16*(a: SomeVec2): auto = (x: a.x.asUInt16, y: a.y.asUInt16)
func asUInt8*(a: SomeVec2): auto = (x: a.x.asUInt8, y: a.y.asUInt8)

func `+`*(a: SomeVec2): auto = a
func `-`*(a: SomeVec2): auto = (x: -a.x, y: -a.y)

template vec2BinaryOperator(op: untyped): untyped =
  func op*[A, B: SomeVec2](a: A, b: B): auto = (x: op(a.x, b.x), y: op(a.y, b.y))
  func op*(a: SomeVec2, b: SomeNumber): auto = (x: op(a.x, b), y: op(a.y, b))

template vec2BinaryEqualsOperator(opEq, op: untyped): untyped =
  func opEq*[A, B: SomeVec2](a: var A, b: B) = a = op(a, b)
  func opEq*(a: var SomeVec2, b: SomeNumber) = a = op(a, b)

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

func `+`*(a: SomeNumber, b: SomeVec2): auto = (x: a + b.x, y: a + b.y)
func `*`*(a: SomeNumber, b: SomeVec2): auto = (x: a * b.x, y: a * b.y)

func `~=`*[A, B: SomeVec2](a: A, b: B): bool = a.x ~= b.x and a.y ~= b.y

func length*(a: SomeVec2): auto =
  let a = a.asFloat
  (a.x * a.x + a.y * a.y).sqrt

func lengthSquared*(a: SomeVec2): auto =
  a.x * a.x + a.y * a.y

func dot*[A, B: SomeVec2](a: A, b: B): auto =
  a.x * b.x + a.y * b.y

func cross*[A, B: SomeVec2](a: A, b: B): auto =
  a.x * b.y - a.y * b.x

func distanceTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).length

func distanceSquaredTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).lengthSquared

func rotate*(a: SomeVec2, phi: SomeNumber): auto =
  let a = a.asFloat
  let sn = sin(phi)
  let cs = cos(phi)
  (x: a.x * cs - a.y * sn,
   y: a.x * sn + a.y * cs)

func round*[A: SomeVec2](a: A): auto =
  (x: a.x.round, y: a.y.round)

func angle*(a: SomeVec2): auto =
  let a = a.asFloat
  arctan2(a.y, a.x)

func isNormalized*(a: SomeVec2): bool =
  a.lengthSquared ~= 1.0

func normalize*(a: SomeVec2): auto =
  var res = a.asFloat
  let lengthSquared = res.lengthSquared
  if lengthSquared == 0:
    res.x = 0
    res.y = 0
  else:
    let length = lengthSquared.sqrt
    res /= length
  res

func lerp*[A, B: SomeVec2](a: A, b: B, weight: SomeNumber): auto =
  let a = a.asFloat
  let b = b.asFloat
  let weight = weight.asFloat
  a * (1.0 - weight) + b * weight

func slide*[A, B: SomeVec2](a: A, b: B): auto =
  let a = a.asFloat
  let b = b.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    a - bNormalized * a.dot(bNormalized)
  else:
    a - b * a.dot(b)

func reflect*[A, B: SomeVec2](a: A, b: B): auto =
  let a = a.asFloat
  let b = b.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    bNormalized * a.dot(bNormalized) * 2.0 - a
  else:
    b * a.dot(b) * 2.0 - a

func bounce*[A, B: SomeVec2](a: A, b: B): auto =
  -a.reflect(b)

func project*[A, B: SomeVec2](a: A, b: B): auto =
  let a = a.asFloat
  let b = b.asFloat
  b * (a.dot(b) / b.lengthSquared)

func angleTo*[A, B: SomeVec2](a: A, b: B): auto =
  let a = a.asFloat
  let b = b.asFloat
  arctan2(a.cross(b), a.dot(b))

func directionTo*[A, B: SomeVec2](a: A, b: B): auto =
  (b - a).normalize

func limit*(a: SomeVec2, limit: SomeNumber): auto =
  var res = a.asFloat
  let limit = limit.asFloat
  let length = res.length
  if length > 0.0 and limit < length:
    res /= length
    res *= limit
  res

{.pop.}