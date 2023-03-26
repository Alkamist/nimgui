{.experimental: "overloadableEnums".}

import ./frame
import ../guimod

template buttonBehavior*(button, isHovered, activate, deactivate: untyped): untyped =
  button.clicked = false
  button.wasDown = button.isDown

  if isHovered and activate:
    button.isDown = true

  if button.isDown and deactivate:
    button.isDown = false
    if isHovered:
      button.clicked = true



type
  InvisibleButtonWidget* = ref object of Widget
    isDown*: bool
    wasDown*: bool
    clicked*: bool

template pressed*(button: InvisibleButtonWidget): bool = button.isDown and not button.wasDown
template released*(button: InvisibleButtonWidget): bool = button.wasDown and not button.isDown

proc addInvisibleButton*(gui: Gui, id: WidgetId): InvisibleButtonWidget {.discardable.} =
  let button = gui.addWidget(id, InvisibleButtonWidget)
  let isHovered = gui.isHovered(button)
  buttonBehavior(button, isHovered, gui.mousePressed(Left), gui.mouseReleased(Left))



type
  ButtonWidget* = ref object of Widget
    isDown*: bool
    wasDown*: bool
    clicked*: bool

template pressed*(button: ButtonWidget): bool = button.isDown and not button.wasDown
template released*(button: ButtonWidget): bool = button.wasDown and not button.isDown

proc addButton*(gui: Gui, id: WidgetId): ButtonWidget {.discardable.} =
  let button = gui.addWidget(id, ButtonWidget)
  let isHovered = gui.isHovered(button)

  buttonBehavior(button, isHovered, gui.mousePressed(Left), gui.mouseReleased(Left))

  let gfx = button.container.drawList
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
    bounds = button.absoluteBounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

  button