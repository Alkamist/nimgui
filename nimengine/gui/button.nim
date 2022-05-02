import ./gui

type
  Button* = ref object of Widget
    isPressed*: bool
    wasPressed*: bool
    onPressed*: proc()
    onReleased*: proc()

func newButton*(): Button =
  Button()

method update*(button: Button) =
  let input = button.input

  button.wasPressed = button.isPressed

  if input.justPressed(MouseButton.Left):
    echo "Yee"

  if button.mouseIsInside and
     input.justPressed(MouseButton.Left):
    button.isPressed = true
    if button.onPressed != nil:
      button.onPressed()

  if input.justReleased(MouseButton.Left):
    button.isPressed = false
    if button.onReleased != nil:
      button.onReleased()

method draw*(button: Button) =
  let canvas = button.canvas
  let x = button.absoluteX
  let y = button.absoluteY

  let color = rgba(0.5, 0.5, 0.5, 1)

  template fill(c: Color): untyped =
    canvas.fillRect(x, y, button.width, button.height, c)

  template stroke(c: Color): untyped =
    canvas.strokeRect(x, y, button.width, button.height, c, 1.0)

  fill(color)
  stroke(color.lightened(0.5))

  if button.isPressed:
    fill(rgba(0, 0, 0, 0.4))
  elif button.mouseIsInside:
    fill(rgba(1, 1, 1, 0.2))