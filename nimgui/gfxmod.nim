{.experimental: "overloadableEnums".}

import std/unicode; export unicode
import opengl
import ./nanovg
import ./math; export math

const NVG_ALIGN_LEFT = (1 shl 0).cint
const NVG_ALIGN_CENTER = (1 shl 1).cint
const NVG_ALIGN_RIGHT = (1 shl 2).cint
const NVG_ALIGN_TOP = (1 shl 3).cint
const NVG_ALIGN_MIDDLE = (1 shl 4).cint
const NVG_ALIGN_BOTTOM = (1 shl 5).cint
const NVG_ALIGN_BASELINE = (1 shl 6).cint

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

  TextAlignX* = enum
    Left
    Center
    Right

  TextAlignY* = enum
    Top
    Center
    Bottom
    Baseline

  Glyph* = object
    index*: uint64
    x*: float
    minX*, maxX*: float

  Gfx* = ref object
    pixelDensity*: float
    nvgContext*: NVGcontext

proc `=destroy`*(gfx: var type Gfx()[]) =
  nvgDelete(gfx.nvgContext)

proc newGfx*(): Gfx =
  result = Gfx(
    nvgContext: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES),
  )

template pixelAlign*(gfx: Gfx, value: float): float =
  let pixelDensity = gfx.pixelDensity
  (value * pixelDensity).round / pixelDensity

