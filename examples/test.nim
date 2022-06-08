{.experimental: "overloadableEnums".}

import ../nimcanvas

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)

let input = window.input
let gui = newGui(input)

window.onFrame = proc() =
  gui.beginFrame()

  gui.endFrame()

while window.isOpen:
  window.update()