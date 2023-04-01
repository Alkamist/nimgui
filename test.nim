{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

let window1 = gui.addWindow()
let window2 = gui.addWindow()

let button1 = window1.addButton()

gui.onFrame:
  window1.update()
  button1.update()
  if button1.justPressed:
    echo "Yee"
  window2.update()

while gui.isOpen:
  gui.update()