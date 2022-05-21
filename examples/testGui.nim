{.experimental: "overloadableEnums".}

import std/math
import std/strutils
import nimengine

const fontData = staticRead("examples/consola.ttf")

let client = newClient()

let openGlContext = gfx.newOpenGlContext(client.handle)
openGlContext.select()

setBackgroundColor(0.1, 0.5, 0.1, 1.0)

let canvas = gfx.newCanvas()
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

let size = client.size / 2.1

for i in 0 ..< 2:
  for j in 0 ..< 2:
    let button = newButtonWidget()
    button.label = "Button"
    button.relativePosition = vec2(20, 40)
    button.size = vec2(100, 60)
    button.onClicked = proc() = echo "Clicked"

    let parent = newWindowWidget()
    parent.title = "Window"
    parent.relativePosition = vec2(20.0 + i.float * size.x, 20.0 + j.float * size.y)
    parent.size = size * 0.95

    let child = newWindowWidget()
    child.title = "Child Window"
    child.relativePosition = vec2(50, 50)
    child.size = vec2(200, 200)

    parent.children.add(child)
    child.children.add(button)
    gui.children.add(parent)

proc onFrame() =
  if client.mouseDown(Middle):
    let zoomPull = client.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    client.dpi *= 2.0.pow(zoomPull * 0.005)
    client.dpi = client.dpi.min(1024.0).max(96.0)

  gfx.setViewport(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.setClipRect(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.clearBackground()

  canvas.beginFrame(client.sizePixels, client.scale)

  gui.update()
  gui.draw()

  canvas.drawText(
    client.dpi.formatFloat(ffDecimal, 4),
    rect2(0, 0, 400, 100),
    rgb(255, 255, 255),
    xAlign = Left,
    yAlign = Top,
    clip = false,
    wordWrap = false,
  )

  canvas.render()

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()