import std/options
import std/unicode
import opengl
import pugl

type
  Vec2 = tuple[x, y: float]

  NativeHandle* = pointer

  MouseButton* = enum
    Unknown,
    Left, Middle, Right,
    Extra1, Extra2,

  KeyboardKey* = enum
    Unknown,
    A, B, C, D, E, F, G, H, I,
    J, K, L, M, N, O, P, Q, R,
    S, T, U, V, W, X, Y, Z,
    Key1, Key2, Key3, Key4, Key5,
    Key6, Key7, Key8, Key9, Key0,
    Pad1, Pad2, Pad3, Pad4, Pad5,
    Pad6, Pad7, Pad8, Pad9, Pad0,
    F1, F2, F3, F4, F5, F6, F7,
    F8, F9, F10, F11, F12,
    Backtick, Minus, Equal, Backspace,
    Tab, CapsLock, Enter, LeftShift,
    RightShift, LeftControl, RightControl,
    LeftAlt, RightAlt, LeftMeta, RightMeta,
    LeftBracket, RightBracket, Space,
    Escape, Backslash, Semicolon, Apostrophe,
    Comma, Period, Slash, ScrollLock,
    Pause, Insert, End, PageUp, Delete,
    Home, PageDown, LeftArrow, RightArrow,
    DownArrow, UpArrow, NumLock, PadDivide,
    PadMultiply, PadSubtract, PadAdd, PadEnter,
    PadDecimal, PrintScreen,

  ChildKind* = enum
    None
    Embedded
    Transient

  OsWindow* = ref object of RootObj
    userData*: pointer

    backendCallbacks*: tuple[
      onClose: proc(window: OsWindow),
      onDraw: proc(window: OsWindow),
      onUpdate: proc(window: OsWindow),
      onMove: proc(window: OsWindow, position: Vec2),
      onResize: proc(window: OsWindow, size: Vec2),
      onMouseMove: proc(window: OsWindow, position, rootPosition: Vec2),
      onMouseEnter: proc(window: OsWindow),
      onMouseExit: proc(window: OsWindow),
      onMouseWheel: proc(window: OsWindow, amount: Vec2),
      onMousePress: proc(window: OsWindow, button: MouseButton),
      onMouseRelease: proc(window: OsWindow, button: MouseButton),
      onKeyPress: proc(window: OsWindow, key: KeyboardKey),
      onKeyRelease: proc(window: OsWindow, key: KeyboardKey),
      onText: proc(window: OsWindow, text: string),
    ]

    title*: string
    minSize*: Option[Vec2]
    maxSize*: Option[Vec2]
    swapInterval*: int = 1
    darkMode*: bool = true
    isResizable*: bool = true
    doubleBuffer*: bool = true
    childKind*: ChildKind
    parentHandle*: NativeHandle

    isOpen*: bool

    lastPosition: Vec2
    lastSize: Vec2 = (400, 300)
    lastVisibility: bool = true

    timerId: pointer
    view: ptr PuglView

var openGlLoaded: bool
var world {.threadvar.}: ptr PuglWorld
var windowCount {.threadvar.}: int

proc update*() =
  puglUpdate(world, 0)

proc puglButtonToMouseButton(button: uint32): MouseButton =
  case button:
  of 0: Left
  of 1: Right
  of 2: Middle
  of 3: Extra1
  of 4: Extra2
  else: Unknown

