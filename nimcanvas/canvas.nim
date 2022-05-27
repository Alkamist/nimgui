when defined(windows):
  import ./canvas/win32; export win32

import opengl
import ./nanovg/nanovg

proc toNvgColor(color: Color): NVGcolor = nvgRGBAf(color.r, color.g, color.b, color.a)

type
  Winding* = enum
    CounterClockwise = NVG_CCW
    Clockwise = NVG_CW

{.push inline.}

proc `backgroundColor=`*(canvas: Canvas, color: Color) =
  canvas.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)

proc beginPath*(canvas: Canvas) =
  nvgBeginPath(canvas.nvgContext)

proc moveTo*(canvas: Canvas, p: Vec2) =
  nvgMoveTo(canvas.nvgContext, p.x, p.y)

proc lineTo*(canvas: Canvas, p: Vec2) =
  nvgLineTo(canvas.nvgContext, p.x, p.y)

proc bezierTo*(canvas: Canvas, c0, c1, p: Vec2) =
  nvgBezierTo(canvas.nvgContext, c0.x, c0.y, c1.x, c1.y, p.x, p.y)

proc quadTo*(canvas: Canvas, c, p: Vec2) =
  nvgQuadTo(canvas.nvgContext, c.x, c.y, p.x, p.y)

proc arcTo*(canvas: Canvas, p0, p1: Vec2, radius: float) =
  nvgArcTo(canvas.nvgContext, p0.x, p0.y, p1.x, p1.y, radius)

proc closePath*(canvas: Canvas) =
  nvgClosePath(canvas.nvgContext)

proc `pathWinding=`*(canvas: Canvas, winding: Winding) =
  nvgPathWinding(canvas.nvgContext, winding.cint)

proc arc*(canvas: Canvas, p: Vec2, r, a0, a1: float, winding: Winding) =
  nvgArc(canvas.nvgContext, p.x, p.y, r, a0, a1, winding.cint)

proc rect*(canvas: Canvas, rect: Rect2) =
  nvgRect(canvas.nvgContext, rect.position.x, rect.position.y, rect.size.x, rect.size.y)

proc roundedRect*(canvas: Canvas, rect: Rect2, radius: float) =
  nvgRoundedRect(canvas.nvgContext, rect.position.x, rect.position.y, rect.size.x, rect.size.y, radius)

proc roundedRect*(canvas: Canvas, rect: Rect2,
                      radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) =
  nvgRoundedRectVarying(canvas.nvgContext,
                        rect.position.x, rect.position.y, rect.size.x, rect.size.y,
                        radTopLeft, radTopRight, radBottomRight, radBottomLeft)

proc ellipse*(canvas: Canvas, c, r: Vec2) =
  nvgEllipse(canvas.nvgContext, c.x, c.y, r.x, r.y)

proc circle*(canvas: Canvas, c: Vec2, r: float) =
  nvgCircle(canvas.nvgContext, c.x, c.y, r)

proc fill*(canvas: Canvas) =
  nvgFill(canvas.nvgContext)

proc stroke*(canvas: Canvas) =
  nvgStroke(canvas.nvgContext)

proc save*(canvas: Canvas) =
  nvgSave(canvas.nvgContext)

proc restore*(canvas: Canvas) =
  nvgRestore(canvas.nvgContext)

proc reset*(canvas: Canvas) =
  nvgReset(canvas.nvgContext)

proc `shapeAntiAlias=`*(canvas: Canvas, enabled: bool) =
  nvgShapeAntiAlias(canvas.nvgContext, enabled.cint)

proc `strokeColor=`*(canvas: Canvas, color: Color) =
  nvgStrokeColor(canvas.nvgContext, color.toNvgColor)

proc `fillColor=`*(canvas: Canvas, color: Color) =
  nvgFillColor(canvas.nvgContext, color.toNvgColor)

{.pop.}

# proc nvgStrokeColor*(canvas: NVGcontext, color: NVGcolor)
# proc nvgStrokePaint*(canvas: NVGcontext, paint: NVGpaint)
# proc nvgFillColor*(canvas: NVGcontext, color: NVGcolor)
# proc nvgFillPaint*(canvas: NVGcontext, paint: NVGpaint)
# proc nvgMiterLimit*(canvas: NVGcontext, limit: cfloat)
# proc nvgStrokeWidth*(canvas: NVGcontext, size: cfloat)
# proc nvgLineCap*(canvas: NVGcontext, cap: cint)
# proc nvgLineJoin*(canvas: NVGcontext, join: cint)
# proc nvgGlobalAlpha*(canvas: NVGcontext, alpha: cfloat)






