{.experimental: "overloadableEnums".}

import ../nimcanvas

let canvas = newCanvas()
canvas.backgroundColor = rgb(16, 16, 16)

var position = vec2(0, 0)

canvas.onFrame = proc() =
  if canvas.mouseDown(Left) and canvas.mouseMoved:
    position += canvas.mouseDelta

  canvas.beginPath()
  canvas.roundedRect rect2(position, vec2(100, 100)), 5
  canvas.fillColor = rgb(255, 255, 255)
  canvas.fill()

while canvas.isOpen:
  canvas.update()