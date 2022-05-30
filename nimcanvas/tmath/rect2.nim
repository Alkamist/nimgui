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

template x*(r: Rect2): float = r.position.x
template `x=`*(r: var Rect2, value: float) = r.position.x = value
template y*(r: Rect2): float = r.position.y
template `y=`*(r: var Rect2, value: float) = r.position.y = value
template width*(r: Rect2): float = r.size.x
template `width=`*(r: var Rect2, value: float) = r.size.x = value
template height*(r: Rect2): float = r.size.y
template `height=`*(r: var Rect2, value: float) = r.size.y = value

func round*(r: Rect2): Rect2 =
  rect2(r.position.round, r.size.round)

func translate*(a: Rect2, b: Vec2): Rect2 =
  rect2(a.position + b, a.size)

func expand*(a: Rect2, b: Vec2): Rect2 =
  rect2(a.position - b, a.size + b * 2.0)

func expand*(a: Rect2, b: float): Rect2 =
  rect2(a.position - b, a.size + b * 2.0)

func contains*(a: Rect2, b: Vec2): bool =
  b.x >= a.x and b.x <= a.x + a.width and
  b.y >= a.y and b.y <= a.y + a.height

func contains*(a, b: Rect2): bool =
  b.x + b.width >= a.x and
  b.x <= a.x + a.width and
  b.y + b.height >= a.y and
  b.y <= a.y + a.height

{.pop.}