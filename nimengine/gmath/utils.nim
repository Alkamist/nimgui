import std/math
export math

{.push inline.}

func snap*[V, S: SomeNumber](value: V, step: S): V =
  if step != 0.0:
    (value / step + 0.5).floor * step
  else:
    value

func `~=`*[A, B: SomeNumber](a: A, b: B): bool =
  const epsilon = 0.000001
  (a - b).abs <= epsilon

func cyclicalIndex*[T](s: openArray[T], i: int): int =
  if i >= s.len:
    i mod s.len
  elif i < 0:
    (((-i - 1) div s.len) + 1) * s.len + i
  else:
    i

{.pop.}