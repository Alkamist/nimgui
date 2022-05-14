{.experimental: "overloadableEnums".}

import std/math
import nimengine

let window = newWindow()

let openGlContext = gfx.newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.setBackgroundColor(0.1, 0.1, 0.1, 1.0)

let canvas = gfx.newCanvas()
canvas.scale = 1.0
canvas.loadFont("examples/consola.ttf", 24)
# canvas.loadFont("examples/Roboto-Regular_1.ttf", 13)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)

  # canvas.drawText(
  #   "Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao ",
  #   (100.0, 100.0, 200.0, 200.0),
  #   (1.0, 1.0, 1.0, 1.0),
  #   xAlign = Left,
  #   yAlign = Top,
  #   clip = true,
  # )

  let points = [
    (50.0, 50.0),
    (150.0, 350.0),
    (250.0, 50.0),
    (350.0, 350.0),
  ]
  canvas.fillPolyLineOpen(points, (1.0, 1.0, 1.0, 1.0))

  canvas.render()

  openGlContext.swapBuffers()

window.onResize = render

window.onMouseWheel = proc() =
  canvas.scale *= 2.0.pow(window.input.mouseWheelY * 0.5)
  canvas.scale = canvas.scale.max(0.1)
  # canvas.loadFont("examples/consola.ttf", 24 * canvas.scale)

while not window.isClosed:
  window.pollEvents()
  render()