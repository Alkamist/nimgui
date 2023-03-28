{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame:
  let window1 = gui.beginWindow("Window 1")
  let row1 = gui.beginRow("Row 1")
  row1.position = vec2(5, 50)
  let button1 = gui.addButton("Button 1")
  button1.size = vec2(42, 64)
  let button2 = gui.addButton("Button 2")
  button2.size = vec2(96, 32)
  let button3 = gui.addButton("Button 3")
  button3.size = vec2(263, 76)
  let button4 = gui.addButton("Button 4")
  button4.size = vec2(167, 14)
  gui.endRow()
  gui.endWindow()

while gui.isOpen:
  gui.update()