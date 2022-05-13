{.experimental: "overloadableEnums".}

import pixie
import nimengine

proc orthoProjection(left, right, top, bottom: float32): array[4, array[4, float32]] =
  [
    [2.0f / (right - left), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f / (top - bottom), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(right + left) / (left - right), (top + bottom) / (bottom - top), 0.0f, 1.0f],
  ]

const vertexSrc = """
#version 300 es
precision highp float;
layout (location = 0) in vec2 Position;
layout (location = 1) in vec2 UV;
uniform mat4 ProjMtx;
out vec2 Frag_UV;
void main()
{
  Frag_UV = UV;
  gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
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
gfx.setBackgroundColor(0.4, 0, 0, 1)

const imageWidth = 1920
const imageHeight = 1080

let shader = newShader(vertexSrc, fragmentSrc)
shader.select()

let vertexBuffer = newVertexBuffer([Float2, Float2])
vertexBuffer.select()
vertexBuffer.upload(StaticDraw, [
  0f, 0, 0, 1,
  0, imageHeight, 0, 0,
  imageWidth, imageHeight, 1, 0,
  imageWidth, 0, 1, 1,
])

let indexBuffer = newIndexBuffer(UInt32)
indexBuffer.select()
indexBuffer.upload(StaticDraw, [
  0'u32, 2, 1,
  0, 3, 2,
])

let texture = newTexture()
texture.select()

let image = newImage(imageWidth, imageHeight)
texture.setMinifyFilter(Linear)
texture.setMagnifyFilter(Linear)
texture.upload(image.width, image.height, cast[seq[uint8]](image.data))

let typeface = readTypeface("experiments/Roboto-Regular_1.ttf")

let font = newFont(typeface)
font.size = 30
font.paint = rgba(255, 255, 255, 255)

var position = vec2(0, 0)

let textTemplate = "The quick brown fox. "
var text = ""
for i in 0 ..< 1000:
  text.add(textTemplate[i mod textTemplate.len])

proc render() =
  image.fill(rgba(0, 255, 0, 0))

  let spans = @[
    newSpan(text, font),
  ]

  image.fillText(typeset(spans, vec2(1024, 1024)), translate(position))

  shader.setUniform("ProjMtx", orthoProjection(0, window.width, window.height, 0))
  texture.uploadSub(image.width, image.height, cast[seq[uint8]](image.data))

  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  gfx.drawTriangles(6, UInt32, 0)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[Left]:
    position.x = window.input.mouseX
    position.y = window.input.mouseY

  render()