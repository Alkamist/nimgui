import ./widget

type
  ButtonWidget* = ref object of Widget
    isHovered*: bool
    isPressed*: bool
    wasPressed*: bool
    onPressed*: proc()
    onReleased*: proc()

func newButtonWidget*(theme: Theme): ButtonWidget =
  ButtonWidget(theme: theme)

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
  let theme = button.theme
  let x = button.absoluteX
  let y = button.absoluteY

  let buttonColor =
    if button.isPressed: theme.colors.buttonPressed
    elif button.isHovered: theme.colors.buttonHovered
    else: theme.colors.button

  canvas.fillRect(x, y, button.width, button.height, buttonColor)
  canvas.strokeRect(x, y, button.width, button.height, theme.colors.border, 1.0)