{.experimental: "overloadableEnums".}

import nimgui
import nimgui/widgets

# const testText = """
# An preost wes on leoden, Laȝamon was ihoten
# He wes Leovenaðes sone -- liðe him be Drihten.
# He wonede at Ernleȝe at æðelen are chirechen,
# Uppen Sevarne staþe, sel þar him þuhte,
# Onfest Radestone, þer he bock radde.
# """

const testText = "An preost wes on leoden, Lðæð\nðæasdf"

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

  let text = gui.getState("Text", GuiText)
  text.position = gui.mousePosition
  text.data = testText

  gui.update(text)

  gui.beginPath()
  for glyph in text.glyphs:
    gui.pathRect(glyph.position + vec2(0.5, 0.5), glyph.size)
  gui.strokeColor = rgba(0, 255, 0, 64)
  gui.stroke()

  gui.draw(text)



  # gui.fillColor = rgb(255, 255, 255)
  # gui.drawText(position, text)

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, 0), $(float(frames) / gui.time))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()