type
  pthread_t* = uint64

# ----------------------------- em_types.h -----------------------------

const EM_TRUE* = 1
const EM_FALSE* = 0

type
  EM_BOOL* = cint
  EM_UTF8* = char

  emscripten_align1_short* = cshort
  emscripten_align4_int64* = clonglong
  emscripten_align2_int64* = clonglong
  emscripten_align1_int64* = clonglong
  emscripten_align2_int* = cint
  emscripten_align1_int* = cint
  emscripten_align2_float* = cfloat
  emscripten_align1_float* = cfloat
  emscripten_align4_double* = cdouble
  emscripten_align2_double* = cdouble
  emscripten_align1_double* = cdouble

  em_callback_func* = proc() {.cdecl.}
  em_arg_callback_func* = proc(a1: pointer) {.cdecl.}
  em_str_callback_func* = proc(a1: cstring) {.cdecl.}

# ----------------------------- emscripten.h -----------------------------

const EM_TIMING_SETTIMEOUT* = 0
const EM_TIMING_RAF* = 1
const EM_TIMING_SETIMMEDIATE* = 2
const EM_LOG_CONSOLE* = 1
const EM_LOG_WARN* = 2
const EM_LOG_ERROR* = 4
const EM_LOG_C_STACK* = 8
const EM_LOG_JS_STACK* = 16
const EM_LOG_DEMANGLE* = 32
const EM_LOG_NO_PATHS* = 64
const EM_LOG_FUNC_PARAMS* = 128
const EM_LOG_DEBUG* = 256
const EM_LOG_INFO* = 512

type
  worker_handle* = cint

  EMSCRIPTEN_RESULT* = cint
  DOM_KEY_LOCATION* = cint

  EMSCRIPTEN_FULLSCREEN_SCALE* = cint
  EMSCRIPTEN_FULLSCREEN_CANVAS_SCALE* = cint
  EMSCRIPTEN_FULLSCREEN_FILTERING* = cint

  em_beforeunload_callback* = proc(eventType: cint; reserved: pointer; userData: pointer): cstring {.cdecl.}
  em_socket_callback* = proc(fd: cint; userData: pointer) {.cdecl.}
  em_socket_error_callback* = proc(fd: cint; err: cint; msg: cstring; userData: pointer) {.cdecl.}
  em_idb_onload_func* = proc(a1: pointer; a2: pointer; a3: cint) {.cdecl.}
  em_idb_exists_func* = proc(a1: pointer; a2: cint) {.cdecl.}
  em_run_preload_plugins_data_onload_func* = proc(a1: pointer; a2: cstring) {.cdecl.}
  em_worker_callback_func* = proc(a1: cstring; a2: cint; a3: pointer) {.cdecl.}
  em_scan_func* = proc(a1: pointer; a2: pointer) {.cdecl.}
  em_dlopen_callback* = proc(handle: pointer; user_data: pointer) {.cdecl.}

{.push importc, cdecl.}

