import ./common
export common

import ./vec2
export vec2

type
  SomeMat3*[T: SomeFloat] = array[3, array[3, T]]

func scale*[T: SomeFloat](v: SomeVec2[T]): SomeMat3[T] =
  [
    [v.x, 0.0, 0.0],
    [0.0, v.y, 0.0],
    [0.0, 0.0, 1.0],
  ]

func translate*[T: SomeFloat](v: SomeVec2[T]): SomeMat3[T] =
  [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [v.x, v.y, 1.0],
  ]

func rotate*[T: SomeFloat](angle: T): SomeMat3[T] =
  let sn = sin(angle)
  let cs = cos(angle)
  [
    [cs, -sn, 0.0],
    [sn, cs, 0.0],
    [0.0, 0.0, 1.0],
  ]