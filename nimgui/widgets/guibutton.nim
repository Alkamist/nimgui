{.experimental: "overloadableEnums".}

import ../guimod

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
    if button.isDown: rgb(36, 37, 43).darken(0.3)
    elif button.isHovered: rgb(36, 37, 43).lighten(0.05)
    else: rgb(36, 37, 43)

  # let borderColorHighlighted =
  #   if button.isDown: borderColor.darken(0.1)
  #   elif button.isHovered: borderColor.lighten(0.4)
  #   else: borderColor

  const cornerRadius = 4.0
  let buttonPaint = gfx.linearGradient(
    vec2(0, 0), vec2(0, button.height),
    rgba(255, 255, 255, 16), rgba(0, 0, 0, 16),
  )
  gfx.beginPath()
  gfx.roundedRect(vec2(1, 1), button.size - 2, cornerRadius - 1.0)
  gfx.fillColor = bodyColorHighlighted
  gfx.fill()
  gfx.fillPaint = buttonPaint
  gfx.fill()

  gfx.beginPath()
  gfx.roundedRect(vec2(0.5, 0.5), button.size - 1, cornerRadius - 0.5)
  gfx.strokeColor = rgba(0, 0, 0, 48)
  gfx.stroke()

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