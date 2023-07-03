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

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()

  let window = root.window("Window")
  if window.init:
    window.position = vec2(300, 300)

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

  # let path = Path.new()
  # path.roundedRect(vec2(50, 50), vec2(200, 100), 5)
  # root.fillPath(path, rgb(255, 0, 0))

  root.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(root.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()