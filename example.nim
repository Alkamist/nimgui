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
  gui.time = osWindow.time
  gui.beginFrame()

  let window = gui.getState("Window", GuiWindow)
  if window.init:
    window.position = vec2(200, 200)
    window.size = vec2(300, 200)
    window.minSize = vec2(200, 100)

  gui.beginWindow(window)

  let button = gui.getState("Button", GuiButton)
  button.position = vec2(300, 300)
  button.size = vec2(50, 50)
  gui.updateButton(button)
  gui.drawButton(button)

  gui.endWindow()

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()