{.experimental: "overloadableEnums".}

import ../nimcanvas

let canvas = newCanvas()
canvas.backgroundColor = rgb(16, 16, 16)
canvas.addFont("consola", "./examples/consola.ttf")
# canvas.addFont("consola", "./examples/Roboto-Regular.ttf")

# const data = """
# proc drawText*(canvas: Canvas, text: string, bounds: Rect2) =
#   var ascender, descender, lineHeight: cfloat
#   nvgTextMetrics(canvas.nvgContext, ascender.addr, descender.addr, lineHeight.addr)

#   let lines = canvas.lineMetrics(text, bounds)
#   var y = bounds.y
#   for line in lines:
#     let lineStartAddr = cast[uint](text[line.byteStart].unsafeAddr)
#     let lineFinishAddr = lineStartAddr + line.byteLen.uint
#     discard nvgText(canvas.nvgContext, bounds.x, y, cast[cstring](lineStartAddr), cast[cstring](lineFinishAddr))
#     y += lineHeight
# """

const data = staticRead("unicodetestfile.txt")

var mouseEdit = canvas.size

canvas.onFrame = proc() =
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