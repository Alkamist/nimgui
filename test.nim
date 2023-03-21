{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(16, 16, 16)

let gfx = newGfx()

gui.onFrame = proc() =
  gfx.beginFrame(gui.sizePixels, gui.pixelDensity)

  gfx.beginPath()
  gfx.rect(rect2(vec2(0.5, 0.5), vec2(gui.size.x - 1, 26)))
  gfx.circle(vec2(gui.size.x * 0.5, 200), 50)
  gfx.strokeColor = rgb(255, 0, 0)
  gfx.stroke()

  gfx.endFrame()

while gui.isOpen:
  gui.update()