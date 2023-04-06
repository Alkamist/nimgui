import std/strutils
import std/strformat

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

const nanovgDir = currentSourceDir() & "/nanovg"

type
  NVGcontext* {.bycopy.} = ptr object

  NVGcolor* {.bycopy.} = object
    r*, g*, b*, a*: cfloat

  NVGglyphPosition* {.bycopy.} = object
    str*: cstring
    x*: cfloat
    minx*, maxx*: cfloat

  NVGtextRow* {.bycopy.} = object
    start*: cstring
    `end`*: cstring
    next*: cstring
    width*: cfloat
    minx*, maxx*: cfloat

  NVGpaint* {.bycopy.} = object
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

{.push importc, cdecl.}

proc nvgCreateGLES2*(flags: cint): NVGcontext
proc nvgDeleteGLES2*(ctx: NVGcontext)
proc nvgCreateGL3*(flags: cint): NVGcontext
proc nvgDeleteGL3*(ctx: NVGcontext)
proc nvgBeginFrame*(ctx: NVGcontext, windowWidth, windowHeight, devicePixelRatio: cfloat)
proc nvgCancelFrame*(ctx: NVGcontext)
proc nvgEndFrame*(ctx: NVGcontext)
proc nvgGlobalCompositeOperation*(ctx: NVGcontext, op: cint)
proc nvgGlobalCompositeBlendFunc*(ctx: NVGcontext, sfactor, dfactor: cint)
proc nvgGlobalCompositeBlendFuncSeparate*(ctx: NVGcontext, srcRGB, dstRGB, srcAlpha, dstAlpha: cint)
proc nvgRGB*(r, g, b: uint8): NVGcolor
proc nvgRGBf*(r, g, b: cfloat): NVGcolor
proc nvgRGBA*(r, g, b, a: uint8): NVGcolor
proc nvgRGBAf*(r, g, b, a: cfloat): NVGcolor
proc nvgLerpRGBA*(c0, c1: NVGcolor, u: cfloat): NVGcolor
proc nvgTransRGBA*(c0: NVGcolor, a: uint8): NVGcolor
proc nvgTransRGBAf*(c0: NVGcolor, a: cfloat): NVGcolor
proc nvgHSL*(h, s, l: cfloat): NVGcolor
proc nvgHSLA*(h, s, l: cfloat, a: uint8): NVGcolor
proc nvgBeginPath*(ctx: NVGcontext)
proc nvgMoveTo*(ctx: NVGcontext, x, y: cfloat)
proc nvgLineTo*(ctx: NVGcontext, x, y: cfloat)
proc nvgBezierTo*(ctx: NVGcontext, c1x, c1y, c2x, c2y, x, y: cfloat)
proc nvgQuadTo*(ctx: NVGcontext, cx, cy, x, y: cfloat)
proc nvgArcTo*(ctx: NVGcontext, x1, y1, x2, y2, radius: cfloat)
proc nvgClosePath*(ctx: NVGcontext)
proc nvgPathWinding*(ctx: NVGcontext, dir: cint)
proc nvgArc*(ctx: NVGcontext, cx, cy, r, a0, a1: cfloat, dir: cint)
proc nvgRect*(ctx: NVGcontext, x, y, w, h: cfloat)
proc nvgRoundedRect*(ctx: NVGcontext, x, y, w, h, r: cfloat)
proc nvgRoundedRectVarying*(ctx: NVGcontext, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: cfloat)
proc nvgEllipse*(ctx: NVGcontext, cx, cy, rx, ry: cfloat)
proc nvgCircle*(ctx: NVGcontext, cx, cy, r: cfloat)
proc nvgFill*(ctx: NVGcontext)
proc nvgStroke*(ctx: NVGcontext)
proc nvgSave*(ctx: NVGcontext)
proc nvgRestore*(ctx: NVGcontext)
proc nvgReset*(ctx: NVGcontext)
proc nvgShapeAntiAlias*(ctx: NVGcontext, enabled: cint)
proc nvgStrokeColor*(ctx: NVGcontext, color: NVGcolor)
proc nvgStrokePaint*(ctx: NVGcontext, paint: NVGpaint)
proc nvgFillColor*(ctx: NVGcontext, color: NVGcolor)
proc nvgFillPaint*(ctx: NVGcontext, paint: NVGpaint)
proc nvgMiterLimit*(ctx: NVGcontext, limit: cfloat)
proc nvgStrokeWidth*(ctx: NVGcontext, size: cfloat)
proc nvgLineCap*(ctx: NVGcontext, cap: cint)
proc nvgLineJoin*(ctx: NVGcontext, join: cint)
proc nvgGlobalAlpha*(ctx: NVGcontext, alpha: cfloat)
proc nvgResetTransform*(ctx: NVGcontext)
proc nvgTransform*(ctx: NVGcontext, a, b, c, d, e, f: cfloat)
proc nvgTranslate*(ctx: NVGcontext, x, y: cfloat)
proc nvgRotate*(ctx: NVGcontext, angle: cfloat)
proc nvgSkewX*(ctx: NVGcontext, angle: cfloat)
proc nvgSkewY*(ctx: NVGcontext, angle: cfloat)
proc nvgScale*(ctx: NVGcontext, x, y: cfloat)
proc nvgCurrentTransform*(ctx: NVGcontext, xform: ptr cfloat)
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
proc nvgCreateImage*(ctx: NVGcontext, filename: cstring, imageFlags: cint): cint
proc nvgCreateImageMem*(ctx: NVGcontext, imageFlags: cint, data: cstring, ndata: cint): cint
proc nvgCreateImageRGBA*(ctx: NVGcontext, w, h, imageFlags: cint, data: cstring): cint
proc nvgUpdateImage*(ctx: NVGcontext, image: cint, data: cstring)
proc nvgImageSize*(ctx: NVGcontext, image: cint, w, h: ptr cint)
proc nvgDeleteImage*(ctx: NVGcontext, image: cint)
proc nvgLinearGradient*(ctx: NVGcontext, sx, sy, ex, ey: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgBoxGradient*(ctx: NVGcontext, x, y, w, h, r, f: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgRadialGradient*(ctx: NVGcontext, cx, cy, inr, outr: cfloat, icol, ocol: NVGcolor): NVGpaint
proc nvgImagePattern*(ctx: NVGcontext, ox, oy, ex, ey, angle: cfloat, image: cint, alpha: cfloat): NVGpaint
proc nvgScissor*(ctx: NVGcontext, x, y, w, h: cfloat)
proc nvgIntersectScissor*(ctx: NVGcontext, x, y, w, h: cfloat)
proc nvgResetScissor*(ctx: NVGcontext)
proc nvgCreateFont*(ctx: NVGcontext, name, filename: cstring): cint
proc nvgCreateFontAtIndex*(ctx: NVGcontext, name, filename: cstring, fontIndex: cint): cint
proc nvgCreateFontMem*(ctx: NVGcontext, name, data: cstring, ndata, freeData: cint): cint
proc nvgCreateFontMemAtIndex*(ctx: NVGcontext, name, data: cstring, ndata, freeData: cint, fontIndex: cint): cint
proc nvgFindFont*(ctx: NVGcontext, name: cstring): cint
proc nvgAddFallbackFontId*(ctx: NVGcontext, baseFont, fallbackFont: cint): cint
proc nvgAddFallbackFont*(ctx: NVGcontext, baseFont, fallbackFont: cstring): cint
proc nvgResetFallbackFontsId*(ctx: NVGcontext, baseFont: cint)
proc nvgResetFallbackFonts*(ctx: NVGcontext, baseFont: cint)
proc nvgFontSize*(ctx: NVGcontext, size: cfloat)
proc nvgFontBlur*(ctx: NVGcontext, blur: cfloat)
proc nvgTextLetterSpacing*(ctx: NVGcontext, spacing: cfloat)
proc nvgTextLineHeight*(ctx: NVGcontext, lineHeight: cfloat)
proc nvgTextAlign*(ctx: NVGcontext, align: cint)
proc nvgFontFaceId*(ctx: NVGcontext, font: cint)
proc nvgFontFace*(ctx: NVGcontext, font: cstring)
proc nvgText*(ctx: NVGcontext, x, y: cfloat, `string`, `end`: cstring): cfloat
proc nvgTextBox*(ctx: NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring)
proc nvgTextBounds*(ctx: NVGcontext, x, y: cfloat, `string`, `end`: cstring, bounds: ptr cfloat): cfloat
proc nvgTextBoxBounds*(ctx: NVGcontext, x, y, breakRowWidth: cfloat, `string`, `end`: cstring, bounds: ptr cfloat)
proc nvgTextGlyphPositions*(ctx: NVGcontext, x, y: cfloat, `string`, `end`: cstring, positions: ptr NVGglyphPosition, maxPositions: cint): cint
proc nvgTextMetrics*(ctx: NVGcontext, ascender, descender, lineh: ptr cfloat)
proc nvgTextBreakLines*(ctx: NVGcontext, `string`, `end`: cstring, breakRowWidth: cfloat, rows: ptr NVGtextRow, maxRows: cint): cint

{.pop.}

{.passC: &" -I{nanovgDir}".}

when defined(emscripten):
  {.passC: "-DNANOVG_GLES2_IMPLEMENTATION".}
else:
  {.passC: "-DNANOVG_GL3_IMPLEMENTATION".}
  {.compile: &"{nanovgDir}/glad.c".}
  proc gladLoadGL*(): int {.importc, cdecl.}
  var gladIsInitialized* {.threadvar.}: bool

{.compile: &"{nanovgDir}/nanovg.c".}
{.compile: &"{nanovgDir}/nanovg_gl.c".}
{.compile: &"{nanovgDir}/nanovg_gl_utils.c".}

proc nvgDelete*(ctx: NVGcontext) =
  when defined(emscripten):
    nvgDeleteGLES2(ctx)
  else:
    nvgDeleteGL3(ctx)

proc nvgCreate*(flags: cint): NVGcontext =
  when defined(emscripten):
    nvgCreateGLES2(flags)
  else:
    if not gladIsInitialized:
      if gladLoadGL() <= 0:
        quit "Failed to initialise glad."
      gladIsInitialized = true
    nvgCreateGL3(flags)