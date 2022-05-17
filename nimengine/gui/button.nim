{.experimental: "overloadableEnums".}

import ./theme
import ./widget

type
  ButtonColors* = object
    background*: tuple[r, g, b, a: float]
    hovered*: tuple[r, g, b, a: float]
    down*: tuple[r, g, b, a: float]
    text*: tuple[r, g, b, a: float]

  ButtonWidget* = ref object of Widget
    colors*: ButtonColors
    label*: string
    isDown*: bool
    onClicked*: proc()
    onPressed*: proc()
    onReleased*: proc()

func defaultButtonColors(): ButtonColors =
  ButtonColors(
    background: defaultColors.button,
    hovered: defaultColors.buttonHovered,
    down: defaultColors.buttonDown,
    text: defaultColors.text,
  )

func newButtonWidget*(): ButtonWidget =
  ButtonWidget(colors: defaultButtonColors())

method update*(button: ButtonWidget) =
  let client = button.client

  if button.mouseIsOver and client.mousePressed(Left):
    button.isDown = true

    if button.onPressed != nil:
      button.onPressed()

  if button.isDown and client.mouseReleased(Left):
    button.isDown = false

    if button.onReleased != nil:
      button.onReleased()

    if button.mouseIsOver:
      if button.onClicked != nil:
        button.onClicked()

method draw*(button: ButtonWidget) =
  let canvas = button.canvas
  let x = button.absolutePosition.x
  let y = button.absolutePosition.y
  let w = button.size.x
  let h = button.size.y
  let rect = (position: (x: x, y: y), size: (x: w, y: h))

  let buttonColor =
    if button.isDown: button.colors.down
    elif button.mouseIsOver: button.colors.hovered
    else: button.colors.background

  canvas.fillRect rect, buttonColor
  canvas.drawText(
    button.label,
    rect,
    button.colors.text,
    xAlign = Center,
    yAlign = Center,
    wordWrap = false,
    clip = true,
  )