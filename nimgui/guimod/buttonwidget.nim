{.experimental: "overloadableEnums".}

import ../guimod

type
  ButtonWidget* = ref object of Widget
    label*: string

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

proc button*(gui: Gui, id: string) =
  let b = gui.getWidget(id, ButtonWidget())
  b.label = id