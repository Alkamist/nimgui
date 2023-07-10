when defined(cpu64):
  type
    UINT_PTR* = uint64
    LONG_PTR* = int64
else:
  type
    UINT_PTR* = cuint
    LONG_PTR* = clong

type
  LPVOID* = pointer
  HANDLE* = LPVOID
  HINSTANCE* = HANDLE
  HMENU* = HANDLE
  HWND* = HANDLE
  HICON* = HANDLE
  HCURSOR* = HANDLE
  HBRUSH* = HANDLE
  HDC* = HANDLE
  HGLRC* = HANDLE
  DPI_AWARENESS_CONTEXT* = HANDLE
  HMODULE* = HINSTANCE

  BOOL* = cint
  UINT* = cuint
  LONG* = clong
  SHORT* = cshort
  WORD* = cushort
  DWORD* = culong
  BYTE* = uint8
  CHAR* = char

  LPSTR* = cstring
  LPCSTR* = cstring

  LPARAM* = LONG_PTR
  WPARAM* = UINT_PTR
  LRESULT* = LONG_PTR

  COLORREF* = DWORD

  ATOM* = WORD

  WNDPROC* = proc(hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}
  TIMERPROC* = proc(unnamedParam1: HWND, unnamedParam2: UINT, unnamedParam3: UINT_PTR, unnamedParam4: DWORD) {.stdcall.}

  LPPOINT* = ptr POINT
  POINT* {.bycopy.} = object
    x*: LONG
    y*: LONG

  LPRECT* = ptr RECT
  RECT* {.bycopy.} = object
    left*: LONG
    top*: LONG
    right*: LONG
    bottom*: LONG

  LPMSG* = ptr MSG
  MSG* {.bycopy.} = object
    hwnd*: HWND
    message*: UINT
    wParam*: WPARAM
    lParam*: LPARAM
    time*: DWORD
    pt*: POINT

  LPCREATESTRUCTA* = ptr CREATESTRUCTA
  CREATESTRUCTA* {.bycopy.} = object
    lpCreateParams*: LPVOID
    hInstance*: HINSTANCE
    hMenu*: HMENU
    hwndParent*: HWND
    cy*: cint
    cx*: cint
    y*: cint
    x*: cint
    style*: LONG
    lpszName*: LPCSTR
    lpszClass*: LPCSTR
    dwExStyle*: DWORD

  LPTRACKMOUSEEVENT* = ptr TTRACKMOUSEEVENT
  TTRACKMOUSEEVENT* {.bycopy.} = object
    cbSize*: DWORD
    dwFlags*: DWORD
    hwndTrack*: HWND
    dwHoverTime*: DWORD

  LPPAINTSTRUCT* = ptr PAINTSTRUCT
  PAINTSTRUCT* {.bycopy.} = object
    hdc*: HDC
    fErase*: BOOL
    rcPaint*: RECT
    fRestore*: BOOL
    fIncUpdate*: BOOL
    rgbReserved*: array[32, BYTE]

  WNDCLASSEXA* {.bycopy.} = object
    cbSize*: UINT
    style*: UINT
    lpfnWndProc*: WNDPROC
    cbClsExtra*: cint
    cbWndExtra*: cint
    hInstance*: HINSTANCE
    hIcon*: HICON
    hCursor*: HCURSOR
    hbrBackground*: HBRUSH
    lpszMenuName*: LPCSTR
    lpszClassName*: LPCSTR
    hIconSm*: HICON

  PIXELFORMATDESCRIPTOR* {.bycopy.} = object
    nSize*: WORD
    nVersion*: WORD
    dwFlags*: DWORD
    iPixelType*: BYTE
    cColorBits*: BYTE
    cRedBits*: BYTE
    cRedShift*: BYTE
    cGreenBits*: BYTE
    cGreenShift*: BYTE
    cBlueBits*: BYTE
    cBlueShift*: BYTE
    cAlphaBits*: BYTE
    cAlphaShift*: BYTE
    cAccumBits*: BYTE
    cAccumRedBits*: BYTE
    cAccumGreenBits*: BYTE
    cAccumBlueBits*: BYTE
    cAccumAlphaBits*: BYTE
    cDepthBits*: BYTE
    cStencilBits*: BYTE
    cAuxBuffers*: BYTE
    iLayerType*: BYTE
    bReserved*: BYTE
    dwLayerMask*: DWORD
    dwVisibleMask*: DWORD
    dwDamageMask*: DWORD

