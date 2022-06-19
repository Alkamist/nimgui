{.experimental: "overloadableEnums".}

import std/exitprocs
import std/times
import std/unicode
import opengl
import winim/lean
import ./window; export window

type
  Win32Window* = ref object of Window
    hwnd*: HWND
    hdc*: HDC
    startHdc*: HDC
    hglrc*: HGLRC
    startHglrc*: HGLRC
    moveTimer*: UINT_PTR
    windowClass*: WNDCLASSEX

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}

var windowClass = WNDCLASSEX(
  cbSize: WNDCLASSEX.sizeof.UINT,
  style: CS_OWNDC,
  lpfnWndProc: windowProc,
  cbClsExtra: 0,
  cbWndExtra: 0,
  hInstance: GetModuleHandle(nil),
  hIcon: 0,
  hCursor: LoadCursor(0, IDC_ARROW),
  hbrBackground: 0,
  lpszMenuName: nil,
  lpszClassName: "Platform Window",
  hIconSm: 0,
)
RegisterClassEx(windowClass)
addExitProc(proc() = UnregisterClass(windowClass.lpszClassName, GetModuleHandle(nil)))

type
  MARGINS* {.byCopy.} = object
    cxLeftWidth*: cint
    cxRightWidth*: cint
    cyTopHeight*: cint
    cyBottomHeight*: cint

const WM_DPICHANGED* = 0x02E0
const DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = -4

type Proc_SetProcessDpiAwarenessContext = proc(value: int): BOOL {.stdcall.}
var SetProcessDpiAwarenessContext: Proc_SetProcessDpiAwarenessContext
type Proc_GetDpiForWindow = proc(hWnd: HWND): UINT {.stdcall.}
var GetDpiForWindow: Proc_GetDpiForWindow
type Proc_DwmExtendFrameIntoClientArea = proc(hWnd: HWND, pMarInset: ptr MARGINS): HRESULT {.stdcall.}
var DwmExtendFrameIntoClientArea: Proc_DwmExtendFrameIntoClientArea

var win32LibrariesAreLoaded = false
template loadLibraries() =
  if not win32LibrariesAreLoaded:
    let user32 = LoadLibraryA("user32.dll")
    if user32 == 0:
      quit("Error loading user32.dll")

    SetProcessDpiAwarenessContext = cast[Proc_SetProcessDpiAwarenessContext](
      GetProcAddress(user32, "SetProcessDpiAwarenessContext")
    )
    GetDpiForWindow = cast[Proc_GetDpiForWindow](
      GetProcAddress(user32, "GetDpiForWindow")
    )

    let dwmapi = LoadLibraryA("dwmapi.dll")
    if dwmapi == 0:
      quit("Error loading dwmapi.dll")

    DwmExtendFrameIntoClientArea = cast[Proc_DwmExtendFrameIntoClientArea](
      GetProcAddress(dwmapi, "DwmExtendFrameIntoClientArea")
    )

    win32LibrariesAreLoaded = true

proc dummyWindowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  DefWindowProc(hwnd, msg, wParam, lParam)

var openGlIsInitialized: bool
template initOpenGl() =
  if not openGlIsInitialized:
    var dummyClass = WNDCLASSEX(
      cbSize: WNDCLASSEX.sizeof.UINT,
      style: CS_HREDRAW or CS_VREDRAW or CS_OWNDC,
      lpfnWndProc: dummyWindowProc,
      cbClsExtra: 0,
      cbWndExtra: 0,
      hInstance: GetModuleHandle(nil),
      hIcon: 0,
      hCursor: 0,
      hbrBackground: 0,
      lpszMenuName: nil,
      lpszClassName: "Dummy Window",
      hIconSm: 0,
    )
    RegisterClassEx(dummyClass.addr)

    let hwnd = CreateWindow(
      lpClassName = dummyClass.lpszClassName,
      lpWindowName = "Dummy Window",
      dwStyle = WS_OVERLAPPEDWINDOW,
      x = CW_USEDEFAULT,
      y = CW_USEDEFAULT,
      nWidth = 500,
      nHeight = 500,
      hWndParent = 0,
      hMenu = 0,
      hInstance = GetModuleHandle(nil),
      lpParam = nil,
    )

    let dc = GetDC(hwnd)

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
    let fmt = ChoosePixelFormat(dc, pfd.addr)
    SetPixelFormat(dc, fmt, pfd.addr)

    let hglrc = wglCreateContext(dc)

    wglMakeCurrent(dc, hglrc)

    opengl.loadExtensions()

    var currentTexture: GLint
    glGetIntegerv(GL_TEXTURE_BINDING_2D, currentTexture.addr)

    wglMakeCurrent(0, 0)
    wglDeleteContext(hglrc)
    ReleaseDC(hwnd, dc)
    DestroyWindow(hwnd)
    UnregisterClass(dummyClass.lpszClassName, GetModuleHandle(nil))

    openGlIsInitialized = true

