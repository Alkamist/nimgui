import ./common
export common

type
  ColorTuple[T] = tuple[r, g, b, a: T]

  SomeColor* = concept c
    c.r is SomeFloat
    c.g is SomeFloat
    c.b is SomeFloat
    c.a is SomeFloat

template r*(tc: ColorTuple): untyped = tc[0]
template g*(tc: ColorTuple): untyped = tc[1]
template b*(tc: ColorTuple): untyped = tc[2]
template a*(tc: ColorTuple): untyped = tc[3]

template lerp*[A, B: SomeColor, W: SomeNumber](ta: A, tb: B, tweight: W): untyped =
  var res = ta
  let b = tb
  let weight = tweight.asFloat
  res.r += (weight * (b.r - res.r))
  res.g += (weight * (b.g - res.g))
  res.b += (weight * (b.b - res.b))
  res.a += (weight * (b.a - res.a))
  res

template darken*[C: SomeColor, W: SomeNumber](tc: C, tamount: W): untyped =
  var res = tc
  let amount = tamount.asFloat
  res.r *= 1.0 - amount
  res.g *= 1.0 - amount
  res.b *= 1.0 - amount
  res

template lighten*[C: SomeColor, W: SomeNumber](tc: C, tamount: W): untyped =
  var res = tc
  let amount = tamount.asFloat
  res.r += (1.0 - res.r) * amount
  res.g += (1.0 - res.g) * amount
  res.b += (1.0 - res.b) * amount
  res