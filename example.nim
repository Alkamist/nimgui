{.experimental: "overloadableEnums".}

import nimgui

let root = GuiRoot.new()

const consolaData = readFile("consola.ttf")
root.vg.addFont("consola", consolaData)

proc highlightOnHoverHook(node: GuiNode) =
  node.drawHook:
    if node.isHovered and not node.passInput:
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

  let window = root.addWindow("Window1")
  let windowBody = window.body

  window.minSize = vec2(50, 50)

  let childWindow = windowBody.addWindow("ChildWindow")
  let childWindowBody = childWindow.body

  let button2 = childWindow.addButton("BackgroundButton")
  button2.zIndex = -1
  button2.ignoreClipping = true
  button2.position = vec2(200, 200)
  button2.size = vec2(96, 32)

  let button3 = childWindowBody.addButton("Button3")
  button3.position = vec2(0, 100)
  button3.size = vec2(50, 50)

  let fps = root.addText("Fps")
  fps.textAlignment = textAlignment(Left, Top)
  fps.size = vec2(0, fps.lineHeight)
  fps.data = "Fps: " & $(float(frames) / root.time)

  root.highlightOnHoverHook()

root.run()