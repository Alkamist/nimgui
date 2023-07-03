{.experimental: "overloadableEnums".}

# import std/strutils
import nimgui
import nimgui/controls

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

proc exampleWindow(node: GuiNode, name: string): GuiWindow =
  let window = node.window(name)
  if window.accessCount > 2:
    return window

  let button = window.body.button("Button")
  if button.init:
    button.position = vec2(100, 100)
    button.size = vec2(96, 32)

  let slider = window.body.slider("Slider")
  if slider.init:
    slider.position = vec2(200, 200)
    slider.minValue = 200.0
    slider.maxValue = 400.0

  button.position.x = slider.value
  if button.clicked:
    slider.value = slider.value + 10.0

  window

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()

  let window1 = root.exampleWindow("Window1")
  if window1.init:
    window1.position = vec2(100, 200)

  let window2 = window1.body.exampleWindow("Window2")
  if window2.init:
    window2.position = vec2(50, 50)

  let window3 = root.exampleWindow("Window3")
  if window3.init:
    window3.position = vec2(500, 200)

  let window4 = window3.exampleWindow("Window4")
  if window4.init:
    window4.position = vec2(50, 50)

  root.endFrame()

  osWindow.swapBuffers()

osWindow.run()