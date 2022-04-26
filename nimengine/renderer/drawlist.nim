import ../gmath

func normals*(convexPoly: openArray[Vec2]): seq[Vec2] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[Vec2](convexPoly.len)
  for i in 0 ..< convexPoly.len:
    let nextPointIndex =
      if i == convexPoly.len - 1:
        0
      else:
        i + 1

    let point = convexPoly[i]
    let nextPoint = convexPoly[nextPointIndex]

    result[i] = (nextPoint - point).rotated(0.5 * Pi).normalized

func expanded*(convexPoly: openArray[Vec2], amount: float): seq[Vec2] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[Vec2](convexPoly.len)
  let normals = convexPoly.normals
  for i in 0 ..< convexPoly.len:
    let previousNormalIndex =
      if i == 0:
        convexPoly.len - 1
      else:
        i - 1

    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expander = previousNormal.lerped(normal, 0.5).normalized
    result[i] = convexPoly[i] + expander * amount

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

func addIndex*(list: DrawList, index: Index) =
  list.indexData[list.indexWrite] = index
  inc list.indexWrite

func addConvexPolyFilled*(list: DrawList, points: openArray[Vec2], color: Color) =
  ## Assumes clockwise winding of polygon.

  if points.len < 3:
    return

  # With anti-alias fringes.
  if list.antiAliasIsEnabled:
    let indexCount = (points.len - 2) * 3 + points.len * 6
    let vertexCount = points.len * 2
    list.reserve(vertexCount, indexCount)

    # Add the first anti-alias fringe.
    let firstFringeInner0 = list.vertexWrite
    let firstFringeInner1 = list.vertexWrite + 2
    let firstFringeOuter0 = list.vertexWrite + 1
    let firstFringeOuter1 = list.vertexWrite + 3

    list.addIndex(firstFringeInner0.Index)
    list.addIndex(firstFringeOuter0.Index)
    list.addIndex(firstFringeOuter1.Index)
    list.addIndex(firstFringeOuter1.Index)
    list.addIndex(firstFringeInner1.Index)
    list.addIndex(firstFringeInner0.Index)

    # Add indices.
    for i in countup(4, vertexCount - 1, 2):
      let innerShape0 = list.vertexWrite
      let innerShape1 = list.vertexWrite + i - 2
      let innerShape2 = list.vertexWrite + i

      list.addIndex(innerShape0.Index)
      list.addIndex(innerShape1.Index)
      list.addIndex(innerShape2.Index)

      let aaFringe1 = list.vertexWrite + i - 1
      let aaFringe2 = list.vertexWrite + i + 1

      list.addIndex(innerShape1.Index)
      list.addIndex(aaFringe1.Index)
      list.addIndex(aaFringe2.Index)
      list.addIndex(aaFringe2.Index)
      list.addIndex(innerShape2.Index)
      list.addIndex(innerShape1.Index)

    # Add the final anti-alias fringe.
    let finalFringeInner0 = list.vertexWrite + vertexCount - 2
    let finalFringeInner1 = list.vertexWrite
    let finalFringeOuter0 = list.vertexWrite + vertexCount - 1
    let finalFringeOuter1 = list.vertexWrite + 1

    list.addIndex(finalFringeInner0.Index)
    list.addIndex(finalFringeOuter0.Index)
    list.addIndex(finalFringeOuter1.Index)
    list.addIndex(finalFringeOuter1.Index)
    list.addIndex(finalFringeInner1.Index)
    list.addIndex(finalFringeInner0.Index)

    # Add vertices.
    let aaColor = rgba(color.r, color.g, color.b, 0)
    let aaPoints = points.expanded(list.antiAliasSize)
    for i in 0 ..< points.len:
      list.addVertex(points[i], color)
      list.addVertex(aaPoints[i], aaColor)

  # No anti-alias fringes.
  else:
    let indexCount = (points.len - 2) * 3
    let vertexCount = points.len
    list.reserve(vertexCount, indexCount)

    # Add indices.
    for i in 2 ..< points.len:
      list.addIndex(list.vertexWrite.Index)
      list.addIndex((list.vertexWrite + i - 1).Index)
      list.addIndex((list.vertexWrite + i).Index)

    # Add vertices.
    for i in 0 ..< vertexCount:
      list.addVertex(points[i], color)