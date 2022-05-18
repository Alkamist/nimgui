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

  let p = (x: 4.0, y: 4.0)
  let s = (x: 200.0, y: 200.0)

  let r = (position: p, size: s)
  let br = (position: p - 3.0, size: s + 6.0)

  canvas.pushClipRect r

  let points = [
    r.position,
    (r.position.x + r.size.x, r.position.y),
    r.position + r.size,
    (r.position.x, r.position.y + r.size.y)
  ]
  let pointsBr = [
    br.position,
    (br.position.x + br.size.x, br.position.y),
    br.position + br.size,
    (br.position.x, br.position.y + br.size.y)
  ]
  canvas.fillConvexPoly pointsBr, (1.0, 0.0, 0.0, 1.0)
  canvas.fillPolyLineClosed points, (1.0, 1.0, 1.0, 1.0), 1.0 / canvas.scale

  canvas.popClipRect

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()