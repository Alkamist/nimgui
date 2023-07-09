{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

const sampleText = """
An preost wes on leoden, Laȝamon was ihoten

He wes Leovenaðes sone -- liðe him be Drihten.

He wonede at Ernleȝe at æðelen are chirechen,

Uppen Sevarne staþe, sel þar him þuhte,

Onfest Radestone, þer he bock radde."""

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
gui.addFont(fontData)

proc exampleWindow(gui: Gui, name: string, initialPosition: Vec2) =
  gui.pushIdSpace(gui.getId(name))

  let positionId = gui.getId("Position")
  var position = gui.getState(positionId, initialPosition)

  let sizeId = gui.getId("Size")
  var size = gui.getState(sizeId, vec2(400, 300))

  gui.beginWindow("Window", position, size)

  # Header
  let header = gui.beginWindowHeader()
  gui.fillText(name, vec2(0, 0), header.size, alignment = vec2(0.5, 0.5))
  gui.endWindowHeader()

  # Body
  let body = gui.beginWindowBody()

  let sliderValueId = gui.getId("SliderValue")
  var sliderValue = gui.getState(sliderValueId, 0.0)

  gui.slider("Slider", sliderValue, vec2(50, 50))

  gui.setState(sliderValueId, sliderValue)

  gui.fillText(sampleText, vec2(0, 0), body.size, alignment = vec2(0, sliderValue))

  gui.endWindowBody()

  gui.endWindow()

  gui.setState(positionId, position)
  gui.setState(sizeId, size)

  gui.popIdSpace()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.exampleWindow("Window1", vec2(0, 50))
  gui.exampleWindow("Window2", vec2(500, 50))

  gui.fillTextRaw("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

  osWindow.swapBuffers()

osWindow.run()