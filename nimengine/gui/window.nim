{.experimental: "overloadableEnums".}

import ./theme
import ./widget

type
  WindowColors* = object
    background*: Color
    title*: Color
    titleBar*: Color
    border*: Color
    resizeHandle*: Color
    resizeHandleHovered*: Color
    resizeHandlePressed*: Color

  WindowWidget* = ref object of Widget
    colors*: WindowColors
    title*: string
    titleBarHeight*: float
    resizeHandleSize*: float
    minWidth*: float
    minHeight*: float
    isMovable*: bool
    isResizable*: bool
    isBeingMoved*: bool
    isBeingResized*: bool
    resizeHandleIsHovered: bool
    titleBarIsHovered: bool
    resizeStartX: float
    resizeStartY: float
    resizeStartWidth: float
    resizeStartHeight: float

func defaultWindowColors(): WindowColors =
  WindowColors(
    background: defaultColors.main,
    title: defaultColors.text,
    titleBar: defaultColors.dark,
    border: defaultColors.border,
    resizeHandle: defaultColors.button,
    resizeHandleHovered: defaultColors.buttonHovered,
    resizeHandlePressed: defaultColors.buttonDown,
  )

func newWindowWidget*(): WindowWidget =
  WindowWidget(
    colors: defaultWindowColors(),
    titleBarHeight: 24.0,
    resizeHandleSize: 24.0,
    isMovable: true,
    isResizable: true,
    minWidth: 100,
    minHeight: 60,
  )

method requestFocus*(window: WindowWidget): bool =
  window.client.mousePressed(Left) and window.mouseIsOver

method releaseFocus*(window: WindowWidget): bool =
  window.client.mousePressed(Left) and not window.mouseIsOver

method update*(window: WindowWidget) =
  let client = window.client

  window.titleBarIsHovered =
    window.isMovable and
    (not window.isBeingResized) and
    window.mouseIsOver and
    window.mousePosition.x >= 0 and window.mousePosition.x <= window.size.x and
    window.mousePosition.y >= 0 and window.mousePosition.y <= window.titleBarHeight

  window.resizeHandleIsHovered =
    window.isResizable and
    window.mouseIsOver and
    window.mousePosition.x >= (window.size.x - window.resizeHandleSize) and window.mousePosition.x <= window.size.x and
    window.mousePosition.y >= (window.size.y - window.resizeHandleSize) and window.mousePosition.y <= window.size.y

  # Press title bar.
  if window.titleBarIsHovered and client.mousePressed(Left):
    window.isBeingMoved = true

  # Release title bar.
  if window.isBeingMoved and client.mouseReleased(Left):
    window.isBeingMoved = false

  # Move window.
  if window.isBeingMoved:
    window.position.x += client.mouseDelta.x
    window.position.y += client.mouseDelta.y

  # Press resize handle.
  if window.resizeHandleIsHovered and client.mousePressed(Left):
    window.isBeingResized = true
    window.resizeStartX = window.mousePosition.x
    window.resizeStartY = window.mousePosition.y
    window.resizeStartWidth = window.size.x
    window.resizeStartHeight = window.size.y

  # Release resize handle.
  if window.isBeingResized and client.mouseReleased(Left):
    window.isBeingResized = false

  # Resize window.
  if window.isBeingResized:
    let resizeWidth = window.resizeStartWidth + (window.mousePosition.x - window.resizeStartX)
    let resizeHeight = window.resizeStartHeight + (window.mousePosition.y - window.resizeStartY)
    window.size.x = resizeWidth.max(window.minWidth)
    window.size.y = resizeHeight.max(window.minHeight)

  window.updateChildren()

method draw*(window: WindowWidget) =
  let canvas = window.canvas
  let x = window.absolutePosition.x
  let y = window.absolutePosition.y
  let w = window.size.x
  let h = window.size.y

  let parentIsFocused =
    window.parent != nil and
    window.parent.isFocused

  let isTopMost =
    window.parent.children.len > 0 and
    window.parent.children[0] == window

  if parentIsFocused and isTopMost:
    canvas.fillRect (x + 5, y + 5, w, h), (r: 0.0, g: 0.0, b: 0.0, a: 0.2)

  canvas.outlineRect (x, y, w, h), window.colors.border

  let body = (
    x: x + 1,
    y: y + window.titleBarHeight,
    width: w - 2,
    height: h - window.titleBarHeight - 1,
  )
  let titleBar = (
    x: x + 1,
    y: y + 1,
    width: w - 2,
    height: window.titleBarHeight - 1,
  )

  canvas.fillRect titleBar, window.colors.titleBar

  const titleInset = 10.0
  canvas.drawText(
    window.title,
    (titleBar.x + titleInset, titleBar.y, titleBar.width - titleInset * 2.0, titleBar.height),
    window.colors.title,
    xAlign = Left,
    yAlign = Center,
    wordWrap = false,
    clip = true,
  )

  canvas.pushClipRect body

  canvas.fillRect body, window.colors.background

  window.drawChildren()

  const resizeInset = 4.0
  let resizeLeft = x + w - window.resizeHandleSize + resizeInset
  let resizeRight = x + w - resizeInset
  let resizeBottom = y + h - resizeInset
  let resizeTop = y + h - window.resizeHandleSize + resizeInset
  let resizeHandlePoints = [
    (resizeLeft, resizeBottom),
    (resizeRight, resizeTop),
    (resizeRight, resizeBottom),
  ]
  let resizeHandleColor =
    if window.isBeingResized: window.colors.resizeHandlePressed
    elif window.resizeHandleIsHovered: window.colors.resizeHandleHovered
    else: window.colors.resizeHandle
  canvas.fillConvexPoly(resizeHandlePoints, resizeHandleColor)

  canvas.popClipRect()