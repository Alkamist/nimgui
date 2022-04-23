import ./vertexbuffer
import ./indexbuffer

type
  Index2d* = uint32

  Vertex2d* = tuple
    position: tuple[x, y: float32]
    texCoords: tuple[u, v: float32]
    color: tuple[r, g, b, a: float32]

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

proc newRenderBatch2d*(): RenderBatch2d =
  RenderBatch2d(
    vertexBuffer: newVertexBuffer([VertexAttributeKind.Float2,
                                   VertexAttributeKind.Float2,
                                   VertexAttributeKind.Float4]),
    indexBuffer: newIndexBuffer(Index2d.toIndexKind),
  )

proc flush*(batch: RenderBatch2d) =
  batch.vertexBuffer.upload(batch.vertexData[0..<batch.vertexWrite])
  batch.indexBuffer.upload(batch.indexData[0..<batch.indexWrite])
  if batch.onFlush != nil:
    batch.onFlush()
  batch.vertexWrite = 0
  batch.indexWrite = 0

proc reserve*(batch: RenderBatch2d, vertexCount, indexCount: int) =
  assert(batch.indexData.len + indexCount <= Index2d.high.int)
  batch.vertexData.setLen(batch.vertexData.len + vertexCount)
  batch.indexData.setLen(batch.indexData.len + indexCount)

proc unreserve*(batch: RenderBatch2d, vertexCount, indexCount: int) =
  batch.vertexData.setLen((batch.vertexData.len - vertexCount).max(0))
  batch.indexData.setLen((batch.indexData.len - indexCount).max(0))

proc flushIfOverflow*(batch: RenderBatch2d, vertexCount, indexCount: int) =
  if batch.vertexWrite + vertexCount > batch.vertexData.len or
     batch.indexWrite + indexCount > batch.indexData.len:
    batch.flush()

proc reserveQuads*(batch: RenderBatch2d, quadCount: int) =
  batch.reserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc unreserveQuads*(batch: RenderBatch2d, quadCount: int) =
  batch.unreserve(quadCount * verticesPerQuad, quadCount * indicesPerQuad)

proc addQuad*(batch: RenderBatch2d, a, b, c, d: Vertex2d) =
  batch.flushIfOverflow(verticesPerQuad, indicesPerQuad)

  batch.vertexData[batch.vertexWrite + 0] = a
  batch.vertexData[batch.vertexWrite + 1] = b
  batch.vertexData[batch.vertexWrite + 2] = c
  batch.vertexData[batch.vertexWrite + 3] = d

  batch.indexData[batch.indexWrite + 0] = (batch.vertexWrite + 0).uint32
  batch.indexData[batch.indexWrite + 1] = (batch.vertexWrite + 1).uint32
  batch.indexData[batch.indexWrite + 2] = (batch.vertexWrite + 3).uint32
  batch.indexData[batch.indexWrite + 3] = (batch.vertexWrite + 1).uint32
  batch.indexData[batch.indexWrite + 4] = (batch.vertexWrite + 2).uint32
  batch.indexData[batch.indexWrite + 5] = (batch.vertexWrite + 3).uint32

  batch.vertexWrite += verticesPerQuad
  batch.indexWrite += indicesPerQuad