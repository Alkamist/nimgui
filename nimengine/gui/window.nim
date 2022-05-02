import ./widget
import ./container

type
  WindowWidget* = ref object of ContainerWidget
    isGrabbed: bool

func newWindowWidget*(): WindowWidget =
  WindowWidget()

method update*(window: WindowWidget) =
  let input = window.input

  if window.mouseIsInside and
     input.justPressed(MouseButton.Left):
    window.isGrabbed = true

  if window.isGrabbed and
     input.justReleased(MouseButton.Left):
    window.isGrabbed = false

  if window.isGrabbed:
    window.x += input.mouseXChange
    window.y -= input.mouseYChange

  window.updateWidgets()

method draw*(window: WindowWidget) =
  let canvas = window.canvas
  let x = window.absoluteX
  let y = window.absoluteY

  let color = rgba(0.2, 0.2, 0.2, 1)

  canvas.fillRect(x, y, window.width, window.height, color)
  canvas.strokeRect(x, y, window.width, window.height, color.lightened(0.5), 1.0)

  window.drawWidgets()