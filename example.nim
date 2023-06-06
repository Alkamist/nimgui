{.experimental: "overloadableEnums".}

import nimgui

let root = GuiRoot.new()

const consolaData = readFile("consola.ttf")
root.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(node: GuiNode) =
  node.drawHook:
    if node.isHovered and not node.passInput:
      let vg = node.vg
      vg.beginPath()
      vg.rect(vec2(0.5, 0.5), node.size - vec2(1.0, 1.0))
      vg.strokeWidth = 1
      vg.strokeColor = rgb(0, 255, 0)
      vg.stroke()
  if node of GuiContainer:
    for child in GuiContainer(node).activeNodes:
      child.highlightOnHoverHook()

var frames = 0

let padding = vec2(5, 5)

root.onFrame:
  frames += 1

  let b1 = root.addButton("Button1")
  b1.position = vec2(50, 50)
  b1.size = vec2(96, 32)
  b1.update()

  let w1 = root.addWindow("Window1")
  w1.update()

  let fps = root.addText("Fps")
  fps.size = vec2(200, 18)
  fps.alignX = Left
  fps.alignY = Baseline
  fps.data = $(float(frames) / root.time)
  fps.update()

  root.highlightOnHoverHook()

root.run()