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
    resizeHandlePressed: defaultColors.buttonPressed,
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

method requestFocus*(window: WindowWidget, input: Input): bool =
  input.mousePressed[left] and window.mouseIsOver(input)

method releaseFocus*(window: WindowWidget, input: Input): bool =
  input.mousePressed[left] and not window.mouseIsOver(input)

method update*(window: WindowWidget, input: Input) =
  let mouseX = input.mouseX
  let mouseY = input.mouseY
  let absoluteX = window.absoluteX
  let absoluteY = window.absoluteY
  let mouseIsOver = window.mouseIsOver(input)
  let windowLeft = absoluteX
  let windowRight = windowLeft + window.width
  let windowTop = absoluteY
  let windowBottom = windowTop + window.height
  let titleTop = windowTop
  let titleBottom = titleTop + window.titleBarHeight
  let resizeLeft = windowRight - window.resizeHandleSize
  let resizeRight = windowRight
  let resizeBottom = windowBottom
  let resizeTop = windowBottom - window.resizeHandleSize

  window.titleBarIsHovered =
    window.isMovable and
    (not window.isBeingResized) and
    mouseIsOver and
    mouseX >= windowLeft and mouseX <= windowRight and
    mouseY >= titleTop and mouseY <= titleBottom

  window.resizeHandleIsHovered =
    window.isResizable and
    mouseIsOver and
    mouseX >= resizeLeft and mouseX <= resizeRight and
    mouseY >= resizeTop and mouseY <= resizeBottom

  # Press title bar.
  if window.titleBarIsHovered and input.mousePressed[left]:
    window.isBeingMoved = true

  # Release title bar.
  if window.isBeingMoved and input.mouseReleased[left]:
    window.isBeingMoved = false

  # Move window.
  if window.isBeingMoved:
    window.x += input.mouseXChange
    window.y += input.mouseYChange

  # Press resize handle.
  if window.resizeHandleIsHovered and input.mousePressed[left]:
    window.isBeingResized = true
    window.resizeStartX = mouseX
    window.resizeStartY = mouseY
    window.resizeStartWidth = window.width
    window.resizeStartHeight = window.height

  # Release resize handle.
  if window.isBeingResized and input.mouseReleased[left]:
    window.isBeingResized = false

  # Resize window.
  if window.isBeingResized:
    let resizeWidth = window.resizeStartWidth + (mouseX - window.resizeStartX)
    let resizeHeight = window.resizeStartHeight + (mouseY - window.resizeStartY)
    window.width = resizeWidth.max(window.minWidth)
    window.height = resizeHeight.max(window.minHeight)

  window.updateChildren(input)

method draw*(window: WindowWidget, canvas: Canvas) =
  let x = window.absoluteX
  let y = window.absoluteY

  canvas.pushClipRect(x, y, window.width, window.height)

  # Background and title bar.
  canvas.fillRect(x, y, window.width, window.height, window.colors.background)
  canvas.fillRect(x, y, window.width, window.titleBarHeight, window.colors.titleBar)

  window.drawChildren(canvas)

  # Resize Handle.
  let left = x
  let right = left + window.width
  let top = y
  let bottom = top + window.height
  let resizeInset = 4.0
  let resizeLeft = right - window.resizeHandleSize + resizeInset
  let resizeRight = right - resizeInset
  let resizeBottom = bottom - resizeInset
  let resizeTop = bottom - window.resizeHandleSize + resizeInset
  let resizeHandlePoints = [
    vec2(resizeLeft, resizeBottom),
    vec2(resizeRight, resizeTop),
    vec2(resizeRight, resizeBottom),
  ]
  let resizeHandleColor =
    if window.isBeingResized: window.colors.resizeHandlePressed
    elif window.resizeHandleIsHovered: window.colors.resizeHandleHovered
    else: window.colors.resizeHandle
  canvas.addConvexPoly(resizeHandlePoints, resizeHandleColor, 0.5)

  # Border:
  canvas.strokeRect(x, y, window.width, window.height, window.colors.border, 1.0)

  canvas.popClipRect()