proc emscripten_run_script*(script: cstring)
proc emscripten_run_script_int*(script: cstring): cint
proc emscripten_run_script_string*(script: cstring): cstring
proc emscripten_async_run_script*(script: cstring; millis: cint)
proc emscripten_async_load_script*(script: cstring; onload: em_callback_func; onerror: em_callback_func)
proc emscripten_set_main_loop*(`func`: em_callback_func; fps: cint; simulate_infinite_loop: cint)
proc emscripten_set_main_loop_timing*(mode: cint; value: cint): cint
proc emscripten_get_main_loop_timing*(mode: ptr cint; value: ptr cint)
proc emscripten_set_main_loop_arg*(`func`: em_arg_callback_func; arg: pointer; fps: cint; simulate_infinite_loop: cint)
proc emscripten_pause_main_loop*()
proc emscripten_resume_main_loop*()
proc emscripten_cancel_main_loop*()
proc emscripten_set_socket_error_callback*(userData: pointer; callback: em_socket_error_callback)
proc emscripten_set_socket_open_callback*(userData: pointer; callback: em_socket_callback)
proc emscripten_set_socket_listen_callback*(userData: pointer; callback: em_socket_callback)
proc emscripten_set_socket_connection_callback*(userData: pointer; callback: em_socket_callback)
proc emscripten_set_socket_message_callback*(userData: pointer; callback: em_socket_callback)
proc emscripten_set_socket_close_callback*(userData: pointer; callback: em_socket_callback)
proc emscripten_set_main_loop_expected_blockers*(num: cint)
proc emscripten_async_call*(`func`: em_arg_callback_func; arg: pointer; millis: cint)
proc emscripten_exit_with_live_runtime*()
proc emscripten_force_exit*(status: cint)
proc emscripten_get_device_pixel_ratio*(): cdouble
proc emscripten_get_window_title*(): cstring
proc emscripten_set_window_title*(a1: cstring)
proc emscripten_get_screen_size*(width: ptr cint; height: ptr cint)
proc emscripten_hide_mouse*()
proc emscripten_get_now*(): cdouble
proc emscripten_random*(): cfloat
proc emscripten_idb_async_load*(db_name: cstring; file_id: cstring; arg: pointer; onload: em_idb_onload_func; onerror: em_arg_callback_func)
proc emscripten_idb_async_store*(db_name: cstring; file_id: cstring; `ptr`: pointer; num: cint; arg: pointer; onstore: em_arg_callback_func; onerror: em_arg_callback_func)
proc emscripten_idb_async_delete*(db_name: cstring; file_id: cstring; arg: pointer; ondelete: em_arg_callback_func; onerror: em_arg_callback_func)
proc emscripten_idb_async_exists*(db_name: cstring; file_id: cstring; arg: pointer; oncheck: em_idb_exists_func; onerror: em_arg_callback_func)
proc emscripten_idb_load*(db_name: cstring; file_id: cstring; pbuffer: ptr pointer; pnum: ptr cint; perror: ptr cint)
proc emscripten_idb_store*(db_name: cstring; file_id: cstring; buffer: pointer; num: cint; perror: ptr cint)
proc emscripten_idb_delete*(db_name: cstring; file_id: cstring; perror: ptr cint)
proc emscripten_idb_exists*(db_name: cstring; file_id: cstring; pexists: ptr cint; perror: ptr cint)
proc emscripten_idb_load_blob*(db_name: cstring; file_id: cstring; pblob: ptr cint; perror: ptr cint)
proc emscripten_idb_store_blob*(db_name: cstring; file_id: cstring; buffer: pointer; num: cint; perror: ptr cint)
proc emscripten_idb_read_from_blob*(blob: cint; start: cint; num: cint; buffer: pointer)
proc emscripten_idb_free_blob*(blob: cint)
proc emscripten_run_preload_plugins*(file: cstring; onload: em_str_callback_func; onerror: em_str_callback_func): cint
proc emscripten_run_preload_plugins_data*(data: cstring; size: cint; suffix: cstring; arg: pointer; onload: em_run_preload_plugins_data_onload_func; onerror: em_arg_callback_func)
proc emscripten_lazy_load_code*()
proc emscripten_create_worker*(url: cstring): worker_handle
proc emscripten_destroy_worker*(worker: worker_handle)
proc emscripten_call_worker*(worker: worker_handle; funcname: cstring; data: cstring; size: cint; callback: em_worker_callback_func; arg: pointer)
proc emscripten_worker_respond*(data: cstring; size: cint)
proc emscripten_worker_respond_provisionally*(data: cstring; size: cint)
proc emscripten_get_worker_queue_size*(worker: worker_handle): cint
proc emscripten_get_compiler_setting*(name: cstring): clong
proc emscripten_has_asyncify*(): cint
proc emscripten_debugger*()
proc emscripten_get_preloaded_image_data*(path: cstring; w: ptr cint; h: ptr cint): cstring
proc emscripten_get_preloaded_image_data_from_FILE*(file: ptr FILE; w: ptr cint; h: ptr cint): cstring
proc emscripten_log*(flags: cint; format: cstring) {.varargs.}
proc emscripten_get_callstack*(flags: cint; `out`: cstring; maxbytes: cint): cint
proc emscripten_print_double*(x: cdouble; to: cstring; max: cint): cint
proc emscripten_scan_registers*(`func`: em_scan_func)
proc emscripten_scan_stack*(`func`: em_scan_func)
proc emscripten_dlopen*(filename: cstring; flags: cint; user_data: pointer; onsuccess: em_dlopen_callback; onerror: em_arg_callback_func)
proc emscripten_throw_number*(number: cdouble)
proc emscripten_throw_string*(utf8String: cstring)
proc emscripten_sleep*(ms: cuint)

{.pop.}

# ----------------------------- html5.h -----------------------------

