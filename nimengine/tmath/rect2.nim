import ./common
export common

import ./vec2
export vec2

type
  Rect2*[T] = tuple
    position, size: Vec2[T]

template position*[T](tr: Rect2[T]): untyped = tr[0]
template size*[T](tr: Rect2[T]): untyped = tr[1]

template round*[T](tr: Rect2[T]): untyped =
  let r = tr
  (position: r.position.round, size: r.size.round)

template translate*[A, B](tr: Rect2[A], tv: Vec2[B]): untyped =
  var res = tr
  res.position += tv
  res

template expand*[A, B](tr: Rect2[A], tv: Vec2[B]): untyped =
  let v = tv
  var res = tr
  res.position -= v
  res.size += v * 2.0
  res

template contains*[A, B](tr: Rect2[A], tv: Vec2[B]): bool =
  let r = tr
  let v = tv
  v.x >= r.position.x and v.x <= r.position.x + r.size.x and
  v.y >= r.position.y and v.y <= r.position.y + r.size.y