{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

let window1 = gui.root.addWidget(WindowWidget)
let window2 = gui.root.addWidget(WindowWidget)

# let button1 = window1.addWidget(ButtonWidget)
# button1.useMouseButton(Left)

gui.onFrame:
  discard
  # if button1.isDown and gui.mouseMoved:
  #   button1.position += gui.mouseDelta

while gui.isOpen:
  gui.update()