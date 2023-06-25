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

var someValue = 0.0

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.slider("Slider", vec2(100, 100), vec2(200, 24), someValue, 21.0, 138.0)

  let button = gui.getState("Button", GuiButton)
  button.position = vec2(100, 200)
  button.size = vec2(50, 50)
  gui.update(button)
  gui.draw(button)

  if button.pressed:
    someValue += 2.0

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(100, 150), someValue.formatFloat(ffDecimal, 4))

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, 0), "Fps: " & gui.fps.formatFloat(ffDecimal, 4))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()