const EMSCRIPTEN_EVENT_KEYPRESS* = 1
const EMSCRIPTEN_EVENT_KEYDOWN* = 2
const EMSCRIPTEN_EVENT_KEYUP* = 3
const EMSCRIPTEN_EVENT_CLICK* = 4
const EMSCRIPTEN_EVENT_MOUSEDOWN* = 5
const EMSCRIPTEN_EVENT_MOUSEUP* = 6
const EMSCRIPTEN_EVENT_DBLCLICK* = 7
const EMSCRIPTEN_EVENT_MOUSEMOVE* = 8
const EMSCRIPTEN_EVENT_WHEEL* = 9
const EMSCRIPTEN_EVENT_RESIZE* = 10
const EMSCRIPTEN_EVENT_SCROLL* = 11
const EMSCRIPTEN_EVENT_BLUR* = 12
const EMSCRIPTEN_EVENT_FOCUS* = 13
const EMSCRIPTEN_EVENT_FOCUSIN* = 14
const EMSCRIPTEN_EVENT_FOCUSOUT* = 15
const EMSCRIPTEN_EVENT_DEVICEORIENTATION* = 16
const EMSCRIPTEN_EVENT_DEVICEMOTION* = 17
const EMSCRIPTEN_EVENT_ORIENTATIONCHANGE* = 18
const EMSCRIPTEN_EVENT_FULLSCREENCHANGE* = 19
const EMSCRIPTEN_EVENT_POINTERLOCKCHANGE* = 20
const EMSCRIPTEN_EVENT_VISIBILITYCHANGE* = 21
const EMSCRIPTEN_EVENT_TOUCHSTART* = 22
const EMSCRIPTEN_EVENT_TOUCHEND* = 23
const EMSCRIPTEN_EVENT_TOUCHMOVE* = 24
const EMSCRIPTEN_EVENT_TOUCHCANCEL* = 25
const EMSCRIPTEN_EVENT_GAMEPADCONNECTED* = 26
const EMSCRIPTEN_EVENT_GAMEPADDISCONNECTED* = 27
const EMSCRIPTEN_EVENT_BEFOREUNLOAD* = 28
const EMSCRIPTEN_EVENT_BATTERYCHARGINGCHANGE* = 29
const EMSCRIPTEN_EVENT_BATTERYLEVELCHANGE* = 30
const EMSCRIPTEN_EVENT_WEBGLCONTEXTLOST* = 31
const EMSCRIPTEN_EVENT_WEBGLCONTEXTRESTORED* = 32
const EMSCRIPTEN_EVENT_MOUSEENTER* = 33
const EMSCRIPTEN_EVENT_MOUSELEAVE* = 34
const EMSCRIPTEN_EVENT_MOUSEOVER* = 35
const EMSCRIPTEN_EVENT_MOUSEOUT* = 36
const EMSCRIPTEN_EVENT_CANVASRESIZED* = 37
const EMSCRIPTEN_EVENT_POINTERLOCKERROR* = 38
const EMSCRIPTEN_RESULT_SUCCESS* = 0
const EMSCRIPTEN_RESULT_DEFERRED* = 1
const EMSCRIPTEN_RESULT_NOT_SUPPORTED* = -1
const EMSCRIPTEN_RESULT_FAILED_NOT_DEFERRED* = -2
const EMSCRIPTEN_RESULT_INVALID_TARGET* = -3
const EMSCRIPTEN_RESULT_UNKNOWN_TARGET* = -4
const EMSCRIPTEN_RESULT_INVALID_PARAM* = -5
const EMSCRIPTEN_RESULT_FAILED* = -6
const EMSCRIPTEN_RESULT_NO_DATA* = -7
const EMSCRIPTEN_RESULT_TIMED_OUT* = -8
const EMSCRIPTEN_EVENT_TARGET_INVALID* = 0
const EMSCRIPTEN_EVENT_TARGET_DOCUMENT* = (cast[cstring](1))
const EMSCRIPTEN_EVENT_TARGET_WINDOW* = (cast[cstring](2))
const EMSCRIPTEN_EVENT_TARGET_SCREEN* = (cast[cstring](3))
const DOM_KEY_LOCATION_STANDARD* = 0x00
const DOM_KEY_LOCATION_LEFT* = 0x01
const DOM_KEY_LOCATION_RIGHT* = 0x02
const DOM_KEY_LOCATION_NUMPAD* = 0x03
const EM_HTML5_SHORT_STRING_LEN_BYTES* = 32
const EM_HTML5_MEDIUM_STRING_LEN_BYTES* = 64
const EM_HTML5_LONG_STRING_LEN_BYTES* = 128
const DOM_DELTA_PIXEL* = 0x00
const DOM_DELTA_LINE* = 0x01
const DOM_DELTA_PAGE* = 0x02
const EMSCRIPTEN_DEVICE_MOTION_EVENT_SUPPORTS_ACCELERATION* = 0x01
const EMSCRIPTEN_DEVICE_MOTION_EVENT_SUPPORTS_ACCELERATION_INCLUDING_GRAVITY* = 0x02
const EMSCRIPTEN_DEVICE_MOTION_EVENT_SUPPORTS_ROTATION_RATE* = 0x04
const EMSCRIPTEN_ORIENTATION_PORTRAIT_PRIMARY* = 1
const EMSCRIPTEN_ORIENTATION_PORTRAIT_SECONDARY* = 2
const EMSCRIPTEN_ORIENTATION_LANDSCAPE_PRIMARY* = 4
const EMSCRIPTEN_ORIENTATION_LANDSCAPE_SECONDARY* = 8
const EMSCRIPTEN_FULLSCREEN_SCALE_DEFAULT* = 0
const EMSCRIPTEN_FULLSCREEN_SCALE_STRETCH* = 1
const EMSCRIPTEN_FULLSCREEN_SCALE_ASPECT* = 2
const EMSCRIPTEN_FULLSCREEN_SCALE_CENTER* = 3
const EMSCRIPTEN_FULLSCREEN_CANVAS_SCALE_NONE* = 0
const EMSCRIPTEN_FULLSCREEN_CANVAS_SCALE_STDDEF* = 1
const EMSCRIPTEN_FULLSCREEN_CANVAS_SCALE_HIDEF* = 2
const EMSCRIPTEN_FULLSCREEN_FILTERING_DEFAULT* = 0
const EMSCRIPTEN_FULLSCREEN_FILTERING_NEAREST* = 1
const EMSCRIPTEN_FULLSCREEN_FILTERING_BILINEAR* = 2
const EMSCRIPTEN_VISIBILITY_HIDDEN* = 0
const EMSCRIPTEN_VISIBILITY_VISIBLE* = 1
const EMSCRIPTEN_VISIBILITY_PRERENDER* = 2
const EMSCRIPTEN_VISIBILITY_UNLOADED* = 3
const EM_CALLBACK_THREAD_CONTEXT_MAIN_RUNTIME_THREAD* = (cast[pthread_t](0x1))
const EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD* = (cast[pthread_t](0x2))
const EM_CALLBACK_THREAD_CONTEXT_MAIN_BROWSER_THREAD* = EM_CALLBACK_THREAD_CONTEXT_MAIN_RUNTIME_THREAD

