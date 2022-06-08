{.experimental: "overloadableEnums".}

import opengl
import std/unicode
import ./text; export text
import ./nanovg/nanovg
import ./math; export math

proc gladLoadGL(): int {.cdecl, importc.}
var gladIsInitialized {.threadvar.}: bool

type
  Paint* = NVGpaint

  Winding* = enum
    CounterClockwise
    Clockwise

  PathWinding* = enum
    CounterClockwise
    Clockwise
    Solid
    Hole

  LineCap* = enum
    Butt
    Round
    Square

  LineJoin* = enum
    Round
    Bevel
    Miter

  VgContext* = ref object
    sizePixels*: Vec2
    scale*: float
    nvgContext*: NVGcontext

proc `=destroy`*(ctx: var type VgContext()[]) =
  nvgDeleteGL3(ctx.nvgContext)

proc newVgContext*(): VgContext =
  if not gladIsInitialized:
    if gladLoadGL() <= 0:
      quit "Failed to initialise glad."
    gladIsInitialized = true
  result = VgContext(
    nvgContext: nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES),
  )

template pixelAlign*(value: float, ctx: VgContext): float =
  let scale = ctx.scale
  (value * scale).round / scale

template pixelAlign*(position: Vec2, ctx: VgContext): Vec2 =
  vec2(
    position.x.pixelAlign(ctx),
    position.y.pixelAlign(ctx),
  )

template pixelAlign*(bounds: Rect2, ctx: VgContext): Rect2 =
  rect2(
    bounds.x.pixelAlign(ctx),
    bounds.y.pixelAlign(ctx),
    bounds.width.pixelAlign(ctx),
    bounds.height.pixelAlign(ctx),
  )

{.push inline.}

proc toNVGEnum(winding: Winding): cint =
  case winding:
  of CounterClockwise: NVG_CCW
  of Clockwise: NVG_CW

proc toNVGEnum(winding: PathWinding): cint =
  case winding:
  of CounterClockwise: NVG_CCW
  of Clockwise: NVG_CW
  of Solid: NVG_SOLID
  of Hole: NVG_HOLE

proc toNVGEnum(cap: LineCap): cint =
  case cap:
  of Butt: NVG_BUTT
  of Round: NVG_ROUND
  of Square: NVG_SQUARE

proc toNVGEnum(join: LineJoin): cint =
  case join:
  of Round: NVG_ROUND
  of Bevel: NVG_BEVEL
  of Miter: NVG_MITER

proc toNvgColor(color: Color): NVGcolor =
  nvgRGBAf(color.r, color.g, color.b, color.a)

proc beginFrame*(ctx: VgContext, sizePixels: Vec2, scale: float) =
  ctx.sizePixels = sizePixels
  ctx.scale = scale
  nvgBeginFrame(ctx.nvgContext, sizePixels.x / scale, sizePixels.y / scale, scale)
  nvgResetScissor(ctx.nvgContext)

proc endFrame*(ctx: VgContext) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)
  glViewport(0.GLint, 0.GLint, ctx.sizePixels.x.GLsizei, ctx.sizePixels.y.GLsizei)
  glScissor(0.GLint, 0.GLint, ctx.sizePixels.x.GLsizei, ctx.sizePixels.y.GLsizei)
  glClear(GL_STENCIL_BUFFER_BIT)
  nvgEndFrame(ctx.nvgContext)

proc beginPath*(ctx: VgContext) =
  nvgBeginPath(ctx.nvgContext)

proc moveTo*(ctx: VgContext, p: Vec2) =
  nvgMoveTo(ctx.nvgContext, p.x, p.y)

proc lineTo*(ctx: VgContext, p: Vec2) =
  nvgLineTo(ctx.nvgContext, p.x, p.y)

proc bezierTo*(ctx: VgContext, c0, c1, p: Vec2) =
  nvgBezierTo(ctx.nvgContext, c0.x, c0.y, c1.x, c1.y, p.x, p.y)

proc quadTo*(ctx: VgContext, c, p: Vec2) =
  nvgQuadTo(ctx.nvgContext, c.x, c.y, p.x, p.y)

