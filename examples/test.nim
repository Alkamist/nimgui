{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)
window.gfx.addFont("consola", consolaData)
window.gfx.font = "consola"

let gui = newGui(window)

var count = 0

window.onFrame = proc() =
  if window.mouseDown(Middle) and window.mouseMoved:
    let zoomPull = window.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    window.frame.pixelDensity *= 2.0.pow(zoomPull * 0.005)
    window.frame.pixelDensity = window.frame.pixelDensity.clamp(0.25, 5.0)

  gui.beginFrame()

  # discard gui.beginWindow("Window 1")
  if Clicked in gui.button("Button 1"):
    inc count
    echo count
  # gui.endWindow()

  # gui.beginWindow("Window 2")
  # gui.endWindow()

  gui.endFrame()

while window.isOpen:
  window.update()