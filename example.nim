{.experimental: "overloadableEnums".}

# import std/strutils
import nimgui
import nimgui/widgets

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

type
  SampleWindow = ref object of GuiWindow

proc update(window: SampleWindow) =
  GuiWindow(window).update()
  GuiWindow(window).draw()

  let body = window.body
  body.update()

  let slider = body.getNode("Slider", GuiSlider)
  if slider.init:
    slider.position = vec2(5, 32 + 10)
    slider.size = vec2(300, 24)
    slider.minValue = 30.0
    slider.maxValue = 140.0

  slider.update()
  slider.draw()

  let button = body.getNode("Button", GuiButton)
  if button.init:
    button.size = vec2(96, 32)
  button.position = vec2(slider.position.x + slider.handle.position.x, 5)

  button.update()
  button.draw()

  if button.clicked:
    slider.value = slider.value + 10.0

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()



  let window1 = root.getNode("Window1", SampleWindow)
  if window1.init:
    window1.default()
    window1.position = vec2(200, 300)

  window1.update()

  let window2 = window1.getNode("Window2", SampleWindow)
  if window2.init:
    window2.default()
    window2.position = vec2(200, 300)

  window2.update()



  let window3 = root.getNode("Window3", SampleWindow)
  if window3.init:
    window3.default()
    window3.position = vec2(500, 300)

  window3.update()

  let window4 = window3.getNode("Window4", SampleWindow)
  if window4.init:
    window4.default()
    window4.position = vec2(200, 300)

  window4.update()


  # root.fillTextLine(vec2(0, 0), "Fps: " & root.fps.formatFloat(ffDecimal, 4))

  root.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(root.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()