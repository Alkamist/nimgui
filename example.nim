{.experimental: "overloadableEnums".}

import std/times
# import std/strformat
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(widget: Widget) =
  widget.drawHook = proc(widget: Widget) =
    if widget.isHovered and not widget.passInput:
      let gfx = widget.vg
      gfx.beginPath()
      gfx.rect(vec2(0, 0), widget.size)
      gfx.strokeColor = rgb(0, 255, 0)
      gfx.stroke()

  for child in widget.childDrawOrder:
    child.highlightOnHoverHook()

var frames = 0

gui.run:
  frames += 1

  let window = gui.addWindow("Window1")
  window.update()
  window.highlightOnHoverHook()

  let windowHeader = window.addHeader()

  let fps = windowHeader.addText("Fps")
  fps.data = $(float(frames) / cpuTime())