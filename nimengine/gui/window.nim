import ./widget
import ./container

type
  WindowWidget* = ref object of ContainerWidget
    isGrabbed*: bool

func newWindowWidget*(): WindowWidget =
  WindowWidget()

method update*(window: WindowWidget, input: Input) =
  if window.mouseIsInside(input) and input.justPressed(MouseButton.Left):
    window.isGrabbed = true

  if window.isGrabbed and input.justReleased(MouseButton.Left):
    window.isGrabbed = false

  if window.isGrabbed:
    window.x += input.mouseXChange
    window.y -= input.mouseYChange

  window.updateChildren(input)

method draw*(window: WindowWidget, canvas: Canvas) =
  let x = window.absoluteX
  let y = window.absoluteY

  let color = rgba(0.2, 0.2, 0.2, 1)

  canvas.fillRect(x, y, window.width, window.height, color)
  canvas.strokeRect(x, y, window.width, window.height, color.lightened(0.5), 1.0)

  window.drawChildren(canvas)