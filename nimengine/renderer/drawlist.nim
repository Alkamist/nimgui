import ../gmath

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

  DrawList* = ref object
    vertexData*: seq[Vertex]
    vertexWrite*: int
    indexData*: seq[Index]
    indexWrite*: int
    whitePixelUv*: Vec2
    antiAliasSize*: float
    antiAliasIsEnabled*: bool

func newDrawList*(): DrawList =
  DrawList(antiAliasSize: 1.0, antiAliasIsEnabled: true)

func reset*(list: DrawList) =
  list.vertexWrite = 0
  list.indexWrite = 0
  list.vertexData.setLen(0)
  list.indexData.setLen(0)

func reserve*(list: DrawList, vertexCount, indexCount: int) =
  assert(list.indexData.len + indexCount <= Index.high.int)
  list.vertexData.setLen(list.vertexData.len + vertexCount)
  list.indexData.setLen(list.indexData.len + indexCount)

func unreserve*(list: DrawList, vertexCount, indexCount: int) =
  list.vertexWrite -= vertexCount
  list.indexWrite -= indexCount
  list.vertexData.setLen((list.vertexData.len - vertexCount).max(0))
  list.indexData.setLen((list.indexData.len - indexCount).max(0))

func addVertex*(list: DrawList, position: Vec2, color: Color) =
  list.vertexData[list.vertexWrite] = Vertex(
    x: position.x, y: position.y,
    u: list.whitePixelUv.x, v: list.whitePixelUv.y,
    r: color.r, g: color.g, b: color.b, a: color.a,
  )
  inc list.vertexWrite

func addIndex*(list: DrawList, index: int) =
  list.indexData[list.indexWrite] = (list.vertexWrite + index).Index
  inc list.indexWrite

func addPolyLineNoAntiAlias*(list: DrawList, points: openArray[Vec2], color: Color, thickness = 1.0) =
  if points.len < 2:
    return

  let indexCount = (points.len - 1) * 6
  let vertexCount = points.len * 2
  list.reserve(vertexCount, indexCount)

  # Add indices.
  for i in countup(3, vertexCount - 1, 2):
    list.addIndex(i - 3)
    list.addIndex(i - 2)
    list.addIndex(i - 1)
    list.addIndex(i - 1)
    list.addIndex(i - 2)
    list.addIndex(i)

  # Add vertices.
  let thickness = thickness.max(1.0)
  let halfThickness = 0.5 * thickness
  let normals = points.openNormals

  let startExpander = normals[0] * halfThickness
  let aStart = points[0] + startExpander
  let bStart = points[0] - startExpander
  list.addVertex(aStart, color)
  list.addVertex(bStart, color)

  for i in 1 ..< normals.len:
    let previousNormal = normals[i - 1]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerped(normal, 0.5).normalized
    let theta = previousNormal.angleTo(expanderNormal)
    let expanderLength = halfThickness / cos(theta)
    let expander = expanderNormal * expanderLength

    let a = points[i] + expander
    let b = points[i] - expander

    list.addVertex(a, color)
    list.addVertex(b, color)

  let endExpander = normals[normals.len - 1] * halfThickness
  let aEnd = points[points.len - 1] + endExpander
  let bEnd = points[points.len - 1] - endExpander
  list.addVertex(aEnd, color)
  list.addVertex(bEnd, color)

func addConvexPolyFilledNoAntiAlias*(list: DrawList, points: openArray[Vec2], color: Color) =
  ## Assumes clockwise winding of polygon.
  if points.len < 3:
    return

  let indexCount = (points.len - 2) * 3
  let vertexCount = points.len
  list.reserve(vertexCount, indexCount)

  # Add indices.
  for i in 2 ..< points.len:
    list.addIndex(0)
    list.addIndex(i)
    list.addIndex(i - 1)

  # Add vertices.
  for i in 0 ..< vertexCount:
    list.addVertex(points[i], color)

func addConvexPolyFilledAntiAlias*(list: DrawList, points: openArray[Vec2], color: Color) =
  ## Assumes clockwise winding of polygon.
  if points.len < 3:
    return

  let indexCount = (points.len - 2) * 3 + points.len * 6
  let vertexCount = points.len * 2
  list.reserve(vertexCount, indexCount)

  # Add the first anti-alias fringe.
  let firstFringeInner0 = 0
  let firstFringeInner1 = 2
  let firstFringeOuter0 = 1
  let firstFringeOuter1 = 3

  list.addIndex(firstFringeInner0)
  list.addIndex(firstFringeOuter1)
  list.addIndex(firstFringeOuter0)
  list.addIndex(firstFringeOuter1)
  list.addIndex(firstFringeInner0)
  list.addIndex(firstFringeInner1)

  # Add indices.
  for i in countup(4, vertexCount - 1, 2):
    let innerShape0 = 0
    let innerShape1 = i - 2
    let innerShape2 = i

    list.addIndex(innerShape0)
    list.addIndex(innerShape2)
    list.addIndex(innerShape1)

    let aaFringe1 = i - 1
    let aaFringe2 = i + 1

    list.addIndex(innerShape1)
    list.addIndex(aaFringe2)
    list.addIndex(aaFringe1)
    list.addIndex(aaFringe2)
    list.addIndex(innerShape1)
    list.addIndex(innerShape2)

  # Add the final anti-alias fringe.
  let finalFringeInner0 = vertexCount - 2
  let finalFringeInner1 = 0
  let finalFringeOuter0 = vertexCount - 1
  let finalFringeOuter1 = 1

  list.addIndex(finalFringeInner0)
  list.addIndex(finalFringeOuter1)
  list.addIndex(finalFringeOuter0)
  list.addIndex(finalFringeOuter1)
  list.addIndex(finalFringeInner0)
  list.addIndex(finalFringeInner1)

  # Add vertices.
  let aaColor = rgba(color.r, color.g, color.b, 0)
  let normals = points.closedNormals

  for i in 0 ..< points.len:
    let previousNormalIndex = if i == 0: points.len - 1 else: i - 1

    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expander = previousNormal.lerped(normal, 0.5).normalized
    let aaPoint = points[i] + expander * list.antiAliasSize

    list.addVertex(points[i], color)
    list.addVertex(aaPoint, aaColor)