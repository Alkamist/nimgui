import ../tmath

const circleAutoSegmentMin = 4
const circleAutoSegmentMax = 512

template roundUpToEven(value: int): int =
  ((value + 1) div 2) * 2

template circleAutoSegmentCalc(radius, maxError: float): int =
  let segments = (PI / (1.0 - maxError.min(radius) / radius).arccos).ceil.int.roundUpToEven
  segments.clamp(circleAutoSegmentMin, circleAutoSegmentMax)

type
  PolyLine* = object
    points*: seq[Vec2]
    viewScale*: float
    curveTesselationTolerance*: float
    circleTessellationMaxError*: float

func polyLine*(viewScale: float): PolyLine =
  result = PolyLine(
    viewScale: viewScale,
    curveTesselationTolerance: 1.25,
    circleTessellationMaxError: 0.3,
  )

template `[]`*(poly: var PolyLine, i: untyped): untyped =
  poly.points[i]

template `[]=`*(poly: var PolyLine, i, v: untyped): untyped =
  poly.points[i] = v

template add*(poly: var PolyLine, position: Vec2): untyped =
  poly.points.add position

template len*(poly: PolyLine): int =
  poly.points.len

template reserve*(poly: var PolyLine, amount: int): untyped =
  poly.points.setLen(poly.points.len + amount)

template unreserve*(poly: var PolyLine, amount: int): untyped =
  poly.points.setLen(poly.points.len - amount)

template firstPoint*(poly: PolyLine): untyped =
  poly.points[0]

template lastPoint*(poly: PolyLine): untyped =
  poly.points[poly.points.len - 1]

template isClosed*(poly: PolyLine): bool =
  poly.points.len > 3 and
  poly.firstPoint ~= poly.lastPoint

func bezierCubic(p1, p2, p3, p4: Vec2, t: float): Vec2 =
  let u = 1.0 - t
  let w1 = u * u * u
  let w2 = 3.0 * u * u * t
  let w3 = 3.0 * u * t * t
  let w4 = t * t * t
  vec2(w1 * p1.x + w2 * p2.x + w3 * p3.x + w4 * p4.x,
       w1 * p1.y + w2 * p2.y + w3 * p3.y + w4 * p4.y)

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

func bezierCubicCurveTo*(poly: var PolyLine, p2, p3, p4: Vec2, segments = 0) =
  if poly.len == 0:
    poly.add vec2()

  let p1 = poly.lastPoint
  if segments == 0:
    poly.points.bezierCubicCurveToCasteljau(
      p1.x, p1.y,
      p2.x, p2.y,
      p3.x, p3.y,
      p4.x, p4.y,
      poly.curveTesselationTolerance / poly.viewScale,
      0,
    )
  else:
    let step = 1.0 / segments.float
    for i in 1 .. segments:
      poly.add bezierCubic(p1, p2, p3, p4, step * i.float)

func arcToN(poly: var PolyLine, center: Vec2, radius, startAngle, endAngle: float, segments: int) =
  let firstArcPoint = center + vec2(1, 0).rotate(startAngle) * radius
  let skipFirstArcPoint = poly.len > 0 and poly.lastPoint ~= firstArcPoint
  let arcStartIndex = poly.len
  let arcPointCount = if skipFirstArcPoint: segments else: segments + 1

  poly.reserve(arcPointCount)

  for i in 0 ..< arcPointCount:
    let arcIndex = if skipFirstArcPoint: i + 1 else: i
    let angle = startAngle + (arcIndex.float / segments.float) * (endAngle - startAngle)

    let point = center + vec2(1, 0).rotate(angle) * radius

    poly[arcStartIndex + i] = point

func arcTo*(poly: var PolyLine, center: Vec2, radius, startAngle, endAngle: float, segments = 0) =
  if radius < 0.5 * poly.viewScale:
    poly.add center
    return

  if segments > 0:
    poly.arcToN(center, radius, startAngle, endAngle, segments)

  else:
    let arcLength = (endAngle - startAngle).abs
    let circleSegmentCount = circleAutoSegmentCalc(radius, poly.circleTessellationMaxError / poly.viewScale)
    let arcSegmentMin = (2.0 * PI / arcLength).int
    let arcSegmentCountUnClamped = (circleSegmentCount.float * arcLength / (PI * 2.0)).ceil.int
    let arcSegmentCount = arcSegmentCountUnClamped.max(arcSegmentMin)
    poly.arcToN(center, radius, startAngle, endAngle, arcSegmentCount)

# func rect(rect: Rect2,
#           poly: var PolyLine,
#           rounding = (topLeft: 0.0, topRight: 0.0, bottomRight: 0.0, bottomLeft: 0.0)) =


#   let a = rect.position
#   let b = rect.position + rect.size

#   if rounding.topLeft < 0.5:
#     poly.add a
#   else:
#     poly.

#   if rounding < 0.5:
#     poly.add a
#     poly.add vec2(b.x, a.y)
#     poly.add b
#     poly.add vec2(a.x, b.y)
#   else:
#     PathArcToFast(ImVec2(a.x + rounding_tl, a.y + rounding_tl), rounding_tl, 6, 9);
#     PathArcToFast(ImVec2(b.x - rounding_tr, a.y + rounding_tr), rounding_tr, 9, 12);
#     PathArcToFast(ImVec2(b.x - rounding_br, b.y - rounding_br), rounding_br, 0, 3);
#     PathArcToFast(ImVec2(a.x + rounding_bl, b.y - rounding_bl), rounding_bl, 3, 6);