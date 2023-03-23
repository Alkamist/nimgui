{.experimental: "overloadableEnums".}

import nimgui

const robotoData = readFile("Roboto-Regular.ttf")

let gui = newGui()
gui.gfx.addFont("roboto", robotoData)
gui.gfx.font = "roboto"

gui.onFrame:
  gui.beginWindow("Window 1")
  # gui.button("Button 1")
  # gui.button("Button 2")
  # gui.button("Button 3")
  # gui.button("Button 4")
  gui.endWindow()
  # let gfx = gui.gfx
  # gfx.beginPath()
  # gfx.circle(gui.osWindow.mousePosition, 50.0)
  # gfx.closePath()
  # gfx.strokeColor = rgb(255, 50, 50)
  # gfx.stroke()

while gui.isOpen:
  gui.update()