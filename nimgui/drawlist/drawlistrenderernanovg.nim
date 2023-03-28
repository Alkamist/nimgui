{.experimental: "overloadableEnums".}

import opengl
import ./nanovg
import ./drawlist

proc gladLoadGL(): int {.cdecl, importc.}
var gladIsInitialized {.threadvar.}: bool

# proc toNVGEnum(winding: Winding): cint =
#   case winding:
#   of CounterClockwise: NVG_CCW
#   of Clockwise: NVG_CW

proc toNVGEnum(winding: PathWinding): cint =
  case winding:
  of CounterClockwise: NVG_CCW
  of Clockwise: NVG_CW
  of Solid: NVG_SOLID
  of Hole: NVG_HOLE

# proc toNVGEnum(cap: LineCap): cint =
#   case cap:
#   of Butt: NVG_BUTT
#   of Round: NVG_ROUND
#   of Square: NVG_SQUARE

# proc toNVGEnum(join: LineJoin): cint =
#   case join:
#   of Round: NVG_ROUND
#   of Bevel: NVG_BEVEL
#   of Miter: NVG_MITER

proc toNvgColor(color: Color): NVGcolor =
  nvgRGBAf(color.r, color.g, color.b, color.a)

type
  DrawListRenderer* = ref object
    nvgContext: NVGcontext

proc `=destroy`*(renderer: var type DrawListRenderer()[]) =
  nvgDeleteGL3(renderer.nvgContext)

proc newDrawListRenderer*(): DrawListRenderer =
  if not gladIsInitialized:
    if gladLoadGL() <= 0:
      quit "Failed to initialise glad."
    gladIsInitialized = true
  result = DrawListRenderer(
    nvgContext: nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES),
  )

proc beginFrame*(renderer: DrawListRenderer, sizePixels: Vec2, pixelDensity: float) =
  nvgBeginFrame(renderer.nvgContext, sizePixels.x / pixelDensity, sizePixels.y / pixelDensity, pixelDensity)
  nvgResetScissor(renderer.nvgContext)

proc endFrame*(renderer: DrawListRenderer, sizePixels: Vec2) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)
  glViewport(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
  glScissor(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
  glClear(GL_STENCIL_BUFFER_BIT)
  nvgEndFrame(renderer.nvgContext)

proc render*(renderer: DrawListRenderer, drawList: DrawList) =
  let ctx = renderer.nvgContext
  for command in drawList.commands:
    case command.kind:
    of BeginPath: nvgBeginPath(ctx)
    of ClosePath: nvgClosePath(ctx)
    of Fill: nvgFill(ctx)
    of ResetClip: nvgResetScissor(ctx)
    of ResetTransform: nvgResetTransform(ctx)
    of Translate:
      let c = command.translate
      nvgTranslate(ctx, c.distance.x, c.distance.y)
    of Rect:
      let c = command.rect
      nvgRect(ctx, c.rect.x, c.rect.y, c.rect.width, c.rect.height)
    of RoundedRect:
      let c = command.roundedRect
      nvgRoundedRectVarying(
        ctx,
        c.rect.x, c.rect.y, c.rect.width, c.rect.height,
        c.topLeftRadius, c.topRightRadius, c.bottomRightRadius, c.bottomLeftRadius,
      )
    of SetFillColor:
      let c = command.setFillColor
      nvgFillColor(ctx, c.color.toNvgColor)
    of SetPathWinding:
      let c = command.setPathWinding
      nvgPathWinding(ctx, c.winding.toNVGEnum)
    of Clip:
      let c = command.clip
      if c.intersect:
        nvgIntersectScissor(ctx, c.rect.x, c.rect.y, c.rect.width, c.rect.height)
      else:
        nvgScissor(ctx, c.rect.x, c.rect.y, c.rect.width, c.rect.height)