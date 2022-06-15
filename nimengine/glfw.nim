import std/strutils

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.passC: "-I" & currentSourceDir() & "/glfw".}
{.passC: "-I" & currentSourceDir() & "/glfw/include".}

when defined(emscripten):
  {.passL: "-s USE_WEBGL2=1 -s USE_GLFW=3".}
else:
  when defined(windows):
    when defined(gcc):
      {.passC: "-D_GLFW_WIN32", passL: "-lopengl32 -lgdi32 -limm32".}
    when defined(vcc):
      {.passC: "-D_GLFW_WIN32".}
      {.link: "kernel32.lib".}
      {.link: "gdi32.lib".}
      {.link: "shell32.lib".}
      {.link: "user32.lib".}
      {.link: "imm32.lib".}
    {.
      compile: "glfw/src/win32_init.c",
      compile: "glfw/src/win32_joystick.c",
      compile: "glfw/src/win32_monitor.c",
      compile: "glfw/src/win32_time.c",
      compile: "glfw/src/win32_thread.c",
      compile: "glfw/src/win32_window.c",
      compile: "glfw/src/wgl_context.c",
      compile: "glfw/src/egl_context.c",
      compile: "glfw/src/osmesa_context.c"
    .}
  elif defined(macosx):
    {.
      passC: "-D_GLFW_COCOA",
      passL: "-framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo",
      compile: "glfw/src/cocoa_init.m",
      compile: "glfw/src/cocoa_joystick.m",
      compile: "glfw/src/cocoa_monitor.m",
      compile: "glfw/src/cocoa_window.m",
      compile: "glfw/src/cocoa_time.c",
      compile: "glfw/src/posix_thread.c",
      compile: "glfw/src/nsgl_context.m",
      compile: "glfw/src/egl_context.c",
      compile: "glfw/src/osmesa_context.c"
    .}
  elif defined(linux):
    {.passL: "-pthread -lGL -lX11 -lXrandr -lXxf86vm -lXi -lXcursor -lm -lXinerama".}

    when defined(wayland):
      {.
        passC: "-D_GLFW_WAYLAND",
        compile: "glfw/src/wl_init.c",
        compile: "glfw/src/wl_monitor.c",
        compile: "glfw/src/wl_window.c",
        compile: "glfw/src/posix_time.c",
        compile: "glfw/src/posix_thread.c",
        compile: "glfw/src/xkb_unicode.c",
        compile: "glfw/src/egl_context.c",
        compile: "glfw/src/osmesa_context.c"
      .}
    else:
      {.
        passC: "-D_GLFW_X11",
        compile: "glfw/src/x11_init.c",
        compile: "glfw/src/x11_monitor.c",
        compile: "glfw/src/x11_window.c",
        compile: "glfw/src/xkb_unicode.c",
        compile: "glfw/src/posix_time.c",
        compile: "glfw/src/posix_thread.c",
        compile: "glfw/src/glx_context.c",
        compile: "glfw/src/egl_context.c",
        compile: "glfw/src/osmesa_context.c"
      .}

    {.compile: "glfw/src/linux_joystick.c".}
  else:
    {.
      compile: "glfw/src/null_init.c",
      compile: "glfw/src/null_monitor.c",
      compile: "glfw/src/null_window.c",
      compile: "glfw/src/null_joystick.c",
      compile: "glfw/src/posix_time.c",
      compile: "glfw/src/posix_thread.c",
      compile: "glfw/src/osmesa_context.c"
    .}

  {.
    compile: "glfw/src/context.c",
    compile: "glfw/src/init.c",
    compile: "glfw/src/input.c",
    compile: "glfw/src/monitor.c",
    compile: "glfw/src/vulkan.c",
    compile: "glfw/src/window.c"
  .}