template createOpenGlContext(window: Win32Window) =
  initOpenGl()

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

  window.hdc = GetDC(window.hwnd)
  SetPixelFormat(
    window.hdc,
    ChoosePixelFormat(window.hdc, pfd.addr),
    pfd.addr,
  )
  window.hglrc = wglCreateContext(window.hdc)
  wglMakeCurrent(window.hdc, window.hglrc)
  ReleaseDC(window.hwnd, window.hdc)

template makeContextCurrent*(window: Win32Window) =
  window.startHdc = wglGetCurrentDC()
  window.startHglrc = wglGetCurrentContext()
  wglMakeCurrent(GetDC(window.hwnd), window.hglrc)

template swapBuffers(window: Win32Window) =
  SwapBuffers(window.hdc)

template pollEvents(window: Win32Window) =
  var msg: MSG
  while PeekMessage(msg, window.hwnd, 0, 0, PM_REMOVE) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

template updateBounds(window: Win32Window) =
  var rect: RECT
  GetClientRect(window.hwnd, rect.addr)
  ClientToScreen(window.hwnd, cast[ptr POINT](rect.left.addr))
  ClientToScreen(window.hwnd, cast[ptr POINT](rect.right.addr))
  window.frameState.frameBufferSize = vec2((rect.right - rect.left).float, (rect.bottom - rect.top).float)
  window.frameState.bounds.position = vec2(rect.left.float, rect.top.float) * window.frameState.contentScale
  window.frameState.bounds.size = window.frameState.frameBufferSize * window.frameState.contentScale

proc `bounds=`*(window: Window, bounds: Rect2) =
  let hwnd = cast[Win32Window](window).hwnd

  var rect: RECT
  rect.left = bounds.x.round.int32
  rect.top = bounds.y.round.int32
  rect.right = (bounds.x + bounds.width).round.int32
  rect.bottom = (bounds.y + bounds.height).round.int32
  AdjustWindowRectEx(rect.addr, getWindowStyle(hwnd), FALSE, getWindowExStyle(hwnd))

  SetWindowPos(window->win32.handle, NULL, rect.left, rect.top, 0, 0,
                SWP_NOACTIVATE | SWP_NOZORDER | SWP_NOSIZE);

  discard SetWindowPos(
    cast[Win32Window](window).hwnd,
    HWND_TOP,
    bounds.x.round.int32,
    bounds.y.round.int32,
    bounds.width.round.int32,
    bounds.height.round.int32,
    SWP_FRAMECHANGED,
  )

proc close*(window: Window) =
  let window = cast[Win32Window](window)
  if not window.closeRequested:
    DestroyWindow(window.hwnd)
    window.closeRequested = true

proc update*(window: Window) =
  let window = cast[Win32Window](window)

  if window.exists:
    window.updateFrameState(cpuTime())
    window.pollEvents()

  if window.exists:
    window.makeContextCurrent()

    let frameBufferSize = window.frameBufferSize
    glViewport(0.GLint, 0.GLint, frameBufferSize.x.GLsizei, frameBufferSize.y.GLsizei)
    glClear(GL_COLOR_BUFFER_BIT)

    window.gfx.beginFrame(window.frameBufferSize, window.contentScale)

    if window.onFrame != nil:
      window.onFrame()

    window.gfx.endFrame()
    window.swapBuffers()

proc `backgroundColor=`*(window: Window, color: Color) =
  cast[Win32Window](window).makeContextCurrent()
  glClearColor(color.r, color.g, color.b, color.a)

