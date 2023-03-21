{.experimental: "overloadableEnums".}

import std/times
import std/unicode
import winim/lean except INPUT
import ./guibase; export guibase
import ../openglwrappers/openglcontext

# type
#   MARGINS {.byCopy.} = object
#     cxLeftWidth*: cint
#     cxRightWidth*: cint
#     cyTopHeight*: cint
#     cyBottomHeight*: cint

# proc DwmExtendFrameIntoClientArea*(hWnd: HWND, pMarInset: ptr MARGINS): HRESULT {.discardable, stdcall, dynlib: "dwmapi", importc.}
# proc DwmDefWindowProc(hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM, plResult: ptr LRESULT): BOOL {.discardable, stdcall, dynlib: "dwmapi", importc.}

type
  Gui* = ref object
    inputState*: InputState
    previousInputState*: InputState
    onFrame*: proc()
    handle*: pointer
    isOpen*: bool
    isChild*: bool
    openGlContext*: OpenGlContext
    moveTimer: UINT_PTR

defineGuiProcs()

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
var guiCount = 0

template hwnd(gui: Gui): HWND =
  cast[HWND](gui.handle)

template pollEvents(gui: Gui) =
  var msg: MSG
  while PeekMessage(msg, gui.hwnd, 0, 0, PM_REMOVE) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

proc `size=`*(gui: Gui, size: Vec2) =
  SetWindowPos(gui.hwnd, 0, 0, 0, size.x.int32, size.y.int32, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOMOVE or SWP_NOZORDER)

proc `position=`*(gui: Gui, position: Vec2) =
  SetWindowPos(gui.hwnd, 0, position.x.int32, position.y.int32, 0, 0, SWP_NOACTIVATE or SWP_NOZORDER or SWP_NOSIZE)

template updateBounds(gui: Gui) =
  var rect: RECT
  GetClientRect(gui.hwnd, rect.addr)
  ClientToScreen(gui.hwnd, cast[ptr POINT](rect.left.addr))
  ClientToScreen(gui.hwnd, cast[ptr POINT](rect.right.addr))
  gui.inputState.boundsPixels.position = vec2(rect.left.float, rect.top.float)
  gui.inputState.boundsPixels.size = vec2((rect.right - rect.left).float, (rect.bottom - rect.top).float)

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

proc update*(gui: Gui) =
  gui.processFrame:
    gui.pollEvents()

proc stop*(gui: Gui) =
  if gui.isOpen:
    DestroyWindow(gui.hwnd)
    gui.isOpen = false

