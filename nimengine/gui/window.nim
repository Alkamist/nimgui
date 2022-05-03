import ./theme
import ./widget
import ./container

type
  WindowColors* = object
    background*: Color
    border*: Color
    titleBar*: Color
    titleBarHovered*: Color
    titleBarPressed*: Color
    resizeHandle*: Color
    resizeHandleHovered*: Color
    resizeHandlePressed*: Color

  WindowWidget* = ref object of ContainerWidget
    colors*: WindowColors
    titleBarHeight*: float
    resizeHandleSize*: float
    minWidth*: float
    minHeight*: float
    isMovable*: bool
    isResizable*: bool
    isBeingMoved: bool
    isBeingResized: bool
    resizeHandleIsHovered: bool
    titleBarIsHovered: bool
    resizeStartX: float
    resizeStartY: float
    resizeStartWidth: float
    resizeStartHeight: float

func defaultWindowColors(): WindowColors =
  WindowColors(
    background: defaultColors.background,
    border: defaultColors.border,
    titleBar: defaultColors.primary,
    titleBarHovered: defaultColors.primary.lightened(0.2),
    titleBarPressed: defaultColors.primary.darkened(0.5),
    resizeHandle: defaultColors.primary,
    resizeHandleHovered: defaultColors.primary.lightened(0.2),
    resizeHandlePressed: defaultColors.primary.darkened(0.5),
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

method update*(window: WindowWidget, input: Input) =
  let mouseX = input.mouseX
  let mouseY = input.mouseY
  let absoluteX = window.absoluteX
  let absoluteY = window.absoluteY
  let mouseIsInsideParent =
    if window.parent.isNil: true
    else:
      window.parent.absolutePointIsInside(mouseX, mouseY)

  let left = absoluteX
  let right = left + window.width
  let top = absoluteY
  let bottom = top + window.height

  # Moving:

  let titleTop = top
  let titleBottom = titleTop + window.titleBarHeight

  window.titleBarIsHovered =
    window.isMovable and
    (not window.isBeingResized) and
    mouseIsInsideParent and
    mouseX >= left and mouseX <= right and
    mouseY >= titleTop and mouseY <= titleBottom

  if window.titleBarIsHovered and
     input.justPressed(MouseButton.Left):
    window.isBeingMoved = true

  if window.isBeingMoved and input.justReleased(MouseButton.Left):
    window.isBeingMoved = false

  if window.isBeingMoved:
    window.x += input.mouseXChange
    window.y += input.mouseYChange

  # Resizing:

  let resizeLeft = right - window.resizeHandleSize
  let resizeRight = right
  let resizeBottom = bottom
  let resizeTop = bottom - window.resizeHandleSize

  let mouseIsInsideResizeHandle =
    mouseIsInsideParent and
    mouseX >= resizeLeft and mouseX <= resizeRight and
    mouseY >= resizeTop and mouseY <= resizeBottom

  window.resizeHandleIsHovered =
    window.isResizable and mouseIsInsideResizeHandle

  if window.resizeHandleIsHovered and input.justPressed(MouseButton.Left):
    window.isBeingResized = true
    window.resizeStartX = mouseX
    window.resizeStartY = mouseY
    window.resizeStartWidth = window.width
    window.resizeStartHeight = window.height

  if window.isBeingResized and input.justReleased(MouseButton.Left):
    window.isBeingResized = false

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

  # Backgrounds:
  let titleBarColor =
    if window.isBeingMoved: window.colors.titleBarPressed
    elif window.titleBarIsHovered: window.colors.titleBarHovered
    else: window.colors.titleBar
  canvas.fillRect(x, y, window.width, window.height, window.colors.background)
  canvas.fillRect(x, y, window.width, window.titleBarHeight, titleBarColor)

  window.drawChildren(canvas)

  # Resize Handle:
  let left = x
  let right = left + window.width
  let top = y
  let bottom = top + window.height
  let resizeInset = 3.0
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