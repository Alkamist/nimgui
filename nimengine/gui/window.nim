{.experimental: "overloadableEnums".}

import ./theme
import ./widget

type
  WindowColors* = object
    background*: tuple[r, g, b, a: float]
    title*: tuple[r, g, b, a: float]
    titleBar*: tuple[r, g, b, a: float]
    border*: tuple[r, g, b, a: float]
    resizeHandle*: tuple[r, g, b, a: float]
    resizeHandleHovered*: tuple[r, g, b, a: float]
    resizeHandlePressed*: tuple[r, g, b, a: float]

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
    resizeMouseStart: tuple[x, y: float]
    resizeSizeStart: tuple[x, y: float]

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

func titleBarRect*(window: WindowWidget): tuple[position, size: tuple[x, y: float]] =
  (window.position, (window.size.x, window.titleBarHeight))

func resizeHandleRect*(window: WindowWidget): tuple[position, size: tuple[x, y: float]] =
  (window.position + window.size - window.resizeHandleSize,
   (window.resizeHandleSize, window.resizeHandleSize))

func bodyRect*(window: WindowWidget): tuple[position, size: tuple[x, y: float]] =
  let rect = window.rect
  let titleBarRect = window.titleBarRect
  (rect.position + (0.0, titleBarRect.size.y),
   rect.size - (0.0, titleBarRect.size.y))

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
    window.titleBarRect.contains(client.mousePosition)

  window.resizeHandleIsHovered =
    window.isResizable and
    window.mouseIsOver and
    window.resizeHandleRect.contains(client.mousePosition)

  # Press title bar.
  if window.titleBarIsHovered and client.mousePressed(Left):
    window.isBeingMoved = true

  # Release title bar.
  if window.isBeingMoved and client.mouseReleased(Left):
    window.isBeingMoved = false

  # Move window.
  if window.isBeingMoved:
    window.relativePosition += client.mouseDelta

  # Press resize handle.
  if window.resizeHandleIsHovered and client.mousePressed(Left):
    window.isBeingResized = true
    window.resizeMouseStart = client.mousePosition
    window.resizeSizeStart = window.size

  # Release resize handle.
  if window.isBeingResized and client.mouseReleased(Left):
    window.isBeingResized = false

  # Resize window.
  if window.isBeingResized:
    let size = window.resizeSizeStart + client.mousePosition - window.resizeMouseStart
    window.size = (size.x.max(window.minWidth), size.y.max(window.minHeight))

  window.updateChildren()

method draw*(window: WindowWidget) =
  let canvas = window.canvas
  let rect = window.rect
  let titleBarRect = window.titleBarRect
  let resizeHandleRect = window.resizeHandleRect

  let parentIsFocused =
    window.parent != nil and
    window.parent.isFocused

  let isTopMost =
    window.parent.children.len > 0 and
    window.parent.children[0] == window

  if parentIsFocused and isTopMost:
    let shadowRect = rect.translate (x: 5.0, y: 5.0)
    let shadowColor = (r: 0.0, g: 0.0, b: 0.0, a: 0.2)
    canvas.fillRect shadowRect, shadowColor

  canvas.fillRect rect, window.colors.background
  canvas.fillRect titleBarRect, window.colors.titleBar

  const titleInset = 10.0
  let titleTextRect = (
    position: titleBarRect.position + (titleInset, 0.0),
    size: titleBarRect.size - (2.0 * titleInset, 0.0),
  )

  canvas.drawText(
    window.title,
    titleTextRect,
    window.colors.title,
    xAlign = Left,
    yAlign = Center,
    wordWrap = false,
    clip = true,
  )

  canvas.pushClipRect window.bodyRect

  window.drawChildren()

  const resizeInset = 4.0
  let resizeLeft = resizeHandleRect.position.x + resizeInset
  let resizeRight = resizeHandleRect.position.x + resizeHandleRect.size.x - resizeInset
  let resizeBottom = resizeHandleRect.position.y + resizeHandleRect.size.y - resizeInset
  let resizeTop = resizeHandleRect.position.y + resizeInset
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

  canvas.outlineRect rect, window.colors.border