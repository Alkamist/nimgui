{.experimental: "overloadableEnums".}

import ../nimcanvas

const consolaData = staticRead("consola.ttf")

let canvas = newCanvas()
canvas.backgroundColor = rgb(13, 17, 23)
# canvas.backgroundColor = rgb(255, 255, 255)
canvas.addFont("consola", consolaData)
canvas.font = "consola"

let gui = newWidget(canvas)

let w = canvas.width / 2.0
let h = canvas.height / 2.0

for i in 0 ..< 2:
  for j in 0 ..< 2:
    let button = newButtonWidget()
    button.label = "Ayy Lmao"
    button.relativeX = 50
    button.relativeY = 50
    button.width = 93
    button.height = 32

    let window = newWindowWidget()
    window.title = "Ayy Lmao"
    window.relativeX = i.float * w + 10.0
    window.relativeY = j.float * h + 10.0
    window.width = w * 0.95
    window.height = h * 0.95

    window.children.add(button)
    gui.children.add(window)

canvas.onFrame = proc() =
  if canvas.mouseDown(Middle):
    let zoomPull = canvas.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    canvas.dpi *= 2.0.pow(zoomPull * 0.005)
    canvas.dpi = canvas.dpi.clamp(96.0, 5000.0)

  gui.update()
  gui.draw()

while canvas.isOpen:
  canvas.update()