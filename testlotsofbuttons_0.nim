{.experimental: "overloadableEnums".}

# Figure out how to purge unused widgets from the table.

import nimgui
import std/sugar

const fontData = readFile("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", fontData)
gui.gfx.font = "consola"

const rows = 25
const columns = 25

var elapsed = 0.0
var frames = 0

gui.onFrame:
  let gfx = gui.gfx

  let buttonWidth = gui.size.x / rows.float
  let buttonHeight = gui.size.y / columns.float
  for i in 0 ..< rows:
    for j in 0 ..< columns:
      capture i, j:
        let buttonId = "Button " & $(i * rows + j)
        gui.button(buttonId):
          button.position = vec2(i.float * buttonWidth, 40 + j.float * buttonHeight)
          button.size = vec2(buttonWidth * 0.9, buttonHeight * 0.9)
          if button.pressed:
            echo buttonId

  elapsed += gui.deltaTime
  let fps = frames.float / elapsed

  gfx.fontSize = 13
  gfx.fillColor = rgb(201, 209, 217)
  gfx.drawText(
    text = gfx.newText($fps),
    bounds = rect2(vec2(0, 0), vec2(gui.size.x, 32)),
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  frames += 1

while gui.isOpen:
  gui.update()