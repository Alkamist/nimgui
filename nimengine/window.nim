import std/[unicode, tables, exitprocs]
import winim/lean

import ./client

export client

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

type
  Window* = ref object
    shouldClose*: bool
    client*: Client
    hwnd: HWND
    hdc: HDC
    hglrc: HGLRC

var hwndToWindowTable = newTable[HWND, Window]()
var windowClassIsRegistered = false
var windowClass = WNDCLASSEX(
  cbSize: WNDCLASSEX.sizeof.UINT,
  style: CS_CLASSDC,
  lpfnWndProc: windowProc,
  cbClsExtra: 0,
  cbWndExtra: 0,
  hInstance: GetModuleHandle(nil),
  hIcon: 0,
  hCursor: LoadCursor(0, IDC_ARROW),
  hbrBackground: CreateSolidBrush(RGB(0, 0, 0)),
  lpszMenuName: nil,
  lpszClassName: "Default Window Class",
  hIconSm: 0,
)

proc pollEvents*(window: Window) =
  var msg: MSG
  while PeekMessage(msg, window.hwnd, 0, 0, PM_REMOVE) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

proc swapBuffers*(window: Window) =
  SwapBuffers(window.hdc)

proc makeContextCurrent*(window: Window) =
  var pfd = PIXELFORMATDESCRIPTOR(
    nSize: PIXELFORMATDESCRIPTOR.sizeof.WORD,
    nVersion: 1,
  )
  pfd.dwFlags = PFD_DRAW_TO_WINDOW or
                PFD_SUPPORT_OPENGL or
                PFD_SUPPORT_COMPOSITION or
                PFD_DOUBLEBUFFER
  pfd.iPixelType = PFD_TYPE_RGBA
  pfd.cColorBits = 32
  pfd.cAlphaBits = 8
  pfd.iLayerType = PFD_MAIN_PLANE

  window.hdc = GetDC(window.hwnd)
  let format = ChoosePixelFormat(window.hdc, pfd.addr)
  if format == 0:
    raise newException(OSError, "ChoosePixelFormat failed.")

  if SetPixelFormat(window.hdc, format, pfd.addr) == 0:
    raise newException(OSError, "SetPixelFormat failed.")

  var activeFormat = GetPixelFormat(window.hdc)
  if activeFormat == 0:
    raise newException(OSError, "GetPixelFormat failed.")

  if DescribePixelFormat(window.hdc, format, pfd.sizeof.UINT, pfd.addr) == 0:
    raise newException(OSError, "DescribePixelFormat failed.")

  if (pfd.dwFlags and PFD_SUPPORT_OPENGL) != PFD_SUPPORT_OPENGL:
    raise newException(OSError, "PFD_SUPPORT_OPENGL check failed.")

  window.hglrc = wglCreateContext(window.hdc)
  if window.hglrc == 0:
    raise newException(OSError, "wglCreateContext failed.")

  wglMakeCurrent(window.hdc, window.hglrc)

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

func toKeyboardKey(scanCode: int): KeyboardKey =
  case scanCode:
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

func getClientWidthAndHeight(hwnd: HWND): (float, float) =
  var windowRect: RECT
  GetWindowRect(hwnd, windowRect.addr)
  var clientScreenCoords: POINT
  ClientToScreen(hwnd, clientScreenCoords.addr)
  let titleBarHeight = (clientScreenCoords.y - windowRect.top).float
  let fullWindowWidth = (windowRect.right - windowRect.left).float
  let fullWindowHeight = (windowRect.bottom - windowRect.top).float
  (fullWindowWidth, fullWindowHeight - titleBarHeight)

