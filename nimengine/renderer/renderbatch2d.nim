import ./vertexbuffer
import ./indexbuffer

type
  Rect = tuple[x, y, width, height: float]
  Color = tuple[r, g, b, a: float]

  Index2d* = uint32

  Vertex2d* = object
    x*, y*: float32
    u*, v*: float32
    r*, g*, b*, a*: float32

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

proc vertex2d*(x, y, u, v, r, g, b, a: float): Vertex2d =
  Vertex2d(
    x: x.float32, y: y.float32,
    u: u.float32, v: v.float32,
    r: r.float32, g: g.float32, b: b.float32, a: a.float32,
  )

proc expanded(rect: Rect, x, y: float): Rect =
  (
    rect.x - x,
    rect.y - y,
    rect.width + x * 2.0,
    rect.height + y * 2.0,
  )

proc lrbt(rect: Rect): tuple[left, right, bottom, top: float] =
  (rect.x, rect.x + rect.width, rect.y, rect.y + rect.height)

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

proc fillRect*(batch: RenderBatch2d,
               rect, uvRect: Rect,
               color: Color) =
  let bounds = rect.lrbt
  let uvBounds = uvRect.lrbt
  let r = color.r
  let g = color.g
  let b = color.b
  let a = color.a
  batch.addQuad(
    vertex2d(bounds.left, bounds.bottom, uvBounds.left, uvBounds.bottom, r, g, b, a),
    vertex2d(bounds.left, bounds.top, uvBounds.left, uvBounds.top, r, g, b, a),
    vertex2d(bounds.right, bounds.top, uvBounds.right, uvBounds.top, r, g, b, a),
    vertex2d(bounds.right, bounds.bottom, uvBounds.right, uvBounds.bottom, r, g, b, a),
  )

proc strokeRect*(batch: RenderBatch2d,
                 rect, uvRect: Rect,
                 color: Color,
                 thickness: float) =
  let outer = rect.lrbt
  let inner = rect.expanded(-thickness, -thickness).lrbt
  let uThickness = uvRect.width * thickness / rect.width
  let vThickness = uvRect.height * thickness / rect.height
  let uvOuter = uvRect.lrbt
  let uvInner = uvRect.expanded(-uThickness, -vThickness).lrbt
  let r = color.r
  let g = color.g
  let b = color.b
  let a = color.a

  # Left
  batch.addQuad(
    vertex2d(outer.left, outer.bottom, uvOuter.left, uvOuter.bottom, r, g, b, a),
    vertex2d(outer.left, outer.top, uvOuter.left, uvOuter.top, r, g, b, a),
    vertex2d(inner.left, outer.top, uvInner.left, uvOuter.top, r, g, b, a),
    vertex2d(inner.left, outer.bottom, uvInner.left, uvOuter.bottom, r, g, b, a),
  )

  # Top
  batch.addQuad(
    vertex2d(inner.left, inner.top, uvInner.left, uvInner.top, r, g, b, a),
    vertex2d(inner.left, outer.top, uvInner.left, uvOuter.top, r, g, b, a),
    vertex2d(inner.right, outer.top, uvInner.right, uvOuter.top, r, g, b, a),
    vertex2d(inner.right, inner.top, uvInner.right, uvInner.top, r, g, b, a),
  )

  # Right
  batch.addQuad(
    vertex2d(inner.right, outer.bottom, uvInner.right, uvOuter.bottom, r, g, b, a),
    vertex2d(inner.right, outer.top, uvInner.right, uvOuter.top, r, g, b, a),
    vertex2d(outer.right, outer.top, uvOuter.right, uvOuter.top, r, g, b, a),
    vertex2d(outer.right, outer.bottom, uvOuter.right, uvOuter.bottom, r, g, b, a),
  )

  # Bottom
  batch.addQuad(
    vertex2d(inner.left, outer.bottom, uvInner.left, uvOuter.bottom, r, g, b, a),
    vertex2d(inner.left, inner.bottom, uvInner.left, uvInner.bottom, r, g, b, a),
    vertex2d(inner.right, inner.bottom, uvInner.right, uvInner.bottom, r, g, b, a),
    vertex2d(inner.right, outer.bottom, uvInner.right, uvOuter.bottom, r, g, b, a),
  )