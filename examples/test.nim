{.experimental: "overloadableEnums".}

import ../nimengine

# const consolaData = staticRead("consola.ttf")

let window = newWindow()
window.backgroundColor = rgb(16, 16, 16)

let window2 = newWindow()
window2.backgroundColor = rgb(140, 16, 16)

while window.isOpen or window2.isOpen:
  pollEvents()

  window.processFrame:
    if window.anyMousePressed:
      echo window.mousePresses

    let gfx = window.gfx
    gfx.beginPath()
    gfx.roundedRect(rect2(50, 50, 200, 200), 4)
    gfx.fillColor = rgb(200, 100, 20)
    gfx.fill()

  window2.processFrame:
    if window2.anyMousePressed:
      echo window2.mousePresses

    let gfx = window2.gfx
    gfx.beginPath()
    gfx.roundedRect(rect2(50, 50, 300, 400), 4)
    gfx.fillColor = rgb(200, 200, 20)
    gfx.fill()