import ./gmath
import ./window
import ./renderer/rlgl
import ./renderer/openglcontext

export rlgl

type
  Renderer* = ref object
    window*: Window
    onRender*: proc()
    openGlContext: OpenGlContext

proc newRenderer*(window: Window): Renderer =
  result = Renderer()
  result.window = window
  result.openGlContext = initOpenGlContext(window.platform.handle)
  result.openGlContext.select()
  rlLoadExtensions(result.openGlContext.getProcAddress)
  rlglInit(window.width.cint, window.height.cint)

proc render*(renderer: Renderer) =
  renderer.openGlContext.select()

  rlViewport(0, 0, renderer.window.width.cint, renderer.window.height.cint)

  rlLoadIdentity()
  rlOrtho(0, renderer.window.width.cfloat, 0, renderer.window.height.cfloat, 0, 100.0)

  if renderer.onRender != nil:
    renderer.onRender()

  rlDrawRenderBatchActive()
  renderer.openGlContext.swapBuffers()

proc setBackgroundColor*(renderer: Renderer, r, g, b, a: uint8) =
  rlClearColor(r, g, b, a)

proc clear*(renderer: Renderer) =
  rlClearScreenBuffers()

proc drawQuad*(renderer: Renderer, bottom0, bottom1, top0, top1: Vec2, color: Color) =
  rlCheckRenderBatchLimit(6)

  rlBegin(RL_TRIANGLES)

  rlColor4f(color.r, color.g, color.b, color.a)

  rlVertex2f(bottom0.x, bottom0.y)
  rlVertex2f(bottom1.x, bottom1.y)
  rlVertex2f(top0.x, top0.y)

  rlVertex2f(top0.x, top0.y)
  rlVertex2f(bottom1.x, bottom1.y)
  rlVertex2f(top1.x, top1.y)

  rlEnd()

proc drawRect*(renderer: Renderer, rect: Rect, color: Color) =
  let bottomLeft = vec2(rect.x, rect.y)
  let bottomRight = vec2(rect.x + rect.width, rect.y)
  let topLeft = vec2(rect.x, rect.y + rect.height)
  let topRight = vec2(rect.x + rect.width, rect.y + rect.height)
  renderer.drawQuad(bottomLeft, bottomRight, topLeft, topRight, color)

proc drawLineSegment*(renderer: Renderer, a, b: Vec2, thickness: float32, color: Color) =
  let perpendicularStretcher = (b - a).rotated(-0.5 * Pi).normalized() * thickness * 0.5

  let a0 = a - perpendicularStretcher
  let a1 = a + perpendicularStretcher
  let b0 = b - perpendicularStretcher
  let b1 = b + perpendicularStretcher

  renderer.drawQuad(a0, a1, b0, b1, color)