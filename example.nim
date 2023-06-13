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

  if gui.beginWindow("Window").isOpen:
    gui.endWindow()

  if gui.button("Button1").clicked:
    echo "1"

  gui.sameRow()
  gui.nextPosition = gui.mousePosition
  gui.nextSize = vec2(200, 200)

  if gui.button("Button2").clicked:
    echo "2"

  gui.sameRow()

  if gui.button("Button3").clicked:
    echo "3"

  if gui.button("Button4").clicked:
    echo "4"

  # gui.sameRow()

  # if gui.button("Button5").clicked:
  #   echo "5"

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()