template RGB*(r, g, b: untyped): COLORREF = COLORREF(COLORREF(r and 0xff) or (COLORREF(g and 0xff) shl 8) or (COLORREF(b and 0xff) shl 16))
template LOWORD*(l: untyped): WORD = WORD(l and 0xffff)
template HIWORD*(l: untyped): WORD = WORD((l shr 16) and 0xffff)
template LOBYTE*(w: untyped): BYTE = BYTE(w and 0xff)
template HIBYTE*(w: untyped): BYTE = BYTE((w shr 8) and 0xff)
template GET_X_LPARAM*(x: untyped): int = int(cast[int16](LOWORD(x)))
template GET_Y_LPARAM*(x: untyped): int = int(cast[int16](HIWORD(x)))
template GET_WHEEL_DELTA_WPARAM*(wParam: untyped): SHORT = cast[SHORT](HIWORD(wParam))
template MAKEINTRESOURCEA*(i: untyped): untyped = cast[LPSTR](i and 0xffff)

const TRUE* = BOOL(1)
const FALSE* = BOOL(0)

const DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2* = cast[DPI_AWARENESS_CONTEXT](-4)
const PFD_DOUBLEBUFFER* = 0x00000001
const PFD_DRAW_TO_WINDOW* = 0x00000004
const PFD_SUPPORT_OPENGL* = 0x00000020
const PFD_SUPPORT_COMPOSITION* = 0x00008000
const PFD_TYPE_RGBA* = 0
const PFD_MAIN_PLANE* = 0

const WM_CREATE* = 0x0001
const WM_DESTROY* = 0x0002
const WM_MOVE* = 0x0003
const WM_SIZE* = 0x0005
const WM_PAINT* = 0x000F
const WM_CLOSE* = 0x0010
const WM_ERASEBKGND* = 0x0014
const WM_DPICHANGED* = 0x02E0
const WM_MOUSEMOVE* = 0x0200
const WM_LBUTTONDOWN* = 0x0201
const WM_LBUTTONUP* = 0x0202
const WM_LBUTTONDBLCLK* = 0x0203
const WM_RBUTTONDOWN* = 0x0204
const WM_RBUTTONUP* = 0x0205
const WM_RBUTTONDBLCLK* = 0x0206
const WM_MBUTTONDOWN* = 0x0207
const WM_MBUTTONUP* = 0x0208
const WM_MBUTTONDBLCLK* = 0x0209
const WM_MOUSEWHEEL* = 0x020A
const WM_XBUTTONDOWN* = 0x020B
const WM_XBUTTONUP* = 0x020C
const WM_XBUTTONDBLCLK* = 0x020D
const WM_MOUSEHWHEEL* = 0x020E
const WM_MOUSELEAVE* = 0x02A3
const WM_KEYDOWN* = 0x0100
const WM_KEYUP* = 0x0101
const WM_CHAR* = 0x0102
const WM_SYSKEYDOWN* = 0x0104
const WM_SYSKEYUP* = 0x0105
const WM_SYSCHAR* = 0x0106
const WM_NCCALCSIZE* = 0x0083
const WM_ENTERSIZEMOVE* = 0x0231
const WM_EXITSIZEMOVE* = 0x0232
const WM_WINDOWPOSCHANGED* = 0x0047
const WM_TIMER* = 0x0113
const WHEEL_DELTA* = 120
const XBUTTON1* = 0x0001
const XBUTTON2* = 0x0002
const KF_EXTENDED* = 0x0100
const GWLP_USERDATA* = -21
const GWL_STYLE* = -16
const TME_LEAVE* = 0x00000002
const CS_OWNDC* = 0x0020
const CW_USEDEFAULT* = 0x80000000'i32

const PM_REMOVE* = 0x0001

const SW_HIDE* = 0
const SW_SHOW* = 5

const SWP_NOSIZE* = 0x0001
const SWP_NOMOVE* = 0x0002
const SWP_NOZORDER* = 0x0004
const SWP_NOACTIVATE* = 0x0010
const SWP_NOOWNERZORDER* = 0x0200
const SWP_SHOWWINDOW* = 0x0040

const WS_CLIPSIBLINGS* = 0x04000000
const WS_CHILD* = 0x40000000
const WS_CHILDWINDOW* = WS_CHILD
const WS_POPUP* = 0x80000000
const WS_OVERLAPPED* = 0x00000000
const WS_CAPTION* = 0x00C00000
const WS_SYSMENU* = 0x00080000
const WS_THICKFRAME* = 0x00040000
const WS_MINIMIZEBOX* = 0x00020000
const WS_MAXIMIZEBOX* = 0x00010000
const WS_OVERLAPPEDWINDOW* = WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX

const HWND_TOPMOST* = cast[HWND](-1)

const USER_TIMER_MINIMUM* = 10

