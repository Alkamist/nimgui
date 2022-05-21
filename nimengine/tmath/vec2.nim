import ./common
export common

type
  Vec2*[T] = tuple
    x, y: T

{.push inline.}

func vec2*[T](x, y: T): Vec2[T] = (x: x, y: y)

func asFloat*[T](v: Vec2[T]): auto = vec2(v.x.asFloat, v.y.asFloat)
func asFloat64*[T](v: Vec2[T]): auto = vec2(v.x.asFloat64, v.y.asFloat64)
func asFloat32*[T](v: Vec2[T]): auto = vec2(v.x.asFloat32, v.y.asFloat32)
func asInt*[T](v: Vec2[T]): auto = vec2(v.x.asInt, v.y.asInt)
func asInt64*[T](v: Vec2[T]): auto = vec2(v.x.asInt64, v.y.asInt64)
func asInt32*[T](v: Vec2[T]): auto = vec2(v.x.asInt32, v.y.asInt32)
func asInt16*[T](v: Vec2[T]): auto = vec2(x: v.x.asInt16, v.y.asInt16)
func asInt8*[T](v: Vec2[T]): auto = vec2(v.x.asInt8, v.y.asInt8)
func asUInt*[T](v: Vec2[T]): auto = vec2(v.x.asUInt, v.y.asUInt)
func asUInt64*[T](v: Vec2[T]): auto = vec2(v.x.asUInt64, v.y.asUInt64)
func asUInt32*[T](v: Vec2[T]): auto = vec2(v.x.asUInt32, v.y.asUInt32)
func asUInt16*[T](v: Vec2[T]): auto = vec2(v.x.asUInt16, v.y.asUInt16)
func asUInt8*[T](v: Vec2[T]): auto = vec2(v.x.asUInt8, v.y.asUInt8)

func `+`*[T](v: Vec2[T]): auto = v
func `-`*[T](v: Vec2[T]): auto = vec2(-v.x, -v.y)

template vec2BinaryOperator(op: untyped): untyped {.dirty.} =
  func op*[A, B](a: Vec2[A], b: Vec2[B]): auto =
    vec2(op(a.x, b.x), op(a.y, b.y))

  func op*[T](a: Vec2[T], b: SomeNumber): auto =
    vec2(op(a.x, b), op(a.y, b))

template vec2BinaryEqualsOperator(opEq, op: untyped): untyped {.dirty.} =
  func opEq*[A, B](a: var Vec2[A], b: Vec2[B]) =
    a = op(a, b)

  func opEq*[T](a: var Vec2[T], b: SomeNumber) =
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

func `+`*[T](a: SomeNumber, b: Vec2[T]): auto =
  vec2(a + b.x, a + b.y)

func `*`*[T](a: SomeNumber, b: Vec2[T]): auto =
  vec2(a * b.x, a * b.y)

func `~=`*[A, B](a: Vec2[A], b: Vec2[B]): bool =
  a.x ~= b.x and a.y ~= b.y

func length*[T](v: Vec2[T]): auto =
  (v.x * v.x + v.y * v.y).sqrt

func lengthSquared*[T](v: Vec2[T]): auto =
  v.x * v.x + v.y * v.y

func dot*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  a.x * b.x + a.y * b.y

func cross*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  a.x * b.y - a.y * b.x

func distanceTo*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  (a - b).length

func distanceSquaredTo*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  (a - b).lengthSquared

func rotate*[T](v: Vec2[T], phi: SomeNumber): auto =
  let v = v.asFloat
  let phi = phi.asFloat
  let sn = sin(phi)
  let cs = cos(phi)
  vec2(v.x * cs - v.y * sn, v.x * sn + v.y * cs)

func round*[T](v: Vec2[T]): auto =
  vec2(v.x.round, v.y.round)

func angle*[T](v: Vec2[T]): auto =
  arctan2(v.y.asFloat, v.x.asFloat)

func isNormalized*[T](v: Vec2[T]): bool =
  v.lengthSquared ~= 1.0

func normalize*[T](v: Vec2[T]): auto =
  var res = v.asFloat
  let lengthSquared = res.lengthSquared
  if lengthSquared == 0:
    res.x = 0
    res.y = 0
  else:
    let length = lengthSquared.sqrt
    res /= length
  res

func lerp*[A, B](a: Vec2[A], b: Vec2[B], weight: SomeNumber): auto =
  let a = a.asFloat
  let b = b.asFloat
  let weight = weight.asFloat
  a * (1.0 - weight) + b * weight

func slide*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  let a = a.asFloat
  let b = b.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    a - bNormalized * a.dot(bNormalized)
  else:
    a - b * a.dot(b)

func reflect*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  let a = a.asFloat
  let b = b.asFloat
  if not b.isNormalized:
    let bNormalized = b.normalize
    bNormalized * a.dot(bNormalized) * 2.0 - a
  else:
    b * a.dot(b) * 2.0 - a

func bounce*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  -a.reflect(b)

func project*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  let a = a.asFloat
  let b = b.asFloat
  b * (a.dot(b) / b.lengthSquared)

func angleTo*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  let a = a.asFloat
  let b = b.asFloat
  arctan2(a.cross(b), a.dot(b))

func directionTo*[A, B](a: Vec2[A], b: Vec2[B]): auto =
  (b - a).normalize

func limit*[T](v: Vec2[T], limit: SomeNumber): auto =
  var res = v.asFloat
  let limit = limit.asFloat
  let length = res.length
  if length > 0.0 and limit < length:
    res /= length
    res *= limit
  res

{.pop.}

let a = (2.0, 1.0)
let b = (5, 5)

echo a + b