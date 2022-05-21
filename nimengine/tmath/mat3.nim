import ./common
export common

import ./vec2
export vec2

type
  SomeMat3* = concept v
    v[0][0] is SomeFloat
    v[0][1] is SomeFloat
    v[0][2] is SomeFloat
    v[1][0] is SomeFloat
    v[1][1] is SomeFloat
    v[1][2] is SomeFloat
    v[2][0] is SomeFloat
    v[2][1] is SomeFloat
    v[2][2] is SomeFloat

template position*(tm: SomeMat3): untyped =
  let m = tm
  (x: m[2][0], y: m[2][1])

template `position=`*(tm: var SomeMat3, tv: SomeVec2) =
  let v = tv
  tm[2][0] = v.x
  tm[2][1] = v.y

template mat3Identity*(): untyped =
  [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
  ]

template scale*[V: SomeVec2](tv: V): untyped =
  let v = tv
  [
    [v.x, 0.0, 0.0],
    [0.0, v.y, 0.0],
    [0.0, 0.0, 1.0],
  ]

template translate*[V: SomeVec2](tv: V): untyped =
  let v = tv
  [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [v.x, v.y, 1.0],
  ]

template rotate*[A: SomeFloat](tangle: A): untyped =
  let angle = tangle
  let sn = sin(angle)
  let cs = cos(angle)
  [
    [cs, -sn, 0.0],
    [sn, cs, 0.0],
    [0.0, 0.0, 1.0],
  ]

template `*`*[A: SomeMat3, B: SomeVec2](ta: A, tb: B): auto =
  let a = ta
  let b = tb
  (x: a[0][0] * b.x + a[1][0] * b.y + a[2][0],
   y: a[0][1] * b.x + a[1][1] * b.y + a[2][1])