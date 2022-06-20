{.experimental: "overloadableEnums".}

import ../nimengine

let window = newWindow()
window.backgroundColor = rgb(16, 16, 16)

window.onFrame = proc() =
  if window.mouseDown(Left) and window.mouseMoved:
    window.position = window.position + window.mouseDelta
    echo window.position

  let gfx = window.gfx
  gfx.beginPath()
  gfx.roundedRect(rect2(50, 50, 200, 200), 5)
  gfx.fillColor = rgb(200, 200, 0)
  gfx.fill()

while window.exists:
  pollEvents()
  window.update()