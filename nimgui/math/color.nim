import ./common
export common

type
  Color* = object
    r*, g*, b*, a*: float

{.push inline.}

func color*(r, g, b, a = 0.0): Color =
  Color(r: r, g: g, b: b, a: a)

func rgba*(r, g, b, a: uint8 = 0): Color =
  color(r.float / 255, g.float / 255, b.float / 255, a.float / 255)

func rgb*(r, g, b: uint8 = 0): Color =
  color(r.float / 255, g.float / 255, b.float / 255, 1.0)

func lerp*(a, b: Color, weight: float): Color =
  result = a
  result.r += (weight * (b.r - result.r))
  result.g += (weight * (b.g - result.g))
  result.b += (weight * (b.b - result.b))
  result.a += (weight * (b.a - result.a))

func darken*(c: Color, amount: float): Color =
  result = c
  result.r *= 1.0 - amount
  result.g *= 1.0 - amount
  result.b *= 1.0 - amount

func lighten*(c: Color, amount: float): Color =
  result = c
  result.r += (1.0 - result.r) * amount
  result.g += (1.0 - result.g) * amount
  result.b += (1.0 - result.b) * amount

{.pop.}