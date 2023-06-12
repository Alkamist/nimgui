{.experimental: "overloadableEnums".}

import nimgui
import nimgui/imploswindow
import nimgui/widgets
import oswindow

let window = OsWindow.new()
window.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
window.show()

let gui = Gui.new()
gui.attachToOsWindow(window)

window.onFrame = proc(window: OsWindow) =
  gui.beginFrame(window.time)

  if gui.beginWindow("Window").isOpen:
    gui.endWindow()

  gui.endFrame()

  if window.isHovered:
    window.setCursorStyle(gui.cursorStyle)

  window.swapBuffers()

window.run()