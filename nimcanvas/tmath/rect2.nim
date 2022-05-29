import ./common
export common

import ./vec2
export vec2

type
  Rect2* = object
    position*, size*: Vec2

{.push inline.}

# func rect2*(position, size: Vec2): Rect2 =
#   (position: position, size: size)

func rect2*(position, size = vec2()): Rect2 =
  Rect2(position: position, size: size)

func rect2*(x, y, width, height = 0.0): Rect2 =
  rect2(vec2(x, y), vec2(width, height))

template x*(r: Rect2): untyped = r.position.x
template `x=`*(r: var Rect2, value: float): untyped = r.position.x = value
template y*(r: Rect2): untyped = r.position.y
template `y=`*(r: var Rect2, value: float): untyped = r.position.y = value
template width*(r: Rect2): untyped = r.size.x
template `width=`*(r: var Rect2, value: float): untyped = r.size.x = value
template height*(r: Rect2): untyped = r.size.y
template `height=`*(r: var Rect2, value: float): untyped = r.size.y = value

func round*(r: Rect2): Rect2 =
  rect2(r.position.round, r.size.round)

func translate*(a: Rect2, b: Vec2): Rect2 =
  rect2(a.position + b, a.size)

func expand*(a: Rect2, b: Vec2): Rect2 =
  rect2(a.position - b, a.size + b * 2.0)

func contains*(a: Rect2, b: Vec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

{.pop.}