const GLFW_VERSION_MAJOR* = 3
const GLFW_VERSION_MINOR* = 3
const GLFW_VERSION_REVISION* = 2
const GLFW_TRUE* = 1
const GLFW_FALSE* = 0
const GLFW_RELEASE* = 0
const GLFW_PRESS* = 1
const GLFW_REPEAT* = 2
const GLFW_KEY_UNKNOWN* = - 1
const GLFW_KEY_SPACE* = 32
const GLFW_KEY_APOSTROPHE* = 39
const GLFW_KEY_COMMA* = 44
const GLFW_KEY_MINUS* = 45
const GLFW_KEY_PERIOD* = 46
const GLFW_KEY_SLASH* = 47
const GLFW_KEY_0* = 48
const GLFW_KEY_1* = 49
const GLFW_KEY_2* = 50
const GLFW_KEY_3* = 51
const GLFW_KEY_4* = 52
const GLFW_KEY_5* = 53
const GLFW_KEY_6* = 54
const GLFW_KEY_7* = 55
const GLFW_KEY_8* = 56
const GLFW_KEY_9* = 57
const GLFW_KEY_SEMICOLON* = 59
const GLFW_KEY_EQUAL* = 61
const GLFW_KEY_A* = 65
const GLFW_KEY_B* = 66
const GLFW_KEY_C* = 67
const GLFW_KEY_D* = 68
const GLFW_KEY_E* = 69
const GLFW_KEY_F* = 70
const GLFW_KEY_G* = 71
const GLFW_KEY_H* = 72
const GLFW_KEY_I* = 73
const GLFW_KEY_J* = 74
const GLFW_KEY_K* = 75
const GLFW_KEY_L* = 76
const GLFW_KEY_M* = 77
const GLFW_KEY_N* = 78
const GLFW_KEY_O* = 79
const GLFW_KEY_P* = 80
const GLFW_KEY_Q* = 81
const GLFW_KEY_R* = 82
const GLFW_KEY_S* = 83
const GLFW_KEY_T* = 84
const GLFW_KEY_U* = 85
const GLFW_KEY_V* = 86
const GLFW_KEY_W* = 87
const GLFW_KEY_X* = 88
const GLFW_KEY_Y* = 89
const GLFW_KEY_Z* = 90
const GLFW_KEY_LEFT_BRACKET* = 91
const GLFW_KEY_BACKSLASH* = 92
const GLFW_KEY_RIGHT_BRACKET* = 93
const GLFW_KEY_GRAVE_ACCENT* = 96
const GLFW_KEY_WORLD_1* = 161
const GLFW_KEY_WORLD_2* = 162
const GLFW_KEY_ESCAPE* = 256
const GLFW_KEY_ENTER* = 257
const GLFW_KEY_TAB* = 258
const GLFW_KEY_BACKSPACE* = 259
const GLFW_KEY_INSERT* = 260
const GLFW_KEY_DELETE* = 261
const GLFW_KEY_RIGHT* = 262
const GLFW_KEY_LEFT* = 263
const GLFW_KEY_DOWN* = 264
const GLFW_KEY_UP* = 265
const GLFW_KEY_PAGE_UP* = 266
const GLFW_KEY_PAGE_DOWN* = 267
const GLFW_KEY_HOME* = 268
const GLFW_KEY_END* = 269
const GLFW_KEY_CAPS_LOCK* = 280
const GLFW_KEY_SCROLL_LOCK* = 281
const GLFW_KEY_NUM_LOCK* = 282
const GLFW_KEY_PRINT_SCREEN* = 283
const GLFW_KEY_PAUSE* = 284
const GLFW_KEY_F1* = 290
const GLFW_KEY_F2* = 291
const GLFW_KEY_F3* = 292
const GLFW_KEY_F4* = 293
const GLFW_KEY_F5* = 294
const GLFW_KEY_F6* = 295
const GLFW_KEY_F7* = 296
const GLFW_KEY_F8* = 297
const GLFW_KEY_F9* = 298
const GLFW_KEY_F10* = 299
const GLFW_KEY_F11* = 300
const GLFW_KEY_F12* = 301
const GLFW_KEY_F13* = 302
const GLFW_KEY_F14* = 303
const GLFW_KEY_F15* = 304
const GLFW_KEY_F16* = 305
const GLFW_KEY_F17* = 306
const GLFW_KEY_F18* = 307
const GLFW_KEY_F19* = 308
const GLFW_KEY_F20* = 309
const GLFW_KEY_F21* = 310
const GLFW_KEY_F22* = 311
const GLFW_KEY_F23* = 312
const GLFW_KEY_F24* = 313
const GLFW_KEY_F25* = 314
const GLFW_KEY_KP_0* = 320
const GLFW_KEY_KP_1* = 321
const GLFW_KEY_KP_2* = 322
const GLFW_KEY_KP_3* = 323
const GLFW_KEY_KP_4* = 324
const GLFW_KEY_KP_5* = 325
const GLFW_KEY_KP_6* = 326
const GLFW_KEY_KP_7* = 327
const GLFW_KEY_KP_8* = 328
const GLFW_KEY_KP_9* = 329
const GLFW_KEY_KP_DECIMAL* = 330
const GLFW_KEY_KP_DIVIDE* = 331
const GLFW_KEY_KP_MULTIPLY* = 332
const GLFW_KEY_KP_SUBTRACT* = 333
const GLFW_KEY_KP_ADD* = 334
const GLFW_KEY_KP_ENTER* = 335
const GLFW_KEY_KP_EQUAL* = 336
const GLFW_KEY_LEFT_SHIFT* = 340
const GLFW_KEY_LEFT_CONTROL* = 341
const GLFW_KEY_LEFT_ALT* = 342
const GLFW_KEY_LEFT_SUPER* = 343
const GLFW_KEY_RIGHT_SHIFT* = 344
const GLFW_KEY_RIGHT_CONTROL* = 345
const GLFW_KEY_RIGHT_ALT* = 346
const GLFW_KEY_RIGHT_SUPER* = 347
const GLFW_KEY_MENU* = 348
const GLFW_KEY_LAST* = GLFW_KEY_MENU
const GLFW_MOD_SHIFT* = 0x0001
const GLFW_MOD_CONTROL* = 0x0002
const GLFW_MOD_ALT* = 0x0004
const GLFW_MOD_SUPER* = 0x0008
const GLFW_MOUSE_BUTTON_1* = 0
const GLFW_MOUSE_BUTTON_2* = 1
const GLFW_MOUSE_BUTTON_3* = 2
const GLFW_MOUSE_BUTTON_4* = 3
const GLFW_MOUSE_BUTTON_5* = 4
const GLFW_MOUSE_BUTTON_6* = 5
const GLFW_MOUSE_BUTTON_7* = 6
const GLFW_MOUSE_BUTTON_8* = 7
const GLFW_MOUSE_BUTTON_LAST* = GLFW_MOUSE_BUTTON_8
const GLFW_MOUSE_BUTTON_LEFT* = GLFW_MOUSE_BUTTON_1
const GLFW_MOUSE_BUTTON_RIGHT* = GLFW_MOUSE_BUTTON_2
const GLFW_MOUSE_BUTTON_MIDDLE* = GLFW_MOUSE_BUTTON_3
const GLFW_JOYSTICK_1* = 0
const GLFW_JOYSTICK_2* = 1
const GLFW_JOYSTICK_3* = 2
const GLFW_JOYSTICK_4* = 3
const GLFW_JOYSTICK_5* = 4
const GLFW_JOYSTICK_6* = 5
const GLFW_JOYSTICK_7* = 6
const GLFW_JOYSTICK_8* = 7
const GLFW_JOYSTICK_9* = 8
const GLFW_JOYSTICK_10* = 9
const GLFW_JOYSTICK_11* = 10
const GLFW_JOYSTICK_12* = 11
const GLFW_JOYSTICK_13* = 12
const GLFW_JOYSTICK_14* = 13
const GLFW_JOYSTICK_15* = 14
const GLFW_JOYSTICK_16* = 15
const GLFW_JOYSTICK_LAST* = GLFW_JOYSTICK_16
const GLFW_NOT_INITIALIZED* = 0x00010001
const GLFW_NO_CURRENT_CONTEXT* = 0x00010002
const GLFW_INVALID_ENUM* = 0x00010003
const GLFW_INVALID_VALUE* = 0x00010004
const GLFW_OUT_OF_MEMORY* = 0x00010005
const GLFW_API_UNAVAILABLE* = 0x00010006
const GLFW_VERSION_UNAVAILABLE* = 0x00010007
const GLFW_PLATFORM_ERROR* = 0x00010008
const GLFW_FORMAT_UNAVAILABLE* = 0x00010009
const GLFW_NO_WINDOW_CONTEXT* = 0x0001000A
const GLFW_FOCUSED* = 0x00020001
const GLFW_ICONIFIED* = 0x00020002
const GLFW_RESIZABLE* = 0x00020003
const GLFW_VISIBLE* = 0x00020004
const GLFW_DECORATED* = 0x00020005
const GLFW_AUTO_ICONIFY* = 0x00020006
const GLFW_FLOATING* = 0x00020007
const GLFW_MAXIMIZED* = 0x00020008
const GLFW_FOCUS_ON_SHOW* = 0x0002000C
const GLFW_RED_BITS* = 0x00021001
const GLFW_GREEN_BITS* = 0x00021002
const GLFW_BLUE_BITS* = 0x00021003
const GLFW_ALPHA_BITS* = 0x00021004
const GLFW_DEPTH_BITS* = 0x00021005
const GLFW_STENCIL_BITS* = 0x00021006
const GLFW_ACCUM_RED_BITS* = 0x00021007
const GLFW_ACCUM_GREEN_BITS* = 0x00021008
const GLFW_ACCUM_BLUE_BITS* = 0x00021009
const GLFW_ACCUM_ALPHA_BITS* = 0x0002100A
const GLFW_AUX_BUFFERS* = 0x0002100B
const GLFW_STEREO* = 0x0002100C
const GLFW_SAMPLES* = 0x0002100D
const GLFW_SRGB_CAPABLE* = 0x0002100E
const GLFW_REFRESH_RATE* = 0x0002100F
const GLFW_DOUBLEBUFFER* = 0x00021010
const GLFW_CLIENT_API* = 0x00022001
const GLFW_CONTEXT_VERSION_MAJOR* = 0x00022002
const GLFW_CONTEXT_VERSION_MINOR* = 0x00022003
const GLFW_CONTEXT_REVISION* = 0x00022004
const GLFW_CONTEXT_ROBUSTNESS* = 0x00022005
const GLFW_OPENGL_FORWARD_COMPAT* = 0x00022006
const GLFW_OPENGL_DEBUG_CONTEXT* = 0x00022007
const GLFW_OPENGL_PROFILE* = 0x00022008
const GLFW_CONTEXT_RELEASE_BEHAVIOR* = 0x00022009
const GLFW_CONTEXT_NO_ERROR* = 0x0002200A
const GLFW_CONTEXT_CREATION_API* = 0x0002200B
const GLFW_NO_API* = 0
const GLFW_OPENGL_API* = 0x00030001
const GLFW_OPENGL_ES_API* = 0x00030002
const GLFW_NO_ROBUSTNESS* = 0
const GLFW_NO_RESET_NOTIFICATION* = 0x00031001
const GLFW_LOSE_CONTEXT_ON_RESET* = 0x00031002
const GLFW_OPENGL_ANY_PROFILE* = 0
const GLFW_OPENGL_CORE_PROFILE* = 0x00032001
const GLFW_OPENGL_COMPAT_PROFILE* = 0x00032002
const GLFW_CURSOR* = 0x00033001
const GLFW_STICKY_KEYS* = 0x00033002
const GLFW_STICKY_MOUSE_BUTTONS* = 0x00033003
const GLFW_CURSOR_NORMAL* = 0x00034001
const GLFW_CURSOR_HIDDEN* = 0x00034002
const GLFW_CURSOR_DISABLED* = 0x00034003
const GLFW_ANY_RELEASE_BEHAVIOR* = 0
const GLFW_RELEASE_BEHAVIOR_FLUSH* = 0x00035001
const GLFW_RELEASE_BEHAVIOR_NONE* = 0x00035002
const GLFW_NATIVE_CONTEXT_API* = 0x00036001
const GLFW_EGL_CONTEXT_API* = 0x00036002
const GLFW_ARROW_CURSOR* = 0x00036001
const GLFW_IBEAM_CURSOR* = 0x00036002
const GLFW_CROSSHAIR_CURSOR* = 0x00036003
const GLFW_HAND_CURSOR* = 0x00036004
const GLFW_HRESIZE_CURSOR* = 0x00036005
const GLFW_VRESIZE_CURSOR* = 0x00036006
const GLFW_CONNECTED* = 0x00040001
const GLFW_DISCONNECTED* = 0x00040002
const GLFW_DONT_CARE* = -1

