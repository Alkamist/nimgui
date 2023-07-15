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

let performance = Performance.new(gui)

let slider = Slider.new(gui)

let text = Text.new(gui)
text.position = slider.position + vec2(0, slider.size.y + 5.0)
text.data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

let title = Text.new(gui)
title.data = "Window"

let window = Window.new(gui)

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  window.beginUpdate()
  window.draw()

  let header = window.beginHeader()
  title.position.x = (header.size.x - title.size.x) * 0.5
  title.position.y = (header.size.y - title.lineHeight) * 0.5
  title.update()
  title.draw()
  window.endHeader()

  window.beginBody(vec2(5.0, 5.0))

  slider.update()
  slider.draw()

  if gui.mouseHitTest(text.position, text.size):
    gui.requestHover(text)
  text.update()
  text.draw()

  window.endBody()
  window.endUpdate()

  performance.update()
  gui.fillTextLine("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()