proc newGui*(parentHandle: pointer = nil): Gui =
  loadLibraries()

  result = Gui()
  result.initState()

  if guiCount == 0:
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
    lpWindowName = "Gui",
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
  result.size = result.size

  # var margins = MARGINS(cxLeftWidth: 10, cxRightWidth: 10,
  #                       cyTopHeight: 10, cyBottomHeight: 10)
  # DwmExtendFrameIntoClientArea(result.hwnd, margins.addr)

  result.openGlContext = newOpenGlContext(result.handle)
  result.openGlContext.select()

  inc guiCount

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    var lpcs = cast[LPCREATESTRUCT](lParam)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

  let gui = cast[Gui](GetWindowLongPtr(hwnd, GWLP_USERDATA))
  if gui == nil or hwnd != gui.hwnd:
    return DefWindowProc(hwnd, msg, wParam, lParam)

  case msg:

  of WM_SETFOCUS:
    gui.inputState.isFocused = true

  of WM_KILLFOCUS:
    gui.inputState.isFocused = false

  of WM_MOVE:
    gui.updateBounds()

  of WM_SIZE:
    gui.processFrame:
      gui.updateBounds()

  # of WM_ENTERSIZEMOVE:
  #   gui.platform.moveTimer = SetTimer(gui.hwnd, 1, USER_TIMER_MINIMUM, nil)

  # of WM_EXITSIZEMOVE:
  #   KillTimer(gui.hwnd, gui.platform.moveTimer)

  # of WM_TIMER:
  #   if wParam == gui.platform.moveTimer:
  #     gui.processFrame:
  #       gui.updateBounds()

  # of WM_WINDOWPOSCHANGED:
  #   gui.processFrame(cpuTime()):
  #     gui.updateBounds()
  #   return 0

  of WM_CLOSE:
    gui.stop()

  of WM_DESTROY:
    dec guiCount
    guiCount = guiCount.max(0)
    if guiCount == 0:
      UnregisterClass(windowClassName, GetModuleHandle(nil))

  of WM_NCCALCSIZE:
    return 0

  of WM_DPICHANGED:
    gui.inputState.pixelDensity = GetDpiForWindow(gui.hwnd).float / densityPixelDpi
    gui.updateBounds()

  of WM_MOUSEMOVE:
    if not gui.inputState.isHovered:
      var tme: TTRACKMOUSEEVENT
      ZeroMemory(tme.addr, sizeof(tme))
      tme.cbSize = sizeof(tme).cint
      tme.dwFlags = TME_LEAVE
      tme.hwndTrack = gui.hwnd
      TrackMouseEvent(tme.addr)
      gui.inputState.isHovered = true

    gui.inputState.mousePositionPixels = vec2(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float)

    if gui.mouseDown(Left):
      gui.position = gui.position + gui.mousePosition

  of WM_MOUSELEAVE:
    gui.inputState.isHovered = false

  of WM_MOUSEWHEEL:
    gui.inputState.mouseWheel.y += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_MOUSEHWHEEL:
    gui.inputState.mouseWheel.x += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    SetCapture(gui.hwnd)
    let button = toMouseButton(msg, wParam)
    gui.inputState.mousePresses.add button
    gui.inputState.mouseDown[button] = true

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ReleaseCapture()
    let button = toMouseButton(msg, wParam)
    gui.inputState.mouseReleases.add button
    gui.inputState.mouseDown[button] = false

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    let key = toKeyboardKey(wParam, lParam)
    gui.inputState.keyPresses.add key
    gui.inputState.keyDown[key] = true

  of WM_KEYUP, WM_SYSKEYUP:
    let key = toKeyboardKey(wParam, lParam)
    gui.inputState.keyReleases.add key
    gui.inputState.keyDown[key] = false

  of WM_CHAR, WM_SYSCHAR:
    if wParam > 0 and wParam < 0x10000:
      gui.inputState.text &= cast[Rune](wParam).toUTF8

  of WM_NCHITTEST:
    const topBorder = 27
    const bottomBorder = 8
    const leftBorder = 8
    const rightBorder = 8

    var m = POINT(x: GET_X_LPARAM(lParam).int32, y: GET_Y_LPARAM(lParam).int32)
    var w: RECT
    GetWindowRect(hWnd, w.addr)

    var frame = RECT()
    AdjustWindowRectEx(frame.addr, WS_OVERLAPPEDWINDOW and not WS_CAPTION, false, 0)

    var row = 1
    var col = 1
    var onResizeBorder = false

    if m.y >= w.top and m.y < w.top + topBorder:
      onResizeBorder = m.y < (w.top - frame.top)
      row = 0
    elif m.y < w.bottom and m.y >= w.bottom - bottomBorder:
      row = 2

    if m.x >= w.left and m.x < w.left + leftBorder:
      col = 0
    elif m.x < w.right and m.x >= w.right - rightBorder:
      col = 2

    let hitTests = [
      [HTTOPLEFT, if onResizeBorder: HTTOP else: HTCAPTION, HTTOPRIGHT],
      [HTLEFT, HTNOWHERE, HTRIGHT],
      [HTBOTTOMLEFT, HTBOTTOM, HTBOTTOMRIGHT],
    ]

    return hitTests[row][col]

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)