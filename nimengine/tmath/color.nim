import ./common
export common

type
  SomeColor = tuple[r, g, b, a: float] or tuple[r, g, b, a: float64] or tuple[r, g, b, a: float32]

template r*(a: SomeColor): untyped = a[0]
template g*(a: SomeColor): untyped = a[1]
template b*(a: SomeColor): untyped = a[2]
template a*(a: SomeColor): untyped = a[3]

{.push inline.}

func lerp*[A, B: SomeColor](a: A, b: B, weight: SomeNumber): auto =
  var res = a
  let weight = weight.asFloat
  res.r += (weight * (b.r - res.r))
  res.g += (weight * (b.g - res.g))
  res.b += (weight * (b.b - res.b))
  res.a += (weight * (b.a - res.a))
  res

func darken*[A: SomeColor](a: A, amount: SomeNumber): auto =
  var res = a
  let amount = amount.asFloat
  res.r *= 1.0 - amount
  res.g *= 1.0 - amount
  res.b *= 1.0 - amount
  res

func lighten*[A: SomeColor](a: A, amount: SomeNumber): auto =
  var res = a
  let amount = amount.asFloat
  res.r += (1.0 - res.r) * amount
  res.g += (1.0 - res.g) * amount
  res.b += (1.0 - res.b) * amount
  res

{.pop.}