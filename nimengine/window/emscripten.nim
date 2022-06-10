import std/times
import ./base; export base

type
  EM_BOOL* = cint
  EMSCRIPTEN_RESULT* = cint

  EMSCRIPTEN_WEBGL_CONTEXT_HANDLE* = cint
  EM_WEBGL_POWER_PREFERENCE* = cint
  EMSCRIPTEN_WEBGL_CONTEXT_PROXY_MODE* = cint

  EmscriptenWebGLContextAttributes* {.importc, header: "<emscripten/html5_webgl.h>".} = object
    alpha*: EM_BOOL
    depth*: EM_BOOL
    stencil*: EM_BOOL
    antialias*: EM_BOOL
    premultipliedAlpha*: EM_BOOL
    preserveDrawingBuffer*: EM_BOOL
    powerPreference*: EM_WEBGL_POWER_PREFERENCE
    failIfMajorPerformanceCaveat*: EM_BOOL
    majorVersion*: cint
    minorVersion*: cint
    enableExtensionsByDefault*: EM_BOOL
    explicitSwapControl*: EM_BOOL
    proxyContextToMainThread*: EMSCRIPTEN_WEBGL_CONTEXT_PROXY_MODE
    renderViaOffscreenBackBuffer*: EM_BOOL

  EmscriptenMouseEvent* {.importc, header: "<emscripten/html5.h>".} = object
    timestamp*: cdouble
    screenX*: clong
    screenY*: clong
    clientX*: clong
    clientY*: clong
    ctrlKey*: EM_BOOL
    shiftKey*: EM_BOOL
    altKey*: EM_BOOL
    metaKey*: EM_BOOL
    button*: cushort
    buttons*: cushort
    movementX*: clong
    movementY*: clong
    targetX*: clong
    targetY*: clong
    canvasX*: clong
    canvasY*: clong
    padding*: clong

  EmscriptenWheelEvent* {.importc, header: "<emscripten/html5.h>".} = object
    mouse*: EmscriptenMouseEvent
    deltaX*: cdouble
    deltaY*: cdouble
    deltaZ*: cdouble
    deltaMode*: culong

  EmscriptenUiEvent* {.importc, header: "<emscripten/html5.h>".} = object
    detail*: clong
    documentBodyClientWidth*: cint
    documentBodyClientHeight*: cint
    windowInnerWidth*: cint
    windowInnerHeight*: cint
    windowOuterWidth*: cint
    windowOuterHeight*: cint
    scrollTop*: cint
    scrollLeft*: cint

  em_ui_callback_func* = proc(eventType: cint, uiEvent: ptr EmscriptenUiEvent, userData: pointer): EM_BOOL {.cdecl.}
  em_mouse_callback_func* = proc(eventType: cint, mouseEvent: ptr EmscriptenMouseEvent, userData: pointer): EM_BOOL {.cdecl.}
  # em_wheel_callback_func* = proc(eventType: cint, wheelEvent: ptr EmscriptenWheelEvent, userData: pointer): EM_BOOL {.cdecl.}

const EM_TRUE* = 1
const EM_FALSE* = 0
const EMSCRIPTEN_EVENT_TARGET_INVALID* = 0
const EMSCRIPTEN_EVENT_TARGET_DOCUMENT* = cstring"1"
const EMSCRIPTEN_EVENT_TARGET_WINDOW* = cstring"2"
const EMSCRIPTEN_EVENT_TARGET_SCREEN* = cstring"3"
const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_DISALLOW* = 0
const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_FALLBACK* = 1
const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_ALWAYS* = 2
const EM_WEBGL_POWER_PREFERENCE_DEFAULT* = 0
const EM_WEBGL_POWER_PREFERENCE_LOW_POWER* = 1
const EM_WEBGL_POWER_PREFERENCE_HIGH_PERFORMANCE* = 2
const EM_CALLBACK_THREAD_CONTEXT_MAIN_BROWSER_THREAD* = 0x1
const EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD* = 0x2