proc arcTo*(ctx: VgContext, p0, p1: Vec2, radius: float) =
  nvgArcTo(ctx.nvgContext, p0.x, p0.y, p1.x, p1.y, radius)

proc closePath*(ctx: VgContext) =
  nvgClosePath(ctx.nvgContext)

proc `pathWinding=`*(ctx: VgContext, winding: PathWinding) =
  nvgPathWinding(ctx.nvgContext, winding.toNVGEnum)

proc arc*(ctx: VgContext, p: Vec2, r, a0, a1: float, winding: Winding) =
  nvgArc(ctx.nvgContext, p.x, p.y, r, a0, a1, winding.toNVGEnum)

proc rect*(ctx: VgContext, rect: Rect2) =
  nvgRect(ctx.nvgContext, rect.x, rect.y, rect.width, rect.height)

proc roundedRect*(ctx: VgContext, rect: Rect2, radius: float) =
  nvgRoundedRect(ctx.nvgContext, rect.x, rect.y, rect.width, rect.height, radius)

proc roundedRect*(ctx: VgContext, rect: Rect2, radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) =
  nvgRoundedRectVarying(ctx.nvgContext,
                        rect.x, rect.y, rect.width, rect.height,
                        radTopLeft, radTopRight, radBottomRight, radBottomLeft)

proc ellipse*(ctx: VgContext, c, r: Vec2) =
  nvgEllipse(ctx.nvgContext, c.x, c.y, r.x, r.y)

proc circle*(ctx: VgContext, c: Vec2, r: float) =
  nvgCircle(ctx.nvgContext, c.x, c.y, r)

proc fill*(ctx: VgContext) =
  nvgFill(ctx.nvgContext)

proc stroke*(ctx: VgContext) =
  nvgStroke(ctx.nvgContext)

proc saveState*(ctx: VgContext) =
  nvgSave(ctx.nvgContext)

proc restoreState*(ctx: VgContext) =
  nvgRestore(ctx.nvgContext)

proc reset*(ctx: VgContext) =
  nvgReset(ctx.nvgContext)

proc `shapeAntiAlias=`*(ctx: VgContext, enabled: bool) =
  nvgShapeAntiAlias(ctx.nvgContext, enabled.cint)

proc `strokeColor=`*(ctx: VgContext, color: Color) =
  nvgStrokeColor(ctx.nvgContext, color.toNvgColor)

proc `strokePaint=`*(ctx: VgContext, paint: Paint) =
  nvgStrokePaint(ctx.nvgContext, paint)

proc `fillColor=`*(ctx: VgContext, color: Color) =
  nvgFillColor(ctx.nvgContext, color.toNvgColor)

proc `fillPaint=`*(ctx: VgContext, paint: Paint) =
  nvgFillPaint(ctx.nvgContext, paint)

proc `miterLimit=`*(ctx: VgContext, limit: float) =
  nvgMiterLimit(ctx.nvgContext, limit)

proc `strokeWidth=`*(ctx: VgContext, width: float) =
  nvgStrokeWidth(ctx.nvgContext, width)

proc `lineCap=`*(ctx: VgContext, cap: LineCap) =
  nvgLineCap(ctx.nvgContext, cap.toNVGEnum)

proc `lineJoin=`*(ctx: VgContext, join: LineJoin) =
  nvgLineJoin(ctx.nvgContext, join.toNVGEnum)

proc `globalAlpha=`*(ctx: VgContext, alpha: float) =
  nvgGlobalAlpha(ctx.nvgContext, alpha)

proc clip*(ctx: VgContext, rect: Rect2, intersect = true) =
  if intersect:
    nvgIntersectScissor(ctx.nvgContext, rect.x, rect.y, rect.width, rect.height)
  else:
    nvgScissor(ctx.nvgContext, rect.x, rect.y, rect.width, rect.height)

proc resetClip*(ctx: VgContext) =
  nvgResetScissor(ctx.nvgContext)

proc addFont*(ctx: VgContext, name, data: string) =
  let font = nvgCreateFontMem(ctx.nvgContext, name.cstring, data.cstring, data.len.cint, 0)
  if font == -1:
    echo "Failed to load font: " & name

