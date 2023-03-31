{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame:
  let gfx = gui.gfx

  let view1 = gui.beginView("View1")
  view1.position = vec2(50, 50)
  view1.size = vec2(8000, 8000)

  gfx.beginPath()
  gfx.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
  gfx.fillColor = rgb(100, 0, 0)
  gfx.fill()

  let view2 = gui.beginView("View2")
  view2.position = vec2(50, 50)
  view2.size = vec2(8000, 8000)

  gfx.beginPath()
  gfx.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
  gfx.fillColor = rgb(0, 100, 0)
  gfx.fill()

  # let window1 = gui.beginWindow("Window1")
  let button1 = gui.addButton("Button1")
  # gui.endWindow()


  gui.endView()
  gui.endView()

while gui.isOpen:
  gui.update()