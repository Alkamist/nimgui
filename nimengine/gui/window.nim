{.experimental: "overloadableEnums".}

import ./gui

type
  WindowWidget* = ref object of WidgetContainer
    isOpen*: bool
    moved*: bool

proc beginWindow*(gui: Gui, id: string): WindowWidget =
  let window = gui.getWidget(id):
    WindowWidget(
      bounds: rect2(0, 0, 200, 200),
      relativePosition: vec2(25, 25),
    )

  window.isOpen = true

  let isHovered = gui.hover == window

  if isHovered and gui.mousePressed(Left):
    window.moved = true

  if window.moved and gui.mouseReleased(Left):
    window.moved = false

  if window.moved:
    window.relativePosition += gui.mouseDelta

  window.draw = proc() =
    let gfx = gui.gfx
    let headerBounds = rect2(
      window.position,
      vec2(window.width, 24.0)
    )
    gfx.drawFrameWithHeader(
      bounds = window.bounds,
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

  gui.pushContainer window

  window

func endWindow*(gui: Gui) =
  gui.popContainer()

template addWindow*(gui: Gui, id: string, code: untyped) =
  block:
    let widget {.inject.} = gui.beginWindow(id)
    code
    gui.endWindow()