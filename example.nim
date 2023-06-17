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

  gui.update(window):
    gui.draw(window)

    # gui.header(window):
    #   let vg = gui.vg
    #   vg.beginPath()
    #   vg.rect(vec2(0, 0), vec2(1000, 1000))
    #   vg.fillColor = rgb(255, 255, 255)
    #   vg.fill()

    gui.body(window):
      let button = gui.getState("Button", GuiButton)
      button.position = vec2(300, 300)
      button.size = vec2(50, 50)

      gui.update(button)
      gui.draw(button)

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()