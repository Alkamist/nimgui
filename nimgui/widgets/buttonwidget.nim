{.experimental: "overloadableEnums".}

import ../guimod
import ../frame

type
  ButtonWidget* = ref object of GuiWidget
    isDown*: bool
    wasDown*: bool
    justClicked*: bool

template justPressed*(button: ButtonWidget): bool = button.isDown and not button.wasDown
template justReleased*(button: ButtonWidget): bool = button.wasDown and not button.isDown

func addButton*(gui: Gui, id: GuiId): ButtonWidget =
  let view = gui.currentView

  let button = gui.addWidget(id, ButtonWidget)
  if button.justCreated:
    button.size = vec2(96, 32)

  let bounds = button.bounds
  let mouseIsInside = view.isHovered and bounds.contains(view.mousePosition)

  button.justClicked = false
  button.wasDown = button.isDown

  if mouseIsInside and view.mouseJustPressed(Left):
    button.isDown = true

  if button.isDown and view.mouseJustReleased(Left):
    button.isDown = false
    if mouseIsInside:
      button.justClicked = true

  let gfx = gui.gfx
  let bodyColor = rgb(33, 38, 45)
  let borderColor = rgb(52, 59, 66)
  # let textColor = rgb(201, 209, 217)

  let bodyColorHighlighted =
    if button.isDown: bodyColor.darken(0.3)
    elif mouseIsInside: bodyColor.lighten(0.05)
    else: bodyColor

  let borderColorHighlighted =
    if button.isDown: borderColor.darken(0.1)
    elif mouseIsInside: borderColor.lighten(0.4)
    else: borderColor

  gfx.drawFrame(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

  button