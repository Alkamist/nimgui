import ./concepts
import ./vertexbuffer
import ./indexbuffer

type
  Index2d* = uint32

  Vertex2d* = object
    position*: tuple[x, y: float32]
    texCoords*: tuple[u, v: float32]
    color*: tuple[r, g, b, a: float32]

  RenderBatch2d* = object
    vertexBuffer*: VertexBuffer
    vertexData*: seq[Vertex2d]
    vertexWrite*: int
    indexBuffer*: IndexBuffer
    indexData*: seq[Index2d]
    indexWrite*: int
    onRender*: proc()

const verticesPerQuad = 4
const indicesPerQuad = 6

func vertex2d*(position, texCoords: SomeVec2, color: SomeColor): Vertex2d =
  Vertex2d(
    position: (
      x: position.x.float32,
      y: position.y.float32,
    ),
    texCoords: (
      u: texCoords.x.float32,
      v: texCoords.y.float32,
    ),
    color: (
      r: color.r.float32,
      g: color.g.float32,
      b: color.b.float32,
      a: color.a.float32,
    )
  )

proc initRenderBatch2d*(): RenderBatch2d =
  RenderBatch2d(
    vertexBuffer: initVertexBuffer([VertexAttributeKind.Float2,
                                    VertexAttributeKind.Float2,
                                    VertexAttributeKind.Float4]),
    indexBuffer: initIndexBuffer(Index2d.toIndexKind),
  )

proc render*(self: var RenderBatch2d) =
  self.vertexBuffer.upload(self.vertexData[0..<self.vertexWrite])
  self.indexBuffer.upload(self.indexData[0..<self.indexWrite])
  if self.onRender != nil:
    self.onRender()
  self.vertexWrite = 0
  self.indexWrite = 0

proc reserve*(self: var RenderBatch2d, vertexCount, indexCount: int) =
  assert(self.indexData.len + indexCount <= Index2d.high.int)
  self.vertexData.setLen(self.vertexData.len + vertexCount)
  self.indexData.setLen(self.indexData.len + indexCount)

proc unreserve*(self: var RenderBatch2d, vertexCount, indexCount: int) =
  self.vertexData.setLen((self.vertexData.len - vertexCount).max(0))
  self.indexData.setLen((self.indexData.len - indexCount).max(0))

proc renderIfOverflow*(self: var RenderBatch2d, vertexCount, indexCount: int) =
  if self.vertexWrite + vertexCount > self.vertexData.len or
     self.indexWrite + indexCount > self.indexData.len:
    self.render()

proc reserveQuads*(self: var RenderBatch2d, quadCount: int) =
  self.reserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc unreserveQuads*(self: var RenderBatch2d, quadCount: int) =
  self.unreserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc addQuad*(self: var RenderBatch2d, a, b, c, d: Vertex2d) =
  self.renderIfOverflow(verticesPerQuad, indicesPerQuad)

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