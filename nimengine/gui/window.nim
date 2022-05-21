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
    resizeMouseStart: Vec2
    resizeSizeStart: Vec2

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

func titleBarRect*(window: WindowWidget): Rect2 =
  rect2(
    window.position,
    vec2(window.size.x, window.titleBarHeight),
  )

func resizeHandleRect*(window: WindowWidget): Rect2 =
  rect2(
    window.position + window.size - window.resizeHandleSize,
    vec2(window.resizeHandleSize, window.resizeHandleSize),
  )

func bodyRect*(window: WindowWidget): Rect2 =
  let rect = window.rect
  let titleBarRect = window.titleBarRect
  rect2(
    rect.position.x,
    rect.position.y + titleBarRect.size.y,
    rect.size.x,
    rect.size.y - titleBarRect.size.y,
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
    window.size = vec2(size.x.max(window.minWidth), size.y.max(window.minHeight))

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
    let shadowRect = rect.translate vec2(5, 5)
    let shadowColor = color(0, 0, 0, 0.2)
    canvas.fillRect shadowRect, shadowColor

  canvas.fillRect rect, window.colors.background
  canvas.fillRect titleBarRect, window.colors.titleBar

  const titleInset = 10.0
  let titleTextRect = rect2(
    titleBarRect.position + vec2(titleInset, 0),
    titleBarRect.size - vec2(2.0 * titleInset, 0),
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
    vec2(resizeLeft, resizeBottom),
    vec2(resizeRight, resizeTop),
    vec2(resizeRight, resizeBottom),
  ]
  let resizeHandleColor =
    if window.isBeingResized: window.colors.resizeHandlePressed
    elif window.resizeHandleIsHovered: window.colors.resizeHandleHovered
    else: window.colors.resizeHandle
  canvas.fillConvexPoly(resizeHandlePoints, resizeHandleColor)

  canvas.popClipRect()

  canvas.strokeRect rect, window.colors.border, canvas.pixelThickness * canvas.scale.round.max(1.0)