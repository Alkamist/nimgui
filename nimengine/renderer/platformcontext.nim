import pkg/opengl

when defined(windows):
  import pkg/winim/lean

  type
    PlatformContext* = object
      handle: HWND
      hdc: HDC
      startHdc: HDC
      hglrc: HGLRC
      startHglrc: HGLRC

  proc initPlatformContext*(handle: HWND): PlatformContext =
    result = PlatformContext(handle: handle)

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

    let dc = GetDC(handle)
    result.hdc = dc

    let fmt = ChoosePixelFormat(dc, pfd.addr)
    SetPixelFormat(dc, fmt, pfd.addr)

    result.hglrc = wglCreateContext(dc)
    wglMakeCurrent(dc, result.hglrc)

    opengl.loadExtensions()

    discard glGetError()
    ReleaseDC(handle, dc)

proc destroy*(ctx: PlatformContext) =
  wglMakeCurrent(0, 0)
  wglDeleteContext(ctx.hglrc)

proc select*(ctx: var PlatformContext) =
  ctx.startHdc = wglGetCurrentDC()
  ctx.startHglrc = wglGetCurrentContext()
  let dc = GetDC(ctx.handle)
  wglMakeCurrent(dc, ctx.hglrc)

proc unselect*(ctx: PlatformContext) =
  ReleaseDC(ctx.handle, ctx.hdc)
  wglMakeCurrent(ctx.startHdc, ctx.startHglrc)

proc swapBuffers*(ctx: PlatformContext) =
  SwapBuffers(ctx.hdc)