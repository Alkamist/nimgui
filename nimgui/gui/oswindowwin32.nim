{.experimental: "overloadableEnums".}

import std/unicode
import winim/lean
import ./ui; export ui
import ../openglwrappers/openglcontext

type
  OsWindow* = ref object of Ui
    onFrame*: proc(window: OsWindow)
    handle*: pointer
    isOpen*: bool
    isChild*: bool
    openGlContext*: OpenGlContext
    # moveTimer: UINT_PTR

template hwnd(window: OsWindow): HWND =
  cast[HWND](window.handle)

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

const windowClassName = "Default Window Class"
var windowCount = 0

template updateBounds(window: OsWindow) =
  var rect: RECT
  GetClientRect(window.hwnd, rect.addr)
  ClientToScreen(window.hwnd, cast[ptr POINT](rect.left.addr))
  ClientToScreen(window.hwnd, cast[ptr POINT](rect.right.addr))
  window.state.boundsPixels.position = vec2(rect.left.float, rect.top.float)
  window.state.boundsPixels.size = vec2((rect.right - rect.left).float, (rect.bottom - rect.top).float)

template processFrame(window: OsWindow) =
  if window.isOpen:
    window.openGlContext.select()
    glClear(GL_COLOR_BUFFER_BIT)

    if window.onFrame != nil:
      window.onFrame(window)

    window.openGlContext.swapBuffers()
    window.updateState()

proc `backgroundColor=`*(window: OsWindow, color: Color) =
  window.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)

proc `position=`*(window: OsWindow, position: Vec2) =
  SetWindowPos(window.hwnd, 0, position.x.int32, position.y.int32, 0, 0, SWP_NOACTIVATE or SWP_NOZORDER or SWP_NOSIZE)

proc `size=`*(window: OsWindow, size: Vec2) =
  SetWindowPos(window.hwnd, 0, 0, 0, size.x.int32, size.y.int32, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOMOVE or SWP_NOZORDER)

func toMouseButton(msg: UINT, wParam: WPARAM): MouseButton =
  case msg:
  of WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK:
    MouseButton.Left
  of WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MBUTTONDBLCLK:
    MouseButton.Middle
  of WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
    MouseButton.Right
  of WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK:
    if HIWORD(wParam) == 1:
      MouseButton.Extra1
    else:
      MouseButton.Extra2
  else:
    MouseButton.Unknown

