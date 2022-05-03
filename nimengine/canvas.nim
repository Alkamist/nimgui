import ./gmath

func closedNormals(poly: openArray[Vec2]): seq[Vec2] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[Vec2](poly.len)
  for i in 0 ..< result.len:
    let nextPointIndex =
      if i == result.len - 1:
        0
      else:
        i + 1

    let point = poly[i]
    let nextPoint = poly[nextPointIndex]

    result[i] = (nextPoint - point).rotated(0.5 * Pi).normalized

func openNormals(poly: openArray[Vec2]): seq[Vec2] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[Vec2](poly.len - 1)
  for i in 0 ..< result.len:
    let point = poly[i]
    let nextPoint = poly[i + 1]

    result[i] = (nextPoint - point).rotated(0.5 * Pi).normalized

type
  Index* = uint32

  Vertex* = object
    x*, y*: float32
    u*, v*: float32
    r*, g*, b*, a*: float32

  DrawCall* = object
    clipRect*: Rect2
    indexOffset*: int
    indexCount*: int

  Canvas* = ref object
    width*, height*: float
    drawCalls*: seq[DrawCall]
    vertexData*: seq[Vertex]
    vertexWrite*: int
    indexData*: seq[Index]
    indexWrite*: int
    whitePixelUv*: Vec2
    clipRectStack: seq[Rect2]

func newCanvas*(width, height: float): Canvas =
  Canvas(width: width, height: height)

func addDrawCall(canvas: Canvas) =
  if canvas.clipRectStack.len == 0:
    return

  let indexOffset = canvas.indexData.len

  canvas.drawCalls.add(DrawCall(
    clipRect: canvas.clipRectStack[canvas.clipRectStack.len - 1],
    indexOffset: indexOffset,
    indexCount: 0,
  ))

func pushClipRect*(canvas: Canvas, clipRect: Rect2) =
  canvas.clipRectStack.add(clipRect)
  canvas.addDrawCall()

func pushClipRect*(canvas: Canvas, x, y, width, height: float) =
  canvas.pushClipRect(rect2(x, y, width, height))

func popClipRect*(canvas: Canvas) =
  canvas.clipRectStack.del(canvas.clipRectStack.len - 1)
  canvas.addDrawCall()

func reset*(canvas: Canvas) =
  canvas.vertexWrite = 0
  canvas.indexWrite = 0
  canvas.vertexData.setLen(0)
  canvas.indexData.setLen(0)
  canvas.clipRectStack.setLen(0)
  canvas.drawCalls.setLen(0)
  canvas.pushClipRect(0, 0, canvas.width, canvas.height)

func reserve*(canvas: Canvas, vertexCount, indexCount: int) =
  assert(canvas.indexData.len + indexCount <= Index.high.int)
  if canvas.drawCalls.len > 0:
    canvas.drawCalls[canvas.drawCalls.len - 1].indexCount += indexCount
  canvas.vertexData.setLen(canvas.vertexData.len + vertexCount)
  canvas.indexData.setLen(canvas.indexData.len + indexCount)

func unreserve*(canvas: Canvas, vertexCount, indexCount: int) =
  canvas.vertexWrite -= vertexCount
  canvas.indexWrite -= indexCount
  if canvas.drawCalls.len > 0:
    canvas.drawCalls[canvas.drawCalls.len - 1].indexCount -= indexCount
  canvas.vertexData.setLen((canvas.vertexData.len - vertexCount).max(0))
  canvas.indexData.setLen((canvas.indexData.len - indexCount).max(0))

func addVertex*(canvas: Canvas, position: Vec2, color: Color) =
  canvas.vertexData[canvas.vertexWrite] = Vertex(
    x: position.x, y: position.y,
    u: canvas.whitePixelUv.x, v: canvas.whitePixelUv.y,
    r: color.r, g: color.g, b: color.b, a: color.a,
  )
  inc canvas.vertexWrite

func addIndex*(canvas: Canvas, index: int) =
  canvas.indexData[canvas.indexWrite] = (canvas.vertexWrite + index).Index
  inc canvas.indexWrite

###############################################################################
# Polyline:
###############################################################################

