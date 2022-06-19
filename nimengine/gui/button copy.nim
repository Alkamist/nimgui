{.experimental: "overloadableEnums".}

import ./widget; export widget
import ./frame

type
  GuiButton* = ref object of Widget
    label*: string
    mouseTriggers*: set[MouseButton]
    isDown*: bool
    wasDown*: bool

template pressed*(button: GuiButton): bool =
  button.isDown and not button.wasDown

template released*(button: GuiButton): bool =
  button.wasDown and not button.isDown

template clicked*(button: GuiButton): bool =
  button.isHovered and button.released

method update*(button: GuiButton, window: Window) =
  button.updateWidget(window)
  button.wasDown = button.isDown

  button.isDown = false
  for mb in MouseButton:
    if button.mouseTriggers.contains(mb) and button.mouseDown(mb):
      button.isDown = true
      break

method draw*(button: GuiButton, window: Window) =
  let gfx = window.gfx
  let bounds = button.bounds.pixelAlign(gfx)

  gfx.saveState()

  let bodyColor =
    if button.isDown: rgb(57, 57, 57).darken(0.3)
    elif button.isHovered: rgb(57, 57, 57).lighten(0.1)
    else: rgb(57, 57, 57)

  let borderColor =
    if button.isDown: rgb(57, 57, 57).lighten(0.3).darken(0.3)
    elif button.isHovered: rgb(57, 57, 57).lighten(0.3).lighten(0.1)
    else: rgb(57, 57, 57).lighten(0.3)

  gfx.drawFrameWithoutHeader(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColor,
    borderColor = borderColor,
  )

  gfx.fontSize = 13
  gfx.fillColor = rgb(200, 200, 200)
  gfx.drawText(
    text = gfx.newText(button.label),
    bounds = bounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  gfx.restoreState()