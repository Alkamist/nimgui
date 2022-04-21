when defined(windows):
  import pkg/winim/lean

  let hmodule = LoadLibraryA("opengl32.dll")

  type
    OpenGlContext* = object
      handle: HWND
      hdc: HDC
      startHdc: HDC
      hglrc: HGLRC
      startHglrc: HGLRC

  proc initOpenGlContext*(handle: HWND): OpenGlContext =
    result = OpenGlContext(handle: handle)

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

    ReleaseDC(handle, dc)

  proc destroy*(self: OpenGlContext) =
    wglMakeCurrent(0, 0)
    wglDeleteContext(self.hglrc)

  proc select*(self: var OpenGlContext) =
    self.startHdc = wglGetCurrentDC()
    self.startHglrc = wglGetCurrentContext()
    let dc = GetDC(self.handle)
    wglMakeCurrent(dc, self.hglrc)

  proc unselect*(self: OpenGlContext) =
    ReleaseDC(self.handle, self.hdc)
    wglMakeCurrent(self.startHdc, self.startHglrc)

  proc swapBuffers*(self: OpenGlContext) =
    SwapBuffers(self.hdc)

  proc getProcAddressWgl(procname: cstring): pointer =
    let p = wglGetProcAddress(procname)
    if p != nil:
      p
    else:
      GetProcAddress(hmodule, procname)

  proc getProcAddress*(self: OpenGlContext): pointer =
    getProcAddressWgl