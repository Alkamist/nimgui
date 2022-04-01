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

when not defined(emscripten):
  var openGlIsLoaded = false

when defined(win32):
  import pkg/winim

  type
    GfxContext* = ref object
      nativeHandle*: HWND
      hdc: HDC
      hglrc: HGLRC

  proc new*(_: type GfxContext, nativeHandle: HWND): GfxContext =
    if not openGlIsLoaded:
      when not defined(emscripten):
        opengl.loadExtensions()
      openGlIsLoaded = true
    GfxContext(nativeHandle: HWND)

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

elif defined(emscripten):
  import ../emscriptenapi

  type
    GfxContext* = ref object
      nativeHandle*: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE

  proc new*(_: type GfxContext, targetCanvas: string): GfxContext =
    var attributes: EmscriptenWebGLContextAttributes
    emscripten_webgl_init_context_attributes(attributes.addr)
    attributes.stencil = true.EM_BOOL
    attributes.depth = true.EM_BOOL
    GfxContext(
      nativeHandle: emscripten_webgl_create_context(targetCanvas, attributes.addr),
    )

  proc makeCurrent*(ctx: GfxContext) =
    discard

proc setBackgroundColor*(gfx: GfxContext, color: ColorRgbaConcept) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clearBackground*(gfx: GfxContext) =
  glClear(GL_COLOR_BUFFER_BIT)

proc clearDepthBuffer*(gfx: GfxContext) =
  glClear(GL_DEPTH_BUFFER_BIT)

proc enableAlphaBlend*(gfx: GfxContext) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc enableDepthTesting*(gfx: GfxContext) =
  glEnable(GL_DEPTH_TEST)

proc setViewport*(gfx: GfxContext, x, y, width, height: int) =
  if width >= 0 and height >= 0:
    glViewport(
      x.GLsizei, y.GLsizei,
      width.GLsizei, height.GLsizei,
    )

proc drawTriangles*[V, I](gfx: GfxContext,
                          shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I]) =
  shader.select()
  vertices.selectLayout()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    indices.typeToGlEnum,
    nil
  )

proc drawTriangles*[V, I](gfx: GfxContext,
                          shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I],
                          texture: Texture) =
  texture.select()
  gfx.drawTriangles(shader, vertices, indices)