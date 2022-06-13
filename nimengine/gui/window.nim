{.experimental: "overloadableEnums".}

import ./gui

type
  WindowWidget* = ref object of WidgetContainer
    isOpen*: bool
    headerIsHovered*: bool
    headerIsGrabbed*: bool
    resizeHandleIsHovered*: bool
    resizeHandleIsGrabbed*: bool
    moved*: bool

proc headerBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position,
    vec2(window.width, 24.0)
  )

proc resizeHandleBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position + window.size - 24.0,
    vec2(24.0, 24.0),
  )

method draw*(window: WindowWidget, gui: Gui) =
  let gfx = gui.gfx
  let bounds = window.bounds
  let headerBounds = rect2(
    bounds.position,
    vec2(bounds.width, 24.0)
  )

  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = 1.0,
    headerHeight = headerBounds.height,
    cornerRadius = 5.0,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )
  # gfx.fontSize = 13
  # gfx.fillColor = rgb(201, 209, 217)
  # gfx.drawText(
  #   text = gfx.newText("Window"),
  #   headerBounds,
  #   alignX = Center,
  #   alignY = Center,
  #   wordWrap = false,
  #   clip = true,
  # )

  gfx.saveState()
  gfx.clip(bounds)
  gui.drawChildrenInRows(window)
  gfx.restoreState()

proc beginWindow*(gui: Gui, id: string): WindowWidget =
  let window = gui.getWidget(id):
    WindowWidget(
      isFreelyPositionable: true,
      bounds: rect2(0, 0, 200, 200),
      relativePosition: vec2(25, 25),
    )

  let isHovered = gui.hover == window

  window.isOpen = true

  window.headerIsHovered =
    not window.headerIsGrabbed and
    isHovered and
    window.headerBounds.contains(gui.mousePosition)

  # window.resizeHandleIsHovered =
  #   window.isResizable and
  #   window.mouseIsOver and
  #   window.resizeHandleBounds.contains(canvas.mousePosition)

  if window.headerIsHovered and gui.mousePressed(Left):
    window.headerIsGrabbed = true

  if window.headerIsGrabbed and gui.mouseReleased(Left):
    window.headerIsGrabbed = false

  if window.headerIsGrabbed and gui.mouseMoved:
    window.relativePosition += gui.mouseDelta
    window.moved = true

  gui.pushContainer window

func endWindow*(gui: Gui) =
  gui.popContainer()

# template addWindow*(gui: Gui, id: string, code: untyped) =
#   block:
#     let widget {.inject.} = gui.beginWindow(id)
#     code
#     gui.endWindow()