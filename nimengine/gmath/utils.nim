import std/math
import std/strutils

func prettyFloat*(f: float32): string =
  result = f.formatFloat(ffDecimal, 4)
  if result[0] != '-':
    result.insert(" ", 0)

func snap*(value, step: float32): float32 =
  if step != 0.0:
    (value / step + 0.5).floor * step
  else:
    value

func `~=`*(a, b: float32): bool =
  const epsilon = 0.000001
  (a - b).abs <= epsilon