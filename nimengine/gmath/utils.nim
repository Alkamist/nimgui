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

{.pop.}