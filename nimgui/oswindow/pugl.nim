import std/strutils
import std/strformat

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.passC: "-DPUGL_STATIC".}
{.passC: &" -I{currentSourceDir()}/pugl/include".}

{.compile: &"{currentSourceDir()}/pugl/src/common.c".}
{.compile: &"{currentSourceDir()}/pugl/src/internal.c".}

when defined(windows):
  when defined(gcc):
    {.passL: "-lopengl32 -ldwmapi -lgdi32".}
  when defined(vcc):
    {.link: "opengl32.lib".}
    {.link: "dwmapi.lib".}
    {.link: "gdi32.lib".}
    {.link: "user32.lib".}
  {.compile: &"{currentSourceDir()}/pugl/src/win.c".}
  {.compile: &"{currentSourceDir()}/pugl/src/win_gl.c".}

type
  PuglCoord* = int16
  PuglSpan* = uint16

  PuglRect* {.bycopy.} = object
    x*: PuglCoord
    y*: PuglCoord
    width*: PuglSpan
    height*: PuglSpan

  PuglStringHint* {.size: sizeof(cint).} = enum
    PUGL_CLASS_NAME = 1
    PUGL_WINDOW_TITLE

  PuglEventType* {.size: sizeof(cint).} = enum
    PUGL_NOTHING
    PUGL_REALIZE
    PUGL_UNREALIZE
    PUGL_CONFIGURE
    PUGL_UPDATE
    PUGL_EXPOSE
    PUGL_CLOSE
    PUGL_FOCUS_IN
    PUGL_FOCUS_OUT
    PUGL_KEY_PRESS
    PUGL_KEY_RELEASE
    PUGL_TEXT
    PUGL_POINTER_IN
    PUGL_POINTER_OUT
    PUGL_BUTTON_PRESS
    PUGL_BUTTON_RELEASE
    PUGL_MOTION
    PUGL_SCROLL
    PUGL_CLIENT
    PUGL_TIMER
    PUGL_LOOP_ENTER
    PUGL_LOOP_LEAVE
    PUGL_DATA_OFFER
    PUGL_DATA

  PuglEventFlag* {.size: sizeof(uint32).} = enum
    PUGL_IS_SEND_EVENT
    PUGL_IS_HINT

  PuglEventFlags* = uint32

  PuglCrossingMode* {.size: sizeof(cint).} = enum
    PUGL_NORMAL
    PUGL_GRAB
    PUGL_UNGRAB

  PuglAnyEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags

  PuglViewStyleFlag* {.size: sizeof(uint32).} = enum
    PUGL_MAPPED
    PUGL_MODAL
    PUGL_ABOVE
    PUGL_BELOW
    PUGL_HIDDEN
    PUGL_TALL
    PUGL_WIDE
    PUGL_FULLSCREEN
    PUGL_RESIZING
    PUGL_DEMANDING

  PuglViewStyleFlags* = uint32

  PuglRealizeEvent* = PuglAnyEvent
  PuglUnrealizeEvent* = PuglAnyEvent

  PuglConfigureEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    x*: PuglCoord
    y*: PuglCoord
    width*: PuglSpan
    height*: PuglSpan
    style*: PuglViewStyleFlags

  PuglLoopEnterEvent* = PuglAnyEvent
  PuglLoopLeaveEvent* = PuglAnyEvent
  PuglCloseEvent* = PuglAnyEvent
  PuglUpdateEvent* = PuglAnyEvent

  PuglExposeEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    x*: PuglCoord
    y*: PuglCoord
    width*: PuglSpan
    height*: PuglSpan

  PuglKey* {.size: sizeof(uint32).} = enum
    PUGL_BACKSPACE = 0x00000008
    PUGL_ENTER = 0x0000000D
    PUGL_ESCAPE = 0x0000001B
    PUGL_SPACE = 0x00000020
    PUGL_DELETE = 0x0000007F
    PUGL_F1 = 0x0000E000
    PUGL_F2
    PUGL_F3
    PUGL_F4
    PUGL_F5
    PUGL_F6
    PUGL_F7
    PUGL_F8
    PUGL_F9
    PUGL_F10
    PUGL_F11
    PUGL_F12
    PUGL_PAGE_UP = 0xE031
    PUGL_PAGE_DOWN
    PUGL_END
    PUGL_HOME
    PUGL_LEFT
    PUGL_UP
    PUGL_RIGHT
    PUGL_DOWN
    PUGL_PRINT_SCREEN = 0xE041
    PUGL_INSERT
    PUGL_PAUSE
    PUGL_MENU
    PUGL_NUM_LOCK
    PUGL_SCROLL_LOCK
    PUGL_CAPS_LOCK
    PUGL_SHIFT_L = 0xE051
    PUGL_SHIFT_R
    PUGL_CTRL_L
    PUGL_CTRL_R
    PUGL_ALT_L
    PUGL_ALT_R
    PUGL_SUPER_L
    PUGL_SUPER_R
    PUGL_PAD_0 = 0xE060
    PUGL_PAD_1
    PUGL_PAD_2
    PUGL_PAD_3
    PUGL_PAD_4
    PUGL_PAD_5
    PUGL_PAD_6
    PUGL_PAD_7
    PUGL_PAD_8
    PUGL_PAD_9
    PUGL_PAD_ENTER
    PUGL_PAD_PAGE_UP = 0xE071
    PUGL_PAD_PAGE_DOWN
    PUGL_PAD_END
    PUGL_PAD_HOME
    PUGL_PAD_LEFT
    PUGL_PAD_UP
    PUGL_PAD_RIGHT
    PUGL_PAD_DOWN
    PUGL_PAD_CLEAR = 0xE09D
    PUGL_PAD_INSERT
    PUGL_PAD_DELETE
    PUGL_PAD_EQUAL
    PUGL_PAD_MULTIPLY = 0xE0AA
    PUGL_PAD_ADD
    PUGL_PAD_SEPARATOR
    PUGL_PAD_SUBTRACT
    PUGL_PAD_DECIMAL
    PUGL_PAD_DIVIDE

  PuglMod* {.size: sizeof(uint32).} = enum
    PUGL_SHIFT
    PUGL_CTRL
    PUGL_ALT
    PUGL_SUPER

  PuglMods* = uint32

  PuglFocusEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    mode*: PuglCrossingMode

  PuglKeyEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods
    keycode*: uint32
    key*: PuglKey

  PuglTextEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods
    keycode*: uint32
    character*: uint32
    `string`*: array[8, uint8]

  PuglScrollDirection* {.size: sizeof(uint32).} = enum
    PUGL_UP
    PUGL_DOWN
    PUGL_LEFT
    PUGL_RIGHT
    PUGL_SMOOTH

  PuglCrossingEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods
    mode*: PuglCrossingMode

  PuglButtonEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods
    button*: uint32

  PuglMotionEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods

  PuglScrollEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    x*: float64
    y*: float64
    xRoot*: float64
    yRoot*: float64
    state*: PuglMods
    direction*: PuglScrollDirection
    dx*: float64
    dy*: float64

  PuglClientEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    data1*: pointer
    data2*: pointer

  PuglTimerEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    id*: pointer

  PuglDataOfferEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64

  PuglDataEvent* {.bycopy.} = object
    `type`*: PuglEventType
    flags*: PuglEventFlags
    time*: float64
    typeIndex*: uint32

  PuglEvent* {.bycopy, union.} = object
    `any`: PuglAnyEvent
    `type`: PuglEventType
    button: PuglButtonEvent
    configure: PuglConfigureEvent
    expose: PuglExposeEvent
    key: PuglKeyEvent
    text: PuglTextEvent
    crossing: PuglCrossingEvent
    motion: PuglMotionEvent
    scroll: PuglScrollEvent
    focus: PuglFocusEvent
    client: PuglClientEvent
    timer: PuglTimerEvent
    offer: PuglDataOfferEvent
    data: PuglDataEvent

  PuglStatus* {.size: sizeof(cint).} = enum
    PUGL_SUCCESS
    PUGL_FAILURE
    PUGL_UNKNOWN_ERROR
    PUGL_BAD_BACKEND
    PUGL_BAD_CONFIGURATION
    PUGL_BAD_PARAMETER
    PUGL_BACKEND_FAILED
    PUGL_REGISTRATION_FAILED
    PUGL_REALIZE_FAILED
    PUGL_SET_FORMAT_FAILED
    PUGL_CREATE_CONTEXT_FAILED
    PUGL_UNSUPPORTED
    PUGL_NO_MEMORY

  PuglWorld* = object
  PuglWorldHandle* = pointer

  PuglWorldType* {.size: sizeof(cint).} = enum
    PUGL_PROGRAM
    PUGL_MODULE

  PuglWorldFlag* {.size: sizeof(uint32).} = enum
    PUGL_WORLD_THREADS

  PuglWorldFlags* = uint32

  PuglView* = object
  PuglBackend* = object

  PuglNativeView* = pointer
  PuglHandle* = pointer

  PuglViewHint* {.size: sizeof(cint).} = enum
    PUGL_CONTEXT_API
    PUGL_CONTEXT_VERSION_MAJOR
    PUGL_CONTEXT_VERSION_MINOR
    PUGL_CONTEXT_PROFILE
    PUGL_CONTEXT_DEBUG
    PUGL_RED_BITS
    PUGL_GREEN_BITS
    PUGL_BLUE_BITS
    PUGL_ALPHA_BITS
    PUGL_DEPTH_BITS
    PUGL_STENCIL_BITS
    PUGL_SAMPLE_BUFFERS
    PUGL_SAMPLES
    PUGL_DOUBLE_BUFFER
    PUGL_SWAP_INTERVAL
    PUGL_RESIZABLE
    PUGL_IGNORE_KEY_REPEAT
    PUGL_REFRESH_RATE
    PUGL_VIEW_TYPE_ENUM
    PUGL_DARK_FRAME

  PuglViewHintValue* {.size: sizeof(cint).} = enum
    PUGL_DONT_CARE = -1
    PUGL_FALSE = 0
    PUGL_TRUE = 1
    PUGL_OPENGL_API = 2
    PUGL_OPENGL_ES_API = 3
    PUGL_OPENGL_CORE_PROFILE = 4
    PUGL_OPENGL_COMPATIBILITY_PROFILE = 5

  PuglViewType* {.size: sizeof(cint).} = enum
    PUGL_NORMAL
    PUGL_UTILITY
    PUGL_DIALOG

  PuglSizeHint* {.size: sizeof(cint).} = enum
    PUGL_DEFAULT_SIZE
    PUGL_MIN_SIZE
    PUGL_MAX_SIZE
    PUGL_FIXED_ASPECT
    PUGL_MIN_ASPECT
    PUGL_MAX_ASPECT

  PuglShowCommand* {.size: sizeof(cint).} = enum
    PUGL_PASSIVE
    PUGL_RAISE
    PUGL_FORCE_RAISE

  PuglCursor* {.size: sizeof(cint).} = enum
    PUGL_ARROW
    PUGL_CARET
    PUGL_CROSSHAIR
    PUGL_HAND
    PUGL_NO
    PUGL_LEFT_RIGHT
    PUGL_UP_DOWN
    PUGL_UP_LEFT_DOWN_RIGHT
    PUGL_UP_RIGHT_DOWN_LEFT
    PUGL_ALL_SCROLL

  PuglEventFunc* = proc(view: ptr PuglView, event: ptr PuglEvent): PuglStatus {.cdecl.}

