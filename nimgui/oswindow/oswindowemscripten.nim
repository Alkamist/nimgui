{.experimental: "overloadableEnums".}

import opengl
import ../emscripten; export emscripten
import ./oswindowbase; export oswindowbase

const canvas = "canvas.emscripten"

{.passL: "-s EXPORTED_RUNTIME_METHODS=ccall".}
{.passL: "-s EXPORTED_FUNCTIONS=_main,_mousePressProc,_mouseReleaseProc,_mouseMoveProc".}

{.emit: """
#include <emscripten/em_js.h>
EM_JS(int, getWindowWidth, (), {
  return window.innerWidth;
});
EM_JS(int, getWindowHeight, (), {
  return window.innerHeight;
});
EM_JS(void, setMouseCursorImage, (const char* cursorName), {
  document.body.style.cursor = UTF8ToString(cursorName);
});
""".}

proc getWindowWidth(): cint {.importc, nodecl.}
proc getWindowHeight(): cint {.importc, nodecl.}
proc setMouseCursorImage(cursorName: cstring) {.importc, nodecl.}

type
  OsWindow* = ref object
    inputState*: InputState
    onFrame*: proc()
    handle*: pointer
    isOpen*: bool
    isChild*: bool
    webGlContext*: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE

var mainWindow: OsWindow

defineOsWindowBaseTemplates(OsWindow)

func toMouseButton(scanCode: int): MouseButton =
  case scanCode:
  of 0: MouseButton.Left
  of 1: MouseButton.Middle
  of 2: MouseButton.Right
  of 3: MouseButton.Extra1
  of 4: MouseButton.Extra2
  else: MouseButton.Unknown

func toJsCursorName(cursor: CursorImage): cstring =
  case cursor:
  of Arrow: cstring"default"
  of IBeam: cstring"text"
  of Crosshair: cstring"crosshair"
  of PointingHand: cstring"pointer"
  of ResizeLeftRight: cstring"ew-resize"
  of ResizeTopBottom: cstring"ns-resize"
  of ResizeTopLeftBottomRight: cstring"nwse-resize"
  of ResizeTopRightBottomLeft: cstring"nesw-resize"

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

  window.updateInputState(emscripten_performance_now() * 0.001)
  emscripten_request_animation_frame(mainLoop, cast[pointer](window))

proc onResize(eventType: cint, uiEvent: ptr EmscriptenUiEvent, userData: pointer): EM_BOOL {.cdecl.} =
  let window = cast[OsWindow](userData)
  discard emscripten_set_canvas_element_size(canvas, uiEvent.windowInnerWidth, uiEvent.windowInnerHeight)
  window.inputState.size.x = uiEvent.windowInnerWidth.float
  window.inputState.size.y = uiEvent.windowInnerHeight.float

proc mousePressProc(button: int) {.exportc.} =
  let button = button.toMouseButton()
  mainWindow.inputState.mousePresses.add button
  mainWindow.inputState.mouseIsDown[button] = true

proc mouseReleaseProc(button: int) {.exportc.} =
  let button = button.toMouseButton()
  mainWindow.inputState.mouseReleases.add button
  mainWindow.inputState.mouseIsDown[button] = false

proc mouseMoveProc(clientX, clientY: cint) {.exportc.} =
  mainWindow.inputState.mousePosition.x = clientX.float
  mainWindow.inputState.mousePosition.y = clientY.float

emscripten_run_script("""
function onMousePress(e) {
  Module.ccall('mousePressProc', null, ['number'], [e.button]);
}
function onMouseRelease(e) {
  Module.ccall('mouseReleaseProc', null, ['number'], [e.button]);
}
function onMouseMove(e) {
  Module.ccall('mouseMoveProc', null, ['number', 'number'], [e.clientX, e.clientY]);
}
window.addEventListener("mousedown", onMousePress);
window.addEventListener("mouseup", onMouseRelease);
window.addEventListener("mousemove", onMouseMove);
""")

proc `backgroundColor=`*(window: OsWindow, color: Color) =
  window.makeContextCurrent()
  glClearColor(color.r, color.g, color.b, color.a)

proc `mouseCursorImage=`*(window: OsWindow, value: CursorImage) =
  setMouseCursorImage(value.toJsCursorName)

template close*(window: OsWindow) = discard
template process*(window: OsWindow) = discard

proc newOsWindow*(parentHandle: pointer = nil): OsWindow =
  mainWindow = OsWindow()
  mainWindow.initInputState(emscripten_performance_now() * 0.001)
  mainWindow.createWebGlContext()
  mainWindow.makeContextCurrent()

  mainWindow.updateBounds()

  discard emscripten_set_resize_callback(EMSCRIPTEN_EVENT_TARGET_WINDOW, cast[pointer](mainWindow), false.EM_BOOL, onResize)
  discard emscripten_request_animation_frame(mainLoop, cast[pointer](mainWindow))

  return mainWindow