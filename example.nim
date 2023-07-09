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

proc testWidget(gui: Gui, id: GuiId, initialPosition: Vec2) =
  gui.pushIdSpace(id)

  gui.beginWindow("Window", initialPosition)
  gui.beginWindowBody()

  let sliderValueId = gui.getId("SliderValue")
  var sliderValue = gui.getState(sliderValueId, 0.0)

  let button = gui.button("Button", vec2(50 + sliderValue * 100.0, 0))
  gui.slider("Slider", sliderValue, vec2(50, 50))

  if button.clicked:
    sliderValue += 0.05

  gui.setState(sliderValueId, sliderValue)

  gui.fillText(sampleText, gui.mousePosition)

  gui.endWindowBody()
  gui.endWindow()

  gui.popIdSpace()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.testWidget(gui.getId("Widget1"), vec2(0, 50))
  gui.testWidget(gui.getId("Widget2"), vec2(500, 50))

  gui.fillText("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

  osWindow.swapBuffers()

osWindow.run()