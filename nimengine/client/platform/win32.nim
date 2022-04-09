import std/[unicode, tables, exitprocs, options]
import winim/lean

import ./win32helpers
import ../base

export base

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

proc updateCursorImage(client: Client) =
  if client.cursorIsHidden:
    SetCursor(0)
  else:
    SetCursor(LoadCursorW(0, IDC_ARROW))

proc hideCursor*(client: Client) =
  if not client.cursorIsHidden:
    client.cursorIsHidden = true
    client.updateCursorImage()

proc showCursor*(client: Client) =
  if client.cursorIsHidden:
    client.cursorIsHidden = false
    client.updateCursorImage()

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
  if not client.cursorIsConfined:
    setClipRectToWindow(client.platform.handle)
    client.cursorIsConfined = true

proc unconfineCursor*(client: Client) =
  if client.cursorIsConfined:
    removeClipRect()
    client.cursorIsConfined = false

proc pinCursorToCenter*(client: Client) =
  if not client.cursorIsPinnedToCenter:
    let cursorPosRestore = getCursorPosition(client.platform.handle)
    if cursorPosRestore.isSome:
      client.platform.restoreCursorPosX = cursorPosRestore.get[0].float
      client.platform.restoreCursorPosY = cursorPosRestore.get[1].float
    client.centerCursor()
    client.cursorIsPinnedToCenter = true

proc unpinCursorFromCenter*(client: Client) =
  if client.cursorIsPinnedToCenter:
    client.setCursorPosition(client.platform.restoreCursorPosX,
                            client.platform.restoreCursorPosY)
    client.cursorIsPinnedToCenter = false

proc newClient*(title = "Client",
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

  result = newClientBase(clientWidth.float, clientHeight.float)
  result.platform = ClientPlatformData(handle: hwnd)

  result.postFrame = proc(client: Client) =
    pollEvents(client.platform.handle)
    if client.cursorIsPinnedToCenter:
      let (width, height) = getClientWidthAndHeight(client.platform.handle)
      if client.platform.lastCursorPosX != width / 2 or
         client.platform.lastCursorPosY != height / 2:
        client.setCursorPosition((width div 2).float, (height div 2).float)

  hwndToClientTable[hwnd] = result

# The giant win32 api event handler function that dispatches events.
proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  template ifClientExists(hwnd: HWND, code: untyped): untyped =
    if hwndToClientTable.contains(hwnd):
      var client {.inject.} = hwndToClientTable[hwnd]
      code

  case msg:

  of WM_SETCURSOR:
    ifClientExists(hwnd):
      if LOWORD(lParam) == HTCLIENT:
        client.updateCursorImage()
        return TRUE

  of WM_SETFOCUS:
    ifClientExists(hwnd):
      client.processFocus()

  of WM_KILLFOCUS:
    ifClientExists(hwnd):
      client.processLoseFocus()

  of WM_MOVE:
    ifClientExists(hwnd):
      if client.cursorIsConfined:
        setClipRectToWindow(hwnd)

  of WM_CLOSE:
    ifClientExists(hwnd):
      client.processClose()
      DestroyWindow(hwnd)
      client.shouldClose = true
      hwndToClientTable.del(hwnd)

  of WM_SIZE:
    ifClientExists(hwnd):
      let (w, h) = getClientWidthAndHeight(hwnd)
      client.processResize(w.float, h.float)

  of WM_MOUSEMOVE:
    ifClientExists(hwnd):
      let x = GET_X_LPARAM(lParam)
      let y = GET_Y_LPARAM(lParam)

      if not client.platform.isTrackingMouse:
        var tme: TTRACKMOUSEEVENT
        ZeroMemory(tme.addr, sizeof(tme))
        tme.cbSize = sizeof(tme).cint
        tme.dwFlags = TME_LEAVE
        tme.hwndTrack = client.platform.handle
        TrackMouseEvent(tme.addr)

        client.platform.isTrackingMouse = true
        client.processMouseEnter()

      if client.cursorIsConfined:
        let dx = x - client.platform.lastCursorPosX.int
        let dy = y - client.platform.lastCursorPosY.int
        client.processMouseMove(client.mouseX + dx.float,
                                client.mouseY + dy.float)
      else:
        client.processMouseMove(x.float, y.float)

      client.platform.lastCursorPosX = x.float
      client.platform.lastCursorPosY = y.float

  of WM_MOUSELEAVE:
    ifClientExists(hwnd):
      client.platform.isTrackingMouse = false
      client.processMouseExit()

  of WM_MOUSEWHEEL:
    ifClientExists(hwnd):
      client.processMouseWheel(0.0, GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float)

  of WM_MOUSEHWHEEL:
    ifClientExists(hwnd):
      client.processMouseWheel(GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float, 0.0)

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    ifClientExists(hwnd):
      SetCapture(hwnd)
      client.processMousePress(toMouseButton(msg, wParam))

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ifClientExists(hwnd):
      ReleaseCapture()
      client.processMouseRelease(toMouseButton(msg, wParam))

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
      client.processKeyPress(key)

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
      client.processKeyRelease(key)

  of WM_CHAR, WM_SYSCHAR:
    ifClientExists(hwnd):
      if wParam > 0 and wParam < 0x10000:
        client.processCharacter(cast[Rune](wParam).toUTF8)

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)