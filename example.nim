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

osWindow.onFrame = proc(osWindow: OsWindow) =
  frames += 1

  gui.time = osWindow.time
  gui.beginFrame()

  gui.fontSize = 26

  gui.pushOffset(vec2(500, 300))
  gui.pushClip(vec2(0, 0), vec2(300, 300))

  for line in gui.textLines(gui.mousePosition, testText):
    gui.beginPath()

    for glyph in line.glyphs:
      gui.pathRect(line.position + vec2(glyph.left, 0) + vec2(0.5, 0.5), vec2(glyph.right - glyph.left, gui.lineHeight) - vec2(1.0, 1.0))

    gui.strokeColor = rgb(255, 0, 0)
    gui.stroke()

    gui.fillColor = rgb(255, 255, 255)
    gui.drawTextLine(line.position, line.text)

  # gui.drawText(gui.mousePosition, testText)

  gui.popClip()
  gui.popOffset()

  gui.fillColor = rgb(255, 255, 255)
  gui.drawTextLine(vec2(0, 0), $(float(frames) / gui.time))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()