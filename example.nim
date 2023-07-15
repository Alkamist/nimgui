{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets
import nimgui/backends

const fontData = readFile("consola.ttf")

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)

gui.setupBackend()
gui.addFont(fontData)
gui.show()

let performance = Performance.new()

let slider = Slider.new()
slider.position = vec2(100, 50)

let text = Text.new()
text.position = vec2(100, 100)
text.data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

let window = Window.new()

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  window.beginUpdate(gui)
  window.draw(gui)
  window.beginBody(gui)

  slider.update(gui)
  slider.draw(gui)

  text.update(gui)
  text.draw(gui)

  window.endBody(gui)
  window.endUpdate(gui)

  performance.update(gui.deltaTime)
  gui.fillTextLine("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()