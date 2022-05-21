import ./common
export common

type
  Vec2* = object
    x*, y*: float

{.push inline.}

# func vec2*(x, y: float): Vec2 = (x: x, y: y)
func vec2*(x, y: float): Vec2 = Vec2(x: x, y: y)

func `+`*(v: Vec2): Vec2 = v
func `-`*(v: Vec2): Vec2 = vec2(-v.x, -v.y)

template vec2BinaryOperator(op: untyped): untyped {.dirty.} =
  func op*(a, b: Vec2): Vec2 =
    vec2(op(a.x, b.x), op(a.y, b.y))

  func op*(a: Vec2, b: float): Vec2 =
    vec2(op(a.x, b), op(a.y, b))

template vec2BinaryEqualsOperator(opEq, op: untyped): untyped {.dirty.} =
  func opEq*(a: var Vec2, b: Vec2) =
    a = op(a, b)

  func opEq*(a: var Vec2, b: float) =
    a = op(a, b)

vec2BinaryOperator(`+`)
vec2BinaryEqualsOperator(`+=`, `+`)
vec2BinaryOperator(`-`)
vec2BinaryEqualsOperator(`-=`, `-`)
vec2BinaryOperator(`*`)
vec2BinaryEqualsOperator(`*=`, `*`)
vec2BinaryOperator(`/`)
vec2BinaryEqualsOperator(`/=`, `/`)
vec2BinaryOperator(`mod`)

func `+`*(a: float, b: Vec2): Vec2 =
  vec2(a + b.x, a + b.y)

func `*`*(a: float, b: Vec2): Vec2 =
  vec2(a * b.x, a * b.y)

func `~=`*(a, b: Vec2): bool =
  a.x ~= b.x and a.y ~= b.y

func length*(v: Vec2): float =
  (v.x * v.x + v.y * v.y).sqrt

func lengthSquared*(v: Vec2): float =
  v.x * v.x + v.y * v.y

func dot*(a, b: Vec2): float =
  a.x * b.x + a.y * b.y

func cross*(a, b: Vec2): float =
  a.x * b.y - a.y * b.x

func distanceTo*(a, b: Vec2): float =
  (a - b).length

func distanceSquaredTo*(a, b: Vec2): float =
  (a - b).lengthSquared

func rotate*(v: Vec2, phi: float): Vec2 =
  let sn = sin(phi)
  let cs = cos(phi)
  vec2(v.x * cs - v.y * sn, v.x * sn + v.y * cs)

func round*(v: Vec2): Vec2 =
  vec2(v.x.round, v.y.round)

func angle*(v: Vec2): float =
  arctan2(v.y, v.x)

func isNormalized*(v: Vec2): bool =
  v.lengthSquared ~= 1.0

func normalize*(v: Vec2): Vec2 =
  result = v
  let lengthSquared = result.lengthSquared
  if lengthSquared == 0:
    result.x = 0
    result.y = 0
  else:
    let length = lengthSquared.sqrt
    result /= length

func lerp*(a, b: Vec2, weight: float): Vec2 =
  a * (1.0 - weight) + b * weight

func slide*(a, b: Vec2): auto =
  if not b.isNormalized:
    let bNormalized = b.normalize
    a - bNormalized * a.dot(bNormalized)
  else:
    a - b * a.dot(b)

func reflect*(a, b: Vec2): Vec2 =
  if not b.isNormalized:
    let bNormalized = b.normalize
    bNormalized * a.dot(bNormalized) * 2.0 - a
  else:
    b * a.dot(b) * 2.0 - a

func bounce*(a, b: Vec2): Vec2 =
  -a.reflect(b)

func project*(a, b: Vec2): Vec2 =
  b * (a.dot(b) / b.lengthSquared)

func angleTo*(a, b: Vec2): float =
  arctan2(a.cross(b), a.dot(b))

func directionTo*(a, b: Vec2): Vec2 =
  (b - a).normalize

func limit*(v: Vec2, limit: float): Vec2 =
  result = v
  let length = result.length
  if length > 0.0 and limit < length:
    result /= length
    result *= limit

{.pop.}