func toKeyboardKey(wParam: WPARAM, lParam: LPARAM): KeyboardKey =
  let scanCode = LOBYTE(HIWORD(lParam))
  let isRight = (HIWORD(lParam) and KF_EXTENDED) == KF_EXTENDED
  case scanCode:
    of 42: KeyboardKey.LeftShift
    of 54: KeyboardKey.RightShift
    of 29:
      if isRight: KeyboardKey.RightControl else: KeyboardKey.LeftControl
    of 56:
      if isRight: KeyboardKey.RightAlt else: KeyboardKey.LeftAlt
    else:
      case wParam.int:
      of 8: KeyboardKey.Backspace
      of 9: KeyboardKey.Tab
      of 13: KeyboardKey.Enter
      of 19: KeyboardKey.Pause
      of 20: KeyboardKey.CapsLock
      of 27: KeyboardKey.Escape
      of 32: KeyboardKey.Space
      of 33: KeyboardKey.PageUp
      of 34: KeyboardKey.PageDown
      of 35: KeyboardKey.End
      of 36: KeyboardKey.Home
      of 37: KeyboardKey.LeftArrow
      of 38: KeyboardKey.UpArrow
      of 39: KeyboardKey.RightArrow
      of 40: KeyboardKey.DownArrow
      of 45: KeyboardKey.Insert
      of 46: KeyboardKey.Delete
      of 48: KeyboardKey.Key0
      of 49: KeyboardKey.Key1
      of 50: KeyboardKey.Key2
      of 51: KeyboardKey.Key3
      of 52: KeyboardKey.Key4
      of 53: KeyboardKey.Key5
      of 54: KeyboardKey.Key6
      of 55: KeyboardKey.Key7
      of 56: KeyboardKey.Key8
      of 57: KeyboardKey.Key9
      of 65: KeyboardKey.A
      of 66: KeyboardKey.B
      of 67: KeyboardKey.C
      of 68: KeyboardKey.D
      of 69: KeyboardKey.E
      of 70: KeyboardKey.F
      of 71: KeyboardKey.G
      of 72: KeyboardKey.H
      of 73: KeyboardKey.I
      of 74: KeyboardKey.J
      of 75: KeyboardKey.K
      of 76: KeyboardKey.L
      of 77: KeyboardKey.M
      of 78: KeyboardKey.N
      of 79: KeyboardKey.O
      of 80: KeyboardKey.P
      of 81: KeyboardKey.Q
      of 82: KeyboardKey.R
      of 83: KeyboardKey.S
      of 84: KeyboardKey.T
      of 85: KeyboardKey.U
      of 86: KeyboardKey.V
      of 87: KeyboardKey.W
      of 88: KeyboardKey.X
      of 89: KeyboardKey.Y
      of 90: KeyboardKey.Z
      of 91: KeyboardKey.LeftMeta
      of 92: KeyboardKey.RightMeta
      of 96: KeyboardKey.Pad0
      of 97: KeyboardKey.Pad1
      of 98: KeyboardKey.Pad2
      of 99: KeyboardKey.Pad3
      of 100: KeyboardKey.Pad4
      of 101: KeyboardKey.Pad5
      of 102: KeyboardKey.Pad6
      of 103: KeyboardKey.Pad7
      of 104: KeyboardKey.Pad8
      of 105: KeyboardKey.Pad9
      of 106: KeyboardKey.PadMultiply
      of 107: KeyboardKey.PadAdd
      of 109: KeyboardKey.PadSubtract
      of 110: KeyboardKey.PadPeriod
      of 111: KeyboardKey.PadDivide
      of 112: KeyboardKey.F1
      of 113: KeyboardKey.F2
      of 114: KeyboardKey.F3
      of 115: KeyboardKey.F4
      of 116: KeyboardKey.F5
      of 117: KeyboardKey.F6
      of 118: KeyboardKey.F7
      of 119: KeyboardKey.F8
      of 120: KeyboardKey.F9
      of 121: KeyboardKey.F10
      of 122: KeyboardKey.F11
      of 123: KeyboardKey.F12
      of 144: KeyboardKey.NumLock
      of 145: KeyboardKey.ScrollLock
      of 186: KeyboardKey.Semicolon
      of 187: KeyboardKey.Equal
      of 188: KeyboardKey.Comma
      of 189: KeyboardKey.Minus
      of 190: KeyboardKey.Period
      of 191: KeyboardKey.Slash
      of 192: KeyboardKey.Backtick
      of 219: KeyboardKey.LeftBracket
      of 220: KeyboardKey.BackSlash
      of 221: KeyboardKey.RightBracket
      of 222: KeyboardKey.Quote
      else: KeyboardKey.Unknown

proc update*(window: OsWindow) =
  if not window.isChild:
    var msg: MSG
    while PeekMessage(msg, window.hwnd, 0, 0, PM_REMOVE) != 0:
      TranslateMessage(msg)
      DispatchMessage(msg)
  window.processFrame()

proc close*(window: OsWindow) =
  if window.isOpen:
    DestroyWindow(window.hwnd)
    window.isOpen = false

