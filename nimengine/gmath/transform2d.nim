import std/math
import ./vec2

template swap(x, y: untyped): untyped =
  let temp = x
  x = y
  y = temp

type
  Transform2d* = object
    elements*: array[3, Vec2]

func transform2d*(xx, xy, yx, yy, ox, oy: float32): Transform2d =
  result.elements[0][0] = xx
  result.elements[0][1] = xy
  result.elements[1][0] = yx
  result.elements[1][1] = yy
  result.elements[2][0] = ox
  result.elements[2][1] = oy

func transform2d*(x, y, origin: Vec2): Transform2d =
  result.elements[0] = x
  result.elements[1] = y
  result.elements[2] = origin

func transform2d*(rot: float32, pos: Vec2): Transform2d =
  let cr = cos(rot)
  let sr = sin(rot)
  result.elements[0][0] = cr
  result.elements[0][1] = sr
  result.elements[1][0] = -sr
  result.elements[1][1] = cr
  result.elements[2] = pos

func transform2d*(rot: float32, scale: Vec2, skew: float32, pos: Vec2): Transform2d =
  result.elements[0][0] = cos(rot) * scale.x
  result.elements[1][1] = cos(rot + skew) * scale.y
  result.elements[1][0] = -sin(rot + skew) * scale.y
  result.elements[0][1] = sin(rot) * scale.x
  result.elements[2] = pos

func transform2d*(): Transform2d =
  result.elements[0][0] = 1.0
  result.elements[1][1] = 1.0

template `[]`*(self: Transform2d, i: int): untyped = self.elements[i]
template `[]=`*(self: Transform2d, i: int, v: float32): untyped = self.elements[i] = v

func tdotx*(self: Transform2d, v: Vec2): float32 =
  self.elements[0][0] * v.x + self.elements[1][0] * v.y

func tdoty*(self: Transform2d, v: Vec2): float32 =
  self.elements[0][1] * v.x + self.elements[1][1] * v.y

func basisXform*(self: Transform2d, v: Vec2): Vec2 =
  vec2(self.tdotx(v), self.tdoty(v))

func basisXformInv*(self: Transform2d, v: Vec2): Vec2 =
  vec2(self.elements[0].dot(v), self.elements[1].dot(v))

func xform*(self: Transform2d, v: Vec2): Vec2 =
  vec2(self.tdotx(v), self.tdoty(v)) + self.elements[2]

func xformInv*(self: Transform2d, v: Vec2): Vec2 =
  let ve = v - self.elements[2]
  vec2(self.elements[0].dot(ve), self.elements[1].dot(ve))

func `==`*(self, other: Transform2d): bool =
  for i in 0 ..< 3:
    if self.elements[i] != other.elements[i]:
      return false
  true

func `*=`*(self: var Transform2d, other: Transform2d) =
  self.elements[2] = self.xform(other.elements[2])

  var x0, x1, y0, y1: float32

  x0 = self.tdotx(other.elements[0])
  x1 = self.tdoty(other.elements[0])
  y0 = self.tdotx(other.elements[1])
  y1 = self.tdoty(other.elements[1])

  self.elements[0][0] = x0
  self.elements[0][1] = x1
  self.elements[1][0] = y0
  self.elements[1][1] = y1

func `*`*(self, other: Transform2d): Transform2d =
  result = self
  result *= other

func `*=`*(self: var Transform2d, v: float32) =
  self.elements[0] *= v
  self.elements[1] *= v
  self.elements[2] *= v

func `*`*(self: Transform2d, v: float32): Transform2d =
  result = self
  result *= v

func invert*(self: var Transform2d) =
  swap(self.elements[0][1], self.elements[1][0])
  self.elements[2] = self.basisXform(-self.elements[2])

func inverse*(self: Transform2d): Transform2d =
  result = self
  result.invert()

func basisDeterminant*(self: Transform2d): float32 =
  self.elements[0].x * self.elements[1].y - self.elements[0].y * self.elements[1].x

func getOrigin*(self: Transform2d): Vec2 =
  self.elements[2]

func setOrigin*(self: var Transform2d, origin: Vec2) =
  self.elements[2] = origin

func affineInvert*(self: var Transform2d) =
  let det = self.basisDeterminant()
  assert(det != 0)
  let idet = 1.0f / det
  swap(self.elements[0][0], self.elements[1][1])
  self.elements[0] *= vec2(idet, -idet)
  self.elements[1] *= vec2(-idet, idet)
  self.elements[2] = self.basisXform(-self.elements[2])

func affineInverse*(self: Transform2d): Transform2d =
  result = self
  result.affineInvert()

func getScale*(self: Transform2d): Vec2 =
  let detSign = self.basisDeterminant().sgn.float32
  vec2(self.elements[0].length(), detSign * self.elements[1].length())

