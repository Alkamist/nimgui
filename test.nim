{.experimental: "overloadableEnums".}

# Write macro that gets string id from variable name and iteration.
# Maybe offload initialization to individual widgets instead of the boilerplate macro.
# Potentially allow button to take in a set of buttons? Figure out how to customize the activation.
# Activation conditions, and overloaded to take in MouseButton or KeyboardKey?

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame:
  gui.window(window1):
    discard
    # gui.button(button1)

  # let button1 = gui.addWidget("Button 1", ButtonWidget)
  # button1.update(gui)

  # gui.button(button1)

while gui.isOpen:
  gui.update()