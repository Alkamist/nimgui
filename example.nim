{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginUpdate()

  let button = root.getNode("Button", GuiButton)
  button.position = vec2(50, 50)
  button.size = vec2(96, 32)
  button.update()
  if button.clicked:
    echo "Clicked"

  # root.fillTextLine(vec2(0, 0), "Fps: " & root.fps.formatFloat(ffDecimal, 4))

  root.endUpdate()

  if osWindow.isHovered:
    osWindow.setCursorStyle(root.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()