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

  var poly = polyLine(canvas.tesselation)
  poly.add vec2(50, 50)
  poly.bezierCubicCurveTo(vec2(300, 50), vec2(300, 50), vec2(300, 300))
  poly.close()

  canvas.strokePolyLine(poly, rgb(255, 255, 255), 5.0)

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()