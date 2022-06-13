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

  if gui.addButton("Click Me 1"):
    echo "Clicked 1"

  discard gui.addButton("Click Me 2")
  if gui.currentWidget(ButtonWidget).pressed:
    echo "Pressed 2"

  if gui.addButton("Click Me 3"):
    echo "Clicked 3"

  gui.endFrame()

while w.isOpen:
  w.update()