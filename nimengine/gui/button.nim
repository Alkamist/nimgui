{.experimental: "overloadableEnums".}

import ./gui

type
  ButtonWidget* = ref object of Widget
    isDown*: bool
    clicked*: bool
    pressed*: bool
    released*: bool

proc beginButton*(gui: Gui, id: string): ButtonWidget =
  let button = gui.getWidget(id):
    ButtonWidget(
      bounds: rect2(0, 0, 97, 32),
      relativePosition: vec2(25, 25),
    )

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

  button.draw = proc() =
    let gfx = gui.gfx
    gfx.drawFrameWithoutHeader(
      bounds = button.bounds,
      borderThickness = 1.0,
      cornerRadius = 5.0,
      bodyColor = rgb(33, 38, 45),
      borderColor = rgb(52, 59, 66),
    )
    gfx.fontSize = 13
    gfx.fillColor = rgb(201, 209, 217)
    gfx.drawText(
      text = gfx.newText(id),
      bounds = button.bounds,
      alignX = Center,
      alignY = Center,
      wordWrap = false,
      clip = true,
    )

  button

template addButton*(gui: Gui, id: string, code: untyped) =
  block:
    let widget {.inject.} = gui.beginButton(id)
    code