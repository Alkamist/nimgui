import std/strutils

{.compile: "glad.c".}
{.compile: "nanovg.c".}

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

const nanovgHeader = currentSourceDir() & "/nanovg_include.h"

type
  NVGcontext* {.importc, header: nanovgHeader.} = object

  NVGcolor* {.union, importc, header: nanovgHeader.} = object
    rgba*: array[4, cfloat]
    r*, g*, b*, a*: cfloat

  NVGcompositeOperationState* {.importc, header: nanovgHeader.} = object
    srcRGB*: cint
    dstRGB*: cint
    srcAlpha*: cint
    dstAlpha*: cint

  NVGglyphPosition* {.importc, header: nanovgHeader.} = object
    str*: cstring
    x*: cfloat
    minx*, maxx*: cfloat

  NVGtextRow* {.importc, header: nanovgHeader.} = object
    start*: cstring
    `end`*: cstring
    next*: cstring
    width*: cfloat
    minx*, maxx*: cfloat

  NVGpaint* {.importc, header: nanovgHeader.} = object
    xform*: array[6, cfloat]
    extent*: array[2, cfloat]
    radius*: cfloat
    feather*: cfloat
    innerColor*: NVGcolor
    outerColor*: NVGcolor
    image*: cint

const NVG_ANTIALIAS* = 1 shl 0
const NVG_STENCIL_STROKES* = 1 shl 1
const NVG_DEBUG* = 1 shl 2
const NVG_CCW* = 1
const NVG_CW* = 2
const NVG_SOLID* = 1
const NVG_HOLE* = 2
const NVG_BUTT* = 0
const NVG_ROUND* = 1
const NVG_SQUARE* = 2
const NVG_BEVEL* = 3
const NVG_MITER* = 4
const NVG_ALIGN_LEFT* = 1 shl 0
const NVG_ALIGN_CENTER* = 1 shl 1
const NVG_ALIGN_RIGHT* = 1 shl 2
const NVG_ALIGN_TOP* = 1 shl 3
const NVG_ALIGN_MIDDLE* = 1 shl 4
const NVG_ALIGN_BOTTOM* = 1 shl 5
const NVG_ALIGN_BASELINE* = 1 shl 6
const NVG_ZERO* = 1 shl 0
const NVG_ONE* = 1 shl 1
const NVG_SRC_COLOR* = 1 shl 2
const NVG_ONE_MINUS_SRC_COLOR* = 1 shl 3
const NVG_DST_COLOR* = 1 shl 4
const NVG_ONE_MINUS_DST_COLOR* = 1 shl 5
const NVG_SRC_ALPHA* = 1 shl 6
const NVG_ONE_MINUS_SRC_ALPHA* = 1 shl 7
const NVG_DST_ALPHA* = 1 shl 8
const NVG_ONE_MINUS_DST_ALPHA* = 1 shl 9
const NVG_SRC_ALPHA_SATURATE* = 1 shl 10
const NVG_SOURCE_OVER* = 0
const NVG_SOURCE_IN* = 1
const NVG_SOURCE_OUT* = 2
const NVG_ATOP* = 3
const NVG_DESTINATION_OVER* = 4
const NVG_DESTINATION_IN* = 5
const NVG_DESTINATION_OUT* = 6
const NVG_DESTINATION_ATOP* = 7
const NVG_LIGHTER* = 8
const NVG_COPY* = 9
const NVG_XOR* = 10
const NVG_IMAGE_GENERATE_MIPMAPS* = 1 shl 0
const NVG_IMAGE_REPEATX* = 1 shl 1
const NVG_IMAGE_REPEATY* = 1 shl 2
const NVG_IMAGE_FLIPY* = 1 shl 3
const NVG_IMAGE_PREMULTIPLIED* = 1 shl 4
const NVG_IMAGE_NEAREST* = 1 shl 5

proc gladLoadGLLoader(a: pointer): int {.cdecl, importc.}

var gladInitialized = false
proc nvgInit*(getProcAddress: pointer) =
  if not gladInitialized:
    if gladLoadGLLoader(getProcAddress) > 0:
      gladInitialized = true

  if not gladInitialized:
    quit "Failed to initialise NanoVG."

{.push importc, header: nanovgHeader.}

