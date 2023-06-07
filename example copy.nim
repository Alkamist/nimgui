{.experimental: "overloadableEnums".}

import nimgui

let root = GuiRoot.new()

const consolaData = readFile("consola.ttf")
root.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(node: GuiNode) =
  node.drawHook:
    if not node.isRoot and node.isHovered and not node.passInput:
      let vg = node.vg
      vg.beginPath()
      vg.rect(vec2(0.5, 0.5), node.size - vec2(1.0, 1.0))
      vg.strokeWidth = 1
      vg.strokeColor = rgb(0, 255, 0)
      vg.stroke()
  for child in node.activeChildren:
    child.highlightOnHoverHook()

var frames = 0

root.onFrame:
  frames += 1

  let grid = root.addNode("ButtonGrid")
  grid.position = vec2(100, 50)
  grid.size = vec2(400, 400)
  grid.queueGrid(
    4, 4,
    spacing = vec2(5, 5),
    padding = vec2(5, 5),
  )

  for i in 0 ..< 16:
    let iteration = $i

    let button = grid.addButton("GridButton" & iteration)
    button.update()

    let text = button.addText("Text")
    text.size = button.size
    text.alignX = Center
    text.alignY = Center
    text.data = iteration

  let button = root.addButton("Button")
  button.size = vec2(grid.width, 50)
  button.update()

  let fps = root.addText("Fps")
  fps.size = vec2(200, 18)
  fps.alignX = Left
  fps.alignY = Baseline
  fps.data = $(float(frames) / root.time)
  fps.update()

  let window = root.addWindow("Window1")
  window.update()

  root.highlightOnHoverHook()

root.run()