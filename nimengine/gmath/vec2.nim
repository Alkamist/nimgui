import std/math
import ./utils

type
  Vec2* = object
    coords*: array[2, float32]

{.push inline.}

func vec2*(x, y: float32 = 0): Vec2 =
  Vec2(coords: [x, y])

template x*(self: Vec2): untyped = self.coords[0]
template y*(self: Vec2): untyped = self.coords[1]
template width*(self: Vec2): untyped = self.coords[0]
template height*(self: Vec2): untyped = self.coords[1]

template `x=`*(self: Vec2, v: float32): untyped = self.coords[0] = v
template `y=`*(self: Vec2, v: float32): untyped = self.coords[1] = v
template `width=`*(self: Vec2, v: float32): untyped = self.coords[0] = v
template `height=`*(self: Vec2, v: float32): untyped = self.coords[1] = v

template `[]`*(self: Vec2, i: int): untyped = self.coords[i]
template `[]=`*(self: Vec2, i: int, v: float32): untyped = self.coords[i] = v

func `$`*(self: Vec2): string =
  "Vec2: " & $self.x.prettyFloat & ", " & $self.y.prettyFloat

template defineUnaryOperator(op): untyped =
  func op*(self: Vec2): Vec2 =
    vec2(op(self.x), op(self.y))

template defineBinaryOperator(op): untyped =
  func op*(self, other: Vec2): Vec2 =
    vec2(op(self.x, other.x), op(self.y, other.y))

  func op*(self: Vec2, other: float32): Vec2 =
    vec2(op(self.x, other), op(self.y, other))

  func op*(self: float32, other: Vec2): Vec2 =
    vec2(op(self, other.x), op(self, other.y))

template defineBinaryEqualOperator(op): untyped =
  func op*(self: var Vec2, other: Vec2) =
    op(self.x, other.x)
    op(self.y, other.y)

  func op*(self: var Vec2, other: float32) =
    op(self.x, other)
    op(self.y, other)

template defineComparativeOperator(op): untyped =
  func op*(self, other: Vec2): bool =
    op(self.x, other.x) and op(self.y, other.y)

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

func dot*(self, other: Vec2): float32 =
  self.x * other.x + self.y * other.y

func length*(self: Vec2): float32 =
  (self.x * self.x + self.y * self.y).sqrt

func lengthSquared*(self: Vec2): float32 =
  self.x * self.x + self.y * self.y

func isNormalized*(self: Vec2): bool =
  self.lengthSquared ~= 1.0

func distanceTo*(self, to: Vec2): float32 =
  (self - to).length

func distanceSquaredTo*(self, to: Vec2): float32 =
  (self - to).lengthSquared

func setAll*(self: var Vec2, value: float32) =
  self.x = value
  self.y = value

func setZero*(self: var Vec2) =
  self.setAll(0)

func cross*(self, other: Vec2): float32 =
  self.x * other.y - self.y * other.x

func rotated*(self: Vec2, phi: float32): Vec2 =
  let s = sin(phi)
  let c = cos(phi)
  vec2(self.x * c - self.y * s, self.x * s + self.y * c)

func rotate*(self: var Vec2, phi: float32) =
  self = self.rotated(phi)

func angle*(self: Vec2): float32 =
  arctan2(self.y, self.x)

func normalize*(self: var Vec2) =
  let lengthSquared = self.lengthSquared
  if lengthSquared == 0:
    self.setZero
  else:
    let length = lengthSquared.sqrt
    self /= length

func normalized*(self: Vec2): Vec2 =
  result = self
  result.normalize

func lerped*(self, other: Vec2, weight: float32): Vec2 =
  self * (1.0 - weight) + other * weight

func lerp*(self: var Vec2, other: Vec2, weight: float32) =
  self = self.lerped(other, weight)

func slid*(self, normal: Vec2): Vec2 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  self - normal * self.dot(normal)

func slide*(self: var Vec2, normal: Vec2) =
  self = self.slid(normal)

func reflected*(self, normal: Vec2): Vec2 =
  assert(normal.isNormalized, "The other vector must be normalized.")
  normal * self.dot(normal) * 2.0 - self

func reflect*(self: var Vec2, normal: Vec2) =
  self = self.reflected(normal)

func bounced*(self, normal: Vec2): Vec2 =
  -self.reflected(normal)

func bounce*(self: var Vec2, normal: Vec2) =
  self = self.bounced(normal)

func projected*(self, other: Vec2): Vec2 =
  other * (self.dot(other) / other.lengthSquared)

func project*(self: var Vec2, other: Vec2): Vec2 =
  self = self.projected(other)

func angleTo*(self, other: Vec2): float32 =
  arctan2(self.cross(other), self.dot(other))

func directionTo*(self, other: Vec2): Vec2 =
  (other - self).normalized

func limitLength*(self: var Vec2, limit: float32) =
  let length = self.length
  if length > 0.0 and limit < length:
    self /= length
    self *= limit

func lengthLimited*(self: Vec2, limit: float32): Vec2 =
  result = self
  result.limitLength(limit)

{.pop.}