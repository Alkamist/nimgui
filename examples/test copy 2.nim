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

  let p = (x: 4.0, y: 4.0) * scale
  let s = (x: 50.0, y: 50.0) * scale

  let rect = (
    position: p,
    size: s,
  )
  let backgroundRect = (
    position: p - 3.0,
    size: s + 6.0,
  )

  canvas.pushClipRect rect
  canvas.fillRect backgroundRect, (1.0, 0.0, 0.0, 1.0)
  canvas.outlineRect rect, (1.0, 1.0, 1.0, 1.0), 1.0
  canvas.popClipRect

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()