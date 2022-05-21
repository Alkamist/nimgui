import ./common
export common

type
  Color*[T] = tuple
    r, g, b, a: T

template r*[T](tc: Color[T]): untyped = tc[0]
template g*[T](tc: Color[T]): untyped = tc[1]
template b*[T](tc: Color[T]): untyped = tc[2]
template a*[T](tc: Color[T]): untyped = tc[3]

template lerp*[A, B](ta: Color[A], tb: Color[B], tweight: SomeNumber): untyped =
  var res = ta
  let b = tb
  let weight = tweight.asFloat
  res.r += (weight * (b.r - res.r))
  res.g += (weight * (b.g - res.g))
  res.b += (weight * (b.b - res.b))
  res.a += (weight * (b.a - res.a))
  res

template darken*[T](tc: Color[T], tamount: SomeNumber): untyped =
  var res = tc
  let amount = tamount.asFloat
  res.r *= 1.0 - amount
  res.g *= 1.0 - amount
  res.b *= 1.0 - amount
  res

template lighten*[T](tc: Color[T], tamount: SomeNumber): untyped =
  var res = tc
  let amount = tamount.asFloat
  res.r += (1.0 - res.r) * amount
  res.g += (1.0 - res.g) * amount
  res.b += (1.0 - res.b) * amount
  res