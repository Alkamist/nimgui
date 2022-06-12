{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let w = newWindow()
w.backgroundColor = rgb(13, 17, 23)
w.gfx.addFont("consola", consolaData)
w.gfx.font = "consola"

let gui = newGui(w)

w.onFrame = proc() =
  if w.mouseDown(Middle) and w.mouseMoved:
    let zoomPull = w.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    w.frame.pixelDensity *= 2.0.pow(zoomPull * 0.005)
    w.frame.pixelDensity = w.frame.pixelDensity.clamp(0.25, 5.0)

  gui.beginFrame()

  var windowActive {.global.} = false

  gui.addButton("Toggle"):
    if widget.pressed:
      windowActive = not windowActive

  if windowActive:
    gui.addWindow("Window 1"):
      gui.addButton("Click me"):
        if widget.clicked:
          echo "Clicked"

  gui.endFrame()

while w.isOpen:
  w.update()