import ./window
import ./renderer/openglstate
import ./renderer/platformcontext

type
  Renderer* = ref object
    window*: Window
    render*: proc(r: Renderer)
    platformContext: PlatformContext
    savedOpenGlState: OpenGlState

proc newRenderer*(window: Window): Renderer =
  result = Renderer()
  result.window = window
  result.platformContext = initPlatformContext(window.platform.handle)
  result.savedOpenGlState = getCurrentOpenGlState()

proc clear*(self: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
  glClear(GL_COLOR_BUFFER_BIT)

proc clip*(self: Renderer, x, y, w, h: float) =
  if w >= 0 and h >= 0:
    glScissor(x.GLsizei, y.GLsizei,
              w.GLsizei, h.GLsizei)

proc saveOpenGlState(self: Renderer) =
  self.savedOpenGlState = getCurrentOpenGlState()

proc restoreSavedOpenGlState(self: Renderer) =
  self.savedOpenGlState.makeCurrent()

proc setupRenderState2d(self: Renderer) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)
  glActiveTexture(GL_TEXTURE0)

proc resize(self: Renderer, x, y, w, h: float) =
  if w >= 0 and h >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               w.GLsizei, h.GLsizei)

proc process*(self: Renderer) =
  let w = self.window.width
  let h = self.window.height

  self.platformContext.select()
  self.saveOpenGlState()
  self.setupRenderState2d()
  self.resize(0, 0, w, h)

  if self.render != nil:
    self.render(self)

  self.clip(0, 0, w, h)
  self.platformContext.swapBuffers()
  self.restoreSavedOpenGlState()
  self.platformContext.unselect()