import std/math
import ./vec2
import ./color

# Ported from nanovg.

type
  Paint* = object
    transform*: array[6, float]
    extent*: array[2, float]
    radius*: float
    feather*: float
    innerColor*: Color
    outerColor*: Color
    image*: int

proc transformIdentity(t: var array[6, float]) =
  t[0] = 1.0
  t[1] = 0.0
  t[2] = 0.0
  t[3] = 1.0
  t[4] = 0.0
  t[5] = 0.0

proc transformRotate(t: var array[6, float], angle: float) =
  let cs = cos(angle)
  let sn = sin(angle)
  t[0] = cs
  t[1] = sn
  t[2] = -sn
  t[3] = cs
  t[4] = 0.0
  t[5] = 0.0

proc solidColorPaint*(color: Color): Paint =
  transformIdentity(result.transform)
  result.radius = 0.0
  result.feather = 1.0
  result.innerColor = color
  result.outerColor = color

proc linearGradient*(start, finish: Vec2, innerColor, outerColor: Color): Paint =
  const large = 1e5

  var dx, dy, d: float

  # Calculate transform aligned to the line
  dx = finish.x - start.x
  dy = finish.y - start.y
  d = sqrt(dx * dx + dy * dy)

  if d > 0.0001:
    dx /= d
    dy /= d
  else:
    dx = 0
    dy = 1

  result.transform[0] = dy
  result.transform[1] = -dx
  result.transform[2] = dx
  result.transform[3] = dy
  result.transform[4] = start.x - dx * large
  result.transform[5] = start.y - dy * large

  result.extent[0] = large
  result.extent[1] = large + d * 0.5

  result.radius = 0.0

  result.feather = max(1.0, d)

  result.innerColor = innerColor
  result.outerColor = outerColor

proc radialGradient*(center: Vec2, innerRadius, outerRadius: float, innerColor, outerColor: Color): Paint =
  let radius = (innerRadius + outerRadius) * 0.5
  let feather = (outerRadius - innerRadius)

  transformIdentity(result.transform)
  result.transform[4] = center.x
  result.transform[5] = center.y

  result.extent[0] = radius
  result.extent[1] = radius

  result.radius = radius

  result.feather = max(1.0, feather)

  result.innerColor = innerColor
  result.outerColor = outerColor

proc boxGradient*(position, size: Vec2, radius, feather: float, innerColor, outerColor: Color): Paint =
  transformIdentity(result.transform)

  result.transform[4] = position.x + size.x * 0.5
  result.transform[5] = position.y + size.y * 0.5

  result.extent[0] = size.x * 0.5
  result.extent[1] = size.y * 0.5

  result.radius = radius

  result.feather = max(1.0, feather)

  result.innerColor = innerColor
  result.outerColor = outerColor

proc imagePattern*(center, size: Vec2, angle: float, image: int, alpha: float): Paint =
  transformRotate(result.transform, angle)

  result.transform[4] = center.x
  result.transform[5] = center.y

  result.extent[0] = size.x
  result.extent[1] = size.y

  result.image = image

  result.innerColor = color(1, 1, 1, alpha)
  result.outerColor = color(1, 1, 1, alpha)