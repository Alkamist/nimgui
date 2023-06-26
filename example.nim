{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)
gui.fontSize = 13

const fontData = readFile("consola.ttf")
gui.addFont(fontData)

var value1 = 0.0
var value2 = 0.0
var value3 = 0.0
var value4 = 0.0

proc testWindow(gui: Gui, id: string, position, size: Vec2, value: var float) =
  let window = gui.beginWindow(id, position, size)

  let header = gui.beginHeader(window)

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, header.size.y * 0.5 - gui.lineHeight * 0.5), id, header.size.x, 0.5)

  gui.endHeader()

  let body = gui.beginBody(window)

  gui.slider("Slider", vec2(5, 5), vec2(body.size.x - 10, 24), value, 21.0, 138.0)

  if gui.button("Button", vec2(5, 52), vec2(50, 50)).pressed:
    value += 2.0

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(5, 34), value.formatFloat(ffDecimal, 4))

  gui.endBody()

  gui.endWindow()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  let windowSize = vec2(400, 300)
  gui.testWindow("Window1", vec2(20, 20), windowSize, value1)
  gui.testWindow("Window2", vec2(20, 20) + vec2(windowSize.x + 20, 0), windowSize, value2)
  gui.testWindow("Window3", vec2(20, 20) + vec2(0, windowSize.y + 20), windowSize, value3)
  gui.testWindow("Window4", vec2(20, 20) + vec2(windowSize.x + 20, windowSize.y + 20), windowSize, value4)

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, 0), "Fps: " & gui.fps.formatFloat(ffDecimal, 4))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()