proc newOsWindow*(parentHandle: pointer = nil): OsWindow =
  loadLibraries()

  result = OsWindow()
  result.initState()

  if windowCount == 0:
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
  var windowStyle = WS_OVERLAPPEDWINDOW or WS_VISIBLE
  if isChild:
    windowStyle = windowStyle or WS_POPUP

  result.isChild = isChild

  let hwnd = CreateWindow(
    lpClassName = windowClassName,
    lpWindowName = "",
    dwStyle = windowStyle.int32,
    x = 0,
    y = 0,
    nWidth = 800,
    nHeight = 600,
    hWndParent = if isChild: cast[HWND](parentHandle) else: GetDesktopWindow(),
    hMenu = 0,
    hInstance = GetModuleHandle(nil),
    lpParam = cast[pointer](result),
  )
  result.isOpen = true
  result.handle = cast[pointer](hwnd)

  discard SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

  result.updateBounds()
  # result.size = result.size

  result.openGlContext = newOpenGlContext(result.handle)
  result.openGlContext.select()

  inc windowCount

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    var lpcs = cast[LPCREATESTRUCT](lParam)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

  let window = cast[OsWindow](GetWindowLongPtr(hwnd, GWLP_USERDATA))
  if window == nil or hwnd != window.hwnd:
    return DefWindowProc(hwnd, msg, wParam, lParam)

  case msg:

  of WM_SETFOCUS:
    window.state.isFocused = true

  of WM_KILLFOCUS:
    window.state.isFocused = false

  of WM_MOVE:
    window.updateBounds()
    window.processFrame()

  of WM_SIZE:
    window.updateBounds()
    window.processFrame()

  # of WM_ENTERSIZEMOVE:
  #   window.platform.moveTimer = SetTimer(window.hwnd, 1, USER_TIMER_MINIMUM, nil)

  # of WM_EXITSIZEMOVE:
  #   KillTimer(window.hwnd, window.platform.moveTimer)

  # of WM_TIMER:
  #   if wParam == window.platform.moveTimer:
  #     window.processFrame:
  #       window.updateBounds()

  # of WM_WINDOWPOSCHANGED:
  #   window.processFrame(cpuTime()):
  #     window.updateBounds()
  #   return 0

  of WM_CLOSE:
    window.close()

  of WM_DESTROY:
    dec windowCount
    windowCount = windowCount.max(0)
    if windowCount == 0:
      UnregisterClass(windowClassName, 0)

  of WM_DPICHANGED:
    window.state.pixelDensity = GetDpiForWindow(window.hwnd).float / densityPixelDpi
    window.updateBounds()

  of WM_MOUSEMOVE:
    if not window.state.isHovered:
      var tme: TTRACKMOUSEEVENT
      ZeroMemory(tme.addr, sizeof(tme))
      tme.cbSize = sizeof(tme).cint
      tme.dwFlags = TME_LEAVE
      tme.hwndTrack = window.hwnd
      TrackMouseEvent(tme.addr)
      window.state.isHovered = true

    window.state.mousePositionPixels = vec2(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float)
    window.processFrame()

  of WM_MOUSELEAVE:
    window.state.isHovered = false

  of WM_MOUSEWHEEL:
    window.state.mouseWheel.y += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float
    window.processFrame()

  of WM_MOUSEHWHEEL:
    window.state.mouseWheel.x += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float
    window.processFrame()

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    SetCapture(window.hwnd)
    let button = toMouseButton(msg, wParam)
    window.state.mousePresses.add button
    window.state.mouseDown[button] = true

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ReleaseCapture()
    let button = toMouseButton(msg, wParam)
    window.state.mouseReleases.add button
    window.state.mouseDown[button] = false

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    let key = toKeyboardKey(wParam, lParam)
    window.state.keyPresses.add key
    window.state.keyDown[key] = true

  of WM_KEYUP, WM_SYSKEYUP:
    let key = toKeyboardKey(wParam, lParam)
    window.state.keyReleases.add key
    window.state.keyDown[key] = false

  of WM_CHAR, WM_SYSCHAR:
    if wParam > 0 and wParam < 0x10000:
      window.state.text &= cast[Rune](wParam).toUTF8

  # of WM_NCCALCSIZE:
  #   return 0

  # of WM_NCHITTEST:
  #   const topBorder = 27
  #   const bottomBorder = 8
  #   const leftBorder = 8
  #   const rightBorder = 8

  #   var m = POINT(x: GET_X_LPARAM(lParam).int32, y: GET_Y_LPARAM(lParam).int32)
  #   var w: RECT
  #   GetWindowRect(hWnd, w.addr)

  #   var frame = RECT()
  #   AdjustWindowRectEx(frame.addr, WS_OVERLAPPEDWINDOW and not WS_CAPTION, false, 0)

  #   var row = 1
  #   var col = 1
  #   var onResizeBorder = false

  #   if m.y >= w.top and m.y < w.top + topBorder:
  #     onResizeBorder = m.y < (w.top - frame.top)
  #     row = 0
  #   elif m.y < w.bottom and m.y >= w.bottom - bottomBorder:
  #     row = 2

  #   if m.x >= w.left and m.x < w.left + leftBorder:
  #     col = 0
  #   elif m.x < w.right and m.x >= w.right - rightBorder:
  #     col = 2

  #   let hitTests = [
  #     [HTTOPLEFT, if onResizeBorder: HTTOP else: HTCAPTION, HTTOPRIGHT],
  #     [HTLEFT, HTNOWHERE, HTRIGHT],
  #     [HTBOTTOMLEFT, HTBOTTOM, HTBOTTOMRIGHT],
  #   ]

  #   return hitTests[row][col]

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)