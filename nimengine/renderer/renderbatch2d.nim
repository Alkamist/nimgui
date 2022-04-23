import ./concepts
import ./vertexbuffer
import ./indexbuffer

type
  Index2d* = uint32

  Vertex2d* = object
    position*: tuple[x, y: float32]
    texCoords*: tuple[u, v: float32]
    color*: tuple[r, g, b, a: float32]

  RenderBatch2d* = ref object
    vertexBuffer*: VertexBuffer
    vertexData*: seq[Vertex2d]
    vertexWrite*: int
    indexBuffer*: IndexBuffer
    indexData*: seq[Index2d]
    indexWrite*: int
    onFlush*: proc()

const verticesPerQuad = 4
const indicesPerQuad = 6

template vertex2d*(t_position, t_texCoords: SomeVec2, t_color: SomeColor): Vertex2d =
  Vertex2d(
    position: (
      x: t_position.x.float32,
      y: t_position.y.float32,
    ),
    texCoords: (
      u: t_texCoords.x.float32,
      v: t_texCoords.y.float32,
    ),
    color: (
      r: t_color.r.float32,
      g: t_color.g.float32,
      b: t_color.b.float32,
      a: t_color.a.float32,
    )
  )

template bottomLeft*(t_rect: SomeRect2): tuple[x, y: float32] =
  (x: t_rect.x, y: t_rect.y)

template bottomRight*(t_rect: SomeRect2): tuple[x, y: float32] =
  (x: t_rect.x + t_rect.width, y: t_rect.y)

template topLeft*(t_rect: SomeRect2): tuple[x, y: float32] =
  (x: t_rect.x, y: t_rect.y + t_rect.height)

template topRight*(t_rect: SomeRect2): tuple[x, y: float32] =
  (x: t_rect.x + t_rect.width, y: t_rect.y + t_rect.height)

proc newRenderBatch2d*(): RenderBatch2d =
  RenderBatch2d(
    vertexBuffer: newVertexBuffer([VertexAttributeKind.Float2,
                                   VertexAttributeKind.Float2,
                                   VertexAttributeKind.Float4]),
    indexBuffer: newIndexBuffer(Index2d.toIndexKind),
  )

proc flush*(self: RenderBatch2d) =
  self.vertexBuffer.upload(self.vertexData[0..<self.vertexWrite])
  self.indexBuffer.upload(self.indexData[0..<self.indexWrite])
  if self.onFlush != nil:
    self.onFlush()
  self.vertexWrite = 0
  self.indexWrite = 0

proc reserve*(self: RenderBatch2d, vertexCount, indexCount: int) =
  assert(self.indexData.len + indexCount <= Index2d.high.int)
  self.vertexData.setLen(self.vertexData.len + vertexCount)
  self.indexData.setLen(self.indexData.len + indexCount)

proc unreserve*(self: RenderBatch2d, vertexCount, indexCount: int) =
  self.vertexData.setLen((self.vertexData.len - vertexCount).max(0))
  self.indexData.setLen((self.indexData.len - indexCount).max(0))

proc flushIfOverflow*(self: RenderBatch2d, vertexCount, indexCount: int) =
  if self.vertexWrite + vertexCount > self.vertexData.len or
     self.indexWrite + indexCount > self.indexData.len:
    self.flush()

proc reserveQuads*(self: RenderBatch2d, quadCount: int) =
  self.reserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc unreserveQuads*(self: RenderBatch2d, quadCount: int) =
  self.unreserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc addQuad*(self: RenderBatch2d, a, b, c, d: Vertex2d) =
  self.flushIfOverflow(verticesPerQuad, indicesPerQuad)

  self.vertexData[self.vertexWrite + 0] = a
  self.vertexData[self.vertexWrite + 1] = b
  self.vertexData[self.vertexWrite + 2] = c
  self.vertexData[self.vertexWrite + 3] = d

  self.indexData[self.indexWrite + 0] = (self.vertexWrite + 0).uint32
  self.indexData[self.indexWrite + 1] = (self.vertexWrite + 1).uint32
  self.indexData[self.indexWrite + 2] = (self.vertexWrite + 3).uint32
  self.indexData[self.indexWrite + 3] = (self.vertexWrite + 1).uint32
  self.indexData[self.indexWrite + 4] = (self.vertexWrite + 2).uint32
  self.indexData[self.indexWrite + 5] = (self.vertexWrite + 3).uint32

  self.vertexWrite += verticesPerQuad
  self.indexWrite += indicesPerQuad

proc fillRect*(self: RenderBatch2d, rect, uv: SomeRect2, color: SomeColor) =
  self.addQuad(
    vertex2d(rect.bottomLeft, uv.bottomLeft, color),
    vertex2d(rect.topLeft, uv.topLeft, color),
    vertex2d(rect.topRight, uv.topRight, color),
    vertex2d(rect.bottomRight, uv.bottomRight, color),
  )

# proc strokeRect*(self: Gui, rect: Rect2, color: Color, thickness: float) =
#   let t = thickness
#   let t2 = 2.0 * thickness
#   self.fillRect(rect2(rect.x + t, rect.y, rect.width - t2, t), color)
#   self.fillRect(rect2(rect.x + t, rect.y + rect.height - t, rect.width - t2, t), color)
#   self.fillRect(rect2(rect.x, rect.y, t, rect.height), color)
#   self.fillRect(rect2(rect.x + rect.width - t, rect.y, t, rect.height), color)