{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame:
  let gfx = gui.gfx

  let layer1 = gui.beginLayer("Layer1")
  layer1.passInput = false
  layer1.position = vec2(50, 50)
  layer1.size = vec2(8000, 8000)

  gfx.beginPath()
  gfx.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
  gfx.fillColor = rgb(100, 0, 0)
  gfx.fill()

  let layer2 = gui.beginLayer("Layer2")
  layer2.passInput = false
  layer2.position = vec2(50, 50)
  layer2.size = vec2(8000, 8000)

  gfx.beginPath()
  gfx.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
  gfx.fillColor = rgb(0, 100, 0)
  gfx.fill()

  # let window1 = gui.beginWindow("Window1")
  let button1 = gui.addButton("Button1")
  # gui.endWindow()

  gui.endLayer()
  gui.endLayer()

while gui.isOpen:
  gui.update()