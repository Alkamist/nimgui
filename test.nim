{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

let w = WindowWidget()
w.size = vec2(300, 200)
w.minSize = vec2(300, 200)
w.maxSize = vec2(600, 500)

gui.onFrame:
  w.update(gui)

while gui.isOpen:
  gui.update()