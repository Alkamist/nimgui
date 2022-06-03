{.experimental: "overloadableEnums".}

import ./widget

type
  WindowColors* = object
    background*: Color
    border*: Color
    titleText*: Color
    titleBackground*: Color

  WindowWidget* = ref object of Widget
    colors*: WindowColors
    title*: string
    titleBarHeight*: float
    resizeHandleSize*: float
    cornerRadius*: float
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

func newWindowWidget*(): WindowWidget =
  WindowWidget(
    colors: WindowColors(
      background: rgb(13, 17, 23),
      border: rgb(52, 59, 66),
      titleText: rgb(201, 209, 217),
      titleBackground: rgb(22, 27, 34),
    ),
    titleBarHeight: 24.0,
    resizeHandleSize: 24.0,
    isMovable: true,
    isResizable: true,
    minWidth: 100,
    minHeight: 60,
    cornerRadius: 5.0,
  )

func titleBarBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position,
    vec2(window.size.x, window.titleBarHeight),
  )

func resizeHandleBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position + window.size - window.resizeHandleSize,
    vec2(window.resizeHandleSize, window.resizeHandleSize),
  )

func bodyBounds*(window: WindowWidget): Rect2 =
  let bounds = window.bounds
  let titleBarBounds = window.titleBarBounds
  rect2(
    bounds.x,
    bounds.y + titleBarBounds.height,
    bounds.width,
    bounds.height - titleBarBounds.height,
  )

method requestFocus*(window: WindowWidget): bool =
  window.canvas.mousePressed(Left) and window.mouseIsOver

method releaseFocus*(window: WindowWidget): bool =
  window.canvas.mousePressed(Left) and not window.mouseIsOver

method update*(window: WindowWidget) =
  let canvas = window.canvas

  window.titleBarIsHovered =
    window.isMovable and
    (not window.isBeingResized) and
    window.mouseIsOver and
    window.titleBarBounds.contains(canvas.mousePosition)

  window.resizeHandleIsHovered =
    window.isResizable and
    window.mouseIsOver and
    window.resizeHandleBounds.contains(canvas.mousePosition)

  # Press title bar.
  if window.titleBarIsHovered and canvas.mousePressed(Left):
    window.isBeingMoved = true

  # Release title bar.
  if window.isBeingMoved and canvas.mouseReleased(Left):
    window.isBeingMoved = false

  # Move window.
  if window.isBeingMoved:
    window.relativePosition += canvas.mouseDelta

  # Press resize handle.
  if window.resizeHandleIsHovered and canvas.mousePressed(Left):
    window.isBeingResized = true
    window.resizeMouseStart = canvas.mousePosition
    window.resizeSizeStart = window.size

  # Release resize handle.
  if window.isBeingResized and canvas.mouseReleased(Left):
    window.isBeingResized = false

  # Resize window.
  if window.isBeingResized:
    let size = window.resizeSizeStart + canvas.mousePosition - window.resizeMouseStart
    window.size = vec2(size.x.max(window.minWidth), size.y.max(window.minHeight))

  window.updateChildren()

method draw*(window: WindowWidget) =
  let canvas = window.canvas
  let bounds = canvas.pixelAlign(window.bounds)
  let titleBarBounds = canvas.pixelAlign(window.titleBarBounds)
  # let resizeHandleBounds = window.resizeHandleBounds

  canvas.saveState()

  let parentIsFocused =
    window.parent != nil and
    window.parent.isFocused

  let isTopMost =
    window.parent.children.len > 0 and
    window.parent.children[0] == window

  let shadowFeather =
    if parentIsFocused and isTopMost: 25.0
    else: 15.0

  # Drop shadow.
  let shadowPaint = canvas.boxGradient(bounds, window.cornerRadius * 2, shadowFeather, rgba(0, 0, 0, 64), rgba(0, 0, 0, 0))
  canvas.beginPath()
  canvas.rect(bounds.expand(shadowFeather).translate(vec2(8, 8)))
  canvas.roundedRect(bounds, window.cornerRadius)
  canvas.pathWinding = Hole
  canvas.fillPaint = shadowPaint
  canvas.fill()

  # Background.
  canvas.beginPath()
  canvas.roundedRect(bounds, window.cornerRadius)
  canvas.fillColor = window.colors.background
  canvas.fill()

  # Title background.
  canvas.beginPath()
  canvas.roundedRect(titleBarBounds, window.cornerRadius, window.cornerRadius, 0, 0)
  canvas.fillColor = window.colors.titleBackground
  canvas.fill()

  # Title text.
  canvas.fontSize = 13
  canvas.fillColor = window.colors.titleText
  canvas.drawText(
    canvas.newText(window.title),
    titleBarBounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  let clipRect = window.bodyBounds.expand(canvas.pixelAlign(-0.5 * window.cornerRadius))
  canvas.clip(clipRect)

  window.drawChildren()

  # const resizeInset = 4.0
  # let resizeLeft = resizeHandleBounds.x + resizeInset
  # let resizeRight = resizeHandleBounds.x + resizeHandleBounds.width - resizeInset
  # let resizeBottom = resizeHandleBounds.y + resizeHandleBounds.height - resizeInset
  # let resizeTop = resizeHandleBounds.y + resizeInset
  # let resizeHandleColor =
  #   if window.isBeingResized: window.colors.resizeHandlePressed
  #   elif window.resizeHandleIsHovered: window.colors.resizeHandleHovered
  #   else: window.colors.resizeHandle

  # canvas.beginPath()
  # canvas.moveTo vec2(resizeLeft, resizeBottom)
  # canvas.lineTo vec2(resizeRight, resizeBottom)
  # canvas.lineTo vec2(resizeRight, resizeTop)
  # canvas.closePath()
  # canvas.fillColor = resizeHandleColor
  # canvas.fill()

  canvas.resetClip()

  # Border.
  let borderThickness = 1.0
  let borderInset = 0.5 * borderThickness
  canvas.beginPath()
  canvas.roundedRect(bounds.expand(-borderInset), window.cornerRadius - borderInset)
  let titleBarBottom = titleBarBounds.y + titleBarBounds.height - 0.5 * borderThickness
  canvas.moveTo(vec2(titleBarBounds.x, titleBarBottom))
  canvas.lineTo(vec2(titleBarBounds.x + titleBarBounds.width, titleBarBottom))
  canvas.strokeWidth = borderThickness
  canvas.strokeColor = window.colors.border
  canvas.stroke()

  canvas.restoreState()