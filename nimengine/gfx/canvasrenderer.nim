import pkg/opengl

import ./canvas
import ./indexbuffer
import ./vertexbuffer
import ./shader
import ./texture

export canvas
export indexbuffer
export vertexBuffer
export shader
export texture

const canvasVertexShader = """
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

const canvasFragmentShader = """
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
  CanvasRenderer* = ref object
    shader*: Shader
    texture*: Texture
    vertexBuffer*: VertexBuffer
    indexBuffer*: IndexBuffer
    vao: GLuint

proc `=destroy`*(renderer: var type CanvasRenderer()[]) =
  glDeleteVertexArrays(1, renderer.vao.addr)

proc newCanvasRenderer*(): CanvasRenderer =
  result = CanvasRenderer()

  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)

  result.shader = newShader(canvasVertexShader, canvasFragmentShader)
  result.texture = newTexture()
  result.texture.upload(1, 1, [255'u8, 255'u8, 255'u8, 255'u8])
  result.vertexBuffer = newVertexBuffer([VertexAttributeKind.Float2,
                                         VertexAttributeKind.Float2,
                                         VertexAttributeKind.Float4])
  result.indexBuffer = newIndexBuffer(IndexKind.UInt32)

proc render*(renderer: CanvasRenderer,
             canvas: Canvas,
             texture = renderer.texture,
             shader = renderer.shader) =
  if canvas.vertexData.len == 0 or canvas.indexData.len == 0:
    return

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_SCISSOR_TEST)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  glViewport(0.GLsizei, 0.GLsizei, canvas.width.GLsizei, canvas.height.GLsizei)

  shader.select()
  renderer.shader.setUniform("ProjMtx", orthoProjection(0, canvas.width, 0, canvas.height))
  texture.select()
  renderer.vertexBuffer.select()
  renderer.vertexBuffer.upload(BufferUsage.StreamDraw, canvas.vertexData)
  renderer.indexBuffer.select()
  renderer.indexBuffer.upload(BufferUsage.StreamDraw, canvas.indexData)

  for drawCall in canvas.drawCalls:
    if drawCall.indexCount == 0:
      continue

    glScissor(
      drawCall.clipRect.x.GLint,
      (canvas.height - (drawCall.clipRect.y + drawCall.clipRect.height) - 1.0).GLint,
      (drawCall.clipRect.width + 1.0).GLsizei,
      (drawCall.clipRect.height + 1.0).GLsizei,
    )

    glDrawElements(
      GL_TRIANGLES,
      drawCall.indexCount.GLsizei,
      renderer.indexBuffer.kind.toGlEnum,
      cast[pointer](drawCall.indexOffset * renderer.indexBuffer.kind.indexSize),
    )