type
  GLFWglproc* = proc() {.cdecl.}
  GLFWvkproc* = proc() {.cdecl.}
  GLFWmonitor* = pointer
  GLFWwindow* = pointer
  GLFWcursorhandle* = pointer
  GLFWerrorfun* = proc (errorCode: cint, description: cstring) {.cdecl.}
  GLFWwindowposfun* = proc (window: GLFWwindow, x: cint, y: cint) {.cdecl.}
  GLFWwindowsizefun* = proc (window: GLFWwindow, width: cint, height: cint) {.cdecl.}
  GLFWwindowclosefun* = proc (window: GLFWwindow) {.cdecl.}
  GLFWwindowrefreshfun* = proc (window: GLFWwindow) {.cdecl.}
  GLFWwindowfocusfun* = proc (window: GLFWwindow, focused: cint) {.cdecl.}
  GLFWwindowiconifyfun* = proc (window: GLFWwindow, iconified: cint) {.cdecl.}
  GLFWframebuffersizefun* = proc (window: GLFWwindow, width: cint, height: cint) {.cdecl.}
  GLFWmousebuttonfun* = proc (window: GLFWwindow, button: cint, action: cint, modifiers: cint) {.cdecl.}
  GLFWcursorposfun* = proc (window: GLFWwindow, x: cdouble, y: cdouble) {.cdecl.}
  GLFWcursorenterfun* = proc (window: GLFWwindow, entered: cint) {.cdecl.}
  GLFWscrollfun* = proc (window: GLFWwindow, xoffset: cdouble, yoffset: cdouble) {.cdecl.}
  GLFWkeyfun* = proc (window: GLFWwindow, key: cint, scancode: cint, action: cint, modifiers: cint) {.cdecl.}
  GLFWcharfun* = proc (window: GLFWwindow, character: cuint) {.cdecl.}
  GLFWcharmodsfun* = proc (window: GLFWwindow, codepoint: cuint, mods: cint) {.cdecl.}
  GLFWdropfun* = proc (window: GLFWwindow, count: cint, paths: cstringArray) {.cdecl.}
  GLFWmonitorfun* = proc (monitor: GLFWmonitor, connected: cint) {.cdecl.}
  GLFWjoystickfun* = proc (joy : cint, event: cint)

  GLFWvidmode* {.pure, final.} = object
    width*: cint
    height*: cint
    redBits*: cint
    greenBits*: cint
    blueBits*: cint
    refreshRate*: cint

  GLFWgammaramp* {.pure, final.} = object
    red*: ptr cushort
    green*: ptr cushort
    blue*: ptr cushort
    size*: cuint

  GLFWimage* {.pure, final.} = object
    width*: cint
    height*: cint
    pixels*: cstring

