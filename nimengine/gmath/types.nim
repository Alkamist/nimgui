type
  Vec2* = tuple[x, y: float]
  Rect2* = tuple[x, y, width, height: float]
  Color* = tuple[r, g, b, a: float]

func vec2*(x, y: float): Vec2 {.inline.} =
  (x: x, y: y)

func rect2*(x, y, width, height: float): Rect2 =
  (x: x, y: y, width: width, height: height)

func rgb*(r, g, b: float): Color =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: 1.0)

func rgba*(r, g, b, a: float): Color =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: a.float / 255)