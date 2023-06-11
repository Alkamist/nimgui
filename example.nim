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

  if gui.button("Button1").pressed:
    echo "1"

  gui.setNextBounds rect2(20, 20, 50, 50)
  if gui.button("Button2").pressed:
    echo "2"

  if gui.beginWindow("Window", rect2(100, 100, 300, 300), rgb(100, 0, 0)).isOpen:
    if gui.button("Button").pressed:
      echo "3"

    if gui.beginWindow("Window2", rect2(80, 80, 300, 300), rgb(0, 100, 0)).isOpen:
      if gui.button("Button").pressed:
        echo "4"

      gui.endWindow()

    gui.endWindow()

  gui.endFrame()

  if window.isHovered:
    window.setCursorStyle(gui.cursorStyle)
  window.swapBuffers()

window.run()