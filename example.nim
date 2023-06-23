{.experimental: "overloadableEnums".}

import nimgui
import nimgui/widgets

const testText = """
An preost wes on leoden, Laȝamon was ihoten
He wes Leovenaðes sone -- liðe him be Drihten.
He wonede at Ernleȝe at æðelen are chirechen,
Uppen Sevarne staþe, sel þar him þuhte,
Onfest Radestone, þer he bock radde.
"""

# const testText = "1234567890\n1234567890"

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

var frames = 0

var position = vec2(50, 50)
var size = vec2(600, 400)

var cullPosition = vec2(100, 100)
var cullSize = vec2(200, 200)

osWindow.onFrame = proc(osWindow: OsWindow) =
  frames += 1

  gui.time = osWindow.time
  gui.beginFrame()

  gui.fontSize = 26

  if gui.mouseDown(Left) and gui.mouseMoved:
    if gui.keyDown(LeftShift):
      position += gui.mouseDelta
    else:
      size += gui.mouseDelta

  if gui.mouseDown(Right) and gui.mouseMoved:
    if gui.keyDown(LeftShift):
      cullPosition += gui.mouseDelta
    else:
      cullSize += gui.mouseDelta

  for line in gui.textBoxLines(position, size, testText, true):
    if line.position.y + gui.lineHeight < cullPosition.y: continue
    if line.position.y > cullPosition.y + cullSize.y: break

    let line = line.trimGlyphs(cullPosition.x, cullPosition.x + cullSize.x)

    gui.beginPath()
    for glyph in line.glyphs:
      gui.pathRect(glyph.position, glyph.size)
    gui.strokeColor = rgb(255, 0, 0)
    gui.stroke()

    gui.drawTextLine(line.position, line.text)

  gui.beginPath()
  gui.pathRect(position, size)
  gui.strokeColor = rgb(0, 255, 0)
  gui.stroke()

  gui.beginPath()
  gui.pathRect(cullPosition, cullSize)
  gui.strokeColor = rgb(0, 0, 255)
  gui.stroke()

  gui.fillColor = rgb(255, 255, 255)
  gui.drawTextLine(vec2(0, 0), $(float(frames) / gui.time))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()