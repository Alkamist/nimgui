{.experimental: "overloadableEnums".}

import nimengine

func vec2*(x, y: float): tuple[x, y: float] =
  (x: x, y: y)

func rect2*(x, y, width, height: float): tuple[x, y, width, height: float] =
  (x: x, y: y, width: width, height: height)

func rgba*(r, g, b, a: uint8): tuple[r, g, b, a: float] =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: a.float / 255)

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.enableBlend()
gfx.setBackgroundColor(0.1, 0.1, 0.1, 1)

let canvas = newCanvas()
# canvas.loadFont("experiments/Roboto-Regular_1.ttf", 16)
canvas.loadFont("experiments/consola.ttf", 13)

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
  # canvas.fillRect(rect2(128, 128, size.x, size.y), rgb(120, 0, 0))
  # canvas.outlineRect(rect2(128, 128, size.x, size.y), rgb(0, 255, 0), 1.0)
  # canvas.drawText(text, rect2(128, 128, size.x, size.y), rgb(255, 255, 255), Left, Top)

  let points = [
    (50.0, 50.0),
    (200.0, 50.0),
    (200.0, 200.0),
    (50.0, 200.0),
  ]

  canvas.fillConvexPoly(points, rgba(120, 0, 0, 255))
  canvas.fillPolyLineClosed(points, rgba(0, 255, 0, 128), 1.0)

  canvas.render()
  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[Left]:
    size.x = (window.input.mouseX - 128).max(0.0)
    size.y = (window.input.mouseY - 128).max(0.0)

  render()