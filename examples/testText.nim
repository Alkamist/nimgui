{.experimental: "overloadableEnums".}

import pkg/nimengine
import pkg/nimengine/gmath/types

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.enableBlend()
gfx.setBackgroundColor(rgb(32, 32, 32))

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer(canvas)

var position = vec2(0, 0)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)

  canvas.fillRect(0, 0, 128, 128, rgb(120, 0, 0))
  canvas.drawText("ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 1234567890.", rect2(0, 0, 128, 128), rgb(255, 255, 255), Center, Center)

  canvasRenderer.render()

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[Left]:
    position.x = window.input.mouseX
    position.y = window.input.mouseY

  render()