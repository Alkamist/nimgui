import test3
import nimengine

const vertexSrc = """
#version 300 es
precision highp float;
layout (location = 0) in vec2 Position;
layout (location = 1) in vec2 UV;
out vec2 Frag_UV;
void main()
{
  Frag_UV = UV;
  gl_Position = vec4(Position.xy, 0, 1);
}
"""

const fragmentSrc = """
#version 300 es
precision mediump float;
uniform sampler2D Texture;
in vec2 Frag_UV;
layout (location = 0) out vec4 Out_Color;
void main()
{
  Out_Color = texture(Texture, Frag_UV.st);
}
"""

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.enableBlend()
gfx.setBackgroundColor(0.2, 0, 0, 1)

let shader = newShader(vertexSrc, fragmentSrc)
shader.select()

let vertexBuffer = newVertexBuffer([VertexAttributeKind.Float2,
                                    VertexAttributeKind.Float2])
vertexBuffer.select()
vertexBuffer.upload(BufferUsage.StaticDraw, [
  -1f, -1, 0, 1,
  -1, 1, 0, 0,
  1, 1, 1, 0,
  1, -1, 1, 1,
])

let indexBuffer = newIndexBuffer(IndexKind.UInt32)
indexBuffer.select()
indexBuffer.upload(BufferUsage.StaticDraw, [
  0'u32, 2, 1,
  0, 3, 2,
])

let texture = newTexture()
texture.select()
texture.upload(128, 128, atlas)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  gfx.drawTriangles(6, IndexKind.UInt32, 0)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()
  render()