func addPolyLineOpenNoFeather(canvas: Canvas, points: openArray[Vec2], color: Color, thickness: float) =
  if points.len < 2:
    return

  let indexCount = (points.len - 1) * 6
  let vertexCount = points.len * 2
  canvas.reserve(vertexCount, indexCount)

  # Add indices.
  for i in countup(3, vertexCount - 1, 2):
    canvas.addIndex(i - 3)
    canvas.addIndex(i - 2)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 2)
    canvas.addIndex(i)

  # Add vertices.
  let halfThickness = 0.5 * thickness
  let normals = points.openNormals

  let startExpander = normals[0] * halfThickness
  let aStart = points[0] + startExpander
  let bStart = points[0] - startExpander
  canvas.addVertex(aStart, color)
  canvas.addVertex(bStart, color)

  for i in 1 ..< normals.len:
    let previousNormal = normals[i - 1]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerped(normal, 0.5).normalized
    let theta = previousNormal.angleTo(expanderNormal)
    let expanderLength = halfThickness / cos(theta)
    let expander = expanderNormal * expanderLength

    let a = points[i] + expander
    let b = points[i] - expander

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

  let endExpander = normals[normals.len - 1] * halfThickness
  let aEnd = points[points.len - 1] + endExpander
  let bEnd = points[points.len - 1] - endExpander
  canvas.addVertex(aEnd, color)
  canvas.addVertex(bEnd, color)

func addPolyLineClosedNoFeather(canvas: Canvas, points: openArray[Vec2], color: Color, thickness: float) =
  if points.len < 2:
    return

  let indexCount = points.len * 6
  let vertexCount = points.len * 2
  canvas.reserve(vertexCount, indexCount)

  # Add indices.
  for i in countup(3, vertexCount - 1, 2):
    canvas.addIndex(i - 3)
    canvas.addIndex(i - 2)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 2)
    canvas.addIndex(i)

  # Add the closing indices.
  canvas.addIndex(vertexCount - 2)
  canvas.addIndex(vertexCount - 1)
  canvas.addIndex(0)
  canvas.addIndex(0)
  canvas.addIndex(vertexCount - 1)
  canvas.addIndex(1)

  # Add vertices.
  let halfThickness = 0.5 * thickness
  let normals = points.closedNormals

  for i in 0 ..< normals.len:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1
    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerped(normal, 0.5).normalized
    let theta = previousNormal.angleTo(expanderNormal)
    let miterLength = halfThickness / cos(theta)
    let expander = expanderNormal * miterLength

    let a = points[i] + expander
    let b = points[i] - expander

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

func addPolyLineClosedFeather(canvas: Canvas, points: openArray[Vec2], color: Color, thickness, feather: float) =
  if points.len < 2:
    return

  let indexCount = points.len * 18
  let vertexCount = points.len * 4
  canvas.reserve(vertexCount, indexCount)

  # Add indices.
  for i in countup(7, vertexCount - 1, 4):
    canvas.addIndex(i - 6)
    canvas.addIndex(i - 5)
    canvas.addIndex(i - 2)
    canvas.addIndex(i - 2)
    canvas.addIndex(i - 5)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 5)
    canvas.addIndex(i - 4)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 1)
    canvas.addIndex(i - 4)
    canvas.addIndex(i)
    canvas.addIndex(i - 7)
    canvas.addIndex(i - 6)
    canvas.addIndex(i - 3)
    canvas.addIndex(i - 3)
    canvas.addIndex(i - 6)
    canvas.addIndex(i - 2)

  # Add the closing indices.
  canvas.addIndex(vertexCount - 3)
  canvas.addIndex(vertexCount - 2)
  canvas.addIndex(1)
  canvas.addIndex(1)
  canvas.addIndex(vertexCount - 2)
  canvas.addIndex(2)
  canvas.addIndex(vertexCount - 2)
  canvas.addIndex(vertexCount - 1)
  canvas.addIndex(2)
  canvas.addIndex(2)
  canvas.addIndex(vertexCount - 1)
  canvas.addIndex(3)
  canvas.addIndex(vertexCount - 4)
  canvas.addIndex(vertexCount - 3)
  canvas.addIndex(0)
  canvas.addIndex(0)
  canvas.addIndex(vertexCount - 3)
  canvas.addIndex(1)

  # Add vertices.
  let halfThickness = thickness * 0.5
  let normals = points.closedNormals
  let featherColor = rgba(color.r, color.g, color.b, 0)

  for i in 0 ..< normals.len:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1
    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerped(normal, 0.5).normalized
    let theta = previousNormal.angleTo(expanderNormal)
    let cosTheta = cos(theta)
    let expanderLength = halfThickness / cosTheta
    let expander = expanderNormal * expanderLength
    let featherLength = feather / cosTheta
    let featherExpander = expanderNormal * featherLength

    let a = points[i] + expander
    let aFeather = a + featherExpander
    let b = points[i] - expander
    let bFeather = b - featherExpander

    canvas.addVertex(aFeather, featherColor)
    canvas.addVertex(a, color)
    canvas.addVertex(b, color)
    canvas.addVertex(bFeather, featherColor)

