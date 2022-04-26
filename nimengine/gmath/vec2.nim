import std/math
import ./utils

export math
export utils

type
  Vec2* = tuple[x, y: float]

func vec2*(x, y: float): Vec2 {.inline.} =
  (x: x, y: y)

type
  SomeVec2* = concept s
    s.x
    s.y

{.push inline.}

template defineUnaryOperator(op): untyped =
  func op*[T: SomeVec2](s: T): T =
    result.x = op(s.x)
    result.y = op(s.y)

template defineBinaryOperator(op): untyped =
  func op*[A, B: SomeVec2](a: A, b: B): A =
    result.x = op(a.x, b.x)
    result.y = op(a.y, b.y)

  func op*[A: SomeVec2, B: not SomeVec2](a: A, b: B): A =
    result.x = op(a.x, typeof(a.x)(b))
    result.y = op(a.y, typeof(a.y)(b))

  func op*[A: not SomeVec2, B: SomeVec2](a: A, b: B): B =
    result.x = op(typeof(b.x)(a), b.x)
    result.y = op(typeof(b.y)(a), b.y)

template defineBinaryEqualOperator(op): untyped =
  func op*[A, B: SomeVec2](a: var A, b: B) =
    op(a.x, b.x)
    op(a.y, b.y)

  func op*[A: SomeVec2, B: not SomeVec2](a: var A, b: B) =
    op(a.x, b)
    op(a.y, b)

template defineComparativeOperator(op): untyped =
  func op*[A, B: SomeVec2](a: A, b: B): bool =
    op(a.x, b.x) and op(a.y, b.y)

defineUnaryOperator(`+`)
defineUnaryOperator(`-`)

defineBinaryOperator(`+`)
defineBinaryOperator(`-`)
defineBinaryOperator(`*`)
defineBinaryOperator(`/`)
defineBinaryOperator(`div`)
defineBinaryOperator(`mod`)

defineBinaryEqualOperator(`+=`)
defineBinaryEqualOperator(`-=`)
defineBinaryEqualOperator(`*=`)
defineBinaryEqualOperator(`/=`)

defineComparativeOperator(`~=`)
defineComparativeOperator(`==`)

func setAll*[T: SomeVec2, V](s: var T, value: V) =
  s.x = typeof(s.x)(value)
  s.y = typeof(s.y)(value)

func setZero*[T: SomeVec2](s: var T) =
  s.setAll(0)

func length*[T: SomeVec2](s: T): auto =
  (s.x * s.x + s.y * s.y).sqrt

func lengthSquared*[T: SomeVec2](s: T): auto =
  s.x * s.x + s.y * s.y

func dot*[A, B: SomeVec2](a: A, b: B): auto =
  a.x * b.x + a.y * b.y

func cross*[A, B: SomeVec2](a: A, b: B): auto =
  a.x * b.y - a.y * b.x

func distanceTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).length

func distanceSquaredTo*[A, B: SomeVec2](a: A, b: B): auto =
  (a - b).lengthSquared

func rotated*[T: SomeVec2, P](s: T, phi: P): T =
  let sn = sin(phi)
  let cs = cos(phi)
  result.x = s.x * cs - s.y * sn
  result.y = s.x * sn + s.y * cs

func rotate*[T: SomeVec2, P](s: var T, phi: P) =
  s = s.rotated(phi)

func angle*[T: SomeVec2](s: T): auto =
  arctan2(s.y, s.x)

func isNormalized*[T: SomeVec2](s: T): bool =
  s.lengthSquared ~= 1.0

func normalize*[T: SomeVec2](s: var T) =
  let lengthSquared = s.lengthSquared
  if lengthSquared == 0:
    s.setZero()
  else:
    let length = lengthSquared.sqrt
    s /= length

func normalized*[T: SomeVec2](s: T): T =
  result = s
  result.normalize()

func lerped*[A, B: SomeVec2](a: A, b: B, weight: float): A =
  a * (1.0 - weight) + b * weight

func lerp*[A, B: SomeVec2](a: var A, b: B, weight: float) =
  a = a.lerped(b, weight)

func slid*[A, B: SomeVec2](a: A, b: B): A =
  assert(b.isNormalized, "The other vector must be normalized.")
  a - b * a.dot(b)

func slide*[A, B: SomeVec2](a: var A, b: B) =
  a = a.slid(b)

func reflected*[A, B: SomeVec2](a: A, b: B): A =
  assert(b.isNormalized, "The other vector must be normalized.")
  b * a.dot(b) * 2.0 - a

func reflect*[A, B: SomeVec2](a: var A, b: B) =
  a = a.reflected(b)

func bounced*[A, B: SomeVec2](a: A, b: B): A =
  -a.reflected(b)

func bounce*[A, B: SomeVec2](a: var A, b: B) =
  a = a.bounced(b)

func projected*[A, B: SomeVec2](a: A, b: B) =
  b * (a.dot(b) / b.lengthSquared)

func project*[A, B: SomeVec2](a: var A, b: B) =
  a = a.projected(b)

func angleTo*[A, B: SomeVec2](a: A, b: B): auto =
  arctan2(a.cross(b), a.dot(b))

func directionTo*[A, B: SomeVec2](a: A, b: B): auto =
  (b - a).normalized

func limit*[T: SomeVec2, L](s: var T, limit: L) =
  let length = s.length
  if length > 0.0 and limit < length:
    s /= length
    s *= limit

func limited*[T: SomeVec2, L](s: T, limit: L): T =
  result = s
  result.limit(limit)

{.pop.}