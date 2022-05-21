{.experimental: "overloadableEnums".}

import std/math
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = gfx.newOpenGlContext(client.handle)
openGlContext.select()

gfx.setBackgroundColor(0, 0, 0, 1)

let canvas = gfx.newCanvas()
canvas.loadFont(fontData, 13)

var scale = 1.0

proc onFrame() =
  if client.mouseDown(Middle):
    let zoomPull = client.mouseDeltaPixels.asFloat.dot((1.0, 1.0).normalize)
    scale *= 2.0.pow(zoomPull * 0.005)
    scale = scale.min(8.0).max(1.0)

  let sizePixels = client.sizePixels.asFloat
  gfx.setViewport(0, 0, sizePixels.x, sizePixels.y)
  gfx.setClipRect(0, 0, sizePixels.x, sizePixels.y)
  gfx.clearBackground()

  canvas.beginFrame(sizePixels, scale)

  let p = parsePath """
    M 5 5
    h 5
    v 5
    h -5
    z
  """
  # let p = parsePath "M2 100 h100 v100 h100 v100 h-100 v100 h-100 v-100 h-100 v-100 h100 z"
  canvas.strokePath p, (1.0, 1.0, 1.0, 1.0), 1.0

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()