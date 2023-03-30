{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame:
  let gfx = gui.gfx

  let view1 = gui.beginView("View1")
  view1.position = vec2(50, 50)
  view1.size = vec2(8000, 8000)
  let view2 = gui.beginView("View2")
  view2.position = vec2(100, 100)
  view2.size = vec2(50, 50)
  gfx.beginPath()
  gfx.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
  gfx.fillColor = rgb(255, 255, 255)
  gfx.fill()
  gui.endView()

while gui.isOpen:
  gui.update()