template pixelAlign*(gfx: Gfx, position: Vec2): Vec2 =
  vec2(
    gfx.pixelAlign(position.x),
    gfx.pixelAlign(position.y),
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

proc beginFrame*(gfx: Gfx, sizePixels: Vec2, pixelDensity: float) =
  gfx.pixelDensity = pixelDensity
  nvgBeginFrame(gfx.nvgContext, sizePixels.x / pixelDensity, sizePixels.y / pixelDensity, pixelDensity)
  nvgResetScissor(gfx.nvgContext)

proc endFrame*(gfx: Gfx, sizePixels: Vec2) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)
  glViewport(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
  glScissor(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
  glClear(GL_STENCIL_BUFFER_BIT)
  nvgEndFrame(gfx.nvgContext)

proc beginPath*(gfx: Gfx) =
  nvgBeginPath(gfx.nvgContext)

proc moveTo*(gfx: Gfx, p: Vec2) =
  nvgMoveTo(gfx.nvgContext, p.x, p.y)

proc lineTo*(gfx: Gfx, p: Vec2) =
  nvgLineTo(gfx.nvgContext, p.x, p.y)

proc bezierTo*(gfx: Gfx, c0, c1, p: Vec2) =
  nvgBezierTo(gfx.nvgContext, c0.x, c0.y, c1.x, c1.y, p.x, p.y)

proc quadTo*(gfx: Gfx, c, p: Vec2) =
  nvgQuadTo(gfx.nvgContext, c.x, c.y, p.x, p.y)

proc arcTo*(gfx: Gfx, p0, p1: Vec2, radius: float) =
  nvgArcTo(gfx.nvgContext, p0.x, p0.y, p1.x, p1.y, radius)

proc closePath*(gfx: Gfx) =
  nvgClosePath(gfx.nvgContext)

proc `pathWinding=`*(gfx: Gfx, winding: PathWinding) =
  nvgPathWinding(gfx.nvgContext, winding.toNVGEnum)

proc arc*(gfx: Gfx, p: Vec2, r, a0, a1: float, winding: Winding) =
  nvgArc(gfx.nvgContext, p.x, p.y, r, a0, a1, winding.toNVGEnum)

proc rect*(gfx: Gfx, position, size: Vec2) =
  nvgRect(gfx.nvgContext, position.x, position.y, size.x, size.y)

proc roundedRect*(gfx: Gfx, position, size: Vec2, radius: float) =
  nvgRoundedRect(gfx.nvgContext, position.x, position.y, size.x, size.y, radius)

proc roundedRect*(gfx: Gfx, position, size: Vec2, radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) =
  nvgRoundedRectVarying(gfx.nvgContext,
                        position.x, position.y, size.x, size.y,
                        radTopLeft, radTopRight, radBottomRight, radBottomLeft)

proc ellipse*(gfx: Gfx, c, r: Vec2) =
  nvgEllipse(gfx.nvgContext, c.x, c.y, r.x, r.y)

proc circle*(gfx: Gfx, c: Vec2, r: float) =
  nvgCircle(gfx.nvgContext, c.x, c.y, r)

proc fill*(gfx: Gfx) =
  nvgFill(gfx.nvgContext)

proc stroke*(gfx: Gfx) =
  nvgStroke(gfx.nvgContext)

proc saveState*(gfx: Gfx) =
  nvgSave(gfx.nvgContext)

proc restoreState*(gfx: Gfx) =
  nvgRestore(gfx.nvgContext)

proc reset*(gfx: Gfx) =
  nvgReset(gfx.nvgContext)

proc `shapeAntiAlias=`*(gfx: Gfx, enabled: bool) =
  nvgShapeAntiAlias(gfx.nvgContext, enabled.cint)

proc `strokeColor=`*(gfx: Gfx, color: Color) =
  nvgStrokeColor(gfx.nvgContext, color.toNvgColor)

proc `strokePaint=`*(gfx: Gfx, paint: Paint) =
  nvgStrokePaint(gfx.nvgContext, paint)

proc `fillColor=`*(gfx: Gfx, color: Color) =
  nvgFillColor(gfx.nvgContext, color.toNvgColor)

proc `fillPaint=`*(gfx: Gfx, paint: Paint) =
  nvgFillPaint(gfx.nvgContext, paint)

proc `miterLimit=`*(gfx: Gfx, limit: float) =
  nvgMiterLimit(gfx.nvgContext, limit)

proc `strokeWidth=`*(gfx: Gfx, width: float) =
  nvgStrokeWidth(gfx.nvgContext, width)

proc `lineCap=`*(gfx: Gfx, cap: LineCap) =
  nvgLineCap(gfx.nvgContext, cap.toNVGEnum)

proc `lineJoin=`*(gfx: Gfx, join: LineJoin) =
  nvgLineJoin(gfx.nvgContext, join.toNVGEnum)

proc `globalAlpha=`*(gfx: Gfx, alpha: float) =
  nvgGlobalAlpha(gfx.nvgContext, alpha)

proc clip*(gfx: Gfx, position, size: Vec2, intersect = true) =
  if intersect:
    nvgIntersectScissor(gfx.nvgContext, position.x, position.y, size.x, size.y)
  else:
    nvgScissor(gfx.nvgContext, position.x, position.y, size.x, size.y)

proc resetClip*(gfx: Gfx) =
  nvgResetScissor(gfx.nvgContext)

proc addFont*(gfx: Gfx, name, data: string) =
  let font = nvgCreateFontMem(gfx.nvgContext, name.cstring, data.cstring, data.len.cint, 0)
  if font == -1:
    echo "Failed to load font: " & name

proc drawText*(gfx: Gfx, position: Vec2, text: openArray[char]): float32 {.discardable.} =
  nvgText(
    gfx.nvgContext,
    position.x, position.y,
    cast[cstring](text[0].unsafeAddr),
    cast[cstring](cast[uint64](text[text.len - 1].unsafeAddr) + 1),
  )

proc textMetrics*(gfx: Gfx): tuple[ascender, descender, lineHeight: float32] =
  nvgTextMetrics(gfx.nvgContext, result.ascender.addr, result.descender.addr, result.lineHeight.addr)

proc setTextAlign*(gfx: Gfx, x: TextAlignX, y: TextAlignY) =
  let nvgXValue = case x:
    of Left: NVG_ALIGN_LEFT
    of Center: NVG_ALIGN_CENTER
    of Right: NVG_ALIGN_RIGHT
  let nvgYValue = case y:
    of Top: NVG_ALIGN_TOP
    of Center: NVG_ALIGN_MIDDLE
    of Bottom: NVG_ALIGN_BOTTOM
    of Baseline: NVG_ALIGN_BASELINE
  nvgTextAlign(gfx.nvgContext, nvgXValue or nvgYValue)

proc `font=`*(gfx: Gfx, name: string) =
  nvgFontFace(gfx.nvgContext, name.cstring)

proc `fontSize=`*(gfx: Gfx, size: float) =
  nvgFontSize(gfx.nvgContext, size)

proc `letterSpacing=`*(gfx: Gfx, spacing: float) =
  nvgTextLetterSpacing(gfx.nvgContext, spacing)

proc linearGradient*(gfx: Gfx, startPosition, endPosition: Vec2, startColor, endColor: Color): Paint =
  nvgLinearGradient(gfx.nvgContext, startPosition.x, startPosition.y, endPosition.x, endPosition.y, startColor.toNvgColor, endColor.toNvgColor)

proc boxGradient*(gfx: Gfx, position, size: Vec2, cornerRadius, feather: float, innerColor, outerColor: Color): Paint =
  nvgBoxGradient(gfx.nvgContext, position.x, position.y, size.x, size.y, cornerRadius, feather, innerColor.toNvgColor, outerColor.toNvgColor)

proc radialGradient*(gfx: Gfx, center: Vec2, innerRadius, outerRadius: float, innerColor, outerColor: Color): Paint =
  nvgRadialGradient(gfx.nvgContext, center.x, center.y, innerRadius, outerRadius, innerColor.toNvgColor, outerColor.toNvgColor)

proc translate*(gfx: Gfx, amount: Vec2) =
  nvgTranslate(gfx.nvgContext, amount.x, amount.y)

{.pop.}

template width*(glyph: Glyph): auto = glyph.maxX - glyph.minX

proc getGlyphs*(gfx: Gfx, position: Vec2, text: openArray[char]): seq[Glyph] =
  if text.len == 0:
    return

  var nvgPositions = newSeq[NVGglyphPosition](text.len)
  discard nvgTextGlyphPositions(gfx.nvgContext, position.x, position.y, cast[cstring](text[0].unsafeAddr), nil, nvgPositions[0].addr, text.len.cint)
  for i in countdown(nvgPositions.len - 1, 0, 1):
    let glyph = nvgPositions[i]
    if glyph.str != nil:
      nvgPositions.setLen(i + 1)
      break

  result.setLen(nvgPositions.len)
  for i, nvgPosition in nvgPositions:
    result[i].index = cast[uint64](nvgPosition.str) - cast[uint64](text[0].unsafeAddr)
    result[i].x = nvgPosition.x
    result[i].minX = nvgPosition.minx
    result[i].maxX = nvgPosition.maxx