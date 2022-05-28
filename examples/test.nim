{.experimental: "overloadableEnums".}

import ../nimcanvas

let canvas = newCanvas()
canvas.backgroundColor = rgb(16, 16, 16)
canvas.addFont("consola", "./examples/consola.ttf")
# canvas.addFont("consola", "./examples/Roboto-Regular.ttf")

var text = """
proc drawText*(canvas: Canvas, text: string, bounds: Rect2) =
  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(canvas.nvgContext, ascender.addr, descender.addr, lineHeight.addr)

  let lines = canvas.lineMetrics(text, bounds)
  var y = bounds.y
  for line in lines:
    let lineStartAddr = cast[uint](text[line.byteStart].unsafeAddr)
    let lineFinishAddr = lineStartAddr + line.byteLen.uint
    discard nvgText(canvas.nvgContext, bounds.x, y, cast[cstring](lineStartAddr), cast[cstring](lineFinishAddr))
    y += lineHeight
"""

# var text = "123456789\n123456789\n123456789\n123456789\n123456789\n123456789\n"

# var text = ""
# for i in 0 ..< 3000:
#   text.add "0123456789"

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

  # canvas.letterSpacing = 20
  canvas.font = "consola"
  canvas.fontSize = 13
  canvas.drawText(text, bounds)
  # canvas.drawTextLine(text, textPosition)

while canvas.isOpen:
  canvas.update()