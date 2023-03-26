{.experimental: "overloadableEnums".}

# Write macro that gets string id from variable name and iteration.
# Maybe offload initialization to individual widgets instead of the boilerplate macro.
# Potentially allow button to take in a set of buttons? Figure out how to customize the activation.
# Activation conditions, and overloaded to take in MouseButton or KeyboardKey?

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

# const rows = 25
# const columns = 25

gui.onFrame:
  gui.window(window1):
    discard

  gui.window(window2):
    discard

  # gui.root.bringToTop(window1)

  # echo gui.root.childZOrder[0] == window1

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