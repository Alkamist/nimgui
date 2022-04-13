import ./vertexbuffer
import ./indexbuffer

const verticesPerQuad = 4
const indicesPerQuad = 6

type
  Color* = object
    r*, g*, b*, a*: float32

  Rect* = object
    x*, y*: float32
    width*, height*: float32

  Vertex2d* = object
    position*: tuple[x, y: float32]
    color*: Color

  QuadBatch* = ref object
    len*: int
    maxLen*: int
    vertexBuffer*: VertexBuffer
    vertexData*: seq[Vertex2d]
    indexBuffer*: IndexBuffer
    indexData*: seq[uint32]
    onRender*: proc()

proc newQuadBatch*(maxLen: int): QuadBatch =
  QuadBatch(
    maxLen: maxLen,
    vertexBuffer: initVertexBuffer([VertexAttributeKind.Float2,
                                    VertexAttributeKind.Float4]),
    vertexData: newSeq[Vertex2d](maxLen * verticesPerQuad),
    indexBuffer: initIndexBuffer(IndexKind.UInt32),
    indexData: newSeq[uint32](maxLen * indicesPerQuad),
  )

proc render*(batch: QuadBatch) =
  let vertexWrite = batch.len * verticesPerQuad
  let indexWrite = batch.len * indicesPerQuad

  batch.vertexBuffer.uploadData(batch.vertexData[0 ..< vertexWrite])
  batch.indexBuffer.uploadData(batch.indexData[0 ..< indexWrite])

  batch.len = 0

  if batch.onRender != nil:
    batch.onRender()

proc addRect*(batch: QuadBatch, rect: Rect, color: Color) =
  if batch.len >= batch.maxLen:
    batch.render()

  let left = rect.x
  let right = rect.x + rect.width
  let bottom = rect.y
  let top = rect.y + rect.height

  let vertexWrite = batch.len * verticesPerQuad
  batch.vertexData[vertexWrite + 0] = Vertex2d(position: (left, top), color: color)
  batch.vertexData[vertexWrite + 1] = Vertex2d(position: (right, top), color: color)
  batch.vertexData[vertexWrite + 2] = Vertex2d(position: (right, bottom), color: color)
  batch.vertexData[vertexWrite + 3] = Vertex2d(position: (left, bottom), color: color)

  let indexWrite = batch.len * indicesPerQuad
  batch.indexData[indexWrite + 0] = (vertexWrite + 0).uint32
  batch.indexData[indexWrite + 1] = (vertexWrite + 1).uint32
  batch.indexData[indexWrite + 2] = (vertexWrite + 3).uint32
  batch.indexData[indexWrite + 3] = (vertexWrite + 1).uint32
  batch.indexData[indexWrite + 4] = (vertexWrite + 2).uint32
  batch.indexData[indexWrite + 5] = (vertexWrite + 3).uint32

  inc batch.len