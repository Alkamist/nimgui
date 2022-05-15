{.experimental: "overloadableEnums".}

import std/math
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = newOpenGlContext(client.handle)
openGlContext.select()

setBackgroundColor(0.1, 0.5, 0.1, 1.0)

let canvas = newCanvas()
canvas.loadFont(fontData, 13)

let gui = newWidget(client, canvas)

let parent = newWindowWidget()
parent.title = "Window"
parent.position = (50.0, 50.0)
parent.size = (400.0, 300.0)

let button = newButtonWidget()
button.label = "Button"
button.position = (20.0, 40.0)
button.size = (200.0, 200.0)
button.onClicked = proc() = echo "Clicked"

parent.children.add button
gui.children.add parent

proc onFrame() =
  if client.mouseWheel.y != 0:
    client.dpi *= 2.0.pow(client.mouseWheel.y * 0.5)

  setViewport(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  setClipRect(0, 0, client.sizePixels.x.float, client.sizePixels.y.float)
  clearBackground()

  canvas.beginFrame(client.size, client.densityPixelsPerPixel)

  gui.update()
  gui.draw()

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()