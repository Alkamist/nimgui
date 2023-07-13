import ../gui

type
  Button* = ref object of Widget
    position*: Vec2
    size*: Vec2
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc init*(button: Button) =
  button.size = vec2(96, 32)

proc update*(button: Button, hover, press, release: bool, draw = true) =
  let gui = button.gui

  let isHovered = gui.isHovered(button)
  let mouseIsOver = gui.mouseIsOver(button)

  button.pressed = false
  button.released = false
  button.clicked = false

  if isHovered and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true

    if mouseIsOver:
      button.clicked = true

  if button.pressed:
    gui.captureHover(button)

  if button.released:
    gui.releaseHover(button)

  if hover:
    gui.requestHover(button)

  if draw:
    let path = Path.new()
    path.roundedRect(button.position, button.size, 3)

    gui.fillPath(path, rgb(31, 32, 34))

    if button.isDown:
      gui.fillPath(path, rgba(0, 0, 0, 8))

    elif isHovered:
      gui.fillPath(path, rgba(255, 255, 255, 8))

proc update*(button: Button, mouseButton = MouseButton.Left, draw = true) =
  let gui = button.gui
  button.update(
    hover = gui.mouseHitTest(button.position, button.size),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
    draw = draw,
  )