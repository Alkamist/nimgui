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

proc updateButton(widget: GuiWidget, mouseButton: MouseButton) =
  let button = GuiButton(widget)
  let gui = button.gui

  button.justClicked = false
  button.wasDown = button.isDown

  if button.isHovered and gui.mouseJustPressed(mouseButton):
    button.isDown = true

  if button.isDown and gui.mouseJustReleased(mouseButton):
    button.isDown = false
    if button.isHovered:
      button.justClicked = true

  button.updateChildren()

proc drawButton(widget: GuiWidget) =
  let button = GuiButton(widget)
  let gfx = button.gui.gfx
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
    position = vec2(0, 0),
    size = button.size,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

  button.drawChildren()

func addInvisibleButton*(parent: GuiWidget, mouseButton = MouseButton.Left): GuiButton =
  result = parent.addWidget(GuiButton)
  result.size = vec2(96, 32)
  result.update = proc(widget: GuiWidget) =
    widget.updateButton(mouseButton)

func addButton*(parent: GuiWidget, mouseButton = MouseButton.Left): GuiButton =
  result = parent.addWidget(GuiButton)
  result.size = vec2(96, 32)
  result.update = proc(widget: GuiWidget) =
    widget.updateButton(mouseButton)
  result.draw = drawButton