import ../gui

type
  Button* = ref object
    gui*: Gui
    position*: Vec2
    size*: Vec2
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc init*(button: Button) =
  button.size = vec2(96, 32)

proc draw*(button: Button) =
  let gui = button.gui

  let path = Path.new()
  path.roundedRect(button.position, button.size, 3)

  gui.fillPath(path, rgb(31, 32, 34))

  if button.isDown:
    gui.fillPath(path, rgba(0, 0, 0, 8))

  elif gui.isHovered(button):
    gui.fillPath(path, rgba(255, 255, 255, 8))

proc update*(button: Button, hover, press, release: bool) =
  let gui = button.gui

  button.pressed = false
  button.released = false
  button.clicked = false

  if gui.isHovered(button) and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true

    if gui.mouseIsOver(button):
      button.clicked = true

  if button.pressed:
    gui.captureHover(button)

  if button.released:
    gui.releaseHover(button)

  if hover:
    gui.requestHover(button)

proc update*(button: Button, mouseButton = MouseButton.Left) =
  let gui = button.gui

  button.update(
    hover = gui.mouseHitTest(button.position, button.size),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )