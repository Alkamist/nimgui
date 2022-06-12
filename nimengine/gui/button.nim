{.experimental: "overloadableEnums".}

import ./gui

type
  ButtonWidget* = ref object of Widget
    isDown*: bool
    clicked*: bool
    pressed*: bool
    released*: bool

proc beginButton*(gui: Gui, id: string): ButtonWidget =
  result = gui.getWidget(id):
    ButtonWidget(
      bounds: rect2(0, 0, 97, 32),
      relativePosition: vec2(25, 25),
    )

  let isHovered = gui.hover == result

  result.clicked = false
  result.pressed = false
  result.released = false

  if isHovered and gui.mousePressed(Left):
    result.isDown = true
    result.pressed = true

  if result.isDown and gui.mouseReleased(Left):
    result.isDown = false
    result.released = true
    if isHovered:
      result.clicked = true

  let bounds = result.bounds
  result.draw = proc() =
    let gfx = gui.gfx
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
      text = gfx.newText(id),
      bounds = bounds,
      alignX = Center,
      alignY = Center,
      wordWrap = false,
      clip = true,
    )

template addButton*(gui: Gui, id: string, code: untyped) =
  block:
    let widget {.inject.} = gui.beginButton(id)
    code