proc puglKeyEventToKeyboardKey(event: ptr PuglKeyEvent): KeyboardKey =
  result = case event.key:
    of PUGL_BACKSPACE: Backspace
    of PUGL_ENTER: Enter
    of PUGL_ESCAPE: Escape
    of PUGL_DELETE: Delete
    of PUGL_SPACE: Space
    of PUGL_F1: F1
    of PUGL_F2: F2
    of PUGL_F3: F3
    of PUGL_F4: F4
    of PUGL_F5: F5
    of PUGL_F6: F6
    of PUGL_F7: F7
    of PUGL_F8: F8
    of PUGL_F9: F9
    of PUGL_F10: F10
    of PUGL_F11: F11
    of PUGL_F12: F12
    of PUGL_PAGE_UP: PageUp
    of PUGL_PAGE_DOWN: PageDown
    of PUGL_END: End
    of PUGL_HOME: Home
    of PUGL_LEFT: LeftArrow
    of PUGL_UP: UpArrow
    of PUGL_RIGHT: RightArrow
    of PUGL_DOWN: DownArrow
    of PUGL_PRINT_SCREEN: PrintScreen
    of PUGL_INSERT: Insert
    of PUGL_PAUSE: Pause
    of PUGL_NUM_LOCK: NumLock
    of PUGL_SCROLL_LOCK: ScrollLock
    of PUGL_CAPS_LOCK: CapsLock
    of PUGL_SHIFT_L: LeftShift
    of PUGL_SHIFT_R: RightShift
    of PUGL_CTRL_L: RightControl # Switched for some reason
    of PUGL_CTRL_R: LeftControl # Switched for some reason
    of PUGL_ALT_L: RightAlt # Switched for some reason
    of PUGL_ALT_R: LeftAlt # Switched for some reason
    of PUGL_SUPER_L: LeftMeta
    of PUGL_SUPER_R: RightMeta
    of PUGL_PAD_0: Pad0
    of PUGL_PAD_1: Pad1
    of PUGL_PAD_2: Pad2
    of PUGL_PAD_3: Pad3
    of PUGL_PAD_4: Pad4
    of PUGL_PAD_5: Pad5
    of PUGL_PAD_6: Pad6
    of PUGL_PAD_7: Pad7
    of PUGL_PAD_8: Pad8
    of PUGL_PAD_9: Pad9
    of PUGL_PAD_ENTER: PadEnter
    of PUGL_PAD_MULTIPLY: PadMultiply
    of PUGL_PAD_ADD: PadAdd
    of PUGL_PAD_SUBTRACT: PadSubtract
    of PUGL_PAD_DECIMAL: PadDecimal
    of PUGL_PAD_DIVIDE: PadDivide
    else:
      case int(event.key):
      of 9: Tab
      of 96: Backtick
      of 49: Key1
      of 50: Key2
      of 51: Key3
      of 52: Key4
      of 53: Key5
      of 54: Key6
      of 55: Key7
      of 56: Key8
      of 57: Key9
      of 48: Key0
      of 45: Minus
      of 61: Equal
      of 113: Q
      of 119: W
      of 101: E
      of 114: R
      of 116: T
      of 121: Y
      of 117: U
      of 105: I
      of 111: O
      of 112: P
      of 91: LeftBracket
      of 93: RightBracket
      of 92: Backslash
      of 97: A
      of 115: S
      of 100: D
      of 102: F
      of 103: G
      of 104: H
      of 106: J
      of 107: K
      of 108: L
      of 59: Semicolon
      of 39: Apostrophe
      of 122: Z
      of 120: X
      of 99: C
      of 118: V
      of 98: B
      of 110: N
      of 109: M
      of 44: Comma
      of 46: Period
      of 47: Slash
      of 57502: Pad0
      of 57459: Pad1
      of 57464: Pad2
      of 57458: Pad3
      of 57461: Pad4
      of 57501: Pad5
      of 57463: Pad6
      of 57460: Pad7
      of 57462: Pad8
      of 57457: Pad9
      of 57503: PadDecimal
      else: Unknown

