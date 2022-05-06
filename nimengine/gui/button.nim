import ./theme
import ./widget

type
  ButtonColors* = object
    background*: Color
    hovered*: Color
    down*: Color

  ButtonWidget* = ref object of Widget
    colors*: ButtonColors
    isDown*: bool
    onClicked*: proc()
    onPressed*: proc()
    onReleased*: proc()

func defaultButtonColors(): ButtonColors =
  ButtonColors(
    background: defaultColors.button,
    hovered: defaultColors.buttonHovered,
    down: defaultColors.buttonDown,
  )

func newButtonWidget*(): ButtonWidget =
  ButtonWidget(colors: defaultButtonColors())

method update*(button: ButtonWidget) =
  if button.mouseIsOver and button.mousePressed[left]:
    button.isDown = true

    if button.onPressed != nil:
      button.onPressed()

  if button.isDown and button.mouseReleased[left]:
    button.isDown = false

    if button.onReleased != nil:
      button.onReleased()

    if button.mouseIsOver:
      if button.onClicked != nil:
        button.onClicked()

method draw*(button: ButtonWidget) =
  let buttonColor =
    if button.isDown: button.colors.down
    elif button.mouseIsOver: button.colors.hovered
    else: button.colors.background

  button.fillRect(0, 0, button.width, button.height, buttonColor)