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

func rect2*(position, size: Vec2): Rect2 =
  Rect2(position: position, size: size)

func rect2*(x, y, width, height: float): Rect2 =
  rect2(vec2(x, y), vec2(width, height))

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