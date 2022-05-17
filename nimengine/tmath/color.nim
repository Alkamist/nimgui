import ./common
export common

type
  SomeColor = tuple[r, g, b, a: float] or tuple[r, g, b, a: float64] or tuple[r, g, b, a: float32]

template lerp*[A, B: SomeColor](a: A, b: B, weight: SomeNumber): auto =
  var aT = a
  let bT = b
  let weightT = weight.asFloat
  aT[0] += (weightT * (bT[0] - aT[0]))
  aT[1] += (weightT * (bT[1] - aT[1]))
  aT[2] += (weightT * (bT[2] - aT[2]))
  aT[3] += (weightT * (bT[3] - aT[3]))
  aT

template darken*[A: SomeColor](a: A, amount: SomeNumber): auto =
  var aT = a
  let amountT = amount.asFloat
  aT[0] *= 1.0 - amountT
  aT[1] *= 1.0 - amountT
  aT[2] *= 1.0 - amountT
  aT

template lighten*[A: SomeColor](a: A, amount: SomeNumber): auto =
  var aT = a
  let amountT = amount.asFloat
  aT[0] += (1.0 - aT[0]) * amountT
  aT[1] += (1.0 - aT[1]) * amountT
  aT[2] += (1.0 - aT[2]) * amountT
  aT