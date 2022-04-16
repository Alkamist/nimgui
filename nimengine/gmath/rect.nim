import ./vec2

type
  Rect* = object
    position*: Vec2
    size*: Vec2

{.push inline.}

template x*(a: Rect): untyped = a.position.x
template y*(a: Rect): untyped = a.position.y
template width*(a: Rect): untyped = a.size.width
template height*(a: Rect): untyped = a.size.height

func area*(a: Rect): float32 =
  a.width * a.height

func center*(a: Rect): Vec2 =
  a.position + (a.size * 0.5f)

func rect*(x, y, width, height: float32): Rect =
  Rect(position: vec2(x, y), size: vec2(width, height))

func rect*(position, size: Vec2): Rect =
  Rect(position: position, size: size)

{.pop.}