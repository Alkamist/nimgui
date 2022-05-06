{.experimental: "overloadableEnums".}

import ./theme
import ./widget

type
  WindowColors* = object
    background*: Color
    titleBar*: Color
    border*: Color
    resizeHandle*: Color
    resizeHandleHovered*: Color
    resizeHandlePressed*: Color

  WindowWidget* = ref object of Widget
    colors*: WindowColors
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
  window.mousePressed[left] and window.mouseIsOver

method releaseFocus*(window: WindowWidget): bool =
  window.mousePressed[left] and not window.mouseIsOver

method update*(window: WindowWidget) =
  window.titleBarIsHovered =
    window.isMovable and
    (not window.isBeingResized) and
    window.mouseIsOver and
    window.mouseX >= 0 and window.mouseX <= window.width and
    window.mouseY >= 0 and window.mouseY <= window.titleBarHeight

  window.resizeHandleIsHovered =
    window.isResizable and
    window.mouseIsOver and
    window.mouseX >= (window.width - window.resizeHandleSize) and window.mouseX <= window.width and
    window.mouseY >= (window.height - window.resizeHandleSize) and window.mouseY <= window.height

  # Press title bar.
  if window.titleBarIsHovered and window.mousePressed[left]:
    window.isBeingMoved = true

  # Release title bar.
  if window.isBeingMoved and window.mouseReleased[left]:
    window.isBeingMoved = false

  # Move window.
  if window.isBeingMoved:
    window.x += window.mouseXChange
    window.y += window.mouseYChange

  # Press resize handle.
  if window.resizeHandleIsHovered and window.mousePressed[left]:
    window.isBeingResized = true
    window.resizeStartX = window.mouseX
    window.resizeStartY = window.mouseY
    window.resizeStartWidth = window.width
    window.resizeStartHeight = window.height

  # Release resize handle.
  if window.isBeingResized and window.mouseReleased[left]:
    window.isBeingResized = false

  # Resize window.
  if window.isBeingResized:
    let resizeWidth = window.resizeStartWidth + (window.mouseX - window.resizeStartX)
    let resizeHeight = window.resizeStartHeight + (window.mouseY - window.resizeStartY)
    window.width = resizeWidth.max(window.minWidth)
    window.height = resizeHeight.max(window.minHeight)

  window.updateChildren()

method draw*(window: WindowWidget) =
  window.pushClipRect()

  # Background and title bar.
  window.fillRect(0, 0, window.width, window.height, window.colors.background)
  window.fillRect(0, 0, window.width, window.titleBarHeight, window.colors.titleBar)

  window.drawChildren()

  # Resize Handle.
  let resizeInset = 4.0
  let resizeLeft = window.x + window.width - window.resizeHandleSize + resizeInset
  let resizeRight = window.x + window.width - resizeInset
  let resizeBottom = window.y + window.height - resizeInset
  let resizeTop = window.y + window.height - window.resizeHandleSize + resizeInset
  let resizeHandlePoints = [
    vec2(resizeLeft, resizeBottom),
    vec2(resizeRight, resizeTop),
    vec2(resizeRight, resizeBottom),
  ]
  let resizeHandleColor =
    if window.isBeingResized: window.colors.resizeHandlePressed
    elif window.resizeHandleIsHovered: window.colors.resizeHandleHovered
    else: window.colors.resizeHandle
  window.canvas.addConvexPoly(resizeHandlePoints, resizeHandleColor)

  # Border:
  window.strokeRect(0, 0, window.width, window.height, window.colors.border, 1.0)

  window.popClipRect()