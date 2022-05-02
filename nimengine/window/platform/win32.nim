import std/unicode
import winim/lean

import ./win32helpers
import ../types
import ../base

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

const windowClassName = "Default Window Class"
var windowCount = 0

proc updateCursorImage(window: Window) =
  if window.cursorIsHidden:
    SetCursor(0)
  else:
    SetCursor(LoadCursorW(0, IDC_ARROW))

proc hideCursor*(window: Window) =
  if not window.cursorIsHidden:
    window.cursorIsHidden = true
    window.updateCursorImage()

proc showCursor*(window: Window) =
  if window.cursorIsHidden:
    window.cursorIsHidden = false
    window.updateCursorImage()

proc setCursorPosition*(window: Window, x, y: float) =
  var pos = POINT(x: x.cint, y: y.cint)
  window.platform.lastCursorPosX = x
  window.platform.lastCursorPosY = y
  ClientToScreen(window.platform.handle, pos.addr)
  SetCursorPos(pos.x, pos.y)

proc centerCursor*(window: Window) =
  let (width, height) = getClientWidthAndHeight(window.platform.handle)
  window.setCursorPosition((width div 2).float, (height div 2).float)

proc confineCursor*(window: Window) =
  if not window.cursorIsConfined:
    setClipRectToWindow(window.platform.handle)
    window.cursorIsConfined = true

proc unconfineCursor*(window: Window) =
  if window.cursorIsConfined:
    removeClipRect()
    window.cursorIsConfined = false

proc pinCursorToCenter*(window: Window) =
  if not window.cursorIsPinnedToCenter:
    let cursorPosRestore = getCursorPosition(window.platform.handle)
    if cursorPosRestore.isSome:
      window.platform.restoreCursorPosX = cursorPosRestore.get[0].float
      window.platform.restoreCursorPosY = cursorPosRestore.get[1].float
    window.centerCursor()
    window.cursorIsPinnedToCenter = true

proc unpinCursorFromCenter*(window: Window) =
  if window.cursorIsPinnedToCenter:
    window.setCursorPosition(window.platform.restoreCursorPosX,
                            window.platform.restoreCursorPosY)
    window.cursorIsPinnedToCenter = false

proc preUpdate*(window: Window) =
  if not window.isChild:
    pollEvents(window.platform.handle)

proc postUpdate*(window: Window) =
  if window.cursorIsPinnedToCenter:
    let (width, height) = getClientWidthAndHeight(window.platform.handle)
    if window.platform.lastCursorPosX != width / 2 or
       window.platform.lastCursorPosY != height / 2:
      window.setCursorPosition((width div 2).float, (height div 2).float)

proc close*(window: Window) =
  window.processClose()
  DestroyWindow(window.platform.handle)
  window.isClosed = true

proc newWindow*(title = "Window",
                x, y = 0,
                width = 1024, height = 768,
                parentHandle: pointer = nil): Window =
  result = Window(input: newInput())

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
  let windowStyle =
    if isChild:
      WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    else:
      WS_OVERLAPPEDWINDOW or WS_VISIBLE

  result.isChild = isChild

  discard CreateWindow(
    lpClassName = windowClassName,
    lpWindowName = title,
    dwStyle = windowStyle.int32,
    x = x.int32,
    y = y.int32,
    nWidth = width.int32,
    nHeight = height.int32,
    hWndParent = cast[HWND](parentHandle),
    hMenu = 0,
    hInstance = GetModuleHandle(nil),
    lpParam = cast[pointer](result),
  )

  inc windowCount



# The giant win32 api event handler function that dispatches events.
proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    var lpcs = cast[LPCREATESTRUCT](lParam)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

    let window = cast[Window](GetWindowLongPtr(hwnd, GWLP_USERDATA))

    let (w, h) = getClientWidthAndHeight(hwnd)
    window.width = w.float
    window.height = h.float
    window.previousWidth = w.float
    window.previousHeight = h.float
    window.platform = WindowPlatformData(handle: hwnd)

  let window = cast[Window](GetWindowLongPtr(hwnd, GWLP_USERDATA))
  if window == nil or hwnd != window.platform.handle:
    return DefWindowProc(hwnd, msg, wParam, lParam)

  case msg:

  of WM_SETCURSOR:
    if LOWORD(lParam) == HTCLIENT:
      window.updateCursorImage()
      return TRUE

  of WM_SETFOCUS:
    window.processFocus()

  of WM_KILLFOCUS:
    window.processLoseFocus()

  of WM_MOVE:
    if window.cursorIsConfined:
      setClipRectToWindow(hwnd)
    window.processMove(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float)

  of WM_SIZE:
    let (w, h) = getClientWidthAndHeight(hwnd)
    window.processResize(w.float, h.float)

  of WM_CLOSE:
    window.close()

  of WM_DESTROY:
    dec windowCount
    windowCount = windowCount.max(0)
    if windowCount == 0:
      UnregisterClass(windowClassName, GetModuleHandle(nil))

  of WM_MOUSEMOVE:
    let x = GET_X_LPARAM(lParam)
    let y = GET_Y_LPARAM(lParam)

    if not window.platform.isTrackingMouse:
      var tme: TTRACKMOUSEEVENT
      ZeroMemory(tme.addr, sizeof(tme))
      tme.cbSize = sizeof(tme).cint
      tme.dwFlags = TME_LEAVE
      tme.hwndTrack = window.platform.handle
      TrackMouseEvent(tme.addr)

      window.platform.isTrackingMouse = true
      window.processMouseEnter()

    if window.cursorIsConfined:
      let dx = x - window.platform.lastCursorPosX.int
      let dy = y - window.platform.lastCursorPosY.int
      window.processMouseMove(window.input.mouseX + dx.float,
                              window.input.mouseY + dy.float)
    else:
      window.processMouseMove(x.float, y.float)

    window.platform.lastCursorPosX = x.float
    window.platform.lastCursorPosY = y.float

  of WM_MOUSELEAVE:
    window.platform.isTrackingMouse = false
    window.processMouseExit()

  of WM_MOUSEWHEEL:
    window.processMouseWheel(0.0, GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float)

  of WM_MOUSEHWHEEL:
    window.processMouseWheel(GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float, 0.0)

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    SetCapture(hwnd)
    window.processMousePress(toMouseButton(msg, wParam))

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ReleaseCapture()
    window.processMouseRelease(toMouseButton(msg, wParam))

  of WM_KEYDOWN, WM_SYSKEYDOWN:
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
    window.processKeyPress(key)

  of WM_KEYUP, WM_SYSKEYUP:
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
    window.processKeyRelease(key)

  of WM_CHAR, WM_SYSCHAR:
    if wParam > 0 and wParam < 0x10000:
      window.processCharacter(cast[Rune](wParam).toUTF8)

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)