{.push discardable, importc, cdecl.}

proc puglStrerror*(status: PuglStatus): cstring
proc puglNewWorld*(`type`: PuglWorldType, flags: PuglWorldFlags): ptr PuglWorld
proc puglFreeWorld*(world: ptr PuglWorld)
proc puglSetWorldHandle*(world: ptr PuglWorld, handle: PuglWorldHandle)
proc puglGetWorldHandle*(world: ptr PuglWorld): PuglWorldHandle
proc puglGetNativeWorld*(world: ptr PuglWorld): pointer
proc puglSetWorldString*(world: ptr PuglWorld, key: PuglStringHint, value: cstring): PuglStatus
proc puglGetWorldString*(world: ptr PuglWorld, key: PuglStringHint): cstring
proc puglGetTime*(world: ptr PuglWorld): float64
proc puglUpdate*(world: ptr PuglWorld, timeout: float64): PuglStatus
proc puglNewView*(world: ptr PuglWorld): ptr PuglView
proc puglFreeView*(view: ptr PuglView)
proc puglGetWorld*(view: ptr PuglView): ptr PuglWorld
proc puglSetHandle*(view: ptr PuglView, handle: PuglHandle)
proc puglGetHandle*(view: ptr PuglView): PuglHandle
proc puglSetBackend*(view: ptr PuglView, backend: ptr PuglBackend): PuglStatus
proc puglGetBackend*(view: ptr PuglView): ptr PuglBackend
proc puglSetEventFunc*(view: ptr PuglView, eventFunc: PuglEventFunc): PuglStatus
proc puglSetViewHint*(view: ptr PuglView, hint: PuglViewHint, value: cint): PuglStatus
proc puglGetViewHint*(view: ptr PuglView, hint: PuglViewHint): cint
proc puglSetViewString*(view: ptr PuglView, key: PuglStringHint, value: cstring): PuglStatus
proc puglGetViewString*(view: ptr PuglView, key: PuglStringHint): cstring
proc puglGetScaleFactor*(view: ptr PuglView): float64
proc puglGetFrame*(view: ptr PuglView): PuglRect
proc puglSetFrame*(view: ptr PuglView, frame: PuglRect): PuglStatus
proc puglSetPosition*(view: ptr PuglView, x, y: cint): PuglStatus
proc puglSetSize*(view: ptr PuglView, width, height: cuint): PuglStatus
proc puglSetSizeHint*(view: ptr PuglView, hint: PuglSizeHint, width, height: PuglSpan): PuglStatus
proc puglSetParentWindow*(view: ptr PuglView, parent: PuglNativeView): PuglStatus
proc puglGetParentWindow*(view: ptr PuglView): PuglNativeView
proc puglSetTransientParent*(view: ptr PuglView, parent: PuglNativeView): PuglStatus
proc puglGetTransientParent*(view: ptr PuglView): PuglNativeView
proc puglRealize*(view: ptr PuglView): PuglStatus
proc puglUnrealize*(view: ptr PuglView): PuglStatus
proc puglShow*(view: ptr PuglView, command: PuglShowCommand): PuglStatus
proc puglHide*(view: ptr PuglView): PuglStatus
proc puglSetViewStyle*(view: ptr PuglView, flags: PuglViewStyleFlags): PuglStatus
proc puglGetViewStyle*(view: ptr PuglView): PuglViewStyleFlags
proc puglGetVisible*(view: ptr PuglView): bool
proc puglGetNativeView*(view: ptr PuglView): PuglNativeView
proc puglGetContext*(view: ptr PuglView): pointer
proc puglPostRedisplay*(view: ptr PuglView): PuglStatus
proc puglPostRedisplayRect*(view: ptr PuglView, rect: PuglRect): PuglStatus
proc puglGrabFocus*(view: ptr PuglView): PuglStatus
proc puglHasFocus*(view: ptr PuglView): bool
proc puglPaste*(view: ptr PuglView): PuglStatus
proc puglGetNumClipboardTypes*(view: ptr PuglView): uint32
proc puglGetClipboardType*(view: ptr PuglView, typeIndex: uint32): cstring
proc puglAcceptOffer*(view: ptr PuglView, offer: ptr PuglDataOfferEvent, typeIndex: uint32): PuglStatus
proc puglSetClipboard*(view: ptr PuglView, `type`: cstring, data: pointer, len: uint): PuglStatus
proc puglGetClipboard*(view: ptr PuglView, typeIndex: uint32, len: ptr uint): pointer
proc puglSetCursor*(view: ptr PuglView, cursor: PuglCursor): PuglStatus
proc puglStartTimer*(view: ptr PuglView, id: pointer, timeout: float64): PuglStatus
proc puglStopTimer*(view: ptr PuglView, id: pointer): PuglStatus
proc puglSendEvent*(view: ptr PuglView, event: ptr PuglEvent): PuglStatus

# GL procs
proc puglGetProcAddress*(name: cstring): pointer
proc puglEnterContext*(view: ptr PuglView): PuglStatus
proc puglLeaveContext*(view: ptr PuglView): PuglStatus
proc puglGlBackend*(): ptr PuglBackend

{.pop.}