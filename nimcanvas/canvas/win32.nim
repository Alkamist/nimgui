{.experimental: "overloadableEnums".}

import std/unicode
import winim/lean as win32
import ./base; export base
import ../tmath; export tmath

const WM_DPICHANGED* = 0x02E0
const DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = -4

type Proc_SetProcessDpiAwarenessContext = proc(value: int): BOOL {.stdcall.}
var SetProcessDpiAwarenessContext: Proc_SetProcessDpiAwarenessContext
type Proc_GetDpiForWindow = proc(hWnd: HWND): UINT {.stdcall.}
var GetDpiForWindow: Proc_GetDpiForWindow

var librariesAreLoaded = false
proc loadLibraries() =
  if not librariesAreLoaded:
    let user32 = LoadLibraryA("user32.dll")
    if user32 == 0:
      quit("Error loading user32.dll")

    SetProcessDpiAwarenessContext = cast[Proc_SetProcessDpiAwarenessContext](
      GetProcAddress(user32, "SetProcessDpiAwarenessContext")
    )
    GetDpiForWindow = cast[Proc_GetDpiForWindow](
      GetProcAddress(user32, "GetDpiForWindow")
    )
    librariesAreLoaded = true

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

const windowClassName = "Default Canvas Class"
var clientCount = 0

func hwnd(canvas: Canvas): HWND =
  cast[HWND](canvas.handle)

proc pollEvents(canvas: Canvas) =
  var msg: MSG
  while PeekMessage(msg, canvas.hwnd, 0, 0, PM_REMOVE) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

proc updateBounds(canvas: Canvas) =
  var rect: RECT
  GetClientRect(canvas.hwnd, rect.addr)
  ClientToScreen(canvas.hwnd, cast[ptr POINT](rect.left.addr))
  ClientToScreen(canvas.hwnd, cast[ptr POINT](rect.right.addr))
  canvas.positionPixels = vec2(rect.left.float, rect.top.float)
  canvas.sizePixels = vec2((rect.right - rect.left).float, (rect.bottom - rect.top).float)

func toMouseButton(msg: UINT, wParam: WPARAM): MouseButton =
  case msg:
  of WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK:
    Left
  of WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MBUTTONDBLCLK:
    Middle
  of WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
    Right
  of WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK:
    if HIWORD(wParam) == 1:
      Extra1
    else:
      Extra2
  else:
    Unknown

func toKeyboardKey(wParam: WPARAM, lParam: LPARAM): KeyboardKey =
  let scanCode = LOBYTE(HIWORD(lParam))
  let isRight = (HIWORD(lParam) and KF_EXTENDED) == KF_EXTENDED
  case scanCode:
    of 42: LeftShift
    of 54: RightShift
    of 29:
      if isRight: RightControl else: LeftControl
    of 56:
      if isRight: RightAlt else: LeftAlt
    else:
      case wParam.int:
      of 8: Backspace
      of 9: Tab
      of 13: Enter
      of 19: Pause
      of 20: CapsLock
      of 27: Escape
      of 32: Space
      of 33: PageUp
      of 34: PageDown
      of 35: End
      of 36: Home
      of 37: LeftArrow
      of 38: UpArrow
      of 39: RightArrow
      of 40: DownArrow
      of 45: Insert
      of 46: KeyboardKey.Delete
      of 48: Key0
      of 49: Key1
      of 50: Key2
      of 51: Key3
      of 52: Key4
      of 53: Key5
      of 54: Key6
      of 55: Key7
      of 56: Key8
      of 57: Key9
      of 65: A
      of 66: B
      of 67: C
      of 68: D
      of 69: KeyboardKey.E
      of 70: F
      of 71: G
      of 72: H
      of 73: I
      of 74: J
      of 75: K
      of 76: L
      of 77: M
      of 78: N
      of 79: O
      of 80: P
      of 81: Q
      of 82: R
      of 83: S
      of 84: T
      of 85: U
      of 86: V
      of 87: W
      of 88: X
      of 89: Y
      of 90: Z
      of 91: LeftMeta
      of 92: RightMeta
      of 96: Pad0
      of 97: Pad1
      of 98: Pad2
      of 99: Pad3
      of 100: Pad4
      of 101: Pad5
      of 102: Pad6
      of 103: Pad7
      of 104: Pad8
      of 105: Pad9
      of 106: PadMultiply
      of 107: PadAdd
      of 109: PadSubtract
      of 110: PadPeriod
      of 111: PadDivide
      of 112: F1
      of 113: F2
      of 114: F3
      of 115: F4
      of 116: F5
      of 117: F6
      of 118: F7
      of 119: F8
      of 120: F9
      of 121: F10
      of 122: F11
      of 123: F12
      of 144: NumLock
      of 145: ScrollLock
      of 186: Semicolon
      of 187: Equal
      of 188: Comma
      of 189: Minus
      of 190: Period
      of 191: Slash
      of 192: Backtick
      of 219: LeftBracket
      of 220: BackSlash
      of 221: RightBracket
      of 222: Quote
      else: Unknown

