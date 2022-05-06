type
  Color* = tuple[r, g, b, a: float]

func rgb*(r, g, b: float): Color =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: 1.0)

func rgba*(r, g, b, a: float): Color =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: a.float / 255)

type
  SomeColor* = concept s
    s.r
    s.g
    s.b
    s.a

{.push inline.}

func lerp*[T: SomeColor](a: var T, b: T, weight: float) =
  a.r += (weight * (b.r - a.r))
  a.g += (weight * (b.g - a.g))
  a.b += (weight * (b.b - a.b))
  a.a += (weight * (b.a - a.a))

func lerped*[T: SomeColor](a, b: T, weight: float): SomeColor =
  result = a
  result.lerp(b, weight)

func darken*[T: SomeColor](s: var T, amount: float) =
  s.r *= 1.0 - amount
  s.g *= 1.0 - amount
  s.b *= 1.0 - amount

func darkened*[T: SomeColor](s: T, amount: float): SomeColor =
  result = s
  result.darken(amount)

func lighten*[T: SomeColor](s: var T, amount: float) =
  s.r += (1.0 - s.r) * amount
  s.g += (1.0 - s.g) * amount
  s.b += (1.0 - s.b) * amount

func lightened*[T: SomeColor](s: T, amount: float): SomeColor =
  result = s
  result.lighten(amount)

{.pop.}