proc onEvent(view: ptr PuglView, event: ptr PuglEvent): PuglStatus {.cdecl.} =
  case cast[ptr PuglEventType](event)[]:

  of PUGL_EXPOSE:
    let window = cast[OsWindow](puglGetHandle(view))
    if window.backendCallbacks.onDraw != nil:
      window.backendCallbacks.onDraw(window)

  of PUGL_UPDATE:
    let window = cast[OsWindow](puglGetHandle(view))
    puglEnterContext(window.view)

    if window.backendCallbacks.onUpdate != nil:
      window.backendCallbacks.onUpdate(window)

    puglLeaveContext(window.view)
    puglPostRedisplay(view)

  of PUGL_LOOP_ENTER:
    let window = cast[OsWindow](puglGetHandle(view))
    puglStartTimer(view, window.timerId, 0)

  of PUGL_LOOP_LEAVE:
    let window = cast[OsWindow](puglGetHandle(view))
    puglStopTimer(view, window.timerId)

  of PUGL_TIMER:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglTimerEvent](event)
    if window.timerId == event.id:
      update()

  of PUGL_CONFIGURE:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglConfigureEvent](event)

    let position = (float(event.x), float(event.y))
    let size = (float(event.width), float(event.height))

    if window.backendCallbacks.onMove != nil and position != window.lastPosition:
      window.backendCallbacks.onMove(window, position)

    if window.backendCallbacks.onResize != nil and size != window.lastSize:
      window.backendCallbacks.onResize(window, size)

    window.lastPosition = position
    window.lastSize = size

  of PUGL_MOTION:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglMotionEvent](event)

    if window.backendCallbacks.onMouseMove != nil:
      window.backendCallbacks.onMouseMove(
        window,
        (float(event.x), float(event.y)),
        (float(event.xRoot), float(event.yRoot)),
      )

  of PUGL_POINTER_IN:
    let window = cast[OsWindow](puglGetHandle(view))
    if window.backendCallbacks.onMouseEnter != nil:
      window.backendCallbacks.onMouseEnter(window)

  of PUGL_POINTER_OUT:
    let window = cast[OsWindow](puglGetHandle(view))
    if window.backendCallbacks.onMouseExit != nil:
        window.backendCallbacks.onMouseExit(window)

  of PUGL_SCROLL:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglScrollEvent](event)

    if window.backendCallbacks.onMouseWheel != nil:
      window.backendCallbacks.onMouseWheel(window, (float(event.dx), float(event.dy)))

  of PUGL_BUTTON_PRESS:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglButtonEvent](event)

    if window.backendCallbacks.onMousePress != nil:
      window.backendCallbacks.onMousePress(window, puglButtonToMouseButton(event.button))

  of PUGL_BUTTON_RELEASE:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglButtonEvent](event)

    if window.backendCallbacks.onMouseRelease != nil:
      window.backendCallbacks.onMouseRelease(window, puglButtonToMouseButton(event.button))

  of PUGL_KEY_PRESS:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglKeyEvent](event)

    if window.backendCallbacks.onKeyPress != nil:
      window.backendCallbacks.onKeyPress(window, puglKeyEventToKeyboardKey(event))

  of PUGL_KEY_RELEASE:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglKeyEvent](event)

    if window.backendCallbacks.onKeyRelease != nil:
      window.backendCallbacks.onKeyRelease(window, puglKeyEventToKeyboardKey(event))

  of PUGL_TEXT:
    let window = cast[OsWindow](puglGetHandle(view))
    let event = cast[ptr PuglTextEvent](event)

    if window.backendCallbacks.onText != nil:
      window.backendCallbacks.onText(window, $cast[Rune](event.character))

  of PUGL_CLOSE:
    let window = cast[OsWindow](puglGetHandle(view))
    puglEnterContext(window.view)

    window.lastVisibility = puglGetVisible(window.view)

    if window.backendCallbacks.onClose != nil:
      window.backendCallbacks.onClose(window)

    puglUnrealize(window.view)
    puglFreeView(window.view)

    window.view = nil
    window.isOpen = false

    windowCount -= 1

    if windowCount == 0:
      puglFreeWorld(world)
      world = nil

  else:
    discard

  PUGL_SUCCESS

