import pkg/opengl
export opengl

var openGlIsInitialized {.threadvar.}: bool

when defined(windows):
  import pkg/winim/lean

  let hmodule = LoadLibraryA("opengl32.dll")

  type
    OpenGlContext* = ref object
      handle: HWND
      hdc: HDC
      startHdc: HDC
      hglrc: HGLRC
      startHglrc: HGLRC

  const dummyClassName = "Dummy Window"

  proc dummyWindowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
    DefWindowProc(hwnd, msg, wParam, lParam)

  proc initOpenGl*() =
    var dummyClass = WNDCLASSEX(
      cbSize: WNDCLASSEX.sizeof.UINT,
      style: CS_HREDRAW or CS_VREDRAW or CS_OWNDC,
      lpfnWndProc: dummyWindowProc,
      cbClsExtra: 0,
      cbWndExtra: 0,
      hInstance: GetModuleHandle(nil),
      hIcon: 0,
      hCursor: LoadCursor(0, IDC_ARROW),
      hbrBackground: CreateSolidBrush(RGB(0, 0, 0)),
      lpszMenuName: nil,
      lpszClassName: dummyClassName,
      hIconSm: 0,
    )
    RegisterClassEx(dummyClass.addr)

    let hwnd = CreateWindow(
      lpClassName = dummyClassName,
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
    UnregisterClass(dummyClassName, GetModuleHandle(nil))

    openGlIsInitialized = true

  proc `=destroy`*(ctx: var type OpenGlContext()[]) =
    wglDeleteContext(ctx.hglrc)

  proc newOpenGlContext*(handle: pointer): OpenGlContext =
    if not openGlIsInitialized:
      initOpenGl()

    let hwnd = cast[HWND](handle)
    result = OpenGlContext(handle: hwnd)

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

    let dc = GetDC(hwnd)
    result.hdc = dc

    let fmt = ChoosePixelFormat(dc, pfd.addr)
    SetPixelFormat(dc, fmt, pfd.addr)

    result.hglrc = wglCreateContext(dc)
    wglMakeCurrent(dc, result.hglrc)

    ReleaseDC(hwnd, dc)

  proc newOpenGlContext*(handle: HWND): OpenGlContext =
    newOpenGlContext(cast[pointer](handle))

  proc select*(ctx: OpenGlContext) =
    ctx.startHdc = wglGetCurrentDC()
    ctx.startHglrc = wglGetCurrentContext()
    let dc = GetDC(ctx.handle)
    wglMakeCurrent(dc, ctx.hglrc)

  proc unselect*(ctx: OpenGlContext) =
    ReleaseDC(ctx.handle, ctx.hdc)
    wglMakeCurrent(ctx.startHdc, ctx.startHglrc)

  proc swapBuffers*(ctx: OpenGlContext) =
    SwapBuffers(ctx.hdc)

  proc getProcAddressWgl(procname: cstring): pointer =
    let p = wglGetProcAddress(procname)
    if p != nil:
      p
    else:
      GetProcAddress(hmodule, procname)

  proc getProcAddress*(ctx: OpenGlContext): pointer =
    getProcAddressWgl