{.experimental: "overloadableEnums".}

import ../nimcanvas

let window = newWindow()
window.backgroundColor = rgb(13, 17, 23)

let input = window.input
let gui = newGui(input)

window.onFrame = proc() =
  gui.beginFrame()

  # if Clicked in gui.button("Ayy Lmao"):
  #   echo "Clicked"

  gui.beginWindow("Ayy Lmao")

  gui.endWindow()

  gui.beginWindow("Ayy Lmao 2")

  gui.endWindow()

  gui.endFrame()

while window.isOpen:
  window.update()