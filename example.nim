{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

const testText = """
An preost wes on leoden, Laȝamon was ihoten
He wes Leovenaðes sone -- liðe him be Drihten.
He wonede at Ernleȝe at æðelen are chirechen,
Uppen Sevarne staþe, sel þar him þuhte,
Onfest Radestone, þer he bock radde.
"""

# var testText = ""
# for _ in 0 ..< 100:
#   testText.add("1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\n")

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
gui.addFont(fontData)

var position = vec2(300, 300)
var wrapWidth = 80.0

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.fontSize = 26

  if gui.mouseDown(Left) and gui.mouseMoved:
    if gui.keyDown(LeftShift):
      position += gui.mouseDelta
    else:
      wrapWidth += gui.mouseDelta.x

  gui.drawText(position, testText, wrapWidth, 0.5, true)

  gui.beginPath()
  gui.pathMoveTo(vec2(position.x, 0))
  gui.pathlineTo(vec2(position.x, gui.size.y))
  gui.pathMoveTo(vec2(position.x + wrapWidth, 0))
  gui.pathlineTo(vec2(position.x + wrapWidth, gui.size.y))
  gui.strokeColor = rgb(0, 255, 0)
  gui.stroke()

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, 0), gui.fps.formatFloat(ffDecimal, 4))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()