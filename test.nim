{.experimental: "overloadableEnums".}

import nimgui

var position = vec2(50, 50)

gui.window:
  if gui.mouseDown(Left) and gui.mouseMoved:
    position += gui.mouseDelta

  gui.beginPath()
  gui.circle(position, 50)
  gui.closePath()
  gui.strokeColor = rgb(255, 255, 255)
  gui.stroke()

# var position1 = vec2(50, 50)

# gui.window:
#   if gui.mouseDown(Left) and gui.mouseMoved:
#     position1 += gui.mouseDelta

#   gui.beginPath()
#   gui.circle(position1, 50)
#   gui.closePath()
#   gui.strokeColor = rgb(255, 255, 255)
#   gui.stroke()