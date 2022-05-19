import ./common
export common

type
  SomeColor*[T: SomeFloat] = tuple[r, g, b, a: T]

template r*(tc: SomeColor): untyped = tc[0]
template g*(tc: SomeColor): untyped = tc[1]
template b*(tc: SomeColor): untyped = tc[2]
template a*(tc: SomeColor): untyped = tc[3]

template lerp*[A, B: SomeColor](ta: A, tb: B, tweight: SomeNumber): auto =
  var res = ta
  let b = tb
  let weight = tweight.asFloat
  res.r += (weight * (b.r - res.r))
  res.g += (weight * (b.g - res.g))
  res.b += (weight * (b.b - res.b))
  res.a += (weight * (b.a - res.a))
  res

template darken*[A: SomeColor](ta: A, tamount: SomeNumber): auto =
  var res = ta
  let amount = tamount.asFloat
  res.r *= 1.0 - amount
  res.g *= 1.0 - amount
  res.b *= 1.0 - amount
  res

template lighten*[A: SomeColor](ta: A, tamount: SomeNumber): auto =
  var res = ta
  let amount = tamount.asFloat
  res.r += (1.0 - res.r) * amount
  res.g += (1.0 - res.g) * amount
  res.b += (1.0 - res.b) * amount
  res