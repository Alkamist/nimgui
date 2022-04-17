type
  SomeVec2 = concept self
    self.x is SomeFloat
    self.y is SomeFloat

  # SomeRect = concept self
  #   self.x is SomeFloat
  #   self.y is SomeFloat
  #   self.width is SomeFloat
  #   self.height is SomeFloat

  SomeColor = concept self
    self.r is SomeFloat
    self.g is SomeFloat
    self.b is SomeFloat
    self.a is SomeFloat

  # Vec2 = object
  #   x, y: float

  # Rect = object
  #   x, y, width, height: float

  # Color = object
  #   r, g, b, a: float

  Index2d* = uint32

  Vertex2d* = object
    position*: tuple[x, y: float32]
    color*: tuple[r, g, b, a: float32]

  RenderBatch2d* = object
    vertexData*: seq[Vertex2d]
    vertexWrite*: int
    indexData*: seq[Index2d]
    indexWrite*: int
    onRender*: proc()

func vertex2d(position: SomeVec2, color: SomeColor): Vertex2d =
  Vertex2d(
    position: (
      x: position.x.float32,
      y: position.y.float32,
    ),
    color: (
      r: color.r.float32,
      g: color.g.float32,
      b: color.b.float32,
      a: color.a.float32,
    )
  )

proc initRenderBatch2d*(): RenderBatch2d =
  RenderBatch2d()

proc render*(self: var RenderBatch2d) =
  if self.onRender != nil:
    self.onRender()

  self.vertexData.setLen(0)
  self.vertexWrite = 0
  self.indexData.setLen(0)
  self.indexWrite = 0

proc reserve*(self: var RenderBatch2d, vertexCount, indexCount: int) =
  assert(indexCount <= Index2d.high.int)

  # If the number of vertices is higher than the maximum value an index
  # can have (based on its data type), then there is an overflow and
  # we need to make a draw call and flush the buffer.
  if self.indexData.len + indexCount > Index2d.high.int:
    self.render()

  self.vertexData.setLen(self.vertexData.len + vertexCount)
  self.indexData.setLen(self.indexData.len + indexCount)

proc unreserve*(self: var RenderBatch2d, vertexCount, indexCount: int) =
  self.vertexData.setLen((self.vertexData.len - vertexCount).max(0))
  self.indexData.setLen((self.indexData.len - indexCount).max(0))

proc reserveQuads*(self: var RenderBatch2d, count: int) =
  self.reserve(4 * count, 6 * count)

proc unreserveQuads*(self: var RenderBatch2d, count: int) =
  self.unreserve(4 * count, 6 * count)

proc addQuad*(self: var RenderBatch2d, a, b, c, d: SomeVec2, color: SomeColor) =
  self.vertexData[self.vertexWrite + 0] = vertex2d(a, color)
  self.vertexData[self.vertexWrite + 1] = vertex2d(b, color)
  self.vertexData[self.vertexWrite + 2] = vertex2d(c, color)
  self.vertexData[self.vertexWrite + 3] = vertex2d(d, color)

  self.indexData[self.indexWrite + 0] = (self.vertexWrite + 0).uint32
  self.indexData[self.indexWrite + 1] = (self.vertexWrite + 1).uint32
  self.indexData[self.indexWrite + 2] = (self.vertexWrite + 3).uint32
  self.indexData[self.indexWrite + 3] = (self.vertexWrite + 1).uint32
  self.indexData[self.indexWrite + 4] = (self.vertexWrite + 2).uint32
  self.indexData[self.indexWrite + 5] = (self.vertexWrite + 3).uint32

  self.vertexWrite += 4
  self.indexWrite += 6