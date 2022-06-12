{.experimental: "overloadableEnums".}

import ./gui

type
  WindowWidget* = ref object of WidgetContainer
    isOpen*: bool
    moved*: bool

proc beginWindow*(gui: Gui, id: string): WindowWidget =
  result = gui.getWidget(id):
    WindowWidget(
      bounds: rect2(0, 0, 200, 200),
      relativePosition: vec2(25, 25),
    )

  result.isOpen = true

  let isHovered = gui.hover == result

  if isHovered and gui.mousePressed(Left):
    result.moved = true

  if result.moved and gui.mouseReleased(Left):
    result.moved = false

  if result.moved:
    result.relativePosition += gui.mouseDelta

  let bounds = result.bounds
  let headerBounds = rect2(
    bounds.position,
    vec2(bounds.width, 24.0)
  )

  result.draw = proc() =
    let gfx = gui.gfx
    gfx.drawFrameWithHeader(
      bounds = bounds,
      borderThickness = 1.0,
      headerHeight = headerBounds.height,
      cornerRadius = 5.0,
      bodyColor = rgb(13, 17, 23),
      headerColor = rgb(22, 27, 34),
      borderColor = rgb(52, 59, 66),
    )
    gfx.fontSize = 13
    gfx.fillColor = rgb(201, 209, 217)
    gfx.drawText(
      text = gfx.newText(id),
      headerBounds,
      alignX = Center,
      alignY = Center,
      wordWrap = false,
      clip = true,
    )

  gui.pushContainer result

func endWindow*(gui: Gui) =
  gui.popContainer()

template addWindow*(gui: Gui, id: string, code: untyped) =
  block:
    let widget {.inject.} = gui.beginWindow(id)
    code
    gui.endWindow()