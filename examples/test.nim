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
    let zoomPull = client.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    scale *= 2.0.pow(zoomPull * 0.005)
    scale = scale.min(8.0).max(1.0)

  gfx.setViewport(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.setClipRect(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.clearBackground()

  canvas.beginFrame(client.sizePixels, scale)

  let p = parsePath """
    M 1 0
    l 0 1
    l -1 0
    l 0 -1
    z
  """
  p.transform vec2(100, 100).translate * rotate(25.0.degToRad) * vec2(200, 200).scale
  canvas.strokePath p, rgb(255, 255, 255), 1.0

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()