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

proc drawLineSegment*(renderer: Renderer, a, b: Vec2, thickness: float32, color: Color) =
  let perpendicularStretcher = (b - a).rotated(-0.5 * Pi).normalized() * thickness

  let a0 = a - perpendicularStretcher
  let a1 = a + perpendicularStretcher
  let b0 = b - perpendicularStretcher
  let b1 = b + perpendicularStretcher

  rlCheckRenderBatchLimit(6)

  rlBegin(RL_TRIANGLES)

  rlColor4f(color.r, color.g, color.b, color.a)

  rlVertex2f(a0.x, a0.y)
  rlVertex2f(a1.x, a1.y)
  rlVertex2f(b0.x, b0.y)

  rlVertex2f(b0.x, b0.y)
  rlVertex2f(a1.x, a1.y)
  rlVertex2f(b1.x, b1.y)

  rlEnd()

# proc drawRectangle*(renderer: Renderer, rect: Rect, color: Color) =
#   rlCheckRenderBatchLimit(6)

#   rlBegin(RL_TRIANGLES)

#   rlColor4f(color.r * 255, color.g * 255, color.b * 255, color.a * 255)

#   rlVertex2f(topLeft.x, topLeft.y)
#   rlVertex2f(bottomLeft.x, bottomLeft.y)
#   rlVertex2f(topRight.x, topRight.y)

#   rlVertex2f(topRight.x, topRight.y)
#   rlVertex2f(bottomLeft.x, bottomLeft.y)
#   rlVertex2f(bottomRight.x, bottomRight.y)

#   rlEnd()