proc newWindow*(parentHandle: pointer = nil): Window =
  loadLibraries()

  result = newWindowBase(cpuTime())

  let isChild = parentHandle != nil
  let windowStyle =
    if isChild:
      WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    else:
      WS_OVERLAPPEDWINDOW or WS_VISIBLE

  cast[Win32Window](result).hwnd = CreateWindow(
    lpClassName = windowClass.lpszClassName,
    lpWindowName = "Window",
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

  discard SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

  cast[Win32Window](result).createOpenGlContext()
  cast[Win32Window](result).updateBounds()

  # var margins: MARGINS
  # margins.cxLeftWidth = 8
  # margins.cxRightWidth = 8
  # margins.cyTopHeight = 20
  # margins.cyBottomHeight = 27

  # discard DwmExtendFrameIntoClientArea(cast[Win32Window](result).hwnd, margins.addr)

  result.bounds = result.bounds
  result.gfx = newGfx()

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
      of 91: KeyboardKey.LeftSuper
      of 92: KeyboardKey.RightSuper
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
      of 110: KeyboardKey.PadDecimal
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
      of 222: KeyboardKey.Apostrophe
      else: KeyboardKey.Unknown

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if msg == WM_CREATE:
    var lpcs = cast[LPCREATESTRUCT](lParam)
    SetWindowLongPtr(hwnd, GWLP_USERDATA, cast[LONG_PTR](lpcs.lpCreateParams))

  let window = cast[Win32Window](GetWindowLongPtr(hwnd, GWLP_USERDATA))
  if window == nil or hwnd != window.hwnd:
    return DefWindowProc(hwnd, msg, wParam, lParam)

  case msg:

  # of WM_NCCALCSIZE:
  #   if wParam == TRUE:
  #     return 0

  of WM_SETFOCUS:
    window.frameState.isFocused = true

  of WM_KILLFOCUS:
    window.frameState.isFocused = false

  of WM_MOVE:
    window.updateBounds()

  of WM_SIZE:
    window.updateBounds()

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
    window.frameState.exists = false

  of WM_DPICHANGED:
    window.frameState.contentScale = GetDpiForWindow(window.hwnd).float / defaultDpi
    window.updateBounds()

  of WM_MOUSEMOVE:
    if not window.frameState.isHovered:
      var tme: TTRACKMOUSEEVENT
      ZeroMemory(tme.addr, sizeof(tme))
      tme.cbSize = sizeof(tme).cint
      tme.dwFlags = TME_LEAVE
      tme.hwndTrack = window.hwnd
      TrackMouseEvent(tme.addr)
      window.frameState.isHovered = true

    window.frameState.mousePosition = vec2(GET_X_LPARAM(lParam).float, GET_Y_LPARAM(lParam).float) * window.frameState.contentScale

  of WM_MOUSELEAVE:
    window.frameState.isHovered = false

  of WM_MOUSEWHEEL:
    window.frameState.mouseWheel.y += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_MOUSEHWHEEL:
    window.frameState.mouseWheel.x += GET_WHEEL_DELTA_WPARAM(wParam).float / WHEEL_DELTA.float

  of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
     WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
     WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
     WM_XBUTTONDOWN, WM_XBUTTONDBLCLK:
    SetCapture(window.hwnd)
    let button = toMouseButton(msg, wParam)
    window.frameState.mousePresses.add button
    window.frameState.mouseDown[button] = true

  of WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
    ReleaseCapture()
    let button = toMouseButton(msg, wParam)
    window.frameState.mouseReleases.add button
    window.frameState.mouseDown[button] = false

  of WM_KEYDOWN, WM_SYSKEYDOWN:
    let key = toKeyboardKey(wParam, lParam)
    window.frameState.keyPresses.add key
    window.frameState.keyDown[key] = true

  of WM_KEYUP, WM_SYSKEYUP:
    let key = toKeyboardKey(wParam, lParam)
    window.frameState.keyReleases.add key
    window.frameState.keyDown[key] = false

  of WM_CHAR, WM_SYSCHAR:
    if wParam > 0 and wParam < 0x10000:
      window.frameState.textInput &= cast[Rune](wParam).toUTF8

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)