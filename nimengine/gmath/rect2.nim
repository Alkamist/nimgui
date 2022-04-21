import ./vec2

type
  Rect2* = object
    position*: Vec2
    size*: Vec2

{.push inline.}

func rect2*(x, y, width, height: float32): Rect2 =
  Rect2(position: vec2(x, y), size: vec2(width, height))

func rect2*(position, size: Vec2): Rect2 =
  Rect2(position: position, size: size)

template x*(self: Rect2): untyped = self.position.x
template y*(self: Rect2): untyped = self.position.y
template width*(self: Rect2): untyped = self.size.width
template height*(self: Rect2): untyped = self.size.height

func bottomLeft*(self: Rect2): Vec2 =
  self.position

func bottomRight*(self: Rect2): Vec2 =
  vec2(self.x + self.width, self.y)

func topLeft*(self: Rect2): Vec2 =
  vec2(self.x, self.y + self.height)

func topRight*(self: Rect2): Vec2 =
  self.position + self.size

func area*(self: Rect2): float32 =
  self.width * self.height

func center*(self: Rect2): Vec2 =
  self.position + (self.size * 0.5f)

func expand*(self: var Rect2, by: float32) =
  self.x -= by
  self.y -= by
  let byX2 = by * 2.0
  self.width += byX2
  self.height += byX2

func expanded*(self: Rect2, by: float32): Rect2 =
  result = self
  result.expand(by)

func expandTo*(self: var Rect2, v: Vec2) =
  assert(self.size.x >= 0 and self.size.y >= 0)

  var start = self.position
  var finish = self.position + self.size

  if v.x < start.x:
    start.x = v.x

  if v.y < start.y:
    start.y = v.y

  if v.x > finish.x:
    finish.x = v.x

  if v.y > finish.y:
    finish.y = v.y

  self.position = start
  self.size = finish - start

{.pop.}