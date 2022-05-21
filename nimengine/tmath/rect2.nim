import ./common
export common

import ./vec2
export vec2

type
  Rect2Tuple[T] = tuple[position, size: T]

  SomeRect2* = concept r
    r.position is SomeVec2
    r.size is SomeVec2

template position*[R: Rect2Tuple](tr: R): untyped = tr[0]
template size*[R: Rect2Tuple](tr: R): untyped = tr[1]

template round*(tr: SomeRect2): untyped =
  let r = tr
  (position: r.position.round, size: r.size.round)

template translate*(tr: SomeRect2, tv: SomeVec2): untyped =
  var res = tr
  res.position += tv
  res

template expand*(tr: SomeRect2, tv: SomeVec2): untyped =
  let v = tv
  var res = tr
  res.position -= v
  res.size += v * 2.0
  res

template contains*(tr: SomeRect2, tv: SomeVec2): bool =
  let r = tr
  let v = tv
  v.x >= r.position.x and v.x <= r.position.x + r.size.x and
  v.y >= r.position.y and v.y <= r.position.y + r.size.y