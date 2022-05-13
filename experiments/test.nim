{.experimental: "overloadableEnums".}

import nimengine

func vec2*(x, y: float): tuple[x, y: float] =
  (x: x, y: y)

func rect2*(x, y, width, height: float): tuple[x, y, width, height: float] =
  (x: x, y: y, width: width, height: height)

func rgb*(r, g, b: float): tuple[r, g, b, a: float] =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: 1.0)

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.enableBlend()
gfx.setBackgroundColor(0.1, 0.1, 0.1, 1)

let canvas = newCanvas()
# canvas.loadFont("experiments/Roboto-Regular_1.ttf", 16)
canvas.loadFont("experiments/consola.ttf", 13)

let whitePixelUv = (
  x: canvas.atlas.whitePixel.x / canvas.atlas.width,
  y: canvas.atlas.whitePixel.y / canvas.atlas.height,
)

let phrase = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLNOPQRSTUVWXYZ 1234567890 "
var text = ""
for i in 0 ..< 1000:
  text.add phrase[i mod phrase.len]

var size = vec2(128, 128)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)
  canvas.addQuad(
    rect2(128, 128, size.x, size.y),
    rect2(whitePixelUv.x, whitePixelUv.y, 0, 0),
    rgb(120, 0, 0),
  )
  canvas.drawText(text, rect2(128, 128, size.x, size.y), rgb(255, 255, 255), Left, Top)

  canvas.render()
  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[Left]:
    size.x = (window.input.mouseX - 128).max(0.0)
    size.y = (window.input.mouseY - 128).max(0.0)

  render()