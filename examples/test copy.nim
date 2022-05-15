{.experimental: "overloadableEnums".}

import std/math
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = newOpenGlContext(client.handle)
openGlContext.select()

setBackgroundColor(0.1, 0.1, 0.1, 1.0)

let canvas = newCanvas()
canvas.loadFont(fontData, 13)

# var frame = 1
var scale = 1.0

proc onFrame() =
  if client.mouseWheel.y != 0.0:
    scale *= 2.0.pow(client.mouseWheel.y * 0.5)
    scale = scale.max(0.1)
    client.scale = scale

  setViewport(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  setClipRect(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  clearBackground()

  canvas.beginFrame(client.size.x, client.size.y, scale)

  let points = [
    (50.0, 50.0),
    (150.0, 350.0),
    (250.0, 50.0),
    (350.0, 350.0),
  ]
  canvas.fillPolyLineOpen(points, (1.0, 1.0, 1.0, 1.0))

  canvas.drawText(
    "Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao Ayy Lmao ",
    (100.0, 100.0, 200.0, 200.0),
    (0.5, 1.0, 1.0, 1.0),
    xAlign = Left,
    yAlign = Top,
    clip = true,
  )

  canvas.render()

  openGlContext.swapBuffers()

  # echo frame
  # inc frame

client.onFrame = onFrame

while client.isOpen:
  client.update()