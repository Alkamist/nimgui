{.experimental: "overloadableEnums".}

import nimgui

gui.backgroundColor = rgb(16, 16, 16)
gui.window:
  gfx.beginPath()
  gfx.circle(window.mousePosition, 50.0)
  gfx.closePath()
  gfx.strokeColor = rgb(255, 255, 255)
  gfx.stroke()

gui.backgroundColor = rgb(16, 90, 16)
gui.window:
  gfx.beginPath()
  gfx.circle(window.mousePosition, 50.0)
  gfx.closePath()
  gfx.strokeColor = rgb(255, 50, 50)
  gfx.stroke()

while gui.isRunning:
  gui.update()

# let window = newOsWindow()
# let gfx = newGfx()

# window.onFrame = proc(window: OsWindow) =
#   gfx.beginFrame(window.sizePixels, window.pixelDensity)
#   gfx.beginPath()
#   gfx.circle(window.mousePosition, 50.0)
#   gfx.closePath()
#   gfx.strokeColor = rgb(255, 50, 50)
#   gfx.stroke()
#   gfx.endFrame()

# while window.isOpen:
#   window.update()