{.experimental: "overloadableEnums".}

import ../guimod
import ./frame

type
  ButtonWidget* = ref object of Widget
    isDown*: bool
    wasDown*: bool
    clicked*: bool
    activate*: bool
    deactivate*: bool

template pressed*(button: ButtonWidget): bool = button.isDown and not button.wasDown
template released*(button: ButtonWidget): bool = button.wasDown and not button.isDown

func initialize*(button: ButtonWidget) =
  button.size = vec2(96, 32)

func update*(button: ButtonWidget) =
  button.clicked = false
  button.wasDown = button.isDown

  if button.isHovered and button.activate:
    button.isDown = true

  if button.isDown and button.deactivate:
    button.isDown = false
    if button.isHovered:
      button.clicked = true

func draw*(button: ButtonWidget) =
  let gfx = button.gfx
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
    bounds = button.absoluteBounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )