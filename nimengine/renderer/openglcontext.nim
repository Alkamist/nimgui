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

  proc `=destroy`*(ctx: var type OpenGlContext()[]) =
    wglDeleteContext(ctx.hglrc)

  proc newOpenGlContext*(handle: pointer): OpenGlContext =
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
      cDepthBits: 24,
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

  # proc delete*(ctx: OpenGlContext) =
  #   wglDeleteContext(ctx.hglrc)

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