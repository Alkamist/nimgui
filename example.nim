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

let performance = gui.newWidget(Performance)

let slider = gui.newWidget(Slider)

let text = gui.newWidget(Text)
text.position = slider.position + vec2(0, slider.size.y + 5.0)
text.data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

let title = gui.newWidget(Text)
title.data = "Window"

let window = gui.newWidget(Window)

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  window.beginUpdate()
  window.draw()

  block: # Header
    let header = window.header
    gui.beginClipRegion(header)
    gui.beginOffset(header.position)

    title.position.x = (header.size.x - title.size.x) * 0.5
    title.position.y = (header.size.y - title.lineHeight) * 0.5
    title.update()
    title.draw()

    gui.endOffset()
    gui.endClipRegion()

  block: # Body
    let body = window.body(vec2(5, 5))
    gui.beginClipRegion(body)
    gui.beginOffset(body.position)

    slider.update()
    slider.draw()

    if gui.mouseHitTest(text.position, text.size):
      gui.requestHover(text)

    text.update()
    text.draw()

    gui.endOffset()
    gui.endClipRegion()

  window.endUpdate()

  performance.update()
  gui.fillTextLine("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()