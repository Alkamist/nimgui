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
parent.x = 50
parent.y = 50
parent.width = 400
parent.height = 300

let button = newButtonWidget()
button.label = "Button"
button.x = 20
button.y = 40
button.width = 100
button.height = 80
button.onClicked = proc() = echo "Clicked"

parent.children.add button
gui.children.add parent

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

  gui.update()
  gui.draw()

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()