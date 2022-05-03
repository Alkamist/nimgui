import ./widget
import ./container

type
  WindowWidget* = ref object of ContainerWidget
    isMovable*: bool
    isResizable*: bool
    isBeingMoved: bool
    isBeingResized: bool

func newWindowWidget*(theme: Theme): WindowWidget =
  WindowWidget(
    theme: theme,
    isMovable: true,
    isResizable: true,
  )

method update*(window: WindowWidget, input: Input) =
  const resizeHandleSize = 24
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

  if window.isResizable and mouseIsInsideResizeHandle and
    input.justPressed(MouseButton.Left):
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

  canvas.fillRect(x, y, window.width, window.height, theme.colors.windowBackground)
  canvas.strokeRect(x, y, window.width, window.height, theme.colors.border, 1.0)

  canvas.fillRect(x, y, window.width, theme.titleBarHeight, theme.colors.titleBackground)
  canvas.strokeRect(x, y, window.width, theme.titleBarHeight, theme.colors.border, 1.0)

  window.drawChildren(canvas)