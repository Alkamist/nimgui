import pkg/opengl
export opengl

import ./window
import ./renderer/openglcontext
import ./renderer/indexbuffer
import ./renderer/vertexbuffer
import ./renderer/shader
import ./renderer/texture
import ./renderer/renderbatch

export indexbuffer
export vertexBuffer
export shader
export texture
export renderbatch

type
  Renderer* = ref object
    window*: Window
    onRender*: proc()
    openGlContext: OpenGlContext

proc newRenderer*(window: Window): Renderer =
  result = Renderer()
  result.window = window
  result.openGlContext = initOpenGlContext(window.platform.handle)
  opengl.loadExtensions()

proc setBackgroundColor*(self: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)

proc clear*(self: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc drawTriangles*(self: Renderer,
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
    nil,
  )

proc drawTriangles*(self: Renderer,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer,
                    texture: Texture) =
  texture.select()
  self.drawTriangles(shader, vertices, indices)

proc setupRenderState(self: Renderer) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  # glEnable(GL_CULL_FACE)
  # glEnable(GL_DEPTH_TEST)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)
  glActiveTexture(GL_TEXTURE0)

proc resize(self: Renderer, x, y, w, h: float) =
  if w >= 0 and h >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               w.GLsizei, h.GLsizei)
    glScissor(x.GLsizei, y.GLsizei,
              w.GLsizei, h.GLsizei)

proc render*(self: Renderer) =
  let w = self.window.width
  let h = self.window.height

  self.setupRenderState()
  self.resize(0, 0, w, h)

  if self.onRender != nil:
    self.onRender()

  self.openGlContext.swapBuffers()