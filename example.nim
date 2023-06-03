{.experimental: "overloadableEnums".}

import std/times
# import std/strformat
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

var frames = 0

gui.run:
  frames += 1

  gui.window("TestWindow1"):
    discard

  gui.window("TestWindow2"):
    if self.init:
      self.position = vec2(200, 200)

  gui.draw:
    gfx.fillColor = rgb(255, 255, 255)
    gfx.font = "consola"
    gfx.fontSize = 13.0
    gfx.setTextAlign(Left, Top)
    gfx.text(vec2(0, 0), $(float(frames) / cpuTime()))