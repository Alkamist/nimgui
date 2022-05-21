import ./common
export common

import ./vec2
export vec2

type
  Mat3*[T]= array[3, array[3, T]]

template position*[T](tm: Mat3[T]): untyped =
  let m = tm
  (x: m[2][0], y: m[2][1])

template `position=`*[A, B](ta: var Mat3[A], tb: Vec2[B]) =
  let b = tb
  ta[2][0] = b.x
  ta[2][1] = b.y

template mat3Identity*[T](): untyped =
  [
    [1.T, 0.T, 0.T],
    [0.T, 1.T, 0.T],
    [0.T, 0.T, 1.T],
  ]

proc scale*[T](tv: Vec2[T]): Mat3[T] =
  let v = tv
  [
    [v.x, 0.T, 0.T],
    [0.T, v.y, 0.T],
    [0.T, 0.T, 1.T],
  ]

template translate*[T](tv: Vec2[T]): untyped =
  let v = tv
  [
    [1.T, 0.T, 0.T],
    [0.T, 1.T, 0.T],
    [v.x, v.y, 1.T],
  ]

template rotate*(tangle: SomeFloat): untyped =
  let angle = tangle
  let sn = sin(angle)
  let cs = cos(angle)
  [
    [cs, -sn, 0.T],
    [sn, cs, 0.T],
    [0.T, 0.T, 1.T],
  ]

template `*`*[A, B](ta: Mat3[A], tb: Vec2[B]): auto =
  let a = ta
  let b = tb
  (x: a[0][0] * b.x + a[1][0] * b.y + a[2][0],
   y: a[0][1] * b.x + a[1][1] * b.y + a[2][1])


let a = (3.0, 2.0)

echo scale (3.0, 3.0) * a