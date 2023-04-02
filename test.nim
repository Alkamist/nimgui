{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

let window1 = gui.addWindow()
let window2 = gui.addWindow()

let headerButton = window2.header.addButton()

let prevDraw = window2.body.draw
window2.body.draw = proc(widget: GuiWidget) =
  prevDraw(widget)
  let gfx = widget.gui.drawList
  gfx.beginPath()
  gfx.rect(rect2(widget.parent.mousePosition, vec2(50, 50)))
  gfx.fillColor = rgb(0, 255, 0)
  gfx.fill()

gui.onFrame:
  headerButton.position = vec2(5, 5)
  headerButton.size = vec2(16, 16)

while gui.isOpen:
  gui.osWindow.update()