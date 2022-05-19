import ./common
export common

import ./vec2
export vec2

type
  SomeRect2*[T: SomeVec2] = tuple[position, size: T]

template position*(tr: SomeRect2): untyped = tr[0]
template size*(tr: SomeRect2): untyped = tr[1]

template round*(tr: SomeRect2): auto =
  let r = tr
  (position: r.position.round, size: r.size.round)

template translate*(tr: SomeRect2, tv: SomeVec2): auto =
  var res = tr
  res.position += tv
  res

template expand*(tr: SomeRect2, tv: SomeVec2): auto =
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