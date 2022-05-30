{.experimental: "overloadableEnums".}

import ./widget

type
  ButtonColors* = object
    background*: Color
    border*: Color
    text*: Color

  ButtonWidget* = ref object of Widget
    colors*: ButtonColors
    label*: string
    cornerRadius*: float
    isDown*: bool
    onClicked*: proc()
    onPressed*: proc()
    onReleased*: proc()

func newButtonWidget*(): ButtonWidget =
  ButtonWidget(
    colors: ButtonColors(
      background: rgb(33, 38, 45),
      border: rgb(52, 59, 66),
      text: rgb(201, 209, 217),
    ),
    cornerRadius: 5.0,
  )

method update*(button: ButtonWidget) =
  let canvas = button.canvas

  if button.mouseIsOver and canvas.mousePressed(Left):
    button.isDown = true

    if button.onPressed != nil:
      button.onPressed()

  if button.isDown and canvas.mouseReleased(Left):
    button.isDown = false

    if button.onReleased != nil:
      button.onReleased()

    if button.mouseIsOver:
      if button.onClicked != nil:
        button.onClicked()

method draw*(button: ButtonWidget) =
  let canvas = button.canvas
  let bounds = button.bounds

  canvas.saveState()

  canvas.beginPath()
  canvas.roundedRect(bounds, button.cornerRadius)
  canvas.fillColor =
    if button.isDown: button.colors.background.darken(0.3)
    elif button.mouseIsOver: button.colors.background.lighten(0.05)
    else: button.colors.background
  canvas.fill()

  let borderThickness = 1.0
  canvas.beginPath()
  canvas.roundedRect(bounds.expand(-0.5 * borderThickness), button.cornerRadius)
  canvas.strokeColor =
    if button.isDown: button.colors.border.darken(0.1)
    elif button.mouseIsOver: button.colors.border.lighten(0.4)
    else: button.colors.border
  canvas.strokeWidth = borderThickness
  canvas.stroke()

  canvas.fillColor = button.colors.text
  canvas.fontSize = 13
  canvas.drawText(
    canvas.newText button.label,
    bounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  canvas.restoreState()