template ifWindowExists(hwnd: HWND, code: untyped): untyped =
  if hwndToWindowTable.contains(hwnd):
    var window {.inject.} = hwndToWindowTable[hwnd]
    code

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  case msg:

  of WM_CLOSE:
    ifWindowExists(hwnd):
      window.client.processClose()
      DestroyWindow(hwnd)
      window.shouldClose = true
      hwndToWindowTable.del(hwnd)

  of WM_SIZE:
    ifWindowExists(hwnd):
      let (w, h) = getClientWidthAndHeight(hwnd)
      window.client.processResize(w, h)

  # of WM_MOVE:
  #   ifWindowExists(hwnd):
  #     var clientScreenCoords: POINT
  #     ClientToScreen(hwnd, clientScreenCoords.addr)
  #     window.processMove(clientScreenCoords.x.float, clientScreenCoords.y.float)

  # of WM_SYSCOMMAND:
  #   ifWindowExists(hwnd):
  #     case wParam:
  #     of SC_MINIMIZE:
  #       window.processMinimize()
  #     of SC_MAXIMIZE:
  #       window.processMaximize()
  #     else: discard

  of WM_MOUSEMOVE:
    ifWindowExists(hwnd):
      window.client.mouse.processMove(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float)

  of WM_MOUSEWHEEL:
    ifWindowExists(hwnd):
      window.client.mouse.processScroll(0.0, GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float)

  of WM_MOUSEHWHEEL:
    ifWindowExists(hwnd):
      window.client.mouse.processScroll(GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float, 0.0)

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    ifWindowExists(hwnd):
      SetCapture(hwnd)
      window.client.mouse.processPress(toMouseButton(msg, wParam))

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ifWindowExists(hwnd):
      ReleaseCapture()
      window.client.mouse.processRelease(toMouseButton(msg, wParam))

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    ifWindowExists(hwnd):
      let scanCode = LOBYTE(HIWORD(lParam))
      let isRight = (HIWORD(lParam) and KF_EXTENDED) == KF_EXTENDED
      let key = case scanCode:
        of 42: KeyboardKey.LeftShift
        of 54: KeyboardKey.RightShift
        of 29:
          if isRight: KeyboardKey.RightControl else: KeyboardKey.LeftControl
        of 56:
          if isRight: KeyboardKey.RightAlt else: KeyboardKey.LeftAlt
        else: toKeyboardKey(wParam.int)
      window.client.keyboard.processPress(key)

  of WM_KEYUP, WM_SYSKEYUP:
    ifWindowExists(hwnd):
      let scanCode = LOBYTE(HIWORD(lParam))
      let isRight = (HIWORD(lParam) and KF_EXTENDED) == KF_EXTENDED
      let key = case scanCode:
        of 42: KeyboardKey.LeftShift
        of 54: KeyboardKey.RightShift
        of 29:
          if isRight: KeyboardKey.RightControl else: KeyboardKey.LeftControl
        of 56:
          if isRight: KeyboardKey.RightAlt else: KeyboardKey.LeftAlt
        else: toKeyboardKey(wParam.int)
      window.client.keyboard.processRelease(key)

  of WM_CHAR, WM_SYSCHAR:
    ifWindowExists(hwnd):
      if wParam > 0 and wParam < 0x10000:
        window.client.keyboard.processCharacter(cast[Rune](wParam).toUTF8)

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)

proc new*(_: type Window,
          title = "Window",
          x, y = 0,
          width = 1024, height = 768,
          parent: HWND = 0): Window =
  if not windowClassIsRegistered:
    RegisterClassEx(windowClass)
    windowClassIsRegistered = true
    addExitProc proc =
      UnregisterClass(windowClass.lpszClassName, windowClass.hInstance)

  let hwnd = CreateWindow(
    lpClassName = windowClass.lpszClassName,
    lpWindowName = title,
    dwStyle = WS_OVERLAPPEDWINDOW,
    x = x.int32,
    y = y.int32,
    nWidth = width.int32,
    nHeight = height.int32,
    hWndParent = parent,
    hMenu = 0,
    hInstance = windowClass.hInstance,
    lpParam = nil,
  )

  ShowWindow(hwnd, SW_SHOWDEFAULT)
  UpdateWindow(hwnd)
  InvalidateRect(hwnd, nil, 1)

  let (clientWidth, clientHeight) = getClientWidthAndHeight(hwnd)

  let w = Window(
    client: Client.new(clientWidth, clientHeight),
    hwnd: hwnd,
  )

  hwndToWindowTable[hwnd] = w
  w