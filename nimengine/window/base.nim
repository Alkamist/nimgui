{.experimental: "overloadableEnums".}

import opengl; export opengl
import ../input; export input
import ../openglwrappers/openglcontext; export openglcontext

when defined(windows):
  import winim/lean as win32 except Input
  type
    PlatformData* = object
      moveTimer*: UINT_PTR

type
  Window* = ref object
    onFrame*: proc()
    handle*: pointer
    input*: Input
    isOpen*: bool
    isChild*: bool
    openGlContext*: OpenGlContext
    platform*: PlatformData

proc initBase*(window: Window) =
  window.openGlContext = newOpenGlContext(window.handle)
  window.openGlContext.select()

template processFrame*(window: Window, time: float, inputStateChanges: untyped)=
  window.input.beginFrame(time)
  inputStateChanges

  window.openGlContext.select()
  glClear(GL_COLOR_BUFFER_BIT)

  if window.onFrame != nil:
    window.onFrame()

  window.openGlContext.swapBuffers()
  window.input.endFrame()

proc `backgroundColor=`*(window: Window, color: Color) =
  window.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)