const IDC_ARROW* = MAKEINTRESOURCEA(32512)
const IDC_IBEAM* = MAKEINTRESOURCEA(32513)
const IDC_WAIT* = MAKEINTRESOURCEA(32514)
const IDC_CROSS* = MAKEINTRESOURCEA(32515)
const IDC_UPARROW* = MAKEINTRESOURCEA(32516)
const IDC_SIZE* = MAKEINTRESOURCEA(32640)
const IDC_ICON* = MAKEINTRESOURCEA(32641)
const IDC_SIZENWSE* = MAKEINTRESOURCEA(32642)
const IDC_SIZENESW* = MAKEINTRESOURCEA(32643)
const IDC_SIZEWE* = MAKEINTRESOURCEA(32644)
const IDC_SIZENS* = MAKEINTRESOURCEA(32645)
const IDC_SIZEALL* = MAKEINTRESOURCEA(32646)
const IDC_NO* = MAKEINTRESOURCEA(32648)
const IDC_HAND* = MAKEINTRESOURCEA(32649)
const IDC_APPSTARTING* = MAKEINTRESOURCEA(32650)
const IDC_HELP* = MAKEINTRESOURCEA(32651)

{.push discardable, stdcall, dynlib: "user32", importc.}
proc GetDesktopWindow*(): HWND
proc DestroyWindow*(hWnd: HWND): BOOL
proc GetDC*(hWnd: HWND): HDC
proc ReleaseDC*(hWnd: HWND, hDC: HDC): cint
proc SetProcessDpiAwarenessContext*(value: DPI_AWARENESS_CONTEXT): BOOL
proc GetDpiForWindow*(hWnd: HWND): UINT
proc GetCursorPos*(lpPoint: LPPOINT): BOOL
proc SetCursor*(hCursor: HCURSOR): HCURSOR
proc ClientToScreen*(hWnd: HWND, lpPoint: LPPOINT): BOOL
proc ScreenToClient*(hWnd: HWND, lpPoint: LPPOINT): BOOL
proc GetClientRect*(hWnd: HWND, lpRect: LPRECT): BOOL
proc SetParent*(hWndChild, hWndNewParent: HWND): HWND
proc SetWindowPos*(hWnd, hWndInsertAfter: HWND, X, Y, cx, cy: cint, uFlags: UINT): BOOL
proc SetCapture*(hWnd: HWND): HWND
proc ReleaseCapture*(): BOOL
proc SetTimer*(hWnd: HWND, nIDEvent: UINT_PTR, uElapse: UINT, lpTimerFunc: TIMERPROC): UINT_PTR
proc KillTimer*(hWnd: HWND, uIDEvent: UINT_PTR): BOOL
proc ShowWindow*(hWnd: HWND , nCmdShow: cint): BOOL
proc TrackMouseEvent*(lpEventTrack: LPTRACKMOUSEEVENT): BOOL
proc BeginPaint*(hWnd: HWND, lpPaint: LPPAINTSTRUCT): HDC
proc EndPaint*(hWnd: HWND, lpPaint: ptr PAINTSTRUCT): BOOL
proc FillRect*(hDC: HDC, lprc: ptr RECT, hbr: HBRUSH): cint
proc InvalidateRect*(hWnd: HWND, lpRect: ptr RECT, bErase: BOOL): BOOL
proc SetWindowLongPtrA*(hWnd: HWND, nIndex: cint, dwNewLong: LONG_PTR): LONG_PTR
proc GetWindowLongPtrA*(hWnd: HWND, nIndex: cint): LONG_PTR
proc DefWindowProcA*(hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT
proc RegisterClassExA*(unnamedParam1: ptr WNDCLASSEXA): ATOM
proc UnregisterClassA*(lpClassName: LPCSTR, hInstance: HINSTANCE): BOOL
proc LoadCursorA*(hInstance: HINSTANCE, lpCursorName: LPCSTR): HCURSOR
proc CreateWindowExA*(dwExStyle: DWORD, lpClassName, lpWindowName: LPCSTR, dwStyle: DWORD, X, Y, nWidth, nHeight: cint, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND
proc PeekMessageA*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL
proc TranslateMessage*(lpMsg: ptr MSG): BOOL
proc DispatchMessageA*(lpMsg: ptr MSG): LRESULT
{.pop.}

{.push discardable, stdcall, dynlib: "kernel32", importc.}
proc GetModuleHandleA*(lpModuleName: LPCSTR): HMODULE
{.pop.}

{.push discardable, stdcall, dynlib: "gdi32", importc.}
proc SetPixelFormat*(hdc: HDC, format: cint, ppfd: ptr PIXELFORMATDESCRIPTOR): BOOL
proc ChoosePixelFormat*(hdc: HDC, ppfd: ptr PIXELFORMATDESCRIPTOR): cint
proc SwapBuffers*(unnamedParam1: HDC): BOOL
proc CreateSolidBrush*(color: COLORREF): HBRUSH
proc SetBkColor*(hdc: HDC, color: COLORREF): COLORREF
{.pop.}

{.push discardable, stdcall, dynlib: "opengl32", importc.}
proc wglCreateContext*(unnamedParam1: HDC): HGLRC
proc wglMakeCurrent*(unnamedParam1: HDC, unnamedParam2: HGLRC): BOOL
{.pop.}