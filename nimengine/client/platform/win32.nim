import std/[unicode, tables, exitprocs, options]
import winim/lean

include ../clientbase

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

var hwndToClientTable = newTable[HWND, Client]()
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

# func getClientWidthAndHeight(hwnd: HWND): (float, float) =
#   var windowRect: RECT
#   GetWindowRect(hwnd, windowRect.addr)
#   var clientScreenCoords: POINT
#   ClientToScreen(hwnd, clientScreenCoords.addr)
#   let titleBarHeight = (clientScreenCoords.y - windowRect.top).float
#   let fullWindowWidth = (windowRect.right - windowRect.left).float
#   let fullWindowHeight = (windowRect.bottom - windowRect.top).float
#   (fullWindowWidth, fullWindowHeight - titleBarHeight)

func getClientWidthAndHeight(hwnd: HWND): (LONG, LONG) =
  var area: RECT
  GetClientRect(hwnd, area.addr)
  (area.right, area.bottom)

func getCursorPosition(hwnd: HWND): Option[(LONG, LONG)] =
  var pos: POINT
  if GetCursorPos(pos.addr):
    ScreenToClient(hwnd, pos.addr)
    return some (pos.x, pos.y)

proc setClipRectToWindow(hwnd: HWND) =
  var clipRect: RECT
  GetClientRect(hwnd, &clipRect)
  ClientToScreen(hwnd, cast[ptr POINT](clipRect.left.addr))
  ClientToScreen(hwnd, cast[ptr POINT](clipRect.right.addr))
  ClipCursor(&clipRect)

proc removeClipRect() =
  ClipCursor(nil)

proc setCursorPosition*(client: Client, x, y: float) =
  var pos = POINT(x: x.cint, y: y.cint)
  client.platform.lastCursorPosX = x
  client.platform.lastCursorPosY = y
  ClientToScreen(client.platform.handle, pos.addr)
  SetCursorPos(pos.x, pos.y)

proc centerCursor*(client: Client) =
  let (width, height) = getClientWidthAndHeight(client.platform.handle)
  client.setCursorPosition((width div 2).float, (height div 2).float)

proc confineCursor*(client: Client) =
  setClipRectToWindow(client.platform.handle)
  client.cursorIsConfined = true

proc unconfineCursor*(client: Client) =
  removeClipRect()
  client.cursorIsConfined = false

proc pinCursorToCenter*(client: Client) =
  let cursorPosRestore = getCursorPosition(client.platform.handle)
  if cursorPosRestore.isSome:
    client.platform.restoreCursorPosX = cursorPosRestore.get[0].float
    client.platform.restoreCursorPosY = cursorPosRestore.get[1].float
  client.centerCursor()
  client.cursorIsPinnedToCenter = true

proc unpinCursorFromCenter*(client: Client) =
  client.setCursorPosition(client.platform.restoreCursorPosX,
                           client.platform.restoreCursorPosY)
  client.cursorIsPinnedToCenter = false

template startEventLoop*(client: Client, code: untyped): untyped =
  while not client.shouldClose:
    code

    var msg: MSG
    while PeekMessage(msg, client.platform.handle, 0, 0, PM_REMOVE) != 0:
      TranslateMessage(msg)
      DispatchMessage(msg)

    if client.cursorIsPinnedToCenter:
      let (width, height) = getClientWidthAndHeight(client.platform.handle)
      if client.platform.lastCursorPosX != width / 2 or
         client.platform.lastCursorPosY != height / 2:
        client.setCursorPosition(width / 2, height / 2)

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

template ifClientExists(hwnd: HWND, code: untyped): untyped =
  if hwndToClientTable.contains(hwnd):
    var client {.inject.} = hwndToClientTable[hwnd]
    code

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  case msg:

  of WM_CLOSE:
    ifClientExists(hwnd):
      client.processClosed()
      DestroyWindow(hwnd)
      client.shouldClose = true
      hwndToClientTable.del(hwnd)

  of WM_SIZE:
    ifClientExists(hwnd):
      let (w, h) = getClientWidthAndHeight(hwnd)
      client.processResized(w.float, h.float)

  of WM_MOUSEMOVE:
    ifClientExists(hwnd):
      let x = GET_X_LPARAM(lParam)
      let y = GET_Y_LPARAM(lParam)

      if client.cursorIsConfined:
        let dx = x - client.platform.lastCursorPosX.int
        let dy = y - client.platform.lastCursorPosY.int
        client.processMouseMoved(client.mouse.x + dx.float,
                                 client.mouse.y + dy.float)
      else:
        client.processMouseMoved(x.float, y.float)

      client.platform.lastCursorPosX = x.float
      client.platform.lastCursorPosY = y.float

  of WM_MOUSEWHEEL:
    ifClientExists(hwnd):
      client.processMouseWheelScrolled(0.0, GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float)

  of WM_MOUSEHWHEEL:
    ifClientExists(hwnd):
      client.processMouseWheelScrolled(GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float, 0.0)

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    ifClientExists(hwnd):
      SetCapture(hwnd)
      client.processMouseButtonPressed(toMouseButton(msg, wParam))

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ifClientExists(hwnd):
      ReleaseCapture()
      client.processMouseButtonReleased(toMouseButton(msg, wParam))

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    ifClientExists(hwnd):
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
      client.processKeyboardKeyPressed(key)

  of WM_KEYUP, WM_SYSKEYUP:
    ifClientExists(hwnd):
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
      client.processKeyboardKeyReleased(key)

  of WM_CHAR, WM_SYSCHAR:
    ifClientExists(hwnd):
      if wParam > 0 and wParam < 0x10000:
        client.processKeyboardCharacterInput(cast[Rune](wParam).toUTF8)

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)

proc new*(_: type Client,
          title = "Client",
          x, y = 0,
          width = 1024, height = 768,
          parent: HWND = 0): Client =
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

  result = newDefaultClient(clientWidth.float, clientHeight.float)
  result.platform = PlatformData(
    handle: hwnd,
  )

  hwndToClientTable[hwnd] = result