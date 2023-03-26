{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

# const rows = 25
# const columns = 25

gui.onFrame:
  gui.button(button1)
  button1.size = vec2(20.0, 20.0)

  gui.button(button2)
  button2.size = vec2(40.0, 20.0)

  gui.button(button3)
  button3.size = vec2(30.0, 20.0)

  gui.button(button4)
  button4.size = vec2(70.0, 20.0)

  # gui.window(window1):
  #   discard

  # gui.window(window2):
  #   discard

  # let buttonWidth = gui.size.x / rows.float
  # let buttonHeight = gui.size.y / columns.float
  # for row in 0 ..< rows:
  #   for col in 0 ..< columns:
  #     let i = row * rows + col
  #     gui.button(loopButton[i])
  #     loopButton.position = vec2(row.float * buttonWidth, col.float * buttonHeight)
  #     loopButton.size = vec2(buttonWidth * 0.9, buttonHeight * 0.9)
  #     if loopButton.clicked:
  #       echo "Button " & $i & " clicked."

  # gui.multiButton(buttonLeft)
  # if buttonLeft.clicked(Left):
  #   echo "Left clicked."

  # gui.multiButton(buttonRight)
  # buttonRight.mouseButtons = {Right}
  # buttonRight.position = vec2(200, 0)
  # if buttonRight.clicked(Right):
  #   echo "Right clicked."

while gui.isOpen:
  gui.update()