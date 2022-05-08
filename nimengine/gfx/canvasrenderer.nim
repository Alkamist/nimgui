import pkg/opengl

import ./gfx
import ./canvas
import ./indexbuffer
import ./vertexbuffer
import ./shader
import ./texture

export gfx
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
    canvas*: Canvas
    shader*: Shader
    atlasTexture*: Texture
    vertexBuffer*: VertexBuffer
    indexBuffer*: IndexBuffer
    vao: GLuint

proc `=destroy`*(renderer: var type CanvasRenderer()[]) =
  glDeleteVertexArrays(1, renderer.vao.addr)

proc newCanvasRenderer*(canvas: Canvas): CanvasRenderer =
  result = CanvasRenderer(canvas: canvas)

  # Stop OpenGl from crashing on later versions.
  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)

  result.shader = newShader(canvasVertexShader, canvasFragmentShader)
  result.atlasTexture = newTexture()
  result.atlasTexture.upload(canvas.atlas.width, canvas.atlas.height, canvas.atlas.data)
  result.vertexBuffer = newVertexBuffer([Float2, Float2, Float4])
  result.indexBuffer = newIndexBuffer(UInt32)

proc render*(renderer: CanvasRenderer,
             atlasTexture = renderer.atlasTexture,
             shader = renderer.shader) =
  let canvas = renderer.canvas

  if canvas.vertexData.len == 0 or canvas.indexData.len == 0:
    return

  gfx.enableBlend()
  gfx.enableClipping()
  gfx.disableFaceCulling()
  gfx.disableDepthTesting()

  shader.select()
  renderer.shader.setUniform("ProjMtx", orthoProjection(0, canvas.width, 0, canvas.height))
  atlasTexture.select()
  renderer.vertexBuffer.select()
  renderer.vertexBuffer.upload(StreamDraw, canvas.vertexData)
  renderer.indexBuffer.select()
  renderer.indexBuffer.upload(StreamDraw, canvas.indexData)

  for drawCall in canvas.drawCalls:
    if drawCall.indexCount == 0:
      continue

    # OpenGl clip rects are placed from the bottom left.
    let crX = drawCall.clipRect.x
    let crYFlipped = canvas.height - (drawCall.clipRect.y + drawCall.clipRect.height)
    let crWidth = drawCall.clipRect.width
    let crHeight = drawCall.clipRect.height
    gfx.setClipRect(
      crX + 0.5,
      crYFlipped - 0.5,
      crWidth + 1.0,
      crHeight + 1.0,
    )

    gfx.drawTriangles(
      drawCall.indexCount,
      renderer.indexBuffer.kind,
      drawCall.indexOffset,
    )