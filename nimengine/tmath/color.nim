import ./common
export common

type
  Color*[T] = tuple
    r, g, b, a: T

{.push inline.}

func color*[T](r, g, b, a: T): Color[T] =
  (r: r, g: g, b: b, a: a)

func rgba*(r, g, b, a: uint8): Color[float] =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: a.float / 255)

func rgb*(r, g, b, a: uint8): Color[float] =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: 1.0)

func lerp*[A, B](a: Color[A], b: Color[B], weight: SomeNumber): Color[A] =
  let weight = weight.asFloat
  result = a
  result.r += (weight * (b.r - result.r))
  result.g += (weight * (b.g - result.g))
  result.b += (weight * (b.b - result.b))
  result.a += (weight * (b.a - result.a))

func darken*[T](c: Color[T], amount: SomeNumber): Color[T] =
  let amount = amount.asFloat
  result = c
  result.r *= 1.0 - amount
  result.g *= 1.0 - amount
  result.b *= 1.0 - amount

func lighten*[T](c: Color[T], amount: SomeNumber): Color[T] =
  let amount = amount.asFloat
  result = c
  result.r += (1.0 - result.r) * amount
  result.g += (1.0 - result.g) * amount
  result.b += (1.0 - result.b) * amount

{.pop.}