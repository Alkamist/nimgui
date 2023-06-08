{.experimental: "overloadableEnums".}

import nimgui

let root = GuiRoot.new()

const consolaData = readFile("consola.ttf")
root.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(node: GuiNode) =
  node.drawHook:
    if node.isHovered:
    # if node.isHoveredIncludingChildren:
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

  let button1 = root.addButton("Button1")

  button1.anchor = anchor(Center, Center)
  button1.position = vec2(root.width * 0.5, root.height * 0.5)
  button1.size = vec2(96, 32)

  if button1.pressed:
    echo "1"

  # root.addButton("Button2"):
  #   self.placement = root.previous.placement
  #   self.y += self.height + 5

  # for i, placement in grid(4, 4, vec2(500, 500), vec2(5, 5), vec2(10, 10)):
  #   root.addButton("GridButton" & $i):
  #     self.placement = placement
  #     self.position += vec2(50, 50)

  #     let button = self
  #     self.addText("Text"):
  #       self.size = button.size
  #       self.data = $i

  let window = root.addWindow("Window1")
  window.minSize = vec2(50, 50)
  let windowBody = window.addBody()
  let windowHeader = window.addHeader()

  let button2 = window.addButton("Button2")
  button2.zIndex = -1
  button2.ignoreClipping = true
  button2.position = vec2(200, 200)
  button2.size = vec2(96, 32)

  let button3 = windowBody.addButton("Button3")
  button3.position = vec2(100, 200)
  button3.size = vec2(96, 32)

  let fps = windowHeader.addText("Fps")
  fps.textAlignment = textAlignment(Center, Center)
  fps.size = windowHeader.size
  fps.data = "Fps: " & $(float(frames) / root.time)

  root.highlightOnHoverHook()

root.run()