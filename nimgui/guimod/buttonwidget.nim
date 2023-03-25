{.experimental: "overloadableEnums".}

import ../guimod

type
  ButtonWidget* = ref object of Widget
    label*: string
    isDown*: bool
    wasDown*: bool

template pressed*(button: ButtonWidget): bool = button.isDown and not button.wasDown
template released*(button: ButtonWidget): bool = button.wasDown and not button.isDown

proc new*(T: type ButtonWidget): T =
  result = T()
  result.size = vec2(96, 32)

proc update*(button: ButtonWidget, gui: Gui) =
  let gfx = gui.drawList
  let bounds = button.bounds
  let isHovered = gui.hover == button

  button.wasDown = button.isDown

  if isHovered and gui.mousePressed(Left):
    button.isDown = true

  if button.isDown and gui.mouseReleased(Left):
    button.isDown = false

  let bodyColor = rgb(33, 38, 45)
  let borderColor = rgb(52, 59, 66)
  # let textColor = rgb(201, 209, 217)

  let bodyColorHighlighted =
    if button.isDown: bodyColor.darken(0.3)
    elif isHovered: bodyColor.lighten(0.05)
    else: bodyColor

  let borderColorHighlighted =
    if button.isDown: borderColor.darken(0.1)
    elif isHovered: borderColor.lighten(0.4)
    else: borderColor

  gfx.drawFrame(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

implementWidget(button, ButtonWidget)