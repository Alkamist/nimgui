{.experimental: "overloadableEnums".}

import ../nimengine

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)

window.onFrame = proc() =
  if window.mouseDown(Middle) and window.mouseMoved:
    let zoomPull = window.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    window.frame.pixelDensity *= 2.0.pow(zoomPull * 0.005)
    window.frame.pixelDensity = window.frame.pixelDensity.clamp(0.25, 5.0)

  let gfx = window.gfx
  gfx.beginPath()
  gfx.roundedRect(rect2(50, 50, 200, 200), 5)
  gfx.fillColor = rgb(120, 120, 0)
  gfx.fill()

let window2 = newWindow()
window2.backgroundColor = rgb(90, 17, 23)

window2.onFrame = proc() =
  if window2.mouseDown(Middle) and window2.mouseMoved:
    let zoomPull = window2.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    window2.frame.pixelDensity *= 2.0.pow(zoomPull * 0.005)
    window2.frame.pixelDensity = window2.frame.pixelDensity.clamp(0.25, 5.0)

  let gfx = window2.gfx
  gfx.beginPath()
  gfx.roundedRect(rect2(50, 50, 200, 200), 5)
  gfx.fillColor = rgb(120, 120, 0)
  gfx.fill()

while window.isOpen:
  window.update()
  window2.update()