import pkg/opengl
export opengl

import ./indexbuffer
import ./shader
import ./texture
import ./types
import ./vertexbuffer

export indexbuffer
export shader
export texture
export types
export vertexbuffer

when defined(win32):
  import pkg/winim/lean

  type
    GfxContext* = ref object
      nativeHandle*: HWND
      hdc*: HDC
      hglrc*: HGLRC

  proc makeCurrent*(ctx: GfxContext) =
    var pfd = PIXELFORMATDESCRIPTOR(
      nSize: PIXELFORMATDESCRIPTOR.sizeof.WORD,
      nVersion: 1,
    )
    pfd.dwFlags = PFD_DRAW_TO_WINDOW or
                  PFD_SUPPORT_OPENGL or
                  PFD_SUPPORT_COMPOSITION or
                  PFD_DOUBLEBUFFER
    pfd.iPixelType = PFD_TYPE_RGBA
    pfd.cColorBits = 32
    pfd.cAlphaBits = 8
    pfd.iLayerType = PFD_MAIN_PLANE

    ctx.hdc = GetDC(ctx.nativeHandle)
    let format = ChoosePixelFormat(ctx.hdc, pfd.addr)
    if format == 0:
      raise newException(OSError, "ChoosePixelFormat failed.")

    if SetPixelFormat(ctx.hdc, format, pfd.addr) == 0:
      raise newException(OSError, "SetPixelFormat failed.")

    var activeFormat = GetPixelFormat(ctx.hdc)
    if activeFormat == 0:
      raise newException(OSError, "GetPixelFormat failed.")

    if DescribePixelFormat(ctx.hdc, format, pfd.sizeof.UINT, pfd.addr) == 0:
      raise newException(OSError, "DescribePixelFormat failed.")

    if (pfd.dwFlags and PFD_SUPPORT_OPENGL) != PFD_SUPPORT_OPENGL:
      raise newException(OSError, "PFD_SUPPORT_OPENGL check failed.")

    ctx.hglrc = wglCreateContext(ctx.hdc)
    if ctx.hglrc == 0:
      raise newException(OSError, "wglCreateContext failed.")

    wglMakeCurrent(ctx.hdc, ctx.hglrc)

  proc new*(_: type GfxContext, nativeHandle: HWND): GfxContext =
    result = GfxContext(nativeHandle: nativeHandle)
    result.makeCurrent()
    opengl.loadExtensions()

  proc swapBuffers*(ctx: GfxContext) =
    SwapBuffers(ctx.hdc)

elif defined(emscripten):
  import ../emscriptenapi
  export emscriptenapi

  type
    GfxContext* = ref object
      nativeHandle*: cstring
      webGlContextHandle*: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE

  proc new*(_: type GfxContext, nativeHandle: cstring): GfxContext =
    var attributes: EmscriptenWebGLContextAttributes
    emscripten_webgl_init_context_attributes(attributes.addr)
    attributes.stencil = true.EM_BOOL
    attributes.depth = true.EM_BOOL
    # I can't get these to work.
    # attributes.explicitSwapControl = true.EM_BOOL
    # attributes.renderViaOffscreenBackBuffer = true.EM_BOOL
    GfxContext(
      nativeHandle: nativeHandle,
      webGlContextHandle: emscripten_webgl_create_context(nativeHandle, attributes.addr),
    )

  proc makeCurrent*(ctx: GfxContext) =
    discard emscripten_webgl_make_context_current(ctx.webGlContextHandle)

  proc swapBuffers*(ctx: GfxContext) =
    # This seems to cause problems from my testing.
    # discard emscripten_webgl_commit_frame()
    discard



proc setBackgroundColor*(ctx: GfxContext, r, g, b, a: float) =
  glClearColor(r, g, b, a)

proc setBackgroundColor*(ctx: GfxContext, color: ColorRgbaConcept) =
  glClearColor(color.r, color.g, color.b, color.a)

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