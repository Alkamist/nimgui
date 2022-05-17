{.experimental: "overloadableEnums".}

import std/math
import std/strutils
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = newOpenGlContext(client.handle)
openGlContext.select()

setBackgroundColor(0.1, 0.5, 0.1, 1.0)

let canvas = newCanvas()
canvas.loadFont(fontData, 13)

let gui = newWidget(client, canvas)

# let parent = newWindowWidget()
# parent.title = "Window"
# parent.relativePosition = (50.0, 50.0)
# parent.size = (400.0, 300.0)

# let button = newButtonWidget()
# button.label = "Button"
# button.relativePosition = (20.0, 40.0)
# button.size = (200.0, 200.0)
# button.onClicked = proc() = echo "Clicked"

# parent.children.add button
# gui.children.add parent

let size = client.size / 5.0

for i in 0 ..< 5:
  for j in 0 ..< 5:
    let button = newButtonWidget()
    button.label = "Button"
    button.relativePosition = (20.0, 40.0)
    button.size = (200.0, 100.0)
    button.onClicked = proc() = echo "Clicked"

    let parent = newWindowWidget()
    parent.title = "Window"
    parent.relativePosition = (i.float * size.x, 20.0 + j.float * size.y)
    parent.size = size * 0.95

    let child = newWindowWidget()
    child.title = "Child Window"
    child.relativePosition = (50.0, 50.0)
    child.size = (200.0, 200.0)

    parent.children.add(child)
    child.children.add(button)
    gui.children.add(parent)

proc onFrame() =
  if client.mouseDown(Middle):
    let zoomPull = client.mouseDeltaPixels.asFloat.dot((1.0, 1.0).normalize)
    client.dpi *= 2.0.pow(zoomPull * 0.005)
    client.dpi = client.dpi.min(1024.0).max(96.0)

  let sizePixels = client.sizePixels.asFloat
  setViewport(0, 0, sizePixels.x, sizePixels.y)
  setClipRect(0, 0, sizePixels.x, sizePixels.y)
  clearBackground()

  canvas.beginFrame(sizePixels, client.scale)

  gui.update()
  gui.draw()

  canvas.drawText(
    client.dpi.formatFloat(ffDecimal, 4),
    ((0.0, 0.0), (400.0, 100.0)),
    (1.0, 1.0, 1.0, 1.0),
    xAlign = Left,
    yAlign = Top,
    clip = false,
  )

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()