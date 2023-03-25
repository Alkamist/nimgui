{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

const rows = 25
const columns = 25

gui.onFrame:
  let buttonWidth = gui.size.x / rows.float
  let buttonHeight = gui.size.y / columns.float
  for row in 0 ..< rows:
    for col in 0 ..< columns:
      let i = row * rows + col
      gui.button(loopButton, i)
      loopButton.position = vec2(row.float * buttonWidth, col.float * buttonHeight)
      loopButton.size = vec2(buttonWidth * 0.9, buttonHeight * 0.9)
      if loopButton.pressed:
        echo "Button " & $i & " pressed."

while gui.isOpen:
  gui.update()