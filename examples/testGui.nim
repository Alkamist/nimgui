{.experimental: "overloadableEnums".}

import ../nimcanvas

const consolaData = staticRead("consola.ttf")

let canvas = newCanvas()
# canvas.backgroundColor = rgb(13, 17, 23)
canvas.backgroundColor = rgb(0, 0, 0)
canvas.addFont("consola", consolaData)
canvas.font = "consola"

let gui = newGui(canvas)

canvas.onFrame = proc() =
  if canvas.mouseDown(Middle):
    let zoomPull = canvas.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    canvas.dpi *= 2.0.pow(zoomPull * 0.005)
    canvas.dpi = canvas.dpi.clamp(96.0, 5000.0)

  gui.beginFrame()
  if Clicked in gui.button("Ayy Lmao"):
    echo "Clicked"

while canvas.isOpen:
  canvas.update()