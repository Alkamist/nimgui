{.experimental: "overloadableEnums".}

import std/unicode
import opengl

import ../tmath
export tmath

import polyline
export polyline

import ./wrappers/functions as gfx
import ./wrappers/shader
import ./wrappers/texture
import ./wrappers/vertexbuffer
import ./wrappers/indexbuffer
import ./wrappers/common
import ./canvasatlas

const vertexSrc = """
#version 300 es
precision highp float;
layout (location = 0) in vec2 Position;
layout (location = 1) in vec2 UV;
layout (location = 2) in vec4 Color;
uniform mat4 ProjMtx;
out vec2 Frag_UV;
out vec4 Frag_Color;
void main()
{
  Frag_UV = UV;
  Frag_Color = Color;
  gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
}
"""

const fragmentSrc = """
#version 300 es
precision mediump float;
uniform sampler2D Texture;
in vec2 Frag_UV;
in vec4 Frag_Color;
layout (location = 0) out vec4 Out_Color;
void main()
{
  Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
}
"""

func orthoProjection(left, right, top, bottom: float32): array[4, array[4, float32]] =
  [
    [2.0f / (right - left), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f / (top - bottom), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(right + left) / (left - right), (top + bottom) / (bottom - top), 0.0f, 1.0f],
  ]

type
  CanvasError* = object of CatchableError

  HorizontalAlignment* = enum
    Left
    Center
    Right

  VerticalAlignment* = enum
    Bottom
    Center
    Top

  Index = uint32

  Vertex = object
    x*, y*: float32
    u*, v*: float32
    r*, g*, b*, a*: float32

  DrawCall = object
    clipRect: Rect2
    indexOffset: int
    indexCount: int

  Canvas* = ref object
    scale*: float
    size*: Vec2
    unscaledTesselationTolerance*: float
    vertexData*: seq[Vertex]
    vertexWrite*: int
    indexData*: seq[Index]
    indexWrite*: int
    shader*: Shader
    atlasTexture*: Texture
    vertexBuffer*: VertexBuffer
    indexBuffer*: IndexBuffer
    vertexArrayId*: GLuint
    drawCalls*: seq[DrawCall]
    clipRectStack*: seq[Rect2]
    atlas*: CanvasAtlas
    atlasFontData*: string
    atlasFontSize*: float
    atlasFontFirstChar*: int
    atlasFontNumChars*: int
    previousScale*: float

func error(canvas: Canvas, msg: string) =
  raise newException(CanvasError, msg)

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

    result[i] = (nextPoint - point).rotate(-0.5 * Pi).normalize

func openNormals(poly: openArray[Vec2]): seq[Vec2] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[Vec2](poly.len - 1)
  for i in 0 ..< result.len:
    let point = poly[i]
    let nextPoint = poly[i + 1]

    result[i] = (nextPoint - point).rotate(-0.5 * Pi).normalize

proc `=destroy`*(canvas: var type Canvas()[]) =
  glDeleteVertexArrays(1, canvas.vertexArrayId.addr)

proc newCanvas*(): Canvas =
  result = Canvas(
    previousScale: 1.0,
    scale: 1.0,
    unscaledTesselationTolerance: 1.25,
  )

  # Stop OpenGl from crashing on later versions.
  glGenVertexArrays(1, result.vertexArrayId.addr)
  glBindVertexArray(result.vertexArrayId)

  result.shader = newShader(vertexSrc, fragmentSrc)
  result.atlasTexture = newTexture()
  result.vertexBuffer = newVertexBuffer([Float2, Float2, Float4])
  result.indexBuffer = newIndexBuffer(UInt32)

proc loadFont*(canvas: Canvas, fontData: string, fontSize: float, firstChar = 0, numChars = 128) =
  canvas.atlasFontData = fontData
  canvas.atlasFontSize = fontSize
  canvas.atlasFontFirstChar = firstChar
  canvas.atlasFontNumChars = numChars
  canvas.atlas = newCanvasAtlas(fontData, fontSize, firstChar, numChars)
  canvas.atlasTexture.upload(canvas.atlas.width, canvas.atlas.height, canvas.atlas.data)

func pixelThickness*(canvas: Canvas): float =
  1.0 / canvas.scale

