import ../tmath

type
  PolyLine* = object
    points*: seq[Vec2]
    tesselation*: float
    isClosed*: bool

{.push inline.}

func polyLine*(tesselation: float): PolyLine =
  PolyLine(tesselation: tesselation)

func close*(poly: var PolyLine) =
  poly.isClosed = true

func add*(poly: var PolyLine, position: Vec2) =
  poly.points.add position

func bezierCubicCurveToCasteljau(points: var seq[Vec2], x1, y1, x2, y2, x3, y3, x4, y4, tolerance: float, level: int) =
  let dx = x4 - x1
  let dy = y4 - y1

  var d2 = (x2 - x4) * dy - (y2 - y4) * dx
  var d3 = (x3 - x4) * dy - (y3 - y4) * dx
  d2 = if d2 >= 0: d2 else: -d2
  d3 = if d3 >= 0: d3 else: -d3

  if (d2 + d3) * (d2 + d3) < tolerance * (dx * dx + dy * dy):
    points.add vec2(x4, y4)

  elif level < 10:
    let x12 = (x1 + x2) * 0.5
    let y12 = (y1 + y2) * 0.5
    let x23 = (x2 + x3) * 0.5
    let y23 = (y2 + y3) * 0.5
    let x34 = (x3 + x4) * 0.5
    let y34 = (y3 + y4) * 0.5
    let x123 = (x12 + x23) * 0.5
    let y123 = (y12 + y23) * 0.5
    let x234 = (x23 + x34) * 0.5
    let y234 = (y23 + y34) * 0.5
    let x1234 = (x123 + x234) * 0.5
    let y1234 = (y123 + y234) * 0.5
    points.bezierCubicCurveToCasteljau(x1, y1, x12, y12, x123, y123, x1234, y1234, tolerance, level + 1)
    points.bezierCubicCurveToCasteljau(x1234, y1234, x234, y234, x34, y34, x4, y4, tolerance, level + 1)

func bezierCubic(p1, p2, p3, p4: Vec2, t: float): Vec2 =
  let u = 1.0 - t
  let w1 = u * u * u
  let w2 = 3.0 * u * u * t
  let w3 = 3.0 * u * t * t
  let w4 = t * t * t
  vec2(w1 * p1.x + w2 * p2.x + w3 * p3.x + w4 * p4.x,
       w1 * p1.y + w2 * p2.y + w3 * p3.y + w4 * p4.y)

func bezierCubicCurveTo*(poly: var PolyLine, p2, p3, p4: Vec2, segments = 0) =
  let p1 = poly.points[poly.points.len - 1]
  if segments == 0:
    poly.points.bezierCubicCurveToCasteljau(
      p1.x, p1.y,
      p2.x, p2.y,
      p3.x, p3.y,
      p4.x, p4.y,
      poly.tesselation,
      0,
    )
  else:
    let step = 1.0 / segments.float
    for i in 1 .. segments:
      poly.points.add bezierCubic(p1, p2, p3, p4, step * i.float)

{.pop.}