{.experimental: "overloadableEnums".}

import ./gui

type
  ButtonWidgetSignal* = enum
    Down
    Pressed
    Released
    Clicked

  ButtonWidget* = ref object of Widget
    isDown*: bool

proc button*(gui: Gui, id: string): set[ButtonWidgetSignal] =
  let button = gui.getWidget(id):
    ButtonWidget(bounds: rect2(50, 50, 97, 32))

  let isHovered = gui.isHovered(button)

  if button.isDown:
    result.incl Down

  if isHovered and gui.mousePressed(Left):
    button.isDown = true
    result.incl Pressed

  if button.isDown and gui.mouseReleased(Left):
    button.isDown = false
    result.incl Released
    if isHovered:
      result.incl Clicked

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