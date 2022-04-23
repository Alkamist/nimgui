import pkg/opengl
export opengl

import ./renderer/openglcontext
import ./renderer/indexbuffer
import ./renderer/vertexbuffer
import ./renderer/shader
import ./renderer/texture
import ./renderer/renderbatch2d

export indexbuffer
export vertexBuffer
export shader
export texture
export renderbatch2d

const defaultVertexShader2d = """
#version 300 es
precision highp float;
layout (location = 0) in vec2 Position;
layout (location = 1) in vec2 UV;
layout (location = 2) in vec4 Color;
uniform mat4 ProjMtx;
out vec2 Frag_UV;
out vec4 Frag_Color;
void main()
{
  Frag_UV = UV;
  Frag_Color = Color;
  gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
}
"""

const defaultFragmentShader2d = """
#version 300 es
precision mediump float;
uniform sampler2D Texture;
in vec2 Frag_UV;
in vec4 Frag_Color;
layout (location = 0) out vec4 Out_Color;
void main()
{
  Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
}
"""

proc orthoProjection(left, right, top, bottom: float32): array[4, array[4, float32]] =
  [
    [2.0f / (right - left), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f / (top - bottom), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(right + left) / (left - right), (top + bottom) / (bottom - top), 0.0f, 1.0f],
  ]

type
  Renderer* = ref object
    onRender2d*: proc()
    onRender3d*: proc()
    defaultShader2d*: Shader
    defaultTexture*: Texture
    # This needs to be last so it is destroyed after the default shader
    # and texture with --gc:arc and --gc:orc.
    openGlContext*: OpenGlContext

proc newRenderer*(handle: pointer): Renderer =
  result = Renderer()
  result.openGlContext = newOpenGlContext(handle)
  opengl.loadExtensions()
  result.defaultShader2d = newShader(defaultVertexShader2d, defaultFragmentShader2d)
  result.defaultTexture = newTexture()
  result.defaultTexture.upload(1, 1, [255'u8, 255'u8, 255'u8, 255'u8])

proc setBackgroundColor*(self: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)

proc setViewport*(self: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               width.GLsizei, height.GLsizei)

proc setClipRect*(self: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glScissor(x.GLsizei, y.GLsizei,
              width.GLsizei, height.GLsizei)

proc clear*(self: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc drawTriangles*(self: Renderer,
                    vertexBuffer: VertexBuffer,
                    indexBuffer: IndexBuffer,
                    shader: Shader,
                    texture = self.defaultTexture) =
  if vertexBuffer.len == 0 or vertexBuffer.len == 0:
    return
  shader.select()
  texture.select()
  vertexBuffer.select()
  indexBuffer.select()
  glDrawElements(
    GL_TRIANGLES,
    indexBuffer.len.GLsizei,
    indexBuffer.kind.toGlEnum,
    nil,
  )

proc drawRenderBatch2d*(self: Renderer,
                        batch: RenderBatch2d,
                        texture = self.defaultTexture,
                        shader = self.defaultShader2d) =
  self.drawTriangles(batch.vertexBuffer, batch.indexBuffer, shader, texture)

proc render*(self: Renderer, width, height: int) =
  self.openGlContext.select()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)
  # glActiveTexture(GL_TEXTURE0)

  let w = width.float
  let h = height.float
  self.setViewport(0, 0, w, h)
  self.setClipRect(0, 0, w, h)

  self.clear()

  if self.onRender2d != nil:
    glDisable(GL_CULL_FACE)
    glDisable(GL_DEPTH_TEST)
    self.defaultShader2d.setUniform("ProjMtx", orthoProjection(0, w, h, 0))
    self.onRender2d()

  if self.onRender3d != nil:
    glEnable(GL_CULL_FACE)
    glEnable(GL_DEPTH_TEST)
    self.onRender3d()

  self.openGlContext.swapBuffers()