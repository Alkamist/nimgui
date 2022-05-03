import ./widget
import ./container

const resizeHandleSize = 24.0

type
  WindowWidget* = ref object of ContainerWidget
    isMovable*: bool
    isResizable*: bool
    isBeingMoved: bool
    isBeingResized: bool
    resizeHandleIsHovered: bool

func newWindowWidget*(theme: Theme): WindowWidget =
  WindowWidget(
    theme: theme,
    isMovable: true,
    isResizable: true,
  )

method update*(window: WindowWidget, input: Input) =
  let theme = window.theme
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
  let titleBottom = titleTop + theme.titleBarHeight

  let mouseIsInsideTitleBar =
    mouseIsInsideParent and
    mouseX >= left and mouseX <= right and
    mouseY >= titleTop and mouseY <= titleBottom

  if window.isMovable and mouseIsInsideTitleBar and
     input.justPressed(MouseButton.Left):
    window.isBeingMoved = true

  if window.isBeingMoved and input.justReleased(MouseButton.Left):
    window.isBeingMoved = false

  if window.isBeingMoved:
    window.x += input.mouseXChange
    window.y += input.mouseYChange

  # Resizing:

  let resizeLeft = right - resizeHandleSize
  let resizeRight = right
  let resizeBottom = bottom
  let resizeTop = bottom - resizeHandleSize

  let mouseIsInsideResizeHandle =
    mouseIsInsideParent and
    mouseX >= resizeLeft and mouseX <= resizeRight and
    mouseY >= resizeTop and mouseY <= resizeBottom

  window.resizeHandleIsHovered = window.isResizable and mouseIsInsideResizeHandle

  if window.resizeHandleIsHovered and input.justPressed(MouseButton.Left):
    window.isBeingResized = true

  if window.isBeingResized and input.justReleased(MouseButton.Left):
    window.isBeingResized = false

  if window.isBeingResized:
    window.width += input.mouseXChange
    window.height += input.mouseYChange

  window.updateChildren(input)

method draw*(window: WindowWidget, canvas: Canvas) =
  let theme = window.theme
  let x = window.absoluteX
  let y = window.absoluteY

  # Backgrounds:
  canvas.fillRect(x, y, window.width, window.height, theme.colors.windowBackground)
  canvas.fillRect(x, y, window.width, theme.titleBarHeight, theme.colors.titleBackground)

  # Resize Handle:
  let left = x
  let right = left + window.width
  let top = y
  let bottom = top + window.height
  let resizeInset = 3.0
  let resizeLeft = right - resizeHandleSize + resizeInset
  let resizeRight = right - resizeInset
  let resizeBottom = bottom - resizeInset
  let resizeTop = bottom - resizeHandleSize + resizeInset
  let resizeHandlePoints = [
    vec2(resizeLeft, resizeBottom),
    vec2(resizeRight, resizeTop),
    vec2(resizeRight, resizeBottom),
  ]
  let resizeHandleColor =
    if window.isBeingResized: theme.colors.buttonPressed
    elif window.resizeHandleIsHovered: theme.colors.buttonHovered
    else: theme.colors.button
  canvas.addConvexPoly(resizeHandlePoints, resizeHandleColor, 0.5)

  # Borders:
  canvas.strokeRect(x, y, window.width, window.height, theme.colors.border, 1.0)
  canvas.strokeRect(x, y, window.width, theme.titleBarHeight, theme.colors.border, 1.0)

  window.drawChildren(canvas)