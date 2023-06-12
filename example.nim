{.experimental: "overloadableEnums".}

import nimgui
import nimgui/imploswindow
import nimgui/widgets
import oswindow as oswnd

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.beginFrame(osWindow.time)

  if gui.button("Button1").clicked:
    echo "Clicked"

  let window = gui.getState("Window", GuiWindow)
  if window.init:
    window.isOpen = true
    window.editBounds = rect2(200, 200, 300, 300)
    window.minSize = vec2(500, 300)

  if gui.beginWindow(window).isOpen:
    gui.endWindow()

  if gui.beginWindow("Window2").isOpen:
    gui.endWindow()

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()