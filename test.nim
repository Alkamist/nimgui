{.experimental: "overloadableEnums".}

import nimgui

let window = newOsWindow()
window.backgroundColor = rgb(0, 200, 0)

let window2 = newOsWindow()
window2.backgroundColor = rgb(200, 0, 0)

window.onFrame = proc() =
  if window.mouseDown(Left) and window.mouseMoved:
    echo "1"

window2.onFrame = proc() =
  if window2.mouseDown(Left) and window2.mouseMoved:
    echo "2"

while window.isOpen or window2.isOpen:
  window.update()
  window2.update()


# var position = vec2(50, 50)

# gui.window:
#   if gui.mouseDown(Left) and gui.mouseMoved:
#     position += gui.mouseDelta

#   gui.beginPath()
#   gui.circle(position, 50)
#   gui.closePath()
#   gui.strokeColor = rgb(255, 255, 255)
#   gui.stroke()

# var position1 = vec2(50, 50)

# gui.window:
#   if gui.mouseDown(Left) and gui.mouseMoved:
#     position1 += gui.mouseDelta

#   gui.beginPath()
#   gui.circle(position1, 50)
#   gui.closePath()
#   gui.strokeColor = rgb(255, 255, 255)
#   gui.stroke()