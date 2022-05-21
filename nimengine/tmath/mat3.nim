import ./common
export common

import ./vec2
export vec2

type
  Mat3* = array[3, array[3, float]]

{.push inline.}

func mat3*(): Mat3 =
  [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
  ]

func position*(m: Mat3): Vec2 =
  vec2(m[2][0], m[2][1])

func `position=`*(a: var Mat3, b: Vec2) =
  a[2][0] = b.x
  a[2][1] = b.y

func scale*(v: Vec2): Mat3 =
  [
    [v.x, 0.0, 0.0],
    [0.0, v.y, 0.0],
    [0.0, 0.0, 1.0],
  ]

func translate*(v: Vec2): Mat3 =
  [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [v.x, v.y, 1.0],
  ]

func rotate*(angle: float): Mat3 =
  let sn = sin(angle)
  let cs = cos(angle)
  [
    [cs, -sn, 0.0],
    [sn, cs, 0.0],
    [0.0, 0.0, 1.0],
  ]

func `*`*(a: Mat3, b: Vec2): Vec2 =
  vec2(a[0][0] * b.x + a[1][0] * b.y + a[2][0],
       a[0][1] * b.x + a[1][1] * b.y + a[2][1])

func `*`*(a, b: Mat3): Mat3 =
  result[0][0] = b[0][0] * a[0][0] + b[0][1] * a[1][0] + b[0][2] * a[2][0]
  result[0][1] = b[0][0] * a[0][1] + b[0][1] * a[1][1] + b[0][2] * a[2][1]
  result[0][2] = b[0][0] * a[0][2] + b[0][1] * a[1][2] + b[0][2] * a[2][2]

  result[1][0] = b[1][0] * a[0][0] + b[1][1] * a[1][0] + b[1][2] * a[2][0]
  result[1][1] = b[1][0] * a[0][1] + b[1][1] * a[1][1] + b[1][2] * a[2][1]
  result[1][2] = b[1][0] * a[0][2] + b[1][1] * a[1][2] + b[1][2] * a[2][2]

  result[2][0] = b[2][0] * a[0][0] + b[2][1] * a[1][0] + b[2][2] * a[2][0]
  result[2][1] = b[2][0] * a[0][1] + b[2][1] * a[1][1] + b[2][2] * a[2][1]
  result[2][2] = b[2][0] * a[0][2] + b[2][1] * a[1][2] + b[2][2] * a[2][2]

{.pop.}