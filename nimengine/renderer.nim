import pkg/opengl
export opengl

import ./window
import ./renderer/color
import ./renderer/concepts
import ./renderer/openglcontext
import ./renderer/indexbuffer
import ./renderer/vertexbuffer
import ./renderer/shader
import ./renderer/texture
import ./renderer/renderbatch

export color
export indexbuffer
export vertexBuffer
export shader
export texture
export renderbatch

type
  Renderer* = ref object
    window*: Window
    onRender2d*: proc()
    onRender3d*: proc()
    openGlContext: OpenGlContext

proc newRenderer*(window: Window): Renderer =
  result = Renderer()
  result.window = window
  result.openGlContext = initOpenGlContext(window.platform.handle)
  opengl.loadExtensions()

proc setBackgroundColor*(self: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)

proc setBackgroundColor*(self: Renderer, color: SomeColor) =
  self.setBackgroundColor(color.r, color.g, color.b, color.a)

proc setViewport*(self: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               width.GLsizei, height.GLsizei)

proc setViewport*(self: Renderer, rect: SomeRect) =
  self.setViewport(rect.x, rect.y, rect.width, rect.height)

proc setClipRect*(self: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glScissor(x.GLsizei, y.GLsizei,
              width.GLsizei, height.GLsizei)

proc setClipRect*(self: Renderer, rect: SomeRect) =
  self.setClipRect(rect.x, rect.y, rect.width, rect.height)

proc clear*(self: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc drawTriangles*(self: Renderer,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer) =
  if vertices.len == 0 or indices.len == 0:
    return
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

proc drawRenderBatch2d*(self: Renderer, shader: Shader, batch: RenderBatch2d) =
  self.drawTriangles(shader, batch.vertexBuffer, batch.indexBuffer)

proc render*(self: Renderer) =
  self.openGlContext.select()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)
  glActiveTexture(GL_TEXTURE0)

  let w = self.window.width
  let h = self.window.height
  self.setViewport(0, 0, w, h)
  self.setClipRect(0, 0, w, h)

  self.clear()

  if self.onRender2d != nil:
    glDisable(GL_CULL_FACE)
    glDisable(GL_DEPTH_TEST)
    self.onRender2d()

  if self.onRender3d != nil:
    glEnable(GL_CULL_FACE)
    glEnable(GL_DEPTH_TEST)
    self.onRender3d()

  self.openGlContext.swapBuffers()