# proc nvgResetTransform*(canvas: NVGcontext)
# proc nvgTransform*(canvas: NVGcontext, a, b, c, d, e, f: cfloat)
# proc nvgTranslate*(canvas: NVGcontext, x, y: cfloat)
# proc nvgRotate*(canvas: NVGcontext, angle: cfloat)
# proc nvgSkewX*(canvas: NVGcontext, angle: cfloat)
# proc nvgSkewY*(canvas: NVGcontext, angle: cfloat)
# proc nvgScale*(canvas: NVGcontext, x, y: cfloat)
# proc nvgCurrentTransform*(canvas: NVGcontext, xform: ptr cfloat)
# proc nvgTransformIdentity*(dst: ptr cfloat)
# proc nvgTransformTranslate*(dst: ptr cfloat, tx, ty: cfloat)
# proc nvgTransformScale*(dst: ptr cfloat, sx, sy: cfloat)
# proc nvgTransformRotate*(dst: ptr cfloat, a: cfloat)
# proc nvgTransformSkewX*(dst: ptr cfloat, a: cfloat)
# proc nvgTransformSkewY*(dst: ptr cfloat, a: cfloat)
# proc nvgTransformMultiply*(dst, src: ptr cfloat)
# proc nvgTransformPremultiply*(dst, src: ptr cfloat)
# proc nvgTransformInverse*(dst, src: ptr cfloat): cint
# proc nvgTransformPoint*(dstx, dsty, xform: ptr cfloat, srcx, srcy: cfloat)
# proc nvgDegToRad*(deg: cfloat): cfloat
# proc nvgRadToDeg*(rad: cfloat): cfloat
# proc nvgCreateImage*(canvas: NVGcontext, filename: cstring, imageFlags: cint): cint
# proc nvgCreateImageMem*(canvas: NVGcontext, imageFlags: cint, data: cstring, ndata: cint): cint
# proc nvgCreateImageRGBA*(canvas: NVGcontext, w, h, imageFlags: cint, data: cstring): cint
# proc nvgUpdateImage*(canvas: NVGcontext, image: cint, data: cstring)
# proc nvgImageSize*(canvas: NVGcontext, image: cint, w, h: ptr cint)
# proc nvgDeleteImage*(canvas: NVGcontext, image: cint)
# proc nvgLinearGradient*(canvas: NVGcontext, sx, sy, ex, ey: cfloat, icol, ocol: NVGcolor): NVGpaint
# proc nvgBoxGradient*(canvas: NVGcontext, x, y, w, h, r, f: cfloat, icol, ocol: NVGcolor): NVGpaint
# proc nvgRadialGradient*(canvas: NVGcontext, cx, cy, inr, outr: cfloat, icol, ocol: NVGcolor): NVGpaint
# proc nvgImagePattern*(canvas: NVGcontext, ox, oy, ex, ey, angle: cfloat, image: cint, alpha: cfloat): NVGpaint
# proc nvgScissor*(canvas: NVGcontext, x, y, w, h: cfloat)
# proc nvgIntersectScissor*(canvas: NVGcontext, x, y, w, h: cfloat)
# proc nvgResetScissor*(canvas: NVGcontext)
# proc nvgCreateFont*(canvas: NVGcontext, name, filename: cstring): cint
# proc nvgCreateFontAtIndex*(canvas: NVGcontext, name, filename: cstring, fontIndex: cint): cint
# proc nvgCreateFontMem*(canvas: NVGcontext, name, data: cstring, ndata, freeData: cint): cint
# proc nvgCreateFontMemAtIndex*(canvas: NVGcontext, name, data: cstring, ndata, freeData: cint, fontIndex: cint): cint
# proc nvgFindFont*(canvas: NVGcontext, name: cstring): cint
# proc nvgAddFallbackFontId*(canvas: NVGcontext, baseFont, fallbackFont: cint): cint
# proc nvgAddFallbackFont*(canvas: NVGcontext, baseFont, fallbackFont: cstring): cint
# proc nvgResetFallbackFontsId*(canvas: NVGcontext, baseFont: cint)
# proc nvgResetFallbackFonts*(canvas: NVGcontext, baseFont: cint)
# proc nvgFontSize*(canvas: NVGcontext, size: cfloat)
# proc nvgFontBlur*(canvas: NVGcontext, blur: cfloat)
# proc nvgTextLetterSpacing*(canvas: NVGcontext, spacing: cfloat)
# proc nvgTextLineHeight*(canvas: NVGcontext, lineHeight: cfloat)
# proc nvgTextAlign*(canvas: NVGcontext, align: cint)
# proc nvgFontFaceId*(canvas: NVGcontext, font: cint)
# proc nvgFontFace*(canvas: NVGcontext, font: cstring)
# proc nvgText*(canvas: NVGcontext, x, y: cfloat, `string`, `end`: cstring): cfloat
# proc nvgTextBox*(canvas: NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring)
# proc nvgTextBounds*(canvas: NVGcontext, x, y: cfloat, `string`, `end`: cstring, bounds: ptr cfloat): cfloat
# proc nvgTextBoxBounds*(canvas: NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring, bounds: ptr cfloat)
# proc nvgTextGlyphPositions*(canvas: NVGcontext, x, y: cfloat, `string`, `end`: cstring, positions: ptr NVGglyphPosition, maxPositions: cint): cint
# proc nvgTextMetrics*(canvas: NVGcontext, ascender, descender, lineh: ptr cfloat)
# proc nvgTextBreakLines*(canvas: NVGcontext, `string`, `end`: cstring, breakRowWidth: cfloat, rows: ptr NVGtextRow, maxRows: cint): cint
