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

  if gui.button("Button").clicked:
    echo "1"

  # if gui.button("Button2").clicked:
  #   echo "2"

  gui.nextBounds = rect2(100, 100, 300, 300)

  if gui.beginWindow("Window1").isOpen:
    gui.endWindow()

  if gui.beginWindow("Window2").isOpen:
    gui.endWindow()

  # gui.button("Button1"):
  #   echo "1"

  # gui.nextBounds = rect2(20, 20, 50, 50)

  # gui.button("Button2"):
  #   echo "2"

  # gui.nextBounds = rect2(100, 100, 300, 300)

  # gui.window("Window"):
  #   gui.button("Button"):
  #     echo "3"

  #   gui.nextBounds = rect2(200, 200, 500, 500)

  #   gui.window("Window"):
  #     gui.button("B"):
  #       echo "4"

  gui.endFrame()

  if window.isHovered:
    window.setCursorStyle(gui.cursorStyle)

  window.swapBuffers()

window.run()