template processFrame(canvas: Canvas, stateChanges: untyped): untyped =
  canvas.updatePreviousState()
  stateChanges
  canvas.beginFrameBase()
  if canvas.onFrame != nil:
    canvas.onFrame()
  canvas.endFrameBase()

proc update*(canvas: Canvas) =
  canvas.processFrame:
    canvas.pollEvents()

proc close*(canvas: Canvas) =
  if canvas.isOpen:
    DestroyWindow(canvas.hwnd)
    canvas.isOpen = false

proc newCanvas*(parentHandle: pointer = nil): Canvas =
  loadLibraries()

  result = cast[Canvas](newCanvasBase())
  result.isOpen = true

  if clientCount == 0:
    var windowClass = WNDCLASSEX(
      cbSize: WNDCLASSEX.sizeof.UINT,
      style: CS_OWNDC,
      lpfnWndProc: windowProc,
      cbClsExtra: 0,
      cbWndExtra: 0,
      hInstance: GetModuleHandle(nil),
      hIcon: 0,
      hCursor: LoadCursor(0, IDC_ARROW),
      hbrBackground: CreateSolidBrush(RGB(0, 0, 0)),
      lpszMenuName: nil,
      lpszClassName: windowClassName,
      hIconSm: 0,
    )
    RegisterClassEx(windowClass)

  let isChild = parentHandle != nil
  let windowStyle =
    if isChild:
      WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    else:
      WS_OVERLAPPEDWINDOW or WS_VISIBLE

  result.isChild = isChild

  let hwnd = CreateWindow(
    lpClassName = windowClassName,
    lpWindowName = "Canvas",
    dwStyle = windowStyle.int32,
    x = 0,
    y = 0,
    nWidth = 800,
    nHeight = 600,
    hWndParent = cast[HWND](parentHandle),
    hMenu = 0,
    hInstance = GetModuleHandle(nil),
    lpParam = cast[pointer](result),
  )
  result.handle = cast[pointer](hwnd)

  discard SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

  result.updateBounds()
  result.initBase()

  inc clientCount

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    var lpcs = cast[LPCREATESTRUCT](lParam)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

  let canvas = cast[Canvas](GetWindowLongPtr(hwnd, GWLP_USERDATA))
  if canvas == nil or hwnd != canvas.hwnd:
    return DefWindowProc(hwnd, msg, wParam, lParam)

  case msg:

  of WM_ENTERSIZEMOVE:
    canvas.platform.moveTimer = SetTimer(canvas.hwnd, 1, USER_TIMER_MINIMUM, nil)

  of WM_EXITSIZEMOVE:
    KillTimer(canvas.hwnd, canvas.platform.moveTimer)

  of WM_TIMER:
    if wParam == canvas.platform.moveTimer:
      canvas.processFrame:
        canvas.updateBounds()

  of WM_WINDOWPOSCHANGED:
    canvas.processFrame:
      canvas.updateBounds()
    return 0

  of WM_CLOSE:
    canvas.close()

  of WM_DESTROY:
    dec clientCount
    clientCount = clientCount.max(0)
    if clientCount == 0:
      UnregisterClass(windowClassName, GetModuleHandle(nil))

  of WM_DPICHANGED:
    canvas.dpi = GetDpiForWindow(canvas.hwnd).float

  of WM_MOUSEMOVE:
    canvas.mousePositionPixels = vec2(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float)

  of WM_MOUSEWHEEL:
    canvas.mouseWheel.y += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_MOUSEHWHEEL:
    canvas.mouseWheel.x += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    SetCapture(canvas.hwnd)
    let button = toMouseButton(msg, wParam)
    canvas.mousePresses.add button
    canvas.mouseDownStates[button] = true

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ReleaseCapture()
    let button = toMouseButton(msg, wParam)
    canvas.mouseReleases.add button
    canvas.mouseDownStates[toMouseButton(msg, wParam)] = false

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    let key = toKeyboardKey(wParam, lParam)
    canvas.keyPresses.add key
    canvas.keyDownStates[key] = true

  of WM_KEYUP, WM_SYSKEYUP:
    let key = toKeyboardKey(wParam, lParam)
    canvas.keyReleases.add key
    canvas.keyDownStates[key] = false

  of WM_CHAR, WM_SYSCHAR:
    if wParam > 0 and wParam < 0x10000:
      canvas.text &= cast[Rune](wParam).toUTF8

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)