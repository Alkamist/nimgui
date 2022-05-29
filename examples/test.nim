{.experimental: "overloadableEnums".}

import ../nimcanvas

const consolaData = staticRead("consola.ttf")
const data = staticRead("unicodetestfile.txt")

let canvas = newCanvas()
canvas.backgroundColor = rgb(16, 16, 16)
canvas.addFont("consola", consolaData)

var mouseEdit = canvas.size - 5

canvas.onFrame = proc() =
  if canvas.mouseDown(Middle):
    let zoomPull = canvas.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    canvas.dpi *= 2.0.pow(zoomPull * 0.005)
    canvas.dpi = canvas.dpi.clamp(96.0, 5000.0)

  let textPosition = vec2(5, 5)

  if canvas.mouseDown(Left) and canvas.mouseMoved:
    mouseEdit = canvas.mousePosition

  let bounds = rect2(textPosition, mouseEdit - textPosition)

  canvas.beginPath()
  canvas.roundedRect(bounds, 5)
  canvas.fillColor = rgb(80, 0, 0)
  canvas.fill()

  canvas.fillColor = rgb(240, 240, 240)

  # canvas.letterSpacing = 2
  canvas.font = "consola"
  canvas.fontSize = 13

  let text = canvas.newText(data)
  canvas.drawText(text, bounds.expand(-2.5), Left, Top, wordWrap = true)

while canvas.isOpen:
  canvas.update()