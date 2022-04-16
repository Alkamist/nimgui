type
  Color* = object
    components*: array[4, float32]

{.push inline.}

template r*(a: Color): untyped = a.components[0]
template g*(a: Color): untyped = a.components[1]
template b*(a: Color): untyped = a.components[2]
template a*(a: Color): untyped = a.components[3]

template `r=`*(a: Color, v: float32): untyped = a.components[0] = v
template `g=`*(a: Color, v: float32): untyped = a.components[1] = v
template `b=`*(a: Color, v: float32): untyped = a.components[2] = v
template `a=`*(a: Color, v: float32): untyped = a.components[3] = v

func rgba*(r, g, b, a: float32): Color =
  Color(components: [r, g, b, a])

func lerp*(self: var Color, to: Color, weight: float32) =
  self.r += (weight * (to.r - self.r))
  self.g += (weight * (to.g - self.g))
  self.b += (weight * (to.b - self.b))
  self.a += (weight * (to.a - self.a))

func lerped*(self, to: Color, weight: float32): Color =
  result = self
  result.lerp(to, weight)

func darken*(self: var Color, amount: float32) =
  self.r *= 1.0f - amount
  self.g *= 1.0f - amount
  self.b *= 1.0f - amount

func darkened*(self: Color, amount: float32): Color =
  result = self
  result.darken(amount)

func lighten*(self: var Color, amount: float32) =
  self.r += (1.0f - self.r) * amount
  self.g += (1.0f - self.g) * amount
  self.b += (1.0f - self.b) * amount

func lightened*(self: Color, amount: float32): Color =
  result = self
  result.lighten(amount)

{.pop.}