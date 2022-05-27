{.experimental: "overloadableEnums".}

import ../nimcanvas

let canvas = newCanvas()
canvas.backgroundColor = rgb(0, 200, 0)

canvas.onFrame = proc() =
  canvas.roundedRect rect2(50, 50, 100, 100), 5
  canvas.fillColor = rgb(255, 255, 255)
  canvas.fill()

while canvas.isOpen:
  canvas.update()