import ./common
export common

import ./vec2
export vec2

type
  Rect2*[T] = tuple
    position, size: Vec2[T]

{.push inline.}

func rect2*[T](position, size: Vec2[T]): Rect2[T] =
  (position: position, size: size)

func round*[T](r: Rect2[T]): auto =
  rect2(r.position.round, r.size.round)

func translate*[A, B](a: Rect2[A], b: Vec2[B]): Rect2[A] =
  rect2(a.position + b, a.size)

func expand*[A, B](a: Rect2[A], b: Vec2[B]): Rect2[A] =
  rect2(a.position - b, a.size + b * 2.0)

func contains*[A, B](a: Rect2[A], b: Vec2[B]): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

{.pop.}