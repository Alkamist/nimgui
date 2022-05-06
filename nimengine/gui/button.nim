import ./theme
import ./widget

type
  ButtonColors* = object
    background*: Color
    hovered*: Color
    pressed*: Color

  ButtonWidget* = ref object of Widget
    colors*: ButtonColors
    isHovered*: bool
    isPressed*: bool
    wasPressed*: bool
    onPressed*: proc()
    onReleased*: proc()

func defaultButtonColors(): ButtonColors =
  ButtonColors(
    background: defaultColors.button,
    hovered: defaultColors.buttonHovered,
    pressed: defaultColors.buttonPressed,
  )

func newButtonWidget*(): ButtonWidget =
  ButtonWidget(colors: defaultButtonColors())

method update*(button: ButtonWidget, input: Input) =
  button.wasPressed = button.isPressed

  button.isHovered = button.mouseIsOver(input)

  if button.isHovered and input.mousePressed[left]:
    button.isPressed = true
    if button.onPressed != nil:
      button.onPressed()

  if button.isPressed and input.mouseReleased[left]:
    button.isPressed = false
    if button.onReleased != nil:
      button.onReleased()

method draw*(button: ButtonWidget, canvas: Canvas) =
  let x = button.absoluteX
  let y = button.absoluteY

  let buttonColor =
    if button.isPressed: button.colors.pressed
    elif button.isHovered: button.colors.hovered
    else: button.colors.background

  canvas.fillRect(x, y, button.width, button.height, buttonColor)