proc open*(window: OsWindow): bool =
  if windowCount == 0:
    world = puglNewWorld(PUGL_PROGRAM, 0)
    puglSetWorldString(world, PUGL_CLASS_NAME, "GuiWindow")

  if window.isOpen:
    return false

  if window.parentHandle != nil and window.childKind == None:
    window.childKind = Embedded

  let view = puglNewView(world)

  puglSetViewString(view, PUGL_WINDOW_TITLE, cstring(window.title))
  puglSetSizeHint(view, PUGL_DEFAULT_SIZE, uint16(window.lastSize.x), uint16(window.lastSize.y))

  if window.minSize.isSome:
    puglSetSizeHint(view, PUGL_MIN_SIZE, uint16(window.minSize.get.x), uint16(window.minSize.get.y))

  if window.maxSize.isSome:
    puglSetSizeHint(view, PUGL_MAX_SIZE, uint16(window.maxSize.get.x), uint16(window.maxSize.get.y))

  puglSetBackend(view, puglGlBackend())

  puglSetViewHint(view, PUGL_DARK_FRAME, if window.darkMode: 1 else: 0)
  puglSetViewHint(view, PUGL_RESIZABLE, if window.isResizable: 1 else: 0)
  puglSetViewHint(view, PUGL_SAMPLES, 1)
  puglSetViewHint(view, PUGL_DOUBLE_BUFFER, if window.doubleBuffer: 1 else: 0)
  puglSetViewHint(view, PUGL_SWAP_INTERVAL, int32(window.swapInterval))
  puglSetViewHint(view, PUGL_IGNORE_KEY_REPEAT, 0)

  case window.childKind:
  of Embedded:
    puglSetPosition(view, 0, 0)
    puglSetParentWindow(view, window.parentHandle)
  of Transient:
    puglSetTransientParent(view, window.parentHandle)
  of None:
    discard

  puglSetHandle(view, cast[pointer](window))
  puglSetEventFunc(view, onEvent)

  let status = puglRealize(view)
  if status != PUGL_SUCCESS:
    puglFreeView(view)
    debugEcho puglStrerror(status)
    return false

  puglSetPosition(view, cint(window.lastPosition.x), cint(window.lastPosition.y))

  if window.lastVisibility:
    puglShow(view, PUGL_RAISE)

  window.view = view
  window.isOpen = true

  if not openGlLoaded:
    opengl.loadExtensions()

  windowCount += 1

  return true

proc close*(window: OsWindow) =
  if not window.isOpen:
    return
  var event = PUGL_CLOSE
  puglSendEvent(window.view, cast[ptr PuglEvent](addr(event)))

proc nativeHandle*(window: OsWindow): NativeHandle =
  puglGetNativeView(window.view)

proc activateContext*(window: OsWindow) =
  puglEnterContext(window.view)

proc deactivateContext*(window: OsWindow) =
  puglLeaveContext(window.view)

proc isVisible*(window: OsWindow): bool =
  if window.view != nil:
    puglGetVisible(window.view)
  else:
    window.lastVisibility

proc `isVisible=`*(window: OsWindow, isVisible: bool) =
  if window.view != nil:
    if isVisible:
      puglShow(window.view, PUGL_RAISE)
    else:
      puglHide(window.view)

  window.lastVisibility = isVisible

proc position*(window: OsWindow): Vec2 =
  if window.view != nil:
    let frame = puglGetFrame(window.view)
    (float(frame.x), float(frame.y))
  else:
    window.lastPosition

proc `position=`*(window: OsWindow, position: Vec2) =
  if window.view != nil:
    puglSetPosition(window.view, cint(position.x), cint(position.y))
  else:
    window.lastPosition = position

proc size*(window: OsWindow): Vec2 =
  if window.view != nil:
    let frame = puglGetFrame(window.view)
    (float(frame.width), float(frame.height))
  else:
    window.lastSize

proc `size=`*(window: OsWindow, size: Vec2) =
  if window.view != nil:
    puglSetSize(window.view, cuint(size.x), cuint(size.y))
  else:
    window.lastSize = size

proc contentScale*(window: OsWindow): float =
  puglGetScaleFactor(window.view)