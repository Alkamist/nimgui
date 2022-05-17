import ./common
export common

import ./vec2
export vec2

type
  SomeRect2*[T: SomeVec2] = tuple[position, size: T]

template translate*(a: SomeRect2, b: SomeVec2): auto =
  var aT = a
  let bT = b
  aT[0] += bT
  aT

template contains*(a: SomeRect2, b: SomeVec2): bool =
  let aT = a
  let bT = b
  let rX = aT[0][0]
  let rY = aT[0][1]
  let rW = aT[1][0]
  let rH = aT[1][1]
  let x = bT[0]
  let y = bT[1]
  x >= rX and x <= rX + rW and
  y >= rY and y <= ry + rH