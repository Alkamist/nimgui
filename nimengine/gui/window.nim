{.experimental: "overloadableEnums".}

import ./gui

type
  WindowWidgetSignal* = enum
    Open
    Moved

  WindowWidget* = ref object of WidgetContainer
    isBeingMoved*: bool

proc beginWindow*(gui: Gui, id: string): set[WindowWidgetSignal] =
  let window = gui.getWidget(id):
    WindowWidget(
      bounds: rect2(0, 0, 200, 200),
      relativePosition: vec2(25, 25),
    )

  let isHovered = gui.hover == window

  if isHovered and gui.mousePressed(Left):
    window.isBeingMoved = true

  if window.isBeingMoved and gui.mouseReleased(Left):
    window.isBeingMoved = false

  if window.isBeingMoved:
    window.relativePosition += gui.mouseDelta
    result.incl Moved

  let headerBounds = rect2(
    window.position,
    vec2(window.width, 24.0)
  )

  window.draw = proc() =
    let gfx = gui.gfx
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

func endWindow*(gui: Gui) =
  gui.popContainer()

template addWindow*(gui: Gui, id: string, code: untyped) =
  block:
    let signals {.inject.} = gui.beginWindow(id)
    code
    gui.endWindow()