import ../gui

type
  Button* = ref object of Widget
    position*: Vec2
    size* = vec2(96, 32)
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc draw*(button: Button) =
  let window = gui.currentWindow

  let path = Path.new()
  path.roundedRect(button.position, button.size, 3)

  window.fillPath(path, rgb(31, 32, 34))

  if button.isDown:
    window.fillPath(path, rgba(0, 0, 0, 8))

  elif window.isHovered(button):
    window.fillPath(path, rgba(255, 255, 255, 8))

proc update*(button: Button, hover, press, release: bool) =
  let window = gui.currentWindow

  button.pressed = false
  button.released = false
  button.clicked = false

  if window.isHovered(button) and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true

    if window.mouseIsOver(button):
      button.clicked = true

  if button.pressed:
    window.captureHover(button)

  if button.released:
    window.releaseHover(button)

  if hover:
    window.requestHover(button)

proc update*(button: Button, mouseButton = MouseButton.Left) =
  let window = gui.currentWindow
  button.update(
    hover = window.mouseHitTest(button.position, button.size),
    press = window.mousePressed(mouseButton),
    release = window.mouseReleased(mouseButton),
  )