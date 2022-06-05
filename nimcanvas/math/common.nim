import std/math
export math

{.push inline.}

func `~=`*(a, b: float): bool =
  (a - b).abs <= 0.000001

{.pop.}