{.push importc, cdecl.}

proc glfwInit*(): cint
proc glfwTerminate*()
proc glfwGetVersion*(major: ptr cint, minor: ptr cint, rev: ptr cint)
proc glfwGetVersionString*(): cstring
proc glfwGetRequiredInstanceExtensions*(count: ptr cuint): ptr cstring
proc glfwExtensionSupported*(extension: cstring): cint
proc glfwGetProcAddress*(procname: cstring): GLFWglproc
proc glfwCreateCursor*(image: ptr GLFWimage, xhot, yhot: cint): GLFWcursorhandle
proc glfwCreateStandardCursor*(shape: cint): GLFWcursorhandle
proc glfwDestroyCursor*(cusor: GLFWcursorhandle)
proc glfwGetTime*(): cdouble
proc glfwGetTimerFrequency*(): culonglong
proc glfwGetTimerValue*(): culonglong
proc glfwSwapInterval*(interval: cint)
proc glfwWaitEventsTimeout*(timeout: cdouble)
proc glfwSetTime*(time: cdouble)
proc glfwPollEvents*()
proc glfwPostEmptyEvent*()
proc glfwWaitEvents*()
proc glfwSetErrorCallback*(cbfun: GLFWerrorfun): GLFWerrorfun
proc glfwJoystickPresent*(joy: cint): cint
proc glfwGetJoystickAxes*(joy: cint, count: ptr cint): ptr cfloat
proc glfwGetJoystickButtons*(joy: cint, count: ptr cint): ptr uint8
proc glfwGetJoystickName*(joy: cint): cstring
proc glfwSetJoystickCallback*(cbfun: GLFWjoystickfun): GLFWjoystickfun
proc glfwGetMonitors*(count: ptr cint): ptr GLFWmonitor
proc glfwGetPrimaryMonitor*(): GLFWmonitor
proc glfwGetGammaRamp*(monitor: GLFWmonitor): ptr GLFWgammaramp
proc glfwGetMonitorName*(monitor: GLFWmonitor): cstring
proc glfwGetMonitorPhysicalSize*(monitor: GLFWmonitor, width: ptr cint, height: ptr cint)
proc glfwGetMonitorContentScale*(monitor: GLFWmonitor, xscale: ptr cfloat, yscale: ptr cfloat)
proc glfwGetMonitorPos*(monitor: GLFWmonitor, xpos: ptr cint, ypos: ptr cint)
proc glfwGetVideoMode*(monitor: GLFWmonitor): ptr GLFWvidmode
proc glfwGetVideoModes*(monitor: GLFWmonitor, count: ptr cint): ptr GLFWvidmode
proc glfwSetMonitorCallback*(cbfun: GLFWmonitorfun): GLFWmonitorfun
proc glfwSetGamma*(monitor: GLFWmonitor, gamma: cfloat)
proc glfwSetGammaRamp*(monitor: GLFWmonitor, ramp: ptr GLFWgammaramp)
proc glfwCreateWindow*(width: cint, height: cint, title: cstring, monitor: GLFWmonitor, share: GLFWwindow): GLFWwindow
proc glfwDefaultWindowHints*()
proc glfwDestroyWindow*(window: GLFWwindow)
proc glfwFocusWindow*(window: GLFWwindow)
proc glfwGetClipboardString*(window: GLFWwindow): cstring
proc glfwGetCursorPos*(window: GLFWwindow, xpos: ptr cdouble, ypos: ptr cdouble)
proc glfwGetCurrentContext*(): GLFWwindow
proc glfwGetFramebufferSize*(window: GLFWwindow, width: ptr cint, height: ptr cint)
proc glfwGetInputMode*(window: GLFWwindow, mode: cint): cint
proc glfwGetKey*(window: GLFWwindow, key: cint): cint
proc glfwGetMouseButton*(window: GLFWwindow, button: cint): cint
proc glfwGetWindowAttrib*(window: GLFWwindow, attrib: cint): cint
proc glfwGetWindowContentScale*(window: GLFWwindow, xscale: ptr cfloat, yscale: ptr cfloat)
proc glfwGetWindowFrameSize*(window: GLFWwindow, left, top, right, bottom: ptr int)
proc glfwGetWindowMonitor*(window: GLFWwindow): GLFWmonitor
proc glfwGetWindowPos*(window: GLFWwindow, xpos: ptr cint, ypos: ptr cint)
proc glfwGetWindowSize*(window: GLFWwindow, width: ptr cint, height: ptr cint)
proc glfwGetWindowUserPointer*(window: GLFWwindow): pointer
proc glfwHideWindow*(window: GLFWwindow)
proc glfwIconifyWindow*(window: GLFWwindow)
proc glfwMakeContextCurrent*(window: GLFWwindow)
proc glfwMaximizeWindow*(window: GLFWwindow)
proc glfwRestoreWindow*(window: GLFWwindow)
proc glfwSetCharCallback*(window: GLFWwindow, cbfun: GLFWcharfun): GLFWcharfun
proc glfwSetCharModsCallback*(window: GLFWwindow, cbfun: GLFWcharmodsfun): GLFWcharmodsfun
proc glfwSetClipboardString*(window: GLFWwindow, string: cstring)
proc glfwSetCursor*(window: GLFWwindow, cursor: GLFWcursorhandle)
proc glfwSetCursorEnterCallback*(window: GLFWwindow, cbfun: GLFWcursorenterfun): GLFWcursorenterfun
proc glfwSetCursorPos*(window: GLFWwindow, xpos: cdouble, ypos: cdouble)
proc glfwSetCursorPosCallback*(window: GLFWwindow, cbfun: GLFWcursorposfun): GLFWcursorposfun
proc glfwSetDropCallback*(window: GLFWwindow, cbfun: GLFWdropfun)
proc glfwSetFramebufferSizeCallback*(window: GLFWwindow, cbfun: GLFWframebuffersizefun): GLFWframebuffersizefun
proc glfwSetInputMode*(window: GLFWwindow, mode: cint, value: cint)
proc glfwSetKeyCallback*(window: GLFWwindow, cbfun: GLFWkeyfun): GLFWkeyfun
proc glfwSetMouseButtonCallback*(window: GLFWwindow, cbfun: GLFWmousebuttonfun): GLFWmousebuttonfun
proc glfwSetScrollCallback*(window: GLFWwindow, cbfun: GLFWscrollfun): GLFWscrollfun
proc glfwSetWindowAspectRatio*(window: GLFWwindow, numer, denom: cint)
proc glfwSetWindowCloseCallback*(window: GLFWwindow, cbfun: GLFWwindowclosefun): GLFWwindowclosefun
proc glfwSetWindowFocusCallback*(window: GLFWwindow, cbfun: GLFWwindowfocusfun): GLFWwindowfocusfun
proc glfwSetWindowIcon*(window: GLFWwindow, count: cint, image: ptr GLFWimage)
proc glfwSetWindowIconifyCallback*(window: GLFWwindow, cbfun: GLFWwindowiconifyfun): GLFWwindowiconifyfun
proc glfwSetWindowMonitor*(window: GLFWwindow, monitor: GLFWmonitor, xpos, ypos, width, height: cint)
proc glfwSetWindowPos*(window: GLFWwindow, xpos: cint, ypos: cint)
proc glfwSetWindowPosCallback*(window: GLFWwindow, cbfun: GLFWwindowposfun): GLFWwindowposfun
proc glfwSetWindowRefreshCallback*(window: GLFWwindow, cbfun: GLFWwindowrefreshfun): GLFWwindowrefreshfun
proc glfwSetWindowShouldClose*(window: GLFWwindow, value: cint)
proc glfwSetWindowSize*(window: GLFWwindow, width: cint, height: cint)
proc glfwSetWindowSizeCallback*(window: GLFWwindow, cbfun: GLFWwindowsizefun): GLFWwindowsizefun
proc glfwSetWindowSizeLimits*(window: GLFWwindow, minwidth, minheight, maxwidth, maxheight: cint)
proc glfwSetWindowTitle*(window: GLFWwindow, title: cstring)
proc glfwSetWindowUserPointer*(window: GLFWwindow, pointer: pointer)
proc glfwShowWindow*(window: GLFWwindow)
proc glfwSwapBuffers*(window: GLFWwindow)
proc glfwWindowShouldClose*(window: GLFWwindow): cint
proc glfwWindowHint*(target: cint, hint: cint)

