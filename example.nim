{.experimental: "overloadableEnums".}

import std/times
# import std/strformat
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(widget: Widget) =
  widget.drawHook:
    if widget.parent != nil and widget.isHovered and not widget.passInput:
      let gfx = widget.vg
      gfx.beginPath()
      gfx.rect(vec2(0.5, 0.5), widget.size)
      gfx.strokeColor = rgb(0, 255, 0)
      gfx.stroke()

  for child in widget.childDrawOrder:
    child.highlightOnHoverHook()

var frames = 0

gui.run:
  frames += 1
  let fpsCount = float(frames) / cpuTime()

  gui.childSpacing = vec2(5, 5)
  gui.childSize = vec2(200, 18)

  gui.layoutPosition = vec2(50, 50)
  gui.childSize = vec2(300, 100)

  let b1 = gui.addButton("Button1")
  b1.update()

  gui.sameRow()
  for i in gui.grid(4, 4):
    let button = gui.addButton("GridButton" & $i)
    button.update()

    let text = button.addText("Text")
    text.size = button.size
    text.data = $i

  let b2 = gui.addButton("Button2")
  b2.update()

  gui.freePosition()
  let fps = gui.addText("Fps")
  fps.update()
  fps.alignX = Left
  fps.alignY = Baseline
  fps.data = $fpsCount

  gui.freePosition()
  let window1 = gui.addWindow("Window1")
  window1.update()

  gui.highlightOnHoverHook()