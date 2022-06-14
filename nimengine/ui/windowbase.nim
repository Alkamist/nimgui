{.experimental: "overloadableEnums".}

import opengl
import ./uihandler; export uihandler
import ../math; export math
import ../openglwrappers/openglcontext; export openglcontext

const densityPixelDpi* = 96.0

when defined(windows):
  import winim/lean except INPUT
  type
    PlatformData* = object
      moveTimer*: UINT_PTR

type
  Window* = ref object of UiHandler
    onFrame*: proc()
    handle*: pointer
    isOpen*: bool
    isChild*: bool
    openGlContext*: OpenGlContext
    platform*: PlatformData

proc newWindowBase*(): Window =
  result = Window()
  result.init()
  result.isOpen = true
  result.frame.isFocused = true
  result.previousFrame.isFocused = false

proc initBase*(window: Window) =
  window.openGlContext = newOpenGlContext(window.handle)
  window.openGlContext.select()

template processFrame*(window: Window, inputStateChanges: untyped) =
  if window.isOpen:
    cast[UiHandler](window).update()
    inputStateChanges

    window.openGlContext.select()
    glClear(GL_COLOR_BUFFER_BIT)

    if window.onFrame != nil:
      window.onFrame()

    window.openGlContext.swapBuffers()

proc `backgroundColor=`*(window: Window, color: Color) =
  window.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)