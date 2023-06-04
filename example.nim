{.experimental: "overloadableEnums".}

import std/times
# import std/strformat
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

proc highlightOnOverHook(widget: Widget) =
  for child in widget.childDrawOrder:
    child.drawHook = proc(widget: Widget) =
      if widget.isHovered:
        let gfx = widget.vg
        gfx.beginPath()
        gfx.rect(vec2(0, 0), widget.size)
        gfx.strokeColor = rgb(0, 255, 0)
        gfx.stroke()
    child.highlightOnOverHook()

var frames = 0

gui.run:
  frames += 1

  let window1 = gui.window("Window1"):
    discard

  gui.newWidget("Window1Overlay", Widget):
    self.zIndex = window1.zIndex + 1
    self.position = window1.position
    self.draw:
      gfx.fillColor = rgb(255, 255, 255)
      gfx.font = "consola"
      gfx.fontSize = 13.0
      gfx.setTextAlign(Left, Top)
      gfx.text(vec2(0, 0), $(float(frames) / cpuTime()))

  gui.window("Window2"):
    if self.init:
      self.position = vec2(200, 200)

  gui.highlightOnOverHook()