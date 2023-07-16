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

let text = Text.new()
text.position = slider.position + vec2(0, slider.size.y + 5.0)
text.data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

let title = Text.new()
title.data = "Window"

let window = Window.new()

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  gui.beginUpdate(window)
  gui.draw(window)

  block: # Header
    let header = window.header
    gui.beginClipRegion(header)
    gui.beginOffset(header.position)

    title.position.x = (header.size.x - title.size.x) * 0.5
    title.position.y = (header.size.y - title.lineHeight) * 0.5
    gui.update(title)
    gui.draw(title)

    gui.endOffset()
    gui.endClipRegion()

  block: # Body
    let body = window.body(vec2(5, 5))
    gui.beginClipRegion(body)
    gui.beginOffset(body.position)

    gui.update(slider)
    gui.draw(slider)

    gui.update(text)
    gui.draw(text)

    gui.endOffset()
    gui.endClipRegion()

  gui.endUpdate(window)

  gui.update(performance)
  gui.fillTextLine("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()