proc `font=`*(ctx: VgContext, name: string) =
  nvgFontFace(ctx.nvgContext, name.cstring)

proc `fontSize=`*(ctx: VgContext, size: float) =
  nvgFontSize(ctx.nvgContext, size)

proc `letterSpacing=`*(ctx: VgContext, spacing: float) =
  nvgTextLetterSpacing(ctx.nvgContext, spacing)

proc linearGradient*(ctx: VgContext, startPosition, endPosition: Vec2, startColor, endColor: Color): Paint =
  nvgLinearGradient(ctx.nvgContext, startPosition.x, startPosition.y, endPosition.x, endPosition.y, startColor.toNvgColor, endColor.toNvgColor)

proc boxGradient*(ctx: VgContext, bounds: Rect2, cornerRadius, feather: float, innerColor, outerColor: Color): Paint =
  nvgBoxGradient(ctx.nvgContext, bounds.x, bounds.y, bounds.width, bounds.height, cornerRadius, feather, innerColor.toNvgColor, outerColor.toNvgColor)

proc radialGradient*(ctx: VgContext, center: Vec2, innerRadius, outerRadius: float, innerColor, outerColor: Color): Paint =
  nvgRadialGradient(ctx.nvgContext, center.x, center.y, innerRadius, outerRadius, innerColor.toNvgColor, outerColor.toNvgColor)

{.pop.}

proc newText*(ctx: VgContext, data: string): Text =
  let runes = data.toRunes
  result = Text(
    data: data,
    glyphs: newSeq[Glyph](runes.len),
    lines: @[(startIndex: 0, endIndex: runes.len - 1)]
  )

  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(ctx.nvgContext, ascender.addr, descender.addr, lineHeight.addr)
  result.ascender = ascender
  result.descender = descender
  result.lineHeight = lineHeight

  var positions = newSeq[NVGglyphPosition](runes.len)
  discard nvgTextGlyphPositions(ctx.nvgContext, 0, 0, data, nil, positions[0].addr, runes.len.cint)

  let lastGlyphStart = cast[cstring](data[data.len - runes[^1].size].unsafeAddr)
  let lastGlyphEnd = cast[cstring](cast[uint](data[0].unsafeAddr) + data.len.uint)
  var lastGlyphBounds: array[4, cfloat]
  discard nvgTextBounds(ctx.nvgContext, 0, 0, lastGlyphStart, lastGlyphEnd, lastGlyphBounds[0].addr)
  result.glyphs[^1].width = lastGlyphBounds[2] - lastGlyphBounds[0]

  var byteIndex = 0
  for i in 0 ..< runes.len:
    let rune = runes[i]
    result.glyphs[i].rune = rune
    result.glyphs[i].byteIndex = byteIndex
    if i + 1 < runes.len:
      result.glyphs[i].width = positions[i + 1].x - positions[i].x
    byteIndex += rune.size

proc drawText*(ctx: VgContext,
               text: Text,
               bounds: Rect2,
               alignX = TextAlignX.Left,
               alignY = TextAlignY.Top,
               wordWrap = false,
               clip = true) =
  proc drawLine(text: Text, line: TextLine, lineBounds: Rect2) =
    let startGlyph = text.glyphs[line.startIndex]
    let endGlyph = text.glyphs[line.endIndex]
    let lineStartAddr = cast[uint](text.data[startGlyph.byteIndex].unsafeAddr)
    let lineByteLen = (endGlyph.byteIndex + endGlyph.rune.size) - startGlyph.byteIndex
    let lineEndAddr = lineStartAddr + lineByteLen.uint
    # ctx.saveState()
    # ctx.beginPath()
    # ctx.roundedRect lineBounds, 2
    # ctx.fillColor = rgb(0, 120, 0)
    # ctx.fill()
    # ctx.restoreState()
    discard nvgText(ctx.nvgContext, lineBounds.x, lineBounds.y + text.ascender, cast[cstring](lineStartAddr), cast[cstring](lineEndAddr))

  if clip:
    ctx.saveState()
    ctx.clip(bounds)

  text.drawLines(bounds, alignX, alignY, wordWrap, clip, drawLine)

  if clip:
    ctx.restoreState()