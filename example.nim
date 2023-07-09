{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
gui.addFont(fontData)

proc testWidget(gui: Gui, id: GuiId, initialPosition: Vec2) =
  gui.pushId(id)

  let positionId = gui.getId("Position")
  let sizeId = gui.getId("Size")
  var position = gui.getState(positionId, initialPosition)
  var size = gui.getState(sizeId, vec2(400, 300))

  gui.beginWindow("Window", position, size)
  gui.beginWindowBody()

  let sliderValueId = gui.getId("SliderValue")
  var sliderValue = gui.getState(sliderValueId, 0.0)

  let button = gui.button("Button", vec2(50 + sliderValue * 100.0, 0))
  gui.slider("Slider", sliderValue, vec2(50, 50))

  if button.clicked:
    sliderValue += 0.05

  gui.setState(sliderValueId, sliderValue)

  gui.endWindowBody()
  gui.endWindow()

  gui.setState(positionId, position)
  gui.setState(sizeId, size)

  gui.popId()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.pushZIndex(1)
  gui.testWidget(gui.getId("Widget1"), vec2(0, 50))
  gui.popZIndex()
  gui.testWidget(gui.getId("Widget2"), vec2(500, 50))

  gui.fillTextRaw("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0), rgb(255, 255, 255), 0, 13)

  gui.endFrame()

  osWindow.swapBuffers()

osWindow.run()