import vec2

type
  Rect* = tuple
    position: Vec2
    size: Vec2

proc expand*(rect: Rect, amount: Vec2): Rect =
  result.position = vec2(
    min(rect.position.x + rect.size.x * 0.5, rect.position.x - amount.x),
    min(rect.position.y + rect.size.y * 0.5, rect.position.y - amount.y),
  )
  result.size = vec2(
    max(0, rect.size.x + amount.x * 2),
    max(0, rect.size.y + amount.y * 2),
  )

proc intersect*(a, b: Rect): Rect =
  let x1 = max(a.position.x, b.position.x)
  let y1 = max(a.position.y, b.position.y)
  var x2 = min(a.position.x + a.size.x, b.position.x + b.size.x)
  var y2 = min(a.position.y + a.size.y, b.position.y + b.size.y)
  if x2 < x1: x2 = x1
  if y2 < y1: y2 = y1
  (position: vec2(x1, y1), size: vec2(x2 - x1, y2 - y1))

proc contains*(a: Rect, b: Vec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y