func addDrawCall(canvas: Canvas) =
  if canvas.clipRectStack.len == 0:
    return

  template currentDrawCall(): untyped = canvas.drawCalls[canvas.drawCalls.len - 1]
  template currentClipRect(): untyped = canvas.clipRectStack[canvas.clipRectStack.len - 1]

  let indexOffset = canvas.indexData.len
  let previousDrawCallIsEmpty =
    canvas.drawCalls.len > 0 and
    currentDrawCall.indexCount > 0

  # Avoid allocating new draw calls if the previous one is empty.
  # There could still be an empty draw call at the end of the list though.
  if canvas.drawCalls.len == 0 or previousDrawCallIsEmpty:
    canvas.drawCalls.add(DrawCall(
      clipRect: currentClipRect,
      indexOffset: indexOffset,
      indexCount: 0,
    ))
  else:
    currentDrawCall.clipRect = currentClipRect
    currentDrawCall.indexOffset = indexOffset

func pushClipRect*(canvas: Canvas, rect: Rect2) =
  let lastRect =
    if canvas.clipRectStack.len > 0:
      canvas.clipRectStack[canvas.clipRectStack.len - 1]
    else:
      rect2(vec2(0.0, 0.0), canvas.size)

  let leftX = max(rect.position.x, lastRect.position.x)
  let rightX = min(rect.position.x + rect.size.x, lastRect.position.x + lastRect.size.x)
  let topY = max(rect.position.y, lastRect.position.y)
  let bottomY = min(rect.position.y + rect.size.y, lastRect.position.y + lastRect.size.y)

  let intersection = rect2(
    leftX,
    topY,
    max(rightX - leftX, 0.0),
    max(bottomY - topY, 0.0),
  )

  canvas.clipRectStack.add intersection
  canvas.addDrawCall()

func popClipRect*(canvas: Canvas) =
  canvas.clipRectStack.setLen(canvas.clipRectStack.len - 1)
  canvas.addDrawCall()

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

func addVertex*(canvas: Canvas, x, y, u, v, r, g, b, a: float) =
  canvas.vertexData[canvas.vertexWrite] = Vertex(
    x: x, y: y,
    u: u, v: v,
    r: r, g: g, b: b, a: a,
  )
  inc canvas.vertexWrite

func addVertex*(canvas: Canvas, position, uv: Vec2, color: Color) =
  canvas.addVertex(
    position.x, position.y,
    uv.x, uv.y,
    color.r, color.g, color.b, color.a,
  )

func addVertex*(canvas: Canvas, position: Vec2, color: Color) =
  canvas.addVertex(
    position,
    canvas.atlas.whitePixelUv.position,
    color,
  )

func addIndex*(canvas: Canvas, index: int) =
  canvas.indexData[canvas.indexWrite] = (canvas.vertexWrite + index).Index
  inc canvas.indexWrite

