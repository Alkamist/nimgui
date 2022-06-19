{.experimental: "overloadableEnums".}

import ../nimengine

let window = newWindow()
window.backgroundColor = rgb(16, 16, 16)

window.onFrame = proc() =
  if window.mouseDown(Right) and window.mouseMoved:
    window.bounds = rect2(
      window.position,
      window.size,
    )

  let gfx = window.gfx
  gfx.beginPath()
  gfx.roundedRect(rect2(50, 50, 200, 200), 5)
  gfx.fillColor = rgb(200, 200, 0)
  gfx.fill()

while window.exists:
  window.update()