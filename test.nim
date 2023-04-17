{.experimental: "overloadableEnums".}

import oswindow
import nimgui
import nimgui/imploswindow

const consolaData = staticRead("consola.ttf")

let guiWindow = newOsWindow()
let gui = newGui()
gui.backgroundColor = rgb(49, 51, 56)
gui.gfx.addFont("consola", consolaData)

let window1 = gui.addWindow()
window1.position = vec2(50, 50)
window1.size = vec2(500, 500)
window1.addTitle("Window 1")

guiWindow.onFrame = proc() =
  implOsWindow(gui, guiWindow)

while guiWindow.isOpen:
  guiWindow.process()