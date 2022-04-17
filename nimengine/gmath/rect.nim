import ./vec2

type
  Rect* = object
    position*: Vec2
    size*: Vec2

{.push inline.}

func rect*(x, y, width, height: float32): Rect =
  Rect(position: vec2(x, y), size: vec2(width, height))

func rect*(position, size: Vec2): Rect =
  Rect(position: position, size: size)

template x*(self: Rect): untyped = self.position.x
template y*(self: Rect): untyped = self.position.y
template width*(self: Rect): untyped = self.size.width
template height*(self: Rect): untyped = self.size.height

func area*(self: Rect): float32 =
  self.width * self.height

func center*(self: Rect): Vec2 =
  self.position + (self.size * 0.5f)

func expand*(self: var Rect, by: float32) =
  self.x -= by
  self.y -= by
  let byX2 = by * 2.0
  self.width += byX2
  self.height += byX2

func expanded*(self: Rect, by: float32): Rect =
  result = self
  result.expand(by)

{.pop.}