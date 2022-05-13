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

let vertexBuffer = newVertexBuffer([Float2, Float2])
vertexBuffer.select()
vertexBuffer.upload(StaticDraw, [
  -1f, -1, 0, 1,
  -1, 1, 0, 0,
  1, 1, 1, 0,
  1, -1, 1, 1,
])

let indexBuffer = newIndexBuffer(UInt32)
indexBuffer.select()
indexBuffer.upload(StaticDraw, [
  0'u32, 2, 1,
  0, 3, 2,
])

let fontData = readFile("experiments/consola.ttf")
let atlas = newCanvasAtlas(fontData, 14)

let texture = newTexture()
texture.select()
texture.upload(atlas.width, atlas.height, atlas.data)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  gfx.drawTriangles(6, UInt32, 0)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()
  render()