proc emscripten_set_main_loop*(f: proc() {.cdecl.}, a: cint, b: bool) {.importc, header: "<emscripten/emscripten.h>".}
proc emscripten_run_script*(code: cstring) {.importc, header: "<emscripten/emscripten.h>".}

proc emscripten_webgl_commit_frame*(): EMSCRIPTEN_RESULT {.importc, header: "<emscripten/html5_webgl.h>".}
proc emscripten_webgl_init_context_attributes*(attributes: ptr EmscriptenWebGLContextAttributes) {.importc, header: "<emscripten/html5_webgl.h>".}
proc emscripten_webgl_create_context*(target: cstring, attributes: ptr EmscriptenWebGLContextAttributes): EMSCRIPTEN_WEBGL_CONTEXT_HANDLE {.importc, header: "<emscripten/html5_webgl.h>".}
proc emscripten_webgl_make_context_current*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EMSCRIPTEN_RESULT {.importc, header: "<emscripten/html5_webgl.h>".}

{.passL: "-s EXPORTED_RUNTIME_METHODS=ccall".}
{.passL: "-s EXPORTED_FUNCTIONS=_main,_initSize,_onMouseMove,_onMouseDown,_onMouseUp,_onResize".}

func toMouseButton(code: int): MouseButton =
  case code:
  of 0: MouseButton.Left
  of 1: MouseButton.Middle
  of 2: MouseButton.Right
  of 3: MouseButton.Extra1
  of 4: MouseButton.Extra2
  else: MouseButton.Unknown

template startEventLoop*(client: Client, code: untyped): untyped =
  proc mainFn() {.cdecl.} =
    code

  emscripten_set_main_loop(mainFn, 0, true)

proc initSize*(clientWidth, clientHeight: float) {.exportc.} =
  globalClient.width = clientWidth
  globalClient.widthChange = 0.0
  globalClient.widthPrevious = clientWidth
  globalClient.height = clientHeight
  globalClient.heightChange = 0.0
  globalClient.heightPrevious = clientHeight

proc onResize(clientWidth, clientHeight: float) {.exportc.} =
  globalClient.processResized(clientWidth, clientHeight)

emscripten_run_script("""
window.addEventListener("resize", e => {
  let canvas = document.getElementById("canvas");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Module.ccall("onResize", null, ["number", "number"], [window.innerWidth, window.innerHeight]);
});
""")

proc onMouseUp(button: int) {.exportc.} =
  globalClient.processMouseButtonReleased(button.toMouseButton)

emscripten_run_script("""
window.addEventListener("mouseup", e => {
  Module.ccall("onMouseUp", null, ["number"], [e.button]);
});
""")

proc onMouseDown(button: int) {.exportc.} =
  globalClient.processMouseButtonPressed(button.toMouseButton)

emscripten_run_script("""
window.addEventListener("mousedown", e => {
  Module.ccall("onMouseDown", null, ["number"], [e.button]);
});
""")

proc onMouseMove(clientX, clientY: float) {.exportc.} =
  globalClient.processMouseMoved(clientX, clientY)

emscripten_run_script("""
window.addEventListener("mousemove", e => {
  Module.ccall("onMouseMove", null, ["number", "number"], [e.clientX, e.clientY]);
});
""")

var canvasCount = 0

proc newWindow*(parentHandle: pointer = nil): Window =
  result = Window()
  result.input = newInput(cpuTime())
  result.isOpen = true
  result.initBase()

  let canvasName = "canvas" & $canvasCount

  var script = ""

  script.add "let " & canvasName & " = document.createElement(" & "\"" & canvasName & "\"" & ")"
  script.add "document.body.appendChild(" & canvasName & ")"

  emscripten_run_script("""
  var mycanvas = document.createElement("canvas");
  mycanvas.id = "mycanvas";
  document.body.appendChild(mycanvas);
  let canvas = document.getElementById("canvas");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Module.ccall("initSize", null, ["number", "number"], [window.innerWidth, window.innerHeight]);
  """)

  inc canvasCount