type
  VkInstance* = pointer
  VkPhysicalDevice* = pointer
  VkAllocationCallbacks* = pointer
  VkSurfaceKHR* = pointer
  VkResult* = enum
    VK_ERROR_FRAGMENTED_POOL = -12
    VK_ERROR_FORMAT_NOT_SUPPORTED = -11
    VK_ERROR_TOO_MANY_OBJECTS = -10
    VK_ERROR_INCOMPATIBLE_DRIVER = -9
    VK_ERROR_FEATURE_NOT_PRESENT = -8
    VK_ERROR_EXTENSION_NOT_PRESENT = -7
    VK_ERROR_LAYER_NOT_PRESENT = -6
    VK_ERROR_MEMORY_MAP_FAILED = -5
    VK_ERROR_DEVICE_LOST = -4
    VK_ERROR_INITIALIZATION_FAILED = -3
    VK_ERROR_OUT_OF_DEVICE_MEMORY = -2
    VK_ERROR_OUT_OF_HOST_MEMORY = -1
    VK_SUCCESS = 0
    VK_NOT_READY = 1
    VK_TIMEOUT = 2
    VK_EVENT_SET = 3
    VK_EVENT_RESET = 4
    VK_INCOMPLETE = 5

proc glfwVulkanSupported*(): cint
proc glfwGetInstanceProcAddress*(instance: VkInstance, procname: cstring): GLFWvkproc
proc glfwGetPhysicalDevicePresentationSupport*(instance: VkInstance, device: VkPhysicalDevice, queuefamily: cuint): cint
proc glfwCreateWindowSurface*(instance: VkInstance, window: GLFWwindow, allocator: ptr VkAllocationCallbacks, surface: ptr VkSurfaceKHR): VkResult

when defined(windows):
  proc glfwGetWin32Window*(window: GLFWwindow): cint
when defined(macosx):
  proc glfwGetCocoaWindow*(window: GLFWwindow): clong

{.pop.}