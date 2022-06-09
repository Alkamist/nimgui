{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)

let input = window.input
let gui = newGui(input)
discard gui.addFont(consolaData, 13)

window.onFrame = proc() =
  if input.mouseDown(Middle) and input.mouseMoved:
    let zoomPull = input.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    window.input.state.pixelDensity *= 2.0.pow(zoomPull * 0.005)
    window.input.state.pixelDensity = window.input.state.pixelDensity.clamp(0.25, 5.0)

  gui.beginFrame()

  gui.endFrame()

while window.isOpen:
  window.update()