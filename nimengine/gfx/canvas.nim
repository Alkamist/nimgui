{.experimental: "overloadableEnums".}

import std/unicode
import opengl

import ../tmath

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
    clipRect: tuple[position, size: tuple[x, y: float]]
    indexOffset: int
    indexCount: int

  Canvas* = ref object
    densityPixelsPerPixel*: float
    size*: tuple[x, y: float]
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
    clipRectStack: seq[tuple[position, size: tuple[x, y: float]]]
    atlas: CanvasAtlas
    atlasFontData: string
    atlasFontSize: float
    atlasFontFirstChar: int
    atlasFontNumChars: int
    previousDensityPixelsPerPixel: float

func error(canvas: Canvas, msg: string) =
  raise newException(CanvasError, msg)

func closedNormals(poly: openArray[tuple[x, y: float]]): seq[tuple[x, y: float]] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[tuple[x, y: float]](poly.len)
  for i in 0 ..< result.len:
    let nextPointIndex =
      if i == result.len - 1:
        0
      else:
        i + 1

    let point = poly[i]
    let nextPoint = poly[nextPointIndex]

    result[i] = (nextPoint - point).rotate(-0.5 * Pi).normalize

func openNormals(poly: openArray[tuple[x, y: float]]): seq[tuple[x, y: float]] =
  ## Assumes clockwise winding of polygon.
  result = newSeq[tuple[x, y: float]](poly.len - 1)
  for i in 0 ..< result.len:
    let point = poly[i]
    let nextPoint = poly[i + 1]

    result[i] = (nextPoint - point).rotate(-0.5 * Pi).normalize

proc `=destroy`*(canvas: var type Canvas()[]) =
  glDeleteVertexArrays(1, canvas.vertexArrayId.addr)

proc newCanvas*(): Canvas =
  result = Canvas(previousDensityPixelsPerPixel: 1.0, densityPixelsPerPixel: 1.0)

  # Stop OpenGl from crashing on later versions.
  glGenVertexArrays(1, result.vertexArrayId.addr)
  glBindVertexArray(result.vertexArrayId)

  result.shader = newShader(vertexSrc, fragmentSrc)
  result.atlasTexture = newTexture()
  result.vertexBuffer = newVertexBuffer([Float2, Float2, Float4])
  result.indexBuffer = newIndexBuffer(UInt32)

proc loadFont*(canvas: Canvas,
               fontData: string, fontSize: float,
               firstChar = 0, numChars = 128) =
  canvas.atlasFontData = fontData
  canvas.atlasFontSize = fontSize
  canvas.atlasFontFirstChar = firstChar
  canvas.atlasFontNumChars = numChars
  canvas.atlas = newCanvasAtlas(fontData, fontSize, firstChar, numChars)
  canvas.atlasTexture.upload(canvas.atlas.size.x, canvas.atlas.size.y, canvas.atlas.data)

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

