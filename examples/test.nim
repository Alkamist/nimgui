{.experimental: "overloadableEnums".}

import std/math
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = gfx.newOpenGlContext(client.handle)

gfx.setBackgroundColor(0.1, 0.1, 0.1, 1.0)

let canvas = gfx.newCanvas()
canvas.loadFont(fontData, 13)

client.onFrame = proc() =
  if client.mouseWheel.y != 0:
    client.dpi *= 2.0.pow(client.mouseWheel.y * 0.5)

  gfx.setViewport(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  gfx.setClipRect(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  gfx.clearBackground()

  canvas.beginFrame(client.size, client.densityPixelsPerPixel)

  # let points = [
  #   (50.0, 50.0),
  #   (150.0, 350.0),
  #   (250.0, 50.0),
  #   (350.0, 350.0),
  # ]
  # canvas.fillPolyLineOpen points, (1.0, 1.0, 1.0, 1.0)

  canvas.fillRect ((100.0, 100.0), (200.0, 200.0)), (0.4, 0.0, 0.0, 1.0)

  canvas.drawText(
    "Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao",
    ((100.0, 100.0), (200.0, 200.0)),
    (0.5, 1.0, 1.0, 1.0),
    xAlign = Left,
    yAlign = Top,
    clip = true,
  )

  canvas.render()

  openGlContext.swapBuffers()

while client.isOpen:
  client.update()