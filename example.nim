{.experimental: "overloadableEnums".}

import nimgui
import oswindow
import vectorgraphics

proc outlineRect(vg: VectorGraphics, rect: Rect2, color: Color) =
  vg.beginPath()
  vg.rect(rect.position + vec2(0.5, 0.5), rect.size - vec2(1.0, 1.0))
  vg.strokeColor = color
  vg.stroke()

let window = OsWindow.new()
window.show()

let vg = VectorGraphics.new()
const consolaData = readFile("consola.ttf")
vg.addFont("consola", consolaData)

var boundingRect = rect2(50, 50, 500, 500)

let gui = Gui()

var frames = 0

window.onFrame = proc(window: OsWindow) =
  frames += 1

  let (pixelWidth, pixelHeight) = window.size
  vg.beginFrame(pixelWidth, pixelHeight, 1.0)

  vg.outlineRect(boundingRect, rgb(255, 0, 255))

  gui.pushLayout(boundingRect, vec2(0, 0))

  gui.row([200.0, -1.0], -1.0)

  gui.column:
    gui.row([10.0, 20.0, -1.0], 30.0)

    for i in 0 ..< 5:
      vg.outlineRect(gui.nextRect, rgb(0, 255, 0))

    gui.setNextRect(rect2(200, 200, 300, 300), Relative)
    vg.outlineRect(gui.nextRect, rgb(255, 0, 0))

    gui.setNextRect(rect2(200, 200, 300, 300), Absolute)
    vg.outlineRect(gui.nextRect, rgb(255, 255, 255))

    vg.outlineRect(gui.nextRect, rgb(0, 255, 0))

  gui.column:
    gui.row([100.0, -1.0], 90.0)

    for i in 0 ..< 5:
      vg.outlineRect(gui.nextRect, rgb(0, 0, 255))

  # vg.outlineRect(rect2(boundingRect.position, gui.currentLayout.max - boundingRect.position), rgb(255, 0, 255))
  discard gui.layoutStack.pop()

  vg.fillColor = rgb(255, 255, 255)
  vg.font = "consola"
  vg.fontSize = 13.0
  vg.textAlignment = textAlignment(Left, Top)
  vg.text(vec2(0, 0), $(float(frames) / window.time))

  vg.endFrame()
  window.swapBuffers()

window.run()