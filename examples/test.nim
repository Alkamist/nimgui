{.experimental: "overloadableEnums".}

import ../nimcanvas

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)

let input = window.input

var scale = 1.0

window.onFrame = proc() =
  if input.mouseDown(Left) and input.mouseMoved:
    let zoomPull = input.mouseDelta.dot(vec2(1, 1).normalize)
    scale *= 2.0.pow(zoomPull * 0.005)
    scale = scale.clamp(0.5, 2.0)

  let vg = newVgContext()
  vg.beginFrame(input.size, scale)
  vg.beginPath()
  vg.rect(rect2(50, 80, 200, 100))
  vg.fillColor = rgb(255, 0, 0)
  vg.fill()
  vg.endFrame()

while window.isOpen:
  window.update()