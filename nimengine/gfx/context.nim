import pkg/opengl
export opengl

import ./indexbuffer
import ./shader
import ./texture
import ./vertexbuffer

export indexbuffer
export shader
export texture
export vertexbuffer

when defined(windows):
  import pkg/winim/lean

  type
    GfxContext* = ref object
      handle*: HWND
      hdc*: HDC
      startHdc: HDC
      hglrc*: HGLRC
      startHglrc*: HGLRC

  proc newGfxContext*(handle: HWND): GfxContext =
    result = GfxContext(handle: handle)

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



proc destroy*(ctx: GfxContext) =
  wglMakeCurrent(0, 0)
  wglDeleteContext(ctx.hglrc)

proc select*(ctx: GfxContext) =
  ctx.startHdc = wglGetCurrentDC()
  ctx.startHglrc = wglGetCurrentContext()
  let dc = GetDC(ctx.handle)
  wglMakeCurrent(dc, ctx.hglrc)

proc unselect*(ctx: GfxContext) =
  ReleaseDC(ctx.handle, ctx.hdc)
  wglMakeCurrent(ctx.startHdc, ctx.startHglrc)

proc swapBuffers*(ctx: GfxContext) =
  SwapBuffers(ctx.hdc)

proc setBackgroundColor*(ctx: GfxContext, r, g, b, a: float) =
  glClearColor(r, g, b, a)

proc clearBackground*(ctx: GfxContext) =
  glClear(GL_COLOR_BUFFER_BIT)

proc clearDepthBuffer*(ctx: GfxContext) =
  glClear(GL_DEPTH_BUFFER_BIT)

proc enableAlphaBlend*(ctx: GfxContext) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc enableDepthTesting*(ctx: GfxContext) =
  glEnable(GL_DEPTH_TEST)

proc setViewport*(ctx: GfxContext, x, y, width, height: int) =
  if width >= 0 and height >= 0:
    glViewport(
      x.GLsizei, y.GLsizei,
      width.GLsizei, height.GLsizei,
    )

proc drawTriangles*(ctx: GfxContext,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer) =
  shader.select()
  vertices.select()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    indices.kind.toGlEnum,
    nil
  )

proc drawTriangles*(ctx: GfxContext,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer,
                    texture: Texture) =
  texture.select()
  ctx.drawTriangles(shader, vertices, indices)