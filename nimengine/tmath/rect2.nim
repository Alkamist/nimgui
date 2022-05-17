import ./common
export common

import ./vec2
export vec2

type
  SomeRect2*[T: SomeVec2] = tuple[position, size: T]

template position*(a: SomeRect2): untyped = a[0]
template size*(a: SomeRect2): untyped = a[1]

{.push inline.}

func translate*(a: SomeRect2, b: SomeVec2): auto =
  var res = a
  res[0] += b
  res

func contains*(a: SomeRect2, b: SomeVec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

{.pop.}