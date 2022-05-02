import ./widget

type
  ButtonWidget* = ref object of Widget
    isHovered*: bool
    isPressed*: bool
    wasPressed*: bool
    onPressed*: proc()
    onReleased*: proc()

func newButtonWidget*(): ButtonWidget =
  ButtonWidget()

method update*(button: ButtonWidget, input: Input) =
  button.wasPressed = button.isPressed

  button.isHovered = button.mouseIsInside(input)

  if button.isHovered and input.justPressed(MouseButton.Left):
    button.isPressed = true
    if button.onPressed != nil:
      button.onPressed()

  if button.isPressed and input.justReleased(MouseButton.Left):
    button.isPressed = false
    if button.onReleased != nil:
      button.onReleased()

method draw*(button: ButtonWidget, canvas: Canvas) =
  let x = button.absoluteX
  let y = button.absoluteY

  let color = rgba(0.5, 0.5, 0.5, 1)

  template drawButton(c: Color): untyped =
    canvas.fillRect(x, y, button.width, button.height, c)
    canvas.strokeRect(x, y, button.width, button.height, c.lightened(0.5), 1.0)

  if button.isPressed:
    drawButton(color.darkened(0.4))
  elif button.isHovered:
    drawButton(color.lightened(0.3))
  else:
    drawButton(color)