type
  EmscriptenKeyboardEvent* {.bycopy.} = object
    timestamp*: cdouble
    location*: culong
    ctrlKey*: EM_BOOL
    shiftKey*: EM_BOOL
    altKey*: EM_BOOL
    metaKey*: EM_BOOL
    repeat*: EM_BOOL
    charCode*: culong
    keyCode*: culong
    which*: culong
    key*: array[EM_HTML5_SHORT_STRING_LEN_BYTES, EM_UTF8]
    code*: array[EM_HTML5_SHORT_STRING_LEN_BYTES, EM_UTF8]
    charValue*: array[EM_HTML5_SHORT_STRING_LEN_BYTES, EM_UTF8]
    locale*: array[EM_HTML5_SHORT_STRING_LEN_BYTES, EM_UTF8]

  EmscriptenMouseEvent* {.bycopy.} = object
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

  EmscriptenWheelEvent* {.bycopy.} = object
    mouse*: EmscriptenMouseEvent
    deltaX*: cdouble
    deltaY*: cdouble
    deltaZ*: cdouble
    deltaMode*: culong

  EmscriptenUiEvent* {.bycopy.} = object
    detail*: clong
    documentBodyClientWidth*: cint
    documentBodyClientHeight*: cint
    windowInnerWidth*: cint
    windowInnerHeight*: cint
    windowOuterWidth*: cint
    windowOuterHeight*: cint
    scrollTop*: cint
    scrollLeft*: cint

  EmscriptenFocusEvent* {.bycopy.} = object
    nodeName*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]
    id*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]

  EmscriptenDeviceOrientationEvent* {.bycopy.} = object
    alpha*: cdouble
    beta*: cdouble
    gamma*: cdouble
    absolute*: EM_BOOL

  EmscriptenDeviceMotionEvent* {.bycopy.} = object
    accelerationX*: cdouble
    accelerationY*: cdouble
    accelerationZ*: cdouble
    accelerationIncludingGravityX*: cdouble
    accelerationIncludingGravityY*: cdouble
    accelerationIncludingGravityZ*: cdouble
    rotationRateAlpha*: cdouble
    rotationRateBeta*: cdouble
    rotationRateGamma*: cdouble
    supportedFields*: cint

  EmscriptenOrientationChangeEvent* {.bycopy.} = object
    orientationIndex*: cint
    orientationAngle*: cint

  EmscriptenFullscreenChangeEvent* {.bycopy.} = object
    isFullscreen*: EM_BOOL
    fullscreenEnabled*: EM_BOOL
    nodeName*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]
    id*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]
    elementWidth*: cint
    elementHeight*: cint
    screenWidth*: cint
    screenHeight*: cint

  EmscriptenFullscreenStrategy* {.bycopy.} = object
    scaleMode*: EMSCRIPTEN_FULLSCREEN_SCALE
    canvasResolutionScaleMode*: EMSCRIPTEN_FULLSCREEN_CANVAS_SCALE
    filteringMode*: EMSCRIPTEN_FULLSCREEN_FILTERING
    canvasResizedCallback*: em_canvasresized_callback_func
    canvasResizedCallbackUserData*: pointer
    canvasResizedCallbackTargetThread*: pthread_t

  EmscriptenPointerlockChangeEvent* {.bycopy.} = object
    isActive*: EM_BOOL
    nodeName*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]
    id*: array[EM_HTML5_LONG_STRING_LEN_BYTES, EM_UTF8]

  EmscriptenVisibilityChangeEvent* {.bycopy.} = object
    hidden*: EM_BOOL
    visibilityState*: cint

  EmscriptenTouchPoint* {.bycopy.} = object
    identifier*: clong
    screenX*: clong
    screenY*: clong
    clientX*: clong
    clientY*: clong
    pageX*: clong
    pageY*: clong
    isChanged*: EM_BOOL
    onTarget*: EM_BOOL
    targetX*: clong
    targetY*: clong
    canvasX*: clong
    canvasY*: clong

  EmscriptenTouchEvent* {.bycopy.} = object
    timestamp*: cdouble
    numTouches*: cint
    ctrlKey*: EM_BOOL
    shiftKey*: EM_BOOL
    altKey*: EM_BOOL
    metaKey*: EM_BOOL
    touches*: array[32, EmscriptenTouchPoint]

  EmscriptenGamepadEvent* {.bycopy.} = object
    timestamp*: cdouble
    numAxes*: cint
    numButtons*: cint
    axis*: array[64, cdouble]
    analogButton*: array[64, cdouble]
    digitalButton*: array[64, EM_BOOL]
    connected*: EM_BOOL
    index*: clong
    id*: array[EM_HTML5_MEDIUM_STRING_LEN_BYTES, EM_UTF8]
    mapping*: array[EM_HTML5_MEDIUM_STRING_LEN_BYTES, EM_UTF8]

  EmscriptenBatteryEvent* {.bycopy.} = object
    chargingTime*: cdouble
    dischargingTime*: cdouble
    level*: cdouble
    charging*: EM_BOOL

  em_key_callback_func* = proc(eventType: cint; keyEvent: ptr EmscriptenKeyboardEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_mouse_callback_func* = proc(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_wheel_callback_func* = proc(eventType: cint; wheelEvent: ptr EmscriptenWheelEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_ui_callback_func* = proc(eventType: cint; uiEvent: ptr EmscriptenUiEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_focus_callback_func* = proc(eventType: cint; focusEvent: ptr EmscriptenFocusEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_deviceorientation_callback_func* = proc(eventType: cint; deviceOrientationEvent: ptr EmscriptenDeviceOrientationEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_devicemotion_callback_func* = proc(eventType: cint; deviceMotionEvent: ptr EmscriptenDeviceMotionEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_orientationchange_callback_func* = proc(eventType: cint; orientationChangeEvent: ptr EmscriptenOrientationChangeEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_fullscreenchange_callback_func* = proc(eventType: cint; fullscreenChangeEvent: ptr EmscriptenFullscreenChangeEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_canvasresized_callback_func* = proc(eventType: cint; reserved: pointer; userData: pointer): EM_BOOL {.cdecl.}
  em_pointerlockchange_callback_func* = proc(eventType: cint; pointerlockChangeEvent: ptr EmscriptenPointerlockChangeEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_pointerlockerror_callback_func* = proc(eventType: cint; reserved: pointer; userData: pointer): EM_BOOL {.cdecl.}
  em_visibilitychange_callback_func* = proc(eventType: cint; visibilityChangeEvent: ptr EmscriptenVisibilityChangeEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_touch_callback_func* = proc(eventType: cint; touchEvent: ptr EmscriptenTouchEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_gamepad_callback_func* = proc(eventType: cint; gamepadEvent: ptr EmscriptenGamepadEvent; userData: pointer): EM_BOOL {.cdecl.}
  em_battery_callback_func* = proc(eventType: cint; batteryEvent: ptr EmscriptenBatteryEvent; userData: pointer): EM_BOOL {.cdecl.}

{.push importc, cdecl.}

proc emscripten_set_keypress_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_key_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_keydown_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_key_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_keyup_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_key_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_click_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mousedown_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mouseup_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_dblclick_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mousemove_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mouseenter_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mouseleave_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mouseover_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_mouseout_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_mouse_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_mouse_status*(mouseState: ptr EmscriptenMouseEvent): EMSCRIPTEN_RESULT
proc emscripten_set_wheel_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_wheel_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_resize_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_ui_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_scroll_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_ui_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_blur_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_focus_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_focus_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_focus_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_focusin_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_focus_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_focusout_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_focus_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_deviceorientation_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_deviceorientation_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_deviceorientation_status*( orientationState: ptr EmscriptenDeviceOrientationEvent): EMSCRIPTEN_RESULT
proc emscripten_set_devicemotion_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_devicemotion_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_devicemotion_status*(motionState: ptr EmscriptenDeviceMotionEvent): EMSCRIPTEN_RESULT
proc emscripten_set_orientationchange_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_orientationchange_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_orientation_status*(orientationStatus: ptr EmscriptenOrientationChangeEvent): EMSCRIPTEN_RESULT
proc emscripten_lock_orientation*(allowedOrientations: cint): EMSCRIPTEN_RESULT
proc emscripten_unlock_orientation*(): EMSCRIPTEN_RESULT
proc emscripten_set_fullscreenchange_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_fullscreenchange_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_fullscreen_status*(fullscreenStatus: ptr EmscriptenFullscreenChangeEvent): EMSCRIPTEN_RESULT
proc emscripten_request_fullscreen*(target: cstring; deferUntilInEventHandler: EM_BOOL): EMSCRIPTEN_RESULT
proc emscripten_request_fullscreen_strategy*(target: cstring; deferUntilInEventHandler: EM_BOOL; fullscreenStrategy: ptr EmscriptenFullscreenStrategy): EMSCRIPTEN_RESULT
proc emscripten_exit_fullscreen*(): EMSCRIPTEN_RESULT
proc emscripten_enter_soft_fullscreen*(target: cstring; fullscreenStrategy: ptr EmscriptenFullscreenStrategy): EMSCRIPTEN_RESULT
proc emscripten_exit_soft_fullscreen*(): EMSCRIPTEN_RESULT
proc emscripten_set_pointerlockchange_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_pointerlockchange_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_pointerlockerror_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_pointerlockerror_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_pointerlock_status*(pointerlockStatus: ptr EmscriptenPointerlockChangeEvent): EMSCRIPTEN_RESULT
proc emscripten_request_pointerlock*(target: cstring; deferUntilInEventHandler: EM_BOOL): EMSCRIPTEN_RESULT
proc emscripten_exit_pointerlock*(): EMSCRIPTEN_RESULT
proc emscripten_set_visibilitychange_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_visibilitychange_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_visibility_status*(visibilityStatus: ptr EmscriptenVisibilityChangeEvent): EMSCRIPTEN_RESULT
proc emscripten_set_touchstart_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_touch_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_touchend_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_touch_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_touchmove_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_touch_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_touchcancel_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_touch_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_gamepadconnected_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_gamepad_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_gamepaddisconnected_callback_on_thread*(userData: pointer; useCapture: EM_BOOL; callback: em_gamepad_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_sample_gamepad_data*(): EMSCRIPTEN_RESULT
proc emscripten_get_num_gamepads*(): cint
proc emscripten_get_gamepad_status*(index: cint; gamepadState: ptr EmscriptenGamepadEvent): EMSCRIPTEN_RESULT
proc emscripten_set_batterychargingchange_callback_on_thread*(userData: pointer; callback: em_battery_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_batterylevelchange_callback_on_thread*(userData: pointer; callback: em_battery_callback_func; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_get_battery_status*(batteryState: ptr EmscriptenBatteryEvent): EMSCRIPTEN_RESULT
proc emscripten_vibrate*(msecs: cint): EMSCRIPTEN_RESULT
proc emscripten_vibrate_pattern*(msecsArray: ptr cint; numEntries: cint): EMSCRIPTEN_RESULT
proc emscripten_set_beforeunload_callback_on_thread*(userData: pointer; callback: em_beforeunload_callback; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_canvas_element_size*(target: cstring; width: cint; height: cint): EMSCRIPTEN_RESULT
proc emscripten_get_canvas_element_size*(target: cstring; width: ptr cint; height: ptr cint): EMSCRIPTEN_RESULT
proc emscripten_set_element_css_size*(target: cstring; width: cdouble; height: cdouble): EMSCRIPTEN_RESULT
proc emscripten_get_element_css_size*(target: cstring; width: ptr cdouble; height: ptr cdouble): EMSCRIPTEN_RESULT
proc emscripten_html5_remove_all_event_listeners*()
proc emscripten_request_animation_frame*(cb: proc (time: cdouble; userData: pointer): EM_BOOL {.cdecl.}; userData: pointer): cint
proc emscripten_cancel_animation_frame*(requestAnimationFrameId: cint)
proc emscripten_request_animation_frame_loop*(cb: proc (time: cdouble; userData: pointer): EM_BOOL {.cdecl.}; userData: pointer)
proc emscripten_date_now*(): cdouble
proc emscripten_performance_now*(): cdouble

{.pop.}

template emscripten_set_keypress_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_keypress_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_keydown_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_keydown_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_keyup_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_keyup_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_click_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_click_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mousedown_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mousedown_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mouseup_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mouseup_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_dblclick_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_dblclick_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mousemove_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mousemove_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mouseenter_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mouseenter_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mouseleave_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mouseleave_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mouseover_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mouseover_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_mouseout_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_mouseout_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_wheel_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_wheel_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_resize_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_resize_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_scroll_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_scroll_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_blur_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_blur_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_focus_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_focus_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_focusin_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_focusin_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_focusout_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_focusout_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_deviceorientation_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_deviceorientation_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_devicemotion_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_devicemotion_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_orientationchange_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_orientationchange_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_fullscreenchange_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_fullscreenchange_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_pointerlockchange_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_pointerlockchange_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_pointerlockerror_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_pointerlockerror_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_visibilitychange_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_visibilitychange_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_touchstart_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_touchstart_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_touchend_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_touchend_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_touchmove_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_touchmove_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_touchcancel_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_touchcancel_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_gamepadconnected_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_gamepadconnected_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_gamepaddisconnected_callback*(userData, useCapture, callback: untyped): untyped = emscripten_set_gamepaddisconnected_callback_on_thread((userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_batterychargingchange_callback*(userData, callback: untyped): untyped = emscripten_set_batterychargingchange_callback_on_thread((userData), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_batterylevelchange_callback*(userData, callback: untyped): untyped = emscripten_set_batterylevelchange_callback_on_thread((userData), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
template emscripten_set_beforeunload_callback*(userData, callback: untyped): untyped = emscripten_set_beforeunload_callback_on_thread((userData), (callback), EM_CALLBACK_THREAD_CONTEXT_MAIN_RUNTIME_THREAD)

# ----------------------------- html5_webgl.h -----------------------------

const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_DISALLOW* = 0
const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_FALLBACK* = 1
const EMSCRIPTEN_WEBGL_CONTEXT_PROXY_ALWAYS* = 2
const EM_WEBGL_POWER_PREFERENCE_DEFAULT* = 0
const EM_WEBGL_POWER_PREFERENCE_LOW_POWER* = 1
const EM_WEBGL_POWER_PREFERENCE_HIGH_PERFORMANCE* = 2
const EMSCRIPTEN_WEBGL_PARAM_TYPE_INT* = 0
const EMSCRIPTEN_WEBGL_PARAM_TYPE_FLOAT* = 1

type
  GLint = cint
  GLenum = cint
  GLint64 = clonglong
  EMSCRIPTEN_WEBGL_CONTEXT_HANDLE* = cint
  EMSCRIPTEN_WEBGL_CONTEXT_PROXY_MODE* = cint
  EM_WEBGL_POWER_PREFERENCE* = cint
  EMSCRIPTEN_WEBGL_PARAM_TYPE* = cint

  EmscriptenWebGLContextAttributes* {.bycopy.} = object
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

  em_webgl_context_callback* = proc(eventType: cint; reserved: pointer; userData: pointer): EM_BOOL {.cdecl.}

{.push importc, cdecl.}

proc emscripten_webgl_init_context_attributes*(attributes: ptr EmscriptenWebGLContextAttributes)
proc emscripten_webgl_create_context*(target: cstring; attributes: ptr EmscriptenWebGLContextAttributes): EMSCRIPTEN_WEBGL_CONTEXT_HANDLE
proc emscripten_webgl_make_context_current*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EMSCRIPTEN_RESULT
proc emscripten_webgl_get_current_context*(): EMSCRIPTEN_WEBGL_CONTEXT_HANDLE
proc emscripten_webgl_get_drawing_buffer_size*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE; width: ptr cint; height: ptr cint): EMSCRIPTEN_RESULT
proc emscripten_webgl_get_context_attributes*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE;outAttributes: ptr EmscriptenWebGLContextAttributes): EMSCRIPTEN_RESULT
proc emscripten_webgl_destroy_context*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EMSCRIPTEN_RESULT
proc emscripten_webgl_enable_extension*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE; extension: cstring): EM_BOOL
proc emscripten_webgl_enable_ANGLE_instanced_arrays*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_enable_OES_vertex_array_object*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_enable_WEBGL_draw_buffers*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_enable_WEBGL_draw_instanced_base_vertex_base_instance*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_enable_WEBGL_multi_draw*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_enable_WEBGL_multi_draw_instanced_base_vertex_base_instance*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_set_webglcontextlost_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_webgl_context_callback; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_set_webglcontextrestored_callback_on_thread*(target: cstring; userData: pointer; useCapture: EM_BOOL; callback: em_webgl_context_callback; targetThread: pthread_t): EMSCRIPTEN_RESULT
proc emscripten_is_webgl_context_lost*(context: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE): EM_BOOL
proc emscripten_webgl_commit_frame*(): EMSCRIPTEN_RESULT
proc emscripten_supports_offscreencanvas*(): EM_BOOL
proc emscripten_webgl1_get_proc_address*(name: cstring): pointer
proc emscripten_webgl2_get_proc_address*(name: cstring): pointer
proc emscripten_webgl_get_proc_address*(name: cstring): pointer
proc emscripten_webgl_get_supported_extensions*(): cstring
proc emscripten_webgl_get_shader_parameter_d*(shader: GLint; param: GLenum): cdouble
proc emscripten_webgl_get_shader_info_log_utf8*(shader: GLint): cstring
proc emscripten_webgl_get_shader_source_utf8*(shader: GLint): cstring
proc emscripten_webgl_get_program_parameter_d*(program: GLint; param: GLenum): cdouble
proc emscripten_webgl_get_program_info_log_utf8*(program: GLint): cstring
proc emscripten_webgl_get_vertex_attrib_d*(index: cint; param: GLenum): cdouble
proc emscripten_webgl_get_vertex_attrib_o*(index: cint; param: GLenum): GLint
proc emscripten_webgl_get_vertex_attrib_v*(index: cint; param: GLenum; dst: pointer; dstLength: cint; dstType: EMSCRIPTEN_WEBGL_PARAM_TYPE): cint
proc emscripten_webgl_get_uniform_d*(program: GLint; location: cint): cdouble
proc emscripten_webgl_get_uniform_v*(program: GLint; location: cint; dst: pointer; dstLength: cint; dstType: EMSCRIPTEN_WEBGL_PARAM_TYPE): cint
proc emscripten_webgl_get_parameter_v*(param: GLenum; dst: pointer; dstLength: cint; dstType: EMSCRIPTEN_WEBGL_PARAM_TYPE): cint
proc emscripten_webgl_get_parameter_d*(param: GLenum): cdouble
proc emscripten_webgl_get_parameter_o*(param: GLenum): GLint
proc emscripten_webgl_get_parameter_utf8*(param: GLenum): cstring
proc emscripten_webgl_get_parameter_i64v*(param: GLenum; dst: ptr GLint64)

{.pop.}

# template emscripten_set_webglcontextlost_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_webglcontextlost_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)
# template emscripten_set_webglcontextrestored_callback*(target, userData, useCapture, callback: untyped): untyped = emscripten_set_webglcontextrestored_callback_on_thread((target), (userData), (useCapture), (callback), EM_CALLBACK_THREAD_CONTEXT_CALLING_THREAD)