func pushClipRect*(canvas: Canvas,
                   rect: tuple[position, size: tuple[x, y: float]]) =
  let lastRect =
    if canvas.clipRectStack.len > 0:
      canvas.clipRectStack[canvas.clipRectStack.len - 1]
    else:
      ((0.0, 0.0), (canvas.size.x, canvas.size.y))

  let leftX = max(rect.position.x, lastRect.position.x)
  let rightX = min(rect.position.x + rect.size.x, lastRect.position.x + lastRect.size.x)
  let topY = max(rect.position.y, lastRect.position.y)
  let bottomY = min(rect.position.y + rect.size.y, lastRect.position.y + lastRect.size.y)

  let intersection = (
    (leftX, topY),
    (max(rightX - leftX, 0.0), max(bottomY - topY, 0.0)),
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

func addVertex*(canvas: Canvas,
                position, uv: tuple[x, y: float],
                color: tuple[r, g, b, a: float]) =
  canvas.vertexData[canvas.vertexWrite] = Vertex(
    x: position.x, y: position.y,
    u: uv.x, v: uv.y,
    r: color.r, g: color.g, b: color.b, a: color.a,
  )
  inc canvas.vertexWrite

func addVertex*(canvas: Canvas,
                position: tuple[x, y: float],
                color: tuple[r, g, b, a: float]) =
  canvas.vertexData[canvas.vertexWrite] = Vertex(
    x: position.x, y: position.y,
    u: canvas.atlas.whitePixelUv.position.x, v: canvas.atlas.whitePixelUv.position.y,
    r: color.r, g: color.g, b: color.b, a: color.a,
  )
  inc canvas.vertexWrite

func addIndex*(canvas: Canvas, index: int) =
  canvas.indexData[canvas.indexWrite] = (canvas.vertexWrite + index).Index
  inc canvas.indexWrite

func addQuad*(canvas: Canvas,
              quad, uv: tuple[position, size: tuple[x, y: float]],
              color: tuple[r, g, b, a: float]) =
  canvas.reserve(4, 6)
  canvas.addIndex(0)
  canvas.addIndex(2)
  canvas.addIndex(1)
  canvas.addIndex(0)
  canvas.addIndex(3)
  canvas.addIndex(2)

  proc lrtb(rect: tuple[position, size: tuple[x, y: float]]): tuple[left, right, top, bottom: float] =
    (rect.position.x, rect.position.x + rect.size.x, rect.position.y, rect.position.y + rect.size.y)

  let quad = quad.lrtb
  let uv = uv.lrtb

  canvas.addVertex(quad.left, quad.bottom, uv.left, uv.bottom, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.left, quad.top, uv.left, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.right, quad.top, uv.right, uv.top, color.r, color.g, color.b, color.a)
  canvas.addVertex(quad.right, quad.bottom, uv.right, uv.bottom, color.r, color.g, color.b, color.a)

proc beginFrame*(canvas: Canvas,
                 size: tuple[x, y: float],
                 densityPixelsPerPixel: float) =
  if canvas.atlas == nil:
    canvas.error "There is no atlas loaded. Make sure to load a font with loadFont."

  canvas.previousDensityPixelsPerPixel = canvas.densityPixelsPerPixel
  canvas.densityPixelsPerPixel = densityPixelsPerPixel
  canvas.size = size
  canvas.vertexWrite = 0
  canvas.indexWrite = 0
  canvas.vertexData.setLen(0)
  canvas.indexData.setLen(0)
  canvas.clipRectStack.setLen(0)
  canvas.drawCalls.setLen(0)
  canvas.pushClipRect ((0.0, 0.0), (size.x, size.y))

  if canvas.densityPixelsPerPixel != canvas.previousDensityPixelsPerPixel:
    canvas.atlas = newCanvasAtlas(
      canvas.atlasFontData,
      canvas.atlasFontSize * canvas.densityPixelsPerPixel,
      canvas.atlasFontFirstChar,
      canvas.atlasFontNumChars,
    )
    canvas.atlasTexture.upload(canvas.atlas.size.x, canvas.atlas.size.y, canvas.atlas.data)

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

  canvas.shader.setUniform("ProjMtx", orthoProjection(0, canvas.size.x, 0, canvas.size.y))
  canvas.vertexBuffer.upload(StreamDraw, canvas.vertexData)
  canvas.indexBuffer.upload(StreamDraw, canvas.indexData)

  for drawCall in canvas.drawCalls:
    if drawCall.indexCount == 0:
      continue

    let dp = canvas.densityPixelsPerPixel
    let crX = drawCall.clipRect.position.x * dp
    let crY = drawCall.clipRect.position.y * dp
    let crHeight = drawCall.clipRect.size.y * dp
    let crWidth = drawCall.clipRect.size.x * dp
    let crYFlipped = canvas.size.y * dp - (crY + crHeight)

    gfx.setClipRect(
      crX + 0.5,
      crYFlipped + 0.5,
      crWidth + 0.5,
      crHeight + 0.5,
    )

    gfx.drawTriangles(
      drawCall.indexCount,
      canvas.indexBuffer.kind,
      drawCall.indexOffset,
    )

func fillRect*(canvas: Canvas,
               quad: tuple[position, size: tuple[x, y: float]],
               color: tuple[r, g, b, a: float]) =
  canvas.addQuad(quad, canvas.atlas.whitePixelUv, color)

func outlineRect*(canvas: Canvas,
                  quad: tuple[position, size: tuple[x, y: float]],
                  color: tuple[r, g, b, a: float],
                  thickness = 1.0) =
  let left = quad.position.x
  let leftInner = left + thickness
  let right = left + quad.size.x
  let rightInner = right - thickness
  let top = quad.position.y
  let bottom = top + quad.size.y
  let bottomInner = bottom - thickness

  let sideHeight = bottom - top
  let topBottomWidth = rightInner - leftInner

  canvas.fillRect ((left, top), (thickness, sideHeight)), color
  canvas.fillRect ((rightInner, top), (thickness, sideHeight)), color

  canvas.fillRect ((leftInner, top), (topBottomWidth, thickness)), color
  canvas.fillRect ((leftInner, bottomInner), (topBottomWidth, thickness)), color

func fillPolyLineOpen*(canvas: Canvas,
                       points: openArray[tuple[x, y: float]],
                       color: tuple[r, g, b, a: float],
                       thickness = 1.0) =
  const bias = (x: 1.0, y: 0.0)

  if points.len < 2:
    return

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
  let halfThickness = 0.5 * thickness
  let normals = points.openNormals

  let startExpander = normals[0] * halfThickness
  let aStart = points[0] + startExpander + bias
  let bStart = points[0] - startExpander + bias
  canvas.addVertex(aStart, color)
  canvas.addVertex(bStart, color)

  for i in 1 ..< normals.len:
    let previousNormal = normals[i - 1]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerp(normal, 0.5).normalize
    let theta = previousNormal.angleTo(expanderNormal)
    let expanderLength = halfThickness / cos(theta)
    let expander = expanderNormal * expanderLength

    let a = points[i] + expander + bias
    let b = points[i] - expander + bias

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

  let endExpander = normals[normals.len - 1] * halfThickness
  let aEnd = points[points.len - 1] + endExpander + bias
  let bEnd = points[points.len - 1] - endExpander + bias
  canvas.addVertex(aEnd, color)
  canvas.addVertex(bEnd, color)

func fillPolyLineClosed*(canvas: Canvas,
                         points: openArray[tuple[x, y: float]],
                         color: tuple[r, g, b, a: float],
                         thickness = 1.0) =
  const bias = (x: 1.0, y: 0.0)

  if points.len < 2:
    return

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
  let halfThickness = 0.5 * thickness
  let normals = points.closedNormals

  for i in 0 ..< normals.len:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1
    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerp(normal, 0.5).normalize
    let theta = previousNormal.angleTo(expanderNormal)
    let miterLength = halfThickness / cos(theta)
    let expander = expanderNormal * miterLength

    let a = points[i] + expander + bias
    let b = points[i] - expander + bias

    canvas.addVertex(a, color)
    canvas.addVertex(b, color)

func fillConvexPoly*(canvas: Canvas,
                     points: openArray[tuple[x, y: float]],
                     color: tuple[r, g, b, a: float]) =
  const bias = (x: 1.0, y: 0.0)

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
  let normals = points.closedNormals

  for i in 0 ..< vertexCount:
    let previousNormalIndex = if i == 0: normals.len - 1 else: i - 1
    let previousNormal = normals[previousNormalIndex]
    let normal = normals[i]

    let expanderNormal = previousNormal.lerp(normal, 0.5).normalize
    let theta = previousNormal.angleTo(expanderNormal)
    let expander = expanderNormal * 0.5 / cos(theta)

    # The polygon needs to be expanded slightly to be
    # inclusive of all pixels when rendered and match up
    # with addPolyLine.
    canvas.addVertex(points[i] + expander + bias, color)

func drawText*(canvas: Canvas,
               text: string,
               bounds: tuple[position, size: tuple[x, y: float]],
               color: tuple[r, g, b, a: float],
               xAlign = HorizontalAlignment.Left,
               yAlign = VerticalAlignment.Center,
               wordWrap = true,
               clip = true) =
  let atlas = canvas.atlas
  let dp = canvas.densityPixelsPerPixel

  if clip:
    canvas.pushClipRect bounds

  let bounds = (
    position: (x: bounds.position.x * dp, y: bounds.position.y * dp),
    size: (x: bounds.size.x * dp, y: bounds.size.y * dp),
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

  let lineHeight = atlas.glyphBoundingBox[1].y

  let yAlignment = case yAlign:
    of Bottom: bounds.size.y - (lineHeight * lineInfo.len.float)
    of Center: 0.5 * (bounds.size.y - (lineHeight * lineInfo.len.float))
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

      let quad = (
        position: (x: bounds.position.x + xAlignment + x + glyphInfo.offset.x,
                   y: bounds.position.y + yAlignment + y + glyphInfo.offset.y),
        size: (x: glyphInfo.size.x.float,
               y: glyphInfo.size.y.float),
      )

      let quadIsEntirelyOutOfBounds =
        clip and
        (quad.position.x + quad.size.x < bounds.position.x or
         quad.position.x > bounds.position.x + bounds.size.x or
         quad.position.y + quad.size.y < bounds.position.y or
         quad.position.y > bounds.position.y + bounds.size.y)

      if not quadIsEntirelyOutOfBounds:
        let quadScaled = (
          position: (x: quad.position.x / dp, y: quad.position.y / dp),
          size: (x: quad.size.x / dp, y: quad.size.y / dp),
        )
        canvas.addQuad(quadScaled, glyphInfo.uv, color)

      x += glyphInfo.xAdvance

    y += lineHeight

  if clip:
    canvas.popClipRect()