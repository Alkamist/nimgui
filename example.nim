{.experimental: "overloadableEnums".}

import nimgui
import nimgui/imploswindow
# import nimgui/widgets
import oswindow as oswnd

# var textTest = ""

# for _ in 0 ..< 100:
#   for _ in 0 ..< 1000:
#     textTest &= "A"
#   textTest &= "\n"

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

  # gui.pushOffset(vec2(0, 300))
  # gui.pushClip(vec2(400, 100), vec2(200, 200))

  gui.fillColor = rgb(255, 255, 255)

  let text = "Test Text"
  let position = gui.mousePosition

  # gui.beginPath()
  # for glyph in gui.calculateGlyphs(text):
  #   gui.pathRect(position + vec2(glyph.x, 0) + vec2(0.5, 0.5), vec2(glyph.width, gui.lineHeight))
  # gui.strokeColor = rgb(0, 255, 0)
  # gui.stroke()

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(position, text)

  # gui.popClip()
  # gui.popOffset()

  gui.fillColor = rgb(255, 255, 255)
  gui.drawText(vec2(0, 0), $(float(frames) / gui.time))

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()