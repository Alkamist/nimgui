{.experimental: "overloadableEnums".}

import nimgui
import nimgui/controls

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()

  let button = root.button("Button"):
    button.size = vec2(50, 50)

  root.endFrame()

  osWindow.swapBuffers()

osWindow.run()