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

  root.addButton("Button1"):
    self.anchor.x = Center
    self.x = root.width * 0.5
    self.size = vec2(96, 32)
    if self.pressed:
      echo "1"

  root.addButton("Button2"):
    self.placement = root.previous.placement
    self.y += self.height + 5

  for i, placement in gridPlacement(4, 4, vec2(500, 500), vec2(5, 5), vec2(10, 10)):
    root.addButton("GridButton" & $i):
      self.placement = placement
      self.position += vec2(100, 100)

  root.addText("Fps"):
    self.size = vec2(200, 18)
    self.alignX = Left
    self.alignY = Baseline
    self.data = $(float(frames) / root.time)

  root.addWindow("Window1")

  root.highlightOnHoverHook()

root.run()