func setScale*(self: var Transform2d, scale: Vec2) =
  self.elements[0].normalize()
  self.elements[1].normalize()
  self.elements[0] *= scale.x
  self.elements[1] *= scale.y

func scaleBasis*(self: var Transform2d, scale: Vec2) =
  self.elements[0][0] *= scale.x
  self.elements[0][1] *= scale.y
  self.elements[1][0] *= scale.x
  self.elements[1][1] *= scale.y

func basisScaled*(self: Transform2d, scale: Vec2): Transform2d =
  result = self
  result.scaleBasis(scale)

func scale*(self: var Transform2d, scale: Vec2) =
  self.scaleBasis(scale)
  self.elements[2] *= scale

func scaled*(self: Transform2d, scale: Vec2): Transform2d =
  result = self
  result.scale(scale)

func setRotation*(self: var Transform2d, v: float32) =
  let scale = self.getScale()
  let cr = cos(v)
  let sr = sin(v)
  self.elements[0][0] = cr
  self.elements[0][1] = sr
  self.elements[1][0] = -sr
  self.elements[1][1] = cr
  self.setScale(scale)

func getRotation*(self: Transform2d): float32 =
  arctan2(self.elements[0].y, self.elements[0].x)

func rotate*(self: var Transform2d, phi: float32) =
  self = transform2d(phi, vec2()) * self

func rotated*(self: Transform2d, phi: float32): Transform2d =
  result = self
  result.rotate(phi)

func getSkew*(self: Transform2d): float32 =
  let det = self.basisDeterminant()
  arccos(self.elements[0].normalized().dot(sgn(det).float32 * self.elements[1].normalized())) - Pi * 0.5f

func setSkew*(self: var Transform2d, angle: float32) =
  let det = self.basisDeterminant()
  self.elements[1] = sgn(det).float32 * self.elements[0].rotated((Pi * 0.5f + angle)).normalized() * self.elements[1].length()

func setRotationAndScale*(self: var Transform2d, rot: float32, scale: Vec2) =
  self.elements[0][0] = cos(rot) * scale.x
  self.elements[1][1] = cos(rot) * scale.y
  self.elements[1][0] = -sin(rot) * scale.y
  self.elements[0][1] = sin(rot) * scale.x

func setRotationScaleAndSkew*(self: var Transform2d, rot: float32, scale: Vec2, skew: float32) =
  self.elements[0][0] = cos(rot) * scale.x
  self.elements[1][1] = cos(rot + skew) * scale.y
  self.elements[1][0] = -sin(rot + skew) * scale.y
  self.elements[0][1] = sin(rot) * scale.x

func translate*(self: var Transform2d, translation: Vec2) =
  self.elements[2] += self.basisXform(translation)

func translate*(self: var Transform2d, x, y: float32) =
  self.translate(vec2(x, y))

func translated*(self: Transform2d, translation: Vec2): Transform2d =
  result = self
  result.translate(translation)

func translated*(self: Transform2d, x, y: float32): Transform2d =
  result = self
  result.translate(x, y)

func orthonormalize*(self: var Transform2d) =
  # Gram-Schmidt Process

  var x = self.elements[0]
  var y = self.elements[1]

  x.normalize()
  y = (y - x * (x.dot(y)))
  y.normalize()

  self.elements[0] = x
  self.elements[1] = y

func orthonormalized*(self: Transform2d): Transform2d =
  result = self
  result.orthonormalize()

func `~=`*(self, other: Transform2d): bool =
  self.elements[0] ~= other.elements[0] and
  self.elements[1] ~= other.elements[1] and
  self.elements[2] ~= other.elements[2]

func lookingAt*(self: Transform2d, target: Vec2): Transform2d =
  result = transform2d(self.getRotation(), self.getOrigin())
  let targetPosition = self.affineInverse().xform(target)
  result.setRotation(result.getRotation() + (targetPosition * self.getScale()).angle())

func interpolatedWith*(self, other: Transform2d, c: float32): Transform2d =
  # extract parameters
  let p1 = self.getOrigin()
  let p2 = other.getOrigin()

  let r1 = self.getRotation()
  let r2 = other.getRotation()

  let s1 = self.getScale()
  let s2 = other.getScale()

  # slerp rotation
  let v1 = vec2(cos(r1), sin(r1))
  let v2 = vec2(cos(r2), sin(r2))

  var dot = v1.dot(v2)

  dot = clamp(dot, -1.0f, 1.0f)

  var v: Vec2

  if dot > 0.9995f:
    v = v1.lerped(v2, c).normalized() # linearly interpolate to avoid numerical precision issues
  else:
    let angle = c * arccos(dot)
    let v3 = (v2 - v1 * dot).normalized()
    v = v1 * cos(angle) + v3 * sin(angle)

  # construct matrix
  result = transform2d(v.angle(), p1.lerped(p2, c))
  result.scaleBasis(s1.lerped(s2, c))