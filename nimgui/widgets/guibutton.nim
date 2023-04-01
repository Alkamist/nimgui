{.experimental: "overloadableEnums".}

import ../guimod
import ./frame

type
  GuiButton* = ref object of GuiWidget
    isDown*: bool
    wasDown*: bool
    justClicked*: bool

template justPressed*(button: GuiButton): bool = button.isDown and not button.wasDown
template justReleased*(button: GuiButton): bool = button.wasDown and not button.isDown

func addButton*(layer: GuiLayer): GuiButton =
  result = layer.addWidget(GuiButton)
  result.size = vec2(96, 32)

method update*(button: GuiButton) =
  let gui = button.gui

  button.justClicked = false
  button.wasDown = button.isDown

  if button.isHovered and gui.mouseJustPressed(Left):
    button.isDown = true

  if button.isDown and gui.mouseJustReleased(Left):
    button.isDown = false
    if button.isHovered:
      button.justClicked = true

method draw*(button: GuiButton) =
  let gfx = button.gui.drawList
  let bodyColor = rgb(33, 38, 45)
  let borderColor = rgb(52, 59, 66)
  # let textColor = rgb(201, 209, 217)

  let bodyColorHighlighted =
    if button.isDown: bodyColor.darken(0.3)
    elif button.isHovered: bodyColor.lighten(0.05)
    else: bodyColor

  let borderColorHighlighted =
    if button.isDown: borderColor.darken(0.1)
    elif button.isHovered: borderColor.lighten(0.4)
    else: borderColor

  gfx.drawFrame(
    bounds = button.bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )