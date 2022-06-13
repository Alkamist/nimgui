{.experimental: "overloadableEnums".}

import ./gui

type
  ButtonWidget* = ref object of Widget
    label*: string
    isDown*: bool
    clicked*: bool
    pressed*: bool
    released*: bool

method draw*(button: ButtonWidget, gui: Gui) =
  let gfx = gui.gfx
  let bounds = button.bounds

  gfx.drawFrameWithoutHeader(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = rgb(33, 38, 45),
    borderColor = rgb(52, 59, 66),
  )

  gfx.fontSize = 13
  gfx.fillColor = rgb(201, 209, 217)
  gfx.drawText(
    text = gfx.newText(button.label),
    bounds = bounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

proc addButton*(gui: Gui, label: string): bool =
  let button = gui.getWidget(label, ButtonWidget())
  button.label = label

  let isHovered = gui.hover == button

  button.clicked = false
  button.pressed = false
  button.released = false

  if isHovered and gui.mousePressed(Left):
    button.isDown = true
    button.pressed = true

  if button.isDown and gui.mouseReleased(Left):
    button.isDown = false
    button.released = true

    if isHovered:
      button.clicked = true

  button.clicked