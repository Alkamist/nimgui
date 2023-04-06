{.experimental: "overloadableEnums".}

import opengl
import ../emscripten; export emscripten
import ./oswindowbase; export oswindowbase

const canvas = "canvas.emscripten"

{.emit: """
#include <emscripten/em_js.h>
EM_JS(int, getWindowWidth, (), {
  return window.innerWidth;
});
EM_JS(int, getWindowHeight, (), {
  return window.innerHeight;
});
""".}

proc getWindowWidth(): cint {.importc, nodecl.}
proc getWindowHeight(): cint {.importc, nodecl.}

type
  OsWindow* = ref object
    inputState*: InputState
    onFrame*: proc()
    handle*: pointer
    isOpen*: bool
    isChild*: bool
    webGlContext*: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE

defineOsWindowBaseTemplates(OsWindow)

func toMouseButton(scanCode: cushort): MouseButton =
  case scanCode:
  of 0: MouseButton.Left
  of 1: MouseButton.Middle
  of 2: MouseButton.Right
  of 3: MouseButton.Extra1
  of 4: MouseButton.Extra2
  else: MouseButton.Unknown

proc createWebGlContext(window: OsWindow) =
  var attributes: EmscriptenWebGLContextAttributes
  emscripten_webgl_init_context_attributes(attributes.addr)
  attributes.stencil = true.EM_BOOL
  attributes.depth = true.EM_BOOL
  window.webGlContext = emscripten_webgl_create_context(canvas, attributes.addr)

proc makeContextCurrent(window: OsWindow) =
  discard emscripten_webgl_make_context_current(window.webGlContext)

proc updateBounds(window: OsWindow) =
  let width = getWindowWidth()
  let height = getWindowHeight()
  discard emscripten_set_canvas_element_size(canvas, width, height)
  window.inputState.size.x = width.float
  window.inputState.size.y = height.float

proc mainLoop(time: cdouble, userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  window.makeContextCurrent()
  glClear(GL_COLOR_BUFFER_BIT)

  if window.onFrame != nil:
    window.onFrame()

  window.updateInputState()
  emscripten_request_animation_frame(mainLoop, cast[pointer](window))

proc onResize(eventType: cint, uiEvent: ptr EmscriptenUiEvent, userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  discard emscripten_set_canvas_element_size(canvas, uiEvent.windowInnerWidth, uiEvent.windowInnerHeight)
  window.inputState.size.x = uiEvent.windowInnerWidth.float
  window.inputState.size.y = uiEvent.windowInnerHeight.float

proc onMouseJustMoved(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  window.inputState.mousePosition.x = mouseEvent.clientX.float
  window.inputState.mousePosition.y = mouseEvent.clientY.float

proc onMouseJustPressed(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  let button = mouseEvent.button.toMouseButton()
  window.inputState.mousePresses.add button
  window.inputState.mouseIsDown[button] = true

proc onMouseJustReleased(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  let button = mouseEvent.button.toMouseButton()
  window.inputState.mouseReleases.add button
  window.inputState.mouseIsDown[button] = false

proc `backgroundColor=`*(window: OsWindow, color: Color) =
  window.makeContextCurrent()
  glClearColor(color.r, color.g, color.b, color.a)

template close*(window: OsWindow) = discard
template process*(window: OsWindow) = discard

proc newOsWindow*(parentHandle: pointer = nil): OsWindow =
  result = OsWindow()
  result.initInputState()
  result.createWebGlContext()
  result.makeContextCurrent()

  result.updateBounds()

  discard emscripten_set_resize_callback(EMSCRIPTEN_EVENT_TARGET_WINDOW, cast[pointer](result), false.EM_BOOL, onResize)
  discard emscripten_set_mousemove_callback(canvas, cast[pointer](result), false.EM_BOOL, onMouseJustMoved)
  discard emscripten_set_mousedown_callback(canvas, cast[pointer](result), false.EM_BOOL, onMouseJustPressed)
  discard emscripten_set_mouseup_callback(canvas, cast[pointer](result), false.EM_BOOL, onMouseJustReleased)
  discard emscripten_request_animation_frame(mainLoop, cast[pointer](result))