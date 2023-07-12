import nimgui
import nimgui/backends

let gui1 = Gui.new()
gui1.backgroundColor = rgb(255, 255, 255)
gui1.setupBackend()
gui1.show()

let gui2 = Gui.new()
gui2.backgroundColor = rgb(0, 0, 0)
gui2.setupBackend()
gui2.show()

gui1.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  let path = Path.new()
  path.rect(vec2(50, 50), vec2(200, 200))
  gui.fillPath(path, rgb(255, 0, 0))

  gui.endFrame()

gui2.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  let path = Path.new()
  path.rect(vec2(50, 50), vec2(200, 200))
  gui.fillPath(path, rgb(0, 255, 0))

  gui.endFrame()

while true:
  if not gui1.closeRequested:
    gui1.pollEvents()
    gui1.makeContextCurrent()
    gui1.processFrame()
    gui1.swapBuffers()

  if not gui2.closeRequested:
    gui2.pollEvents()
    gui2.makeContextCurrent()
    gui2.processFrame()
    gui2.swapBuffers()

  if gui1.closeRequested and gui2.closeRequested:
    break