proc nvgCreateGL3*(flags: cint): ptr NVGcontext
proc nvgBeginFrame*(ctx: ptr NVGcontext, windowWidth, windowHeight, devicePixelRatio: cfloat)
proc nvgCancelFrame*(ctx: ptr NVGcontext)
proc nvgEndFrame*(ctx: ptr NVGcontext)
proc nvgGlobalCompositeOperation*(ctx: ptr NVGcontext, op: cint)
proc nvgGlobalCompositeBlendFunc*(ctx: ptr NVGcontext, sfactor, dfactor: cint)
proc nvgGlobalCompositeBlendFuncSeparate*(ctx: ptr NVGcontext, srcRGB, dstRGB, srcAlpha, dstAlpha: cint)
proc nvgRGB*(r, g, b: uint8): NVGcolor
proc nvgRGBf*(r, g, b: cfloat): NVGcolor
proc nvgRGBA*(r, g, b, a: uint8): NVGcolor
proc nvgRGBAf*(r, g, b, a: cfloat): NVGcolor
proc nvgLerpRGBA*(c0, c1: NVGcolor, u: cfloat): NVGcolor
proc nvgTransRGBA*(c0: NVGcolor, a: uint8): NVGcolor
proc nvgTransRGBAf*(c0: NVGcolor, a: cfloat): NVGcolor
proc nvgHSL*(h, s, l: cfloat): NVGcolor
proc nvgHSLA*(h, s, l: cfloat, a: uint8): NVGcolor
proc nvgBeginPath*(ctx: ptr NVGcontext)
proc nvgMoveTo*(ctx: ptr NVGcontext, x, y: cfloat)
proc nvgLineTo*(ctx: ptr NVGcontext, x, y: cfloat)
proc nvgBezierTo*(ctx: ptr NVGcontext, c1x, c1y, c2x, c2y, x, y: cfloat)
proc nvgQuadTo*(ctx: ptr NVGcontext, cx, cy, x, y: cfloat)
proc nvgArcTo*(ctx: ptr NVGcontext, x1, y1, x2, y2, radius: cfloat)
proc nvgClosePath*(ctx: ptr NVGcontext)
proc nvgPathWinding*(ctx: ptr NVGcontext, dir: cint)
proc nvgArc*(ctx: ptr NVGcontext, cx, cy, r, a0, a1: cfloat, dir: cint)
proc nvgRect*(ctx: ptr NVGcontext, x, y, w, h: cfloat)
proc nvgRoundedRect*(ctx: ptr NVGcontext, x, y, w, h, r: cfloat)
proc nvgRoundedRectVarying*(ctx: ptr NVGcontext, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: cfloat)
proc nvgEllipse*(ctx: ptr NVGcontext, cx, cy, rx, ry: cfloat)
proc nvgCircle*(ctx: ptr NVGcontext, cx, cy, r: cfloat)
proc nvgFill*(ctx: ptr NVGcontext)
proc nvgStroke*(ctx: ptr NVGcontext)
proc nvgSave*(ctx: ptr NVGcontext)
proc nvgRestore*(ctx: ptr NVGcontext)
proc nvgReset*(ctx: ptr NVGcontext)
proc nvgShapeAntiAlias*(ctx: ptr NVGcontext, enabled: cint)
proc nvgStrokeColor*(ctx: ptr NVGcontext, color: NVGcolor)
proc nvgStrokePaint*(ctx: ptr NVGcontext, paint: NVGpaint)
proc nvgFillColor*(ctx: ptr NVGcontext, color: NVGcolor)
proc nvgFillPaint*(ctx: ptr NVGcontext, paint: NVGpaint)
proc nvgMiterLimit*(ctx: ptr NVGcontext, limit: cfloat)
proc nvgStrokeWidth*(ctx: ptr NVGcontext, size: cfloat)
proc nvgLineCap*(ctx: ptr NVGcontext, cap: cint)
proc nvgLineJoin*(ctx: ptr NVGcontext, join: cint)
proc nvgGlobalAlpha*(ctx: ptr NVGcontext, alpha: cfloat)
proc nvgResetTransform*(ctx: ptr NVGcontext)
proc nvgTransform*(ctx: ptr NVGcontext, a, b, c, d, e, f: cfloat)
proc nvgTranslate*(ctx: ptr NVGcontext, x, y: cfloat)
proc nvgRotate*(ctx: ptr NVGcontext, angle: cfloat)
proc nvgSkewX*(ctx: ptr NVGcontext, angle: cfloat)
proc nvgSkewY*(ctx: ptr NVGcontext, angle: cfloat)
proc nvgScale*(ctx: ptr NVGcontext, x, y: cfloat)
proc nvgCurrentTransform*(ctx: ptr NVGcontext, xform: ptr cfloat)
proc nvgTransformIdentity*(dst: ptr cfloat)
proc nvgTransformTranslate*(dst: ptr cfloat, tx, ty: cfloat)
proc nvgTransformScale*(dst: ptr cfloat, sx, sy: cfloat)
proc nvgTransformRotate*(dst: ptr cfloat, a: cfloat)
proc nvgTransformSkewX*(dst: ptr cfloat, a: cfloat)
proc nvgTransformSkewY*(dst: ptr cfloat, a: cfloat)
proc nvgTransformMultiply*(dst, src: ptr cfloat)
proc nvgTransformPremultiply*(dst, src: ptr cfloat)
proc nvgTransformInverse*(dst, src: ptr cfloat): cint
proc nvgTransformPoint*(dstx, dsty, xform: ptr cfloat, srcx, srcy: cfloat)
proc nvgDegToRad*(deg: cfloat): cfloat
proc nvgRadToDeg*(rad: cfloat): cfloat
proc nvgCreateImage*(ctx: ptr NVGcontext, filename: cstring, imageFlags: cint): cint
proc nvgCreateImageMem*(ctx: ptr NVGcontext, imageFlags: cint, data: cstring, ndata: cint): cint
proc nvgCreateImageRGBA*(ctx: ptr NVGcontext, w, h, imageFlags: cint, data: cstring): cint
proc nvgUpdateImage*(ctx: ptr NVGcontext, image: cint, data: cstring)
proc nvgImageSize*(ctx: ptr NVGcontext, image: cint, w, h: ptr cint)
proc nvgDeleteImage*(ctx: ptr NVGcontext, image: cint)
proc nvgLinearGradient*(ctx: ptr NVGcontext, sx, sy, ex, ey: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgBoxGradient*(ctx: ptr NVGcontext, x, y, w, h, r, f: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgRadialGradient*(ctx: ptr NVGcontext, cx, cy, inr, outr: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgImagePattern*(ctx: ptr NVGcontext, ox, oy, ex, ey, angle: cfloat, image: cint, alpha: cfloat): NVGpaint
proc nvgScissor*(ctx: ptr NVGcontext, x, y, w, h: cfloat)
proc nvgIntersectScissor*(ctx: ptr NVGcontext, x, y, w, h: cfloat)
proc nvgResetScissor*(ctx: ptr NVGcontext)
proc nvgCreateFont*(ctx: ptr NVGcontext, name, filename: cstring): cint
proc nvgCreateFontAtIndex*(ctx: ptr NVGcontext, name, filename: cstring, fontIndex: cint): cint
proc nvgCreateFontMem*(ctx: ptr NVGcontext, name, data: cstring, ndata, freeData: cint): cint
proc nvgCreateFontMemAtIndex*(ctx: ptr NVGcontext, name, data: cstring, ndata, freeData: cint, fontIndex: cint): cint
proc nvgFindFont*(ctx: ptr NVGcontext, name: cstring): cint
proc nvgAddFallbackFontId*(ctx: ptr NVGcontext, baseFont, fallbackFont: cint): cint
proc nvgAddFallbackFont*(ctx: ptr NVGcontext, baseFont, fallbackFont: cstring): cint
proc nvgResetFallbackFontsId*(ctx: ptr NVGcontext, baseFont: cint)
proc nvgResetFallbackFonts*(ctx: ptr NVGcontext, baseFont: cint)
proc nvgFontSize*(ctx: ptr NVGcontext, size: cfloat)
proc nvgFontBlur*(ctx: ptr NVGcontext, blur: cfloat)
proc nvgTextLetterSpacing*(ctx: ptr NVGcontext, spacing: cfloat)
proc nvgTextLineHeight*(ctx: ptr NVGcontext, lineHeight: cfloat)
proc nvgTextAlign*(ctx: ptr NVGcontext, align: cint)
proc nvgFontFaceId*(ctx: ptr NVGcontext, font: cint)
proc nvgFontFace*(ctx: ptr NVGcontext, font: cstring)
proc nvgText*(ctx: ptr NVGcontext, x, y: cfloat, `string`, `end`: cstring): cfloat
proc nvgTextBox*(ctx: ptr NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring)
proc nvgTextBounds*(ctx: ptr NVGcontext, x, y: cfloat, `string`, `end`: cstring, bounds: ptr cfloat): cfloat
proc nvgTextBoxBounds*(ctx: ptr NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring, bounds: ptr cfloat)
proc nvgTextGlyphPositions*(ctx: ptr NVGcontext, x, y: cfloat, `string`, `end`: cstring, positions: ptr NVGglyphPosition, maxPositions: cint): cint
proc nvgTextMetrics*(ctx: ptr NVGcontext, ascender, descender, lineh: ptr cfloat)
proc nvgTextBreakLines*(ctx: ptr NVGcontext, `string`, `end`: cstring, breakRowWidth: cfloat, rows: ptr NVGtextRow, maxRows: cint): cint