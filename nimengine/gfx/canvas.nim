{.experimental: "overloadableEnums".}

import std/math
import std/unicode
import opengl

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
  # Vec2 = tuple[x, y: float]
  Rect2 = tuple[x, y, width, height: float]
  Color = tuple[r, g, b, a: float]

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
    width, height: float
    vertexData: seq[Vertex]
    vertexWrite: int
    indexData: seq[Index]
    indexWrite: int
    shader: Shader
    atlasTexture: Texture
    vertexBuffer: VertexBuffer
    indexBuffer: IndexBuffer
    vertexArrayId: GLuint
    drawCalls: seq[DrawCall]
    clipRectStack: seq[Rect2]
    atlas*: CanvasAtlas

func vertex(x, y, u, v, r, g, b, a: float): Vertex =
  Vertex(
    x: x.float32, y: y.float32,
    u: u.float32, v: v.float32,
    r: r.float32, g: g.float32, b: b.float32, a: a.float32,
  )

proc `=destroy`*(canvas: var type Canvas()[]) =
  glDeleteVertexArrays(1, canvas.vertexArrayId.addr)

proc newCanvas*(): Canvas =
  result = Canvas()

  # Stop OpenGl from crashing on later versions.
  glGenVertexArrays(1, result.vertexArrayId.addr)
  glBindVertexArray(result.vertexArrayId)

  result.shader = newShader(vertexSrc, fragmentSrc)
  result.atlasTexture = newTexture()
  result.vertexBuffer = newVertexBuffer([Float2, Float2, Float4])
  result.indexBuffer = newIndexBuffer(UInt32)

proc loadFont*(canvas: Canvas, location: string, pixelHeight: float) =
  let fontData = readFile(location)
  canvas.atlas = newCanvasAtlas(fontData, pixelHeight)
  canvas.atlasTexture.upload(canvas.atlas.width, canvas.atlas.height, canvas.atlas.data)

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

func pushClipRect*(canvas: Canvas, x, y, width, height: float) =
  canvas.clipRectStack.add (x, y, width, height)
  canvas.addDrawCall()

func pushClipRect*(canvas: Canvas, rect: Rect2) =
  canvas.clipRectStack.add rect
  canvas.addDrawCall()

func popClipRect*(canvas: Canvas) =
  canvas.clipRectStack.del(canvas.clipRectStack.len - 1)
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
  canvas.vertexData[canvas.vertexWrite] = vertex(x, y, u, v, r, g, b, a)
  inc canvas.vertexWrite

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
    (rect.x, rect.x + rect.width, rect.y, rect.y + rect.height)

  let quad = quad.lrtb
  let uv = uv.lrtb

  canvas.addVertex(quad.left, quad.bottom, uv.left, uv.bottom, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.left, quad.top, uv.left, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.right, quad.top, uv.right, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.right, quad.bottom, uv.right, uv.bottom, color.r, color.g, color.b, color.a)

func beginFrame*(canvas: Canvas, width, height: float) =
  canvas.width = width
  canvas.height = height
  canvas.vertexWrite = 0
  canvas.indexWrite = 0
  canvas.vertexData.setLen(0)
  canvas.indexData.setLen(0)
  canvas.clipRectStack.setLen(0)
  canvas.drawCalls.setLen(0)
  canvas.pushClipRect(0, 0, canvas.width, canvas.height)

proc render*(canvas: Canvas) =
  if canvas.vertexData.len == 0 or canvas.indexData.len == 0:
    return

  gfx.enableBlend()
  gfx.enableClipping()
  gfx.disableFaceCulling()
  gfx.disableDepthTesting()

  canvas.shader.select()
  canvas.shader.setUniform("ProjMtx", orthoProjection(0, canvas.width, 0, canvas.height))
  canvas.atlasTexture.select()
  canvas.vertexBuffer.select()
  canvas.vertexBuffer.upload(StreamDraw, canvas.vertexData)
  canvas.indexBuffer.select()
  canvas.indexBuffer.upload(StreamDraw, canvas.indexData)

  for drawCall in canvas.drawCalls:
    if drawCall.indexCount == 0:
      continue

    # OpenGl clip rects are placed from the bottom left.
    let crX = drawCall.clipRect.x
    let crYFlipped = canvas.height - (drawCall.clipRect.y + drawCall.clipRect.height)
    let crWidth = drawCall.clipRect.width
    let crHeight = drawCall.clipRect.height
    gfx.setClipRect(
      crX,
      crYFlipped,
      crWidth,
      crHeight,
    )

    gfx.drawTriangles(
      drawCall.indexCount,
      canvas.indexBuffer.kind,
      drawCall.indexOffset,
    )

func drawText*(canvas: Canvas,
               text: string,
               bounds: Rect2,
               color: Color,
               xAlign = HorizontalAlignment.Left,
               yAlign = VerticalAlignment.Center,
               wordWrap = true,
               clip = true) =
  let atlas = canvas.atlas

  if clip:
    canvas.pushClipRect bounds

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

      let outOfBounds = x + glyphInfo.xAdvance > bounds.width

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

  let lineHeight = atlas.glyphBoundingBox[1].y

  let yAlignment = case yAlign:
    of Bottom: bounds.height - (lineHeight * lineInfo.len.float)
    of Center: 0.5 * (bounds.height - (lineHeight * lineInfo.len.float))
    of Top: 0.0

  var y = 2 + lineHeight + atlas.glyphBoundingBox[0].y

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

        if i == info.firstIndex: lineWidth -= glyphInfo.xOffset
        if i == info.lastIndex: lineWidth += glyphInfo.xOffset

      lineWidth

    let xAlignment = case xAlign:
      of Left: 0.0
      of Center: 0.5 * (bounds.width - calculateLineWidth())
      of Right: bounds.width - calculateLineWidth()

    var x = 0.0
    for i in info.firstIndex .. info.lastIndex:
      let rune =
        if atlas.glyphInfoTable.hasKey(runes[i]):
          runes[i]
        else:
          128.Rune

      let glyphInfo = atlas.glyphInfoTable[rune]

      let quad = (
        x: (bounds.x + xAlignment + x + glyphInfo.xOffset).round,
        y: (bounds.y + yAlignment + y + glyphInfo.yOffset).round,
        width: glyphInfo.width.float,
        height: glyphInfo.height.float,
      )

      let quadIsEntirelyOutOfBounds =
        clip and
        (quad.x + quad.width < bounds.x or
         quad.x > bounds.x + bounds.width or
         quad.y + quad.height < bounds.y or
         quad.y > bounds.y + bounds.height)

      if not quadIsEntirelyOutOfBounds:
        let uv = (
          glyphInfo.x.float / atlas.width.float,
          glyphInfo.y.float / atlas.height.float,
          glyphInfo.width.float / atlas.width.float,
          glyphInfo.height.float / atlas.height.float,
        )

        canvas.addQuad(quad, uv, color)

        x += glyphInfo.xAdvance

    y += lineHeight

  if clip:
    canvas.popClipRect()