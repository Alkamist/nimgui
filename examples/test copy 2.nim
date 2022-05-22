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

  # var poly = polyLine(canvas.scale)
  # poly.rect(
  #   rect2(50, 50, 200, 200),
  #   20, 20, 20, 20,
  # )
  # poly.arcTo(vec2(150, 50), 50, degToRad(0.0), degToRad(90.0))
  # poly.bezierCubicCurveTo(vec2(300, 50), vec2(300, 50), vec2(300, 300))

  var poly = polyLine(canvas.scale)
  poly.rect(
    rect2(50, 50, 20, 20),
    2, 2, 2, 2,
  )
  canvas.strokePolyLine(poly, rgb(255, 255, 255), 1.0)

  # let w = client.sizePixels.x / 100.0
  # let h = client.sizePixels.y / 100.0
  # for i in 0 ..< 100:
  #   for j in 0 ..< 100:
  #     var poly = polyLine(canvas.scale)
  #     poly.rect(
  #       rect2(i.float * w, j.float * h, w * 0.95, h * 0.95),
  #       2, 2, 2, 2,
  #     )
  #     canvas.strokePolyLine(poly, rgb(255, 255, 255), 1.0)

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()