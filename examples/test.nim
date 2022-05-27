{.experimental: "overloadableEnums".}

import ../nimcanvas

let canvas = newCanvas()
canvas.backgroundColor = rgb(16, 16, 16)
canvas.addFont("consola", "./examples/consola.ttf")

var text = ""
for _ in 0 ..< 10:
  text.add "0123456789"

var mouseEdit = vec2(0, 0)

canvas.onFrame = proc() =
  let textPosition = vec2(100, 200)

  if canvas.mouseDown(Left) and canvas.mouseMoved:
    mouseEdit = canvas.mousePosition

  let bounds = rect2(textPosition, mouseEdit - textPosition)

  canvas.beginPath()
  canvas.roundedRect(bounds, 5)
  canvas.fillColor = rgb(120, 0, 0)
  canvas.fill()

  canvas.fillColor = rgb(240, 240, 240)

  canvas.font = "consola"
  canvas.fontSize = 13
  canvas.drawText(text, bounds)

while canvas.isOpen:
  canvas.update()