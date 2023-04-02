{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

let window1 = gui.addWindow()
let window2 = gui.addWindow()
let window3 = window2.body.addWindow()

let button1 = window2.addButton()

gui.onFrame:
  if button1.justPressed:
    echo "Yee"

while gui.isOpen:
  gui.osWindow.update()