func addPolyLine*(canvas: Canvas, points: openArray[Vec2], color: Color, thickness = 1.0, feather = 0.0, closed = false) =
  if feather > 0:
    if closed:
      canvas.addPolyLineClosedFeather(points, color, thickness, feather)
    # else:
    #   canvas.addPolyLineOpenAntiAlias(points, color, thickness)
  else:
    if closed:
      canvas.addPolyLineClosedNoFeather(points, color, thickness)
    else:
      canvas.addPolyLineOpenNoFeather(points, color, thickness)

###############################################################################
# Convex Poly:
###############################################################################

func addConvexPolyNoFeather(canvas: Canvas, points: openArray[Vec2], color: Color) =
  ## Assumes clockwise winding of polygon.
  if points.len < 3:
    return

  let indexCount = (points.len - 2) * 3
  let vertexCount = points.len
  canvas.reserve(vertexCount, indexCount)

  # Add indices.
  for i in 2 ..< points.len:
    canvas.addIndex(0)
    canvas.addIndex(i)
    canvas.addIndex(i - 1)

  # Add vertices.
  for i in 0 ..< vertexCount:
    canvas.addVertex(points[i], color)

func addConvexPolyFeather(canvas: Canvas, points: openArray[Vec2], color: Color, feather: float) =
  ## Assumes clockwise winding of polygon.
  if points.len < 3:
    return

  let indexCount = (points.len - 2) * 3 + points.len * 6
  let vertexCount = points.len * 2
  canvas.reserve(vertexCount, indexCount)

  # Add the first feather quad.
  let firstQuadInner0 = 0
  let firstQuadInner1 = 2
  let firstQuadOuter0 = 1
  let firstQuadOuter1 = 3

  canvas.addIndex(firstQuadInner0)
  canvas.addIndex(firstQuadOuter1)
  canvas.addIndex(firstQuadOuter0)
  canvas.addIndex(firstQuadOuter1)
  canvas.addIndex(firstQuadInner0)
  canvas.addIndex(firstQuadInner1)

  # Add indices.
  for i in countup(4, vertexCount - 1, 2):
    let innerShape0 = 0
    let innerShape1 = i - 2
    let innerShape2 = i

    canvas.addIndex(innerShape0)
    canvas.addIndex(innerShape2)
    canvas.addIndex(innerShape1)

    let featherQuad1 = i - 1
    let featherQuad2 = i + 1

    canvas.addIndex(innerShape1)
    canvas.addIndex(featherQuad2)
    canvas.addIndex(featherQuad1)
    canvas.addIndex(featherQuad2)
    canvas.addIndex(innerShape1)
    canvas.addIndex(innerShape2)

  # Add the final feather quad.
  let finalQuadInner0 = vertexCount - 2
  let finalQuadInner1 = 0
  let finalQuadOuter0 = vertexCount - 1
  let finalQuadOuter1 = 1

  canvas.addIndex(finalQuadInner0)
  canvas.addIndex(finalQuadOuter1)
  canvas.addIndex(finalQuadOuter0)
  canvas.addIndex(finalQuadOuter1)
  canvas.addIndex(finalQuadInner0)
  canvas.addIndex(finalQuadInner1)

  # Add vertices.
  let featherColor = rgba(color.r, color.g, color.b, 0)
  let normals = points.closedNormals

  for i in 0 ..< points.len:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1

    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerped(normal, 0.5).normalized
    let theta = previousNormal.angleTo(expanderNormal)
    let featherLength = feather / cos(theta)
    let featherPoint = points[i] + expanderNormal * featherLength

    canvas.addVertex(points[i], color)
    canvas.addVertex(featherPoint, featherColor)

func addConvexPoly*(canvas: Canvas, points: openArray[Vec2], color: Color, feather = 0.0) =
  if feather > 0:
    canvas.addConvexPolyFeather(points, color, feather)
  else:
    canvas.addConvexPolyNoFeather(points, color)

###############################################################################
# Drawing:
###############################################################################

func fillRect*(canvas: Canvas, x, y, width, height: float, color: Color, feather = 0.0) =
  let left = x
  let right = x + width
  let bottom = y
  let top = y + height
  let points = [
    vec2(left, bottom),
    vec2(left, top),
    vec2(right, top),
    vec2(right, bottom),
  ]
  canvas.addConvexPoly(points, color, feather)

func strokeRect*(canvas: Canvas, x, y, width, height: float, color: Color, thickness = 1.0, feather = 0.0) =
  let left = x
  let right = x + width
  let bottom = y
  let top = y + height
  let points = [
    vec2(left, bottom),
    vec2(left, top),
    vec2(right, top),
    vec2(right, bottom),
  ]
  canvas.addPolyLine(points, color, thickness, feather, true)