import pkg/opengl
export opengl

import ./canvas
export canvas

import ./renderer/openglcontext
import ./renderer/indexbuffer
import ./renderer/vertexbuffer
import ./renderer/shader
import ./renderer/texture

export openglcontext
export indexbuffer
export vertexBuffer
export shader
export texture

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
  gl_Position = ProjMtx * vec4(Position.xy + 0.5, 0, 1);
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
    canvasVertexBuffer*: VertexBuffer
    canvasIndexBuffer*: IndexBuffer
    # This needs to be last so it is destroyed after the default shader
    # and texture with --gc:arc and --gc:orc.
    openGlContext*: OpenGlContext

proc newRenderer*(handle: pointer): Renderer =
  result = Renderer()
  result.openGlContext = newOpenGlContext(handle)
  result.defaultShader2d = newShader(defaultVertexShader2d, defaultFragmentShader2d)
  result.defaultTexture = newTexture()
  result.defaultTexture.upload(1, 1, [255'u8, 255'u8, 255'u8, 255'u8])
  result.canvasVertexBuffer = newVertexBuffer([VertexAttributeKind.Float2,
                                               VertexAttributeKind.Float2,
                                               VertexAttributeKind.Float4])
  result.canvasIndexBuffer = newIndexBuffer(uint32.toIndexKind)

proc setBackgroundColor*(renderer: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)

proc setViewport*(renderer: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               width.GLsizei, height.GLsizei)

proc setClipRect*(renderer: Renderer, x, y, width, height: float) =
  if width >= 0 and height >= 0:
    glScissor(x.GLsizei, y.GLsizei,
              width.GLsizei, height.GLsizei)

proc clear*(renderer: Renderer) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc drawTriangles*(renderer: Renderer,
                    vertexBuffer: VertexBuffer,
                    indexBuffer: IndexBuffer,
                    shader: Shader,
                    texture = renderer.defaultTexture) =
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

proc draw*(renderer: Renderer,
           canvas: Canvas,
           texture = renderer.defaultTexture,
           shader = renderer.defaultShader2d) =
  renderer.canvasVertexBuffer.upload(canvas.vertexData)
  renderer.canvasIndexBuffer.upload(canvas.indexData)
  renderer.drawTriangles(renderer.canvasVertexBuffer, renderer.canvasIndexBuffer, shader, texture)

proc render*(renderer: Renderer, width, height: int) =
  renderer.openGlContext.select()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)

  let w = width.float
  let h = height.float
  renderer.setViewport(0, 0, w, h)
  renderer.setClipRect(0, 0, w, h)

  renderer.clear()

  if renderer.onRender2d != nil:
    glDisable(GL_CULL_FACE)
    glDisable(GL_DEPTH_TEST)
    renderer.defaultShader2d.setUniform("ProjMtx", orthoProjection(0, w, h, 0))
    renderer.onRender2d()

  if renderer.onRender3d != nil:
    glEnable(GL_CULL_FACE)
    glEnable(GL_DEPTH_TEST)
    renderer.onRender3d()

  renderer.openGlContext.swapBuffers()