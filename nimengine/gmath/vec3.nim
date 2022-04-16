import std/math
import ./utils

type
  Vec3* = object
    coords*: array[3, float32]

{.push inline.}

template x*(a: Vec3): untyped = a.coords[0]
template y*(a: Vec3): untyped = a.coords[1]
template z*(a: Vec3): untyped = a.coords[2]
template `x=`*(a: Vec3, v: float32): untyped = a.coords[0] = v
template `y=`*(a: Vec3, v: float32): untyped = a.coords[1] = v
template `z=`*(a: Vec3, v: float32): untyped = a.coords[2] = v
template `[]`*(a: Vec3, i: int): untyped = a.coords[i]
template `[]=`*(a: Vec3, i: int, v: float32): untyped = a.coords[i] = v

func `$`*(a: Vec3): string =
  "Vec3: " & $a.x.prettyFloat & ", " & $a.y.prettyFloat & ", " & $a.z.prettyFloat

template defineUnaryOperator(op): untyped =
  func op*(a: Vec3): Vec3 =
    result.x = op(a.x)
    result.y = op(a.y)
    result.z = op(a.z)

template defineBinaryOperator(op): untyped =
  func op*(a, b: Vec3): Vec3 =
    result.x = op(a.x, b.x)
    result.y = op(a.y, b.y)
    result.z = op(a.z, b.z)

  func op*(a: Vec3, b: float32): Vec3 =
    result.x = op(a.x, b)
    result.y = op(a.y, b)
    result.z = op(a.z, b)

  func op*(a: float32, b: Vec3): Vec3 =
    result.x = op(a, b.x)
    result.y = op(a, b.y)
    result.z = op(a, b.z)

template defineBinaryEqualOperator(op): untyped =
  func op*(a: var Vec3, b: Vec3) =
    op(a.x, b.x)
    op(a.y, b.y)
    op(a.z, b.z)

  func op*(a: var Vec3, b: float32) =
    op(a.x, b)
    op(a.y, b)
    op(a.z, b)

template defineComparativeOperator(op): untyped =
  func op*(a, b: Vec3): bool =
    op(a.x, b.x) and op(a.y, b.y) and op(a.z, b.z)

defineUnaryOperator(`+`)
defineUnaryOperator(`-`)

defineBinaryOperator(`+`)
defineBinaryOperator(`-`)
defineBinaryOperator(`*`)
defineBinaryOperator(`/`)
defineBinaryOperator(`mod`)

defineBinaryEqualOperator(`+=`)
defineBinaryEqualOperator(`-=`)
defineBinaryEqualOperator(`*=`)
defineBinaryEqualOperator(`/=`)

defineComparativeOperator(`~=`)
defineComparativeOperator(`==`)

func vec3*(x, y, z: float32 = 0): Vec3 =
  Vec3(coords: [x, y, z])

template mapIt*(v: Vec3, code): untyped =
  block:
    var it {.inject.} = v.x
    let x = code
    it = v.y
    let y = code
    it = v.z
    let z = code
    vec3(x, y, z)

template applyIt*(v: var Vec3, code): untyped =
  block:
    var it {.inject.} = v.x
    v.x = code
    it = v.y
    v.y = code
    it = v.z
    v.z = code

func dot*(a, b: Vec3): float32 =
  a.x * b.x + a.y * b.y + a.z * b.z

func length*(a: Vec3): float32 =
  (a.x * a.x + a.y * a.y + a.z * a.z).sqrt

func lengthSquared*(a: Vec3): float32 =
  a.x * a.x + a.y * a.y + a.z * a.z

func isNormalized*(a: Vec3): bool =
  a.lengthSquared ~= 1.0

func distanceTo*(at, to: Vec3): float32 =
  (at - to).length

func distanceSquaredTo*(at, to: Vec3): float32 =
  (at - to).lengthSquared

func setAll*(a: var Vec3, value: float32) =
  a.x = value
  a.y = value
  a.z = value

func setZero*(a: var Vec3) =
  a.setAll(0)

func cross*(a, b: Vec3): Vec3 =
  result.x = a.y * b.z - a.z * b.y
  result.y = a.z * b.x - a.x * b.z
  result.z = a.x * b.y - a.y * b.x

func normalize*(a: var Vec3) =
  let lengthSquared = a.lengthSquared
  if lengthSquared == 0:
    a.setZero
  else:
    let length = lengthSquared.sqrt
    a /= length

func normalized*(a: Vec3): Vec3 =
  result = a
  result.normalize

func lerp*(a, b: Vec3, v: float32): Vec3 =
  a * (1.0 - v) + b * v

func slide*(a, normal: Vec3): Vec3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  a - normal * a.dot(normal)

func reflect*(a, normal: Vec3): Vec3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  normal * a.dot(normal) * 2.0 - a

func bounce*(a, normal: Vec3): Vec3 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  -a.reflect(normal)

func project*(a, b: Vec3): Vec3 =
  b * (a.dot(b) / b.lengthSquared)

func angleTo*(a, b: Vec3): float32 =
  arctan2(a.cross(b).length, a.dot(b))

func directionTo*(a, b: Vec3): Vec3 =
  (b - a).normalized

func limitLength*(a: Vec3, limit: float32): Vec3 =
  result = a
  let length = result.length
  if length > 0.0 and limit < length:
    result /= length
    result *= limit

{.pop.}