func addQuad*(canvas: Canvas, quad, uv: Rect2, color: Color) =
  canvas.reserve(4, 6)
  canvas.addIndex(0)
  canvas.addIndex(2)
  canvas.addIndex(1)
  canvas.addIndex(0)
  canvas.addIndex(3)
  canvas.addIndex(2)

  proc lrtb(rect: Rect2): tuple[left, right, top, bottom: float] =
    (rect.position.x, rect.position.x + rect.size.x, rect.position.y, rect.position.y + rect.size.y)

  let q = quad.lrtb
  let uv = uv.lrtb

  canvas.addVertex(q.left, q.bottom, uv.left, uv.bottom, color.r, color.g, color.b, color.a)
  canvas.addVertex(q.left, q.top, uv.left, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(q.right, q.top, uv.right, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(q.right, q.bottom, uv.right, uv.bottom, color.r, color.g, color.b, color.a)

proc beginFrame*(canvas: Canvas, size: Vec2, scale: float) =
  if canvas.atlas == nil:
    canvas.error "There is no atlas loaded. Make sure to load a font with loadFont."

  canvas.previousScale = canvas.scale
  canvas.scale = scale
  canvas.size = size
  canvas.vertexWrite = 0
  canvas.indexWrite = 0
  canvas.vertexData.setLen(0)
  canvas.indexData.setLen(0)
  canvas.clipRectStack.setLen(0)
  canvas.drawCalls.setLen(0)
  canvas.pushClipRect rect2(vec2(0.0, 0.0), size)

  if canvas.scale != canvas.previousScale:
    canvas.atlas = newCanvasAtlas(
      canvas.atlasFontData,
      canvas.atlasFontSize * canvas.scale,
      canvas.atlasFontFirstChar,
      canvas.atlasFontNumChars,
    )
    canvas.atlasTexture.upload(canvas.atlas.width, canvas.atlas.height, canvas.atlas.data)

proc render*(canvas: Canvas) =
  if canvas.vertexData.len == 0 or canvas.indexData.len == 0:
    return

  gfx.enableBlend()
  gfx.enableClipping()
  gfx.disableFaceCulling()
  gfx.disableDepthTesting()

  canvas.shader.select()
  canvas.atlasTexture.select()
  canvas.vertexBuffer.select()
  canvas.indexBuffer.select()

  canvas.shader.setUniform("ProjMtx", orthoProjection(0, canvas.size.x / canvas.scale, 0, canvas.size.y / canvas.scale))
  canvas.vertexBuffer.upload(StreamDraw, canvas.vertexData)
  canvas.indexBuffer.upload(StreamDraw, canvas.indexData)

  for drawCall in canvas.drawCalls:
    if drawCall.indexCount == 0:
      continue

    let p = (drawCall.clipRect.position * canvas.scale).round
    let p1 = ((drawCall.clipRect.position + drawCall.clipRect.size) * canvas.scale).round
    let s = p1 - p

    gfx.setClipRect(
      p.x,
      canvas.size.y - (p.y + s.y),
      s.x,
      s.y,
    )

    gfx.drawTriangles(
      drawCall.indexCount,
      canvas.indexBuffer.kind,
      drawCall.indexOffset,
    )

func fillRect*(canvas: Canvas, quad: Rect2, color: Color) =
  canvas.addQuad(quad, canvas.atlas.whitePixelUv, color)

func strokeRect*(canvas: Canvas, quad: Rect2, color: Color, thickness = 1.0) =
  let uv = canvas.atlas.whitePixelUv

  let left = quad.position.x
  let leftInner = left + thickness
  let right = left + quad.size.x
  let rightInner = right - thickness
  let top = quad.position.y
  let bottom = top + quad.size.y
  let bottomInner = bottom - thickness

  let sideHeight = bottom - top
  let topBottomWidth = rightInner - leftInner

  canvas.addQuad rect2(left, top, thickness, sideHeight), uv, color
  canvas.addQuad rect2(rightInner, top, thickness, sideHeight), uv, color

  canvas.addQuad rect2(leftInner, top, topBottomWidth, thickness), uv, color
  canvas.addQuad rect2(leftInner, bottomInner, topBottomWidth, thickness), uv, color

func strokePointsOpen(canvas: Canvas, points: openArray[Vec2], color: Color, thickness: float) =
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
  let normals = points.openNormals

  let startExpander = normals[0] * thickness
  let aStart = points[0]
  let bStart = points[0] - startExpander
  canvas.addVertex(aStart, color)
  canvas.addVertex(bStart, color)

  for i in 1 ..< normals.len:
    let previousNormal = normals[i - 1]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerp(normal, 0.5).normalize
    let theta = previousNormal.angleTo(expanderNormal)
    let expanderLength = thickness / cos(theta)
    let expander = expanderNormal * expanderLength

    let a = points[i]
    let b = points[i] - expander

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

  let endExpander = normals[normals.len - 1] * thickness
  let aEnd = points[points.len - 1]
  let bEnd = points[points.len - 1] - endExpander
  canvas.addVertex(aEnd, color)
  canvas.addVertex(bEnd, color)

func strokePointsClosed(canvas: Canvas, points: openArray[Vec2], color: Color, thickness: float) =
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
  let normals = points.closedNormals

  for i in 0 ..< normals.len:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1
    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerp(normal, 0.5).normalize
    let theta = previousNormal.angleTo(expanderNormal)
    let cosTheta = cos(theta)
    let expander = expanderNormal * thickness / cosTheta

    let a = points[i]
    let b = points[i] - expander

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

func fillPointsConvex(canvas: Canvas, points: openArray[Vec2], color: Color) =
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

func strokePolyLine*(canvas: Canvas, poly: PolyLine, color: Color, thickness = 1.0) =
  if poly.isClosed:
    canvas.strokePointsClosed(poly.points[0 ..< poly.points.len - 1], color, thickness)
  elif poly.len >= 2:
    canvas.strokePointsOpen(poly.points, color, thickness)

func fillConvexPolyLine*(canvas: Canvas, poly: PolyLine, color: Color) =
  canvas.fillPointsConvex(poly.points, color)

func drawText*(canvas: Canvas,
               text: string,
               bounds: Rect2,
               color: Color,
               xAlign = HorizontalAlignment.Left,
               yAlign = VerticalAlignment.Center,
               wordWrap = false,
               clip = true) =
  let atlas = canvas.atlas
  let scale = canvas.scale

  if clip:
    canvas.pushClipRect bounds

  let bounds = rect2(
    bounds.position * scale,
    bounds.size * scale,
  )

  const newLine = "\n".runeAt(0)

  if atlas.glyphInfoTable.len == 0:
    return

  let runes = text.toRunes

  var lineInfo: seq[tuple[firstIndex, lastIndex: int]]
  lineInfo.add (0, runes.len - 1)

  # Extract info about lines based on glyph bounds.
  block:
    template currentLine(): untyped =
      lineInfo[lineInfo.len - 1]

    var i = 0
    var wrapCount = 0
    var lastWhitespace = 0
    var x = 0.0

    while i < runes.len and wrapCount < runes.len:
      let rune = runes[i]

      if not atlas.glyphInfoTable.hasKey(rune):
        inc i
        continue

      let glyphInfo = atlas.glyphInfoTable[rune]

      if rune.isWhiteSpace:
        lastWhitespace = i

      if rune == newLine:
        x = 0.0
        currentLine.lastIndex = i - 1
        inc i
        lineInfo.add (i, runes.len - 1)
        continue

      let outOfBounds = x + glyphInfo.xAdvance > bounds.size.x

      if wordWrap and outOfBounds and i > 0:
        inc wrapCount
        x = 0.0

        if lastWhitespace > currentLine.firstIndex:
          let nextLineStart = lastWhitespace + 1
          currentLine.lastIndex = lastWhitespace - 1
          lineInfo.add (nextLineStart, runes.len - 1)
          i = nextLineStart
          continue
        else:
          currentLine.lastIndex = i - 1
          lineInfo.add (i, runes.len - 1)

      x += glyphInfo.xAdvance
      inc i

  let lineHeight = atlas.glyphBoundingBox.size.y

  let yAlignment = case yAlign:
    of Bottom: bounds.size.y - (lineHeight * lineInfo.len.float)
    of Center: 0.5 * (bounds.size.y - (lineHeight * lineInfo.len.float))
    of Top: 0.0

  var y = 2 + lineHeight + atlas.glyphBoundingBox.position.y

  # Go through every line and draw quads textured with the appropriate glyph.
  for info in lineInfo:
    template calculateLineWidth(): float =
      var lineWidth = 0.0
      for i in info.firstIndex .. info.lastIndex:
        let rune =
          if atlas.glyphInfoTable.hasKey(runes[i]):
            runes[i]
          else:
            128.Rune
        let glyphInfo = atlas.glyphInfoTable[rune]

        lineWidth += glyphInfo.xAdvance

        if i == info.firstIndex: lineWidth -= glyphInfo.offset.x
        if i == info.lastIndex: lineWidth += glyphInfo.offset.x

      lineWidth

    let xAlignment = case xAlign:
      of Left: 0.0
      of Center: 0.5 * (bounds.size.x - calculateLineWidth())
      of Right: bounds.size.x - calculateLineWidth()

    var x = 0.0
    for i in info.firstIndex .. info.lastIndex:
      let rune =
        if atlas.glyphInfoTable.hasKey(runes[i]):
          runes[i]
        else:
          128.Rune

      let glyphInfo = atlas.glyphInfoTable[rune]

      let quad = rect2(
        bounds.position.x + xAlignment + x + glyphInfo.offset.x,
        bounds.position.y + yAlignment + y + glyphInfo.offset.y,
        glyphInfo.rect.size.x.float,
        glyphInfo.rect.size.y.float,
      )

      let quadIsEntirelyOutOfBounds =
        clip and
        (quad.position.x + quad.size.x < bounds.position.x or
         quad.position.x > bounds.position.x + bounds.size.x or
         quad.position.y + quad.size.y < bounds.position.y or
         quad.position.y > bounds.position.y + bounds.size.y)

      if not quadIsEntirelyOutOfBounds:
        let quadScaled = rect2(
          quad.position / scale,
          quad.size / scale,
        )
        canvas.addQuad(quadScaled, glyphInfo.uv, color)

      x += glyphInfo.xAdvance

    y += lineHeight

  if clip:
    canvas.popClipRect()