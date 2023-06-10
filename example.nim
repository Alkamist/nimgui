{.experimental: "overloadableEnums".}

import nimgui
import nimgui/imploswindow
import oswindow

let window = OsWindow.new()
window.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
window.show()

let gui = Gui.new()
gui.attachToOsWindow(window)

window.onFrame = proc(window: OsWindow) =
  gui.beginFrame(window.time)

  if gui.button("Button").pressed:
    echo "1"

  if gui.beginWindow("Window", rect2(100, 100, 300, 300)).isOpen:
    if gui.button("Button").pressed:
      echo "2"

    gui.endWindow()

  gui.endFrame()
  window.swapBuffers()

window.run()