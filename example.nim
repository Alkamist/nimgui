{.experimental: "overloadableEnums".}

import nimgui
import nimgui/controls

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

type
  ExampleWindow = ref object of GuiWindow

proc getExampleWindow(node: GuiNode, id: string): ExampleWindow =
  result = node.getNode(id, ExampleWindow)
  if result.init:
    result.setDefault()

proc update(window: ExampleWindow) =
  GuiWindow(window).update()

  const padding = 10.0

  let slider = window.body.getSlider("Slider")
  slider.position = vec2(padding, padding)
  slider.size.x = slider.parent.size.x - padding * 2
  slider.update()

  let childWindow = window.getWindow("ChildWindow")
  if childWindow.init:
    childWindow.position = vec2(100, 100)

  childWindow.update()

  let button = childWindow.body.getButton("Button")
  button.update()

  if button.clicked:
    slider.value = slider.value + 0.05

  button.position = vec2(padding + slider.value * (button.parent.size.x - button.size.x - padding * 2), padding)

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()

  let window1 = root.getExampleWindow("Window1")
  if window1.init:
    window1.position = vec2(100, 100)

  window1.update()

  let window2 = root.getExampleWindow("Window2")
  if window2.init:
    window2.position = vec2(600, 100)

  window2.update()

  root.endFrame()

  osWindow.swapBuffers()

osWindow.run()