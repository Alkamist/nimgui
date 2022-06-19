{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let window = newWindow()
window.backgroundColor = rgb(16, 16, 16)
window.gfx.addFont("consola", consolaData)

let window2 = newWindow()
window2.backgroundColor = rgb(140, 16, 16)
window2.gfx.addFont("consola", consolaData)

while window.isOpen or window2.isOpen:
  pollEvents()

  window.processFrame:
    let gfx = window.gfx
    gfx.fontSize = 13
    gfx.fillColor = rgb(255, 255, 255)
    gfx.drawText(
      text = gfx.newText("Ayy Lmao"),
      bounds = rect2(vec2(0, 0), window.size),
      alignX = Center,
      alignY = Center,
      wordWrap = false,
      clip = true,
    )

  window2.processFrame:
    let gfx = window2.gfx
    gfx.fontSize = 13
    gfx.fillColor = rgb(255, 255, 255)
    gfx.drawText(
      text = gfx.newText("Ayy Lmao 2"),
      bounds = rect2(vec2(0, 0), window2.size),
      alignX = Center,
      alignY = Center,
      wordWrap = false,
      clip = true,
    )