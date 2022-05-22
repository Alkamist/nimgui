import ../tmath

const defaultCurveTesselationTolerance = 1.25
const defaultCircleTessellationMaxError = 0.3
const arcFastTableSize = 48
const arcFastSampleMax = arcFastTableSize
const circleAutoSegmentMin = 4
const circleAutoSegmentMax = 512

template roundUpToEven(value: int): int =
  (((value + 1) / 2) * 2).int

template circleAutoSegmentCalc(radius, maxError: float): int =
  let segments = (PI / (1.0 - maxError.min(radius) / radius).arccos).ceil.int.roundUpToEven
  segments.clamp(circleAutoSegmentMin, circleAutoSegmentMax)

template circleAutoSegmentCalcR(n: int, maxError: float): float =
  maxError / (1.0 - (PI / n.float.max(PI)).cos)

type
  PolyLine* = object
    points*: seq[Vec2]
    isClosed*: bool
    curveTesselationTolerance*: float
    circleTessellationMaxError: float
    circleSegmentCounts: array[64, uint8]
    arcFastVtx: array[arcFastTableSize, Vec2]
    arcFastRadiusCutoff: float

func `circleTessellationMaxError=`*(poly: var PolyLine, maxError: float) =
  if poly.circleTessellationMaxError == maxError:
    return

  assert(maxError > 0.0)

  poly.circleTessellationMaxError = maxError

  for i in 0 ..< poly.circleSegmentCounts.len:
    let radius = i.float
    poly.circleSegmentCounts[i] =
      if i > 0:
        circleAutoSegmentCalc(radius, poly.circleTessellationMaxError).uint8
      else:
        arcFastSampleMax.uint8

  poly.arcFastRadiusCutoff = circleAutoSegmentCalcR(arcFastSampleMax, poly.circleTessellationMaxError)

func polyLine*(tesselationScale: float): PolyLine =
  result = PolyLine(curveTesselationTolerance: defaultCurveTesselationTolerance / tesselationScale)
  result.`circleTessellationMaxError=` defaultCircleTessellationMaxError

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
      poly.curveTesselationTolerance,
      0,
    )
  else:
    let step = 1.0 / segments.float
    for i in 1 .. segments:
      poly.points.add bezierCubic(p1, p2, p3, p4, step * i.float)

func circleAutoSegmentCount(poly: PolyLine, radius: float): int =
  let radiusIndex = (radius + 0.999999).int
  if radiusIndex < poly.circleSegmentCounts.len:
    poly.circleSegmentCounts[radiusIndex].int
  else:
    circleAutoSegmentCalc(radius, poly.circleTessellationMaxError)

func arcToFastEx*(poly: var PolyLine, center: Vec2, radius: float, minSample, maxSample, step: int) =
  if radius < 0.5:
    poly.add center
    return

  # Calculate arc auto segment step size.
  var step = step
  if step <= 0:
    step = arcFastSampleMax div poly.circleAutoSegmentCount(radius)

  # Make sure we never do steps larger than one quarter of the circle.
  step = step.clamp(1, arcFastTableSize div 4)

  let sampleRange = (maxSample - minSample).abs
  let nextStep = step

  var samples = sampleRange + 1
  var extraMaxSample = false
  if step > 1:
    samples = sampleRange div step + 1
    let overstep = sampleRange mod step

    if overstep > 0:
      extraMaxSample = true
      inc samples

      # When we have overstep to avoid awkwardly looking one long line and one tiny one at the end,
      # distribute first step range evenly between them by reducing first step size.
      if sampleRange > 0:
        step -= (step - overstep) div 2

  var writeIndex = poly.points.len
  poly.points.setLen(poly.points.len + samples)

  var sampleIndex = minSample
  if sampleIndex < 0 or sampleIndex >= arcFastSampleMax:
    sampleIndex = sampleIndex mod arcFastSampleMax
    if sampleIndex < 0:
      sampleIndex += arcFastSampleMax

  if maxSample >= minSample:
    var a = minSample
    while a <= maxSample:
      # Step is clamped to arcFastSampleMax, so we have guaranteed that it will not wrap over range twice or more.
      if sampleIndex >= arcFastSampleMax:
        sampleIndex -= arcFastSampleMax

      let s = poly.arcFastVtx[sampleIndex]
      poly.points[writeIndex] = center + s * radius
      inc writeIndex

      a += step
      sampleIndex += step
      step = nextStep
  else:
    var a = minSample
    while a >= maxSample:
      # Step is clamped to arcFastSampleMax, so we have guaranteed that it will not wrap over range twice or more.
      if sampleIndex < 0:
        sampleIndex += arcFastSampleMax

      let s = poly.arcFastVtx[sampleIndex]
      poly.points[writeIndex] = center + s * radius
      inc writeIndex

      a -= step
      sampleIndex -= step
      step = nextStep

  if extraMaxSample:
    var normalizedMaxSample = maxSample mod arcFastSampleMax
    if normalizedMaxSample < 0:
      normalizedMaxSample += arcFastSampleMax

    let s = poly.arcFastVtx[normalizedMaxSample]
    poly.points[writeIndex] = center + s * radius
    inc writeIndex

func arcToN(poly: var PolyLine, center: Vec2, radius, start, finish: float, segments: int) =
  if radius < 0.5:
    poly.add center
    return

  # Note that we are adding a point at both start and finish.
  # If you are trying to draw a full closed circle you don't want the overlapping points.
  poly.points.setLen(poly.points.len + segments + 1)
  for i in 0 .. segments:
    let a = start + (i.float / segments.float) * (finish - start)
    poly.points[i] = vec2(
      center.x + cos(a) * radius,
      center.y + sin(a) * radius,
    )