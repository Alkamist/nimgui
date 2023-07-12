import std/unicode
import std/times
import ../gui
import ./win32api
import opengl

const densityPixelDpi = 96.0

type
  Win32BackendData = ref object
    closeRequested: bool
    cursorX: int
    cursorY: int
    hwnd: HWND
    hdc: HDC
    hglrc: HGLRC
    sizeMoveTimerId: UINT_PTR

proc toWin32CursorStyle(style: CursorStyle): LPSTR =
  return case style:
    of Arrow: IDC_ARROW
    of IBeam: IDC_IBEAM
    of Crosshair: IDC_CROSS
    of PointingHand: IDC_HAND
    of ResizeLeftRight: IDC_SIZEWE
    of ResizeTopBottom: IDC_SIZENS
    of ResizeTopLeftBottomRight: IDC_SIZENWSE
    of ResizeTopRightBottomLeft: IDC_SIZENESW

proc toMouseButton(msg: UINT, wParam: WPARAM): MouseButton =
  return case msg:
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

proc toKeyboardKey(wParam: WPARAM, lParam: LPARAM): KeyboardKey =
  let scanCode = LOBYTE(HIWORD(lParam))
  let isRight = (HIWORD(lParam) and KF_EXTENDED) == KF_EXTENDED
  return case scanCode:
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

proc `=destroy`*(backendData: var type Win32BackendData()[]) =
  DestroyWindow(backendData.hwnd)

var windowCount = 0
const windowClassName = "DefaultWindowClass"

proc win32BackendData(gui: Gui): Win32BackendData =
  cast[Win32BackendData](gui.backendData)

proc getSize(backendData: Win32BackendData): (int, int) =
  var area: RECT
  GetClientRect(backendData.hwnd, addr(area))
  return (int(area.right), int(area.bottom))

proc getCursorPosition(backendData: Win32BackendData): (int, int) =
  var pos: POINT
  if GetCursorPos(addr(pos)) == TRUE:
    ScreenToClient(backendData.hwnd, addr(pos))
    return (int(pos.x), int(pos.y))

proc updateCursorStyle(gui: Gui) =
  SetCursor(LoadCursorA(nil, gui.cursorStyle.toWin32CursorStyle))

proc closeRequested*(gui: Gui): bool =
  gui.win32BackendData.closeRequested

proc makeContextCurrent*(gui: Gui) =
  let backendData = gui.win32BackendData
  wglMakeCurrent(backendData.hdc, backendData.hglrc)

proc pollEvents*(gui: Gui) =
  let backendData = gui.win32BackendData
  var msg: MSG
  while PeekMessageA(addr(msg), backendData.hwnd, 0, 0, PM_REMOVE) != FALSE:
    TranslateMessage(addr(msg))
    DispatchMessageA(addr(msg))

proc swapBuffers*(gui: Gui) =
  SwapBuffers(gui.win32BackendData.hdc)

proc show*(gui: Gui) =
  ShowWindow(gui.win32BackendData.hwnd, SW_SHOW)

proc hide*(gui: Gui) =
  ShowWindow(gui.win32BackendData.hwnd, SW_HIDE)

proc close*(gui: Gui) =
  let backendData = gui.win32BackendData
  if not backendData.closeRequested:
    backendData.closeRequested = true
    DestroyWindow(backendData.hwnd)

proc processFrame*(gui: Gui) =
  gui.inputTime(cpuTime())
  if not gui.closeRequested:
    gui.clear()
  if gui.onFrame != nil:
    gui.onFrame(gui)
  if gui.isHovered:
    gui.updateCursorStyle()

proc run*(gui: Gui) =
  while true:
    gui.pollEvents()
    if gui.closeRequested:
      return
    gui.makeContextCurrent()
    gui.processFrame()
    gui.swapBuffers()

proc windowProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    let lpcs = cast[LPCREATESTRUCTA](lparam)
    SetWindowLongPtrA(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

  let gui = cast[Gui](GetWindowLongPtrA(hwnd, GWLP_USERDATA))
  if gui == nil or hwnd != gui.win32BackendData.hwnd:
    return DefWindowProcA(hwnd, msg, wparam, lparam)

  let backendData = gui.win32BackendData

  case msg:

  of WM_ENTERSIZEMOVE:
    backendData.sizeMoveTimerId = SetTimer(hwnd, 1, USER_TIMER_MINIMUM, nil)

  of WM_EXITSIZEMOVE:
    KillTimer(hwnd, backendData.sizeMoveTimerId)

  of WM_TIMER:
    if (wParam == backendData.sizeMoveTimerId):
      if not gui.closeRequested:
        gui.makeContextCurrent()
        gui.processFrame()
        gui.swapBuffers()

  of WM_SIZE:
    let contentScale = gui.contentScale
    gui.inputSize(
      float(LOWORD(cast[DWORD](lparam))) / contentScale,
      float(HIWORD(cast[DWORD](lparam))) / contentScale,
    )

  of WM_CLOSE:
    gui.close()

  of WM_DESTROY:
    gui.makeContextCurrent()
    if windowCount > 0:
      windowCount -= 1
      if windowCount == 0:
        UnregisterClassA(windowClassName, nil)
    GcUnRef(backendData)

  of WM_DPICHANGED:
    gui.inputContentScale(float(GetDpiForWindow(backendData.hwnd)) / densityPixelDpi)

  of WM_MOUSEMOVE:
    backendData.cursorX = int(GET_X_LPARAM(lparam))
    backendData.cursorY = int(GET_Y_LPARAM(lparam))

    if not gui.isHovered:
      var tme: TTRACKMOUSEEVENT
      tme.cbSize = DWORD(sizeof(tme))
      tme.dwFlags = TME_LEAVE
      tme.hwndTrack = hwnd
      TrackMouseEvent(addr(tme))
      gui.inputMouseEnter()

    let contentScale = gui.contentScale
    gui.inputMouseMove(
      float(backendData.cursorX) / contentScale,
      float(backendData.cursorY) / contentScale,
    )

    gui.updateCursorStyle()

  of WM_MOUSELEAVE:
    let contentScale = gui.contentScale
    gui.inputMouseMove(
      float(backendData.cursorX) / contentScale,
      float(backendData.cursorY) / contentScale,
    )
    gui.inputMouseExit()

  of WM_MOUSEWHEEL:
    gui.inputMouseWheel(0, float(GET_WHEEL_DELTA_WPARAM(wparam)) / WHEEL_DELTA)

  of WM_MOUSEHWHEEL:
    gui.inputMouseWheel(float(GET_WHEEL_DELTA_WPARAM(wparam)) / WHEEL_DELTA, 0)

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    backendData.cursorX = int(GET_X_LPARAM(lparam))
    backendData.cursorY = int(GET_Y_LPARAM(lparam))
    SetCapture(hwnd)
    gui.inputMousePress(toMouseButton(msg, wparam))

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    backendData.cursorX = int(GET_X_LPARAM(lparam))
    backendData.cursorY = int(GET_Y_LPARAM(lparam))
    ReleaseCapture()
    gui.inputMouseRelease(toMouseButton(msg, wparam))

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    gui.inputKeyPress(toKeyboardKey(wparam, lparam))

  of WM_KEYUP, WM_SYSKEYUP:
    gui.inputKeyRelease(toKeyboardKey(wparam, lparam))

  of WM_CHAR, WM_SYSCHAR:
    if wparam > 0 and wparam < 0x10000:
      gui.inputText($cast[Rune](wparam))

  of WM_ERASEBKGND:
    let hdc = cast[HDC](wparam)
    var clientRect: RECT
    GetClientRect(hwnd, addr(clientRect))
    let r = int(gui.backgroundColor.r * 255)
    let g = int(gui.backgroundColor.g * 255)
    let b = int(gui.backgroundColor.b * 255)
    FillRect(hdc, addr(clientRect), CreateSolidBrush(RGB(r, g, b)))

  # of WM_NCCALCSIZE:
  #   if not gui.isDecorated:
  #     return 0

  else:
    discard

  return DefWindowProcA(hwnd, msg, wparam, lparam)

proc setupBackend*(gui: Gui) =
  let backendData = Win32BackendData()
  GcRef(backendData)

  gui.backendData = cast[pointer](backendData)

  var hinstance = GetModuleHandleA(nil)

  if windowCount == 0:
    var windowClass = WNDCLASSEXA(
      cbSize: UINT(sizeof(WNDCLASSEXA)),
      style: CS_OWNDC,
      lpfnWndProc: windowProc,
      hInstance: hinstance,
      hCursor: nil,
      lpszClassName: windowClassName,
    )
    RegisterClassExA(addr(windowClass))

  backendData.hwnd = CreateWindowExA(
    0,
    windowClassName,
    nil,
    WS_OVERLAPPEDWINDOW,
    cint(CW_USEDEFAULT),
    cint(CW_USEDEFAULT),
    cint(CW_USEDEFAULT),
    cint(CW_USEDEFAULT),
    GetDesktopWindow(),
    nil,
    hinstance,
    cast[pointer](gui),
  )

  (backendData.cursorX, backendData.cursorY) = backendData.getCursorPosition()

  SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

  var pfd = PIXELFORMATDESCRIPTOR(
    nSize: sizeof(PIXELFORMATDESCRIPTOR).WORD,
    nVersion: 1,
    dwFlags: PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_SUPPORT_COMPOSITION or PFD_DOUBLEBUFFER,
    iPixelType: PFD_TYPE_RGBA,
    cColorBits: 32,
    cRedBits: 0, cRedShift: 0,
    cGreenBits: 0, cGreenShift: 0,
    cBlueBits: 0, cBlueShift: 0,
    cAlphaBits: 0, cAlphaShift: 0,
    cAccumBits: 0,
    cAccumRedBits: 0,
    cAccumGreenBits: 0,
    cAccumBlueBits: 0,
    cAccumAlphaBits: 0,
    cDepthBits: 32,
    cStencilBits: 8,
    cAuxBuffers: 0,
    iLayerType: PFD_MAIN_PLANE,
    bReserved: 0,
    dwLayerMask: 0,
    dwVisibleMask: 0,
    dwDamageMask: 0,
  )

  backendData.hdc = GetDC(backendData.hwnd)
  SetPixelFormat(
    backendData.hdc,
    ChoosePixelFormat(backendData.hdc, addr(pfd)),
    addr(pfd),
  )

  backendData.hglrc = wglCreateContext(backendData.hdc)
  wglMakeCurrent(backendData.hdc, backendData.hglrc)

  opengl.loadExtensions()

  ReleaseDC(backendData.hwnd, backendData.hdc)

  windowCount += 1

  let contentScale = float(GetDpiForWindow(backendData.hwnd)) / densityPixelDpi
  gui.inputContentScale(contentScale)

  let (width, height) = backendData.getSize()
  gui.inputSize(
    float(width) / contentScale,
    float(height) / contentScale,
  )

  gui.setupVectorGraphics()