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

proc emscripten_set_resize_callback_on_thread*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_ui_callback_func, targetThread: cint): EMSCRIPTEN_RESULT {.importc, header: "<emscripten/html5.h>".}
template emscripten_set_resize_callback*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_ui_callback_func): EMSCRIPTEN_RESULT =
  emscripten_set_resize_callback_on_thread(target, userData, useCapture, callback, EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)

# proc emscripten_set_mousemove_callback_on_thread*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func, targetThread: cint): EMSCRIPTEN_RESULT {.importc.}
# template emscripten_set_mousemove_callback*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func): EMSCRIPTEN_RESULT =
#   emscripten_set_mousemove_callback_on_thread(target, userData, useCapture, callback, EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)

proc emscripten_set_mousedown_callback_on_thread*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func, targetThread: cint): EMSCRIPTEN_RESULT {.importc, header: "<emscripten/html5.h>".}
template emscripten_set_mousedown_callback*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func): EMSCRIPTEN_RESULT =
  emscripten_set_mousedown_callback_on_thread(target, userData, useCapture, callback, EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)

# proc emscripten_set_mouseup_callback_on_thread*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func, targetThread: cint): EMSCRIPTEN_RESULT {.importc.}
# template emscripten_set_mouseup_callback*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_mouse_callback_func): EMSCRIPTEN_RESULT =
#   emscripten_set_mouseup_callback_on_thread(target, userData, useCapture, callback, EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)

# proc emscripten_set_wheel_callback_on_thread*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_wheel_callback_func, targetThread: cint): EMSCRIPTEN_RESULT {.importc.}
# template emscripten_set_wheel_callback*(target: cstring, userData: pointer, useCapture: EM_BOOL, callback: em_wheel_callback_func): EMSCRIPTEN_RESULT =
#   emscripten_set_wheel_callback_on_thread(target, userData, useCapture, callback, EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)