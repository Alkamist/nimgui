import ../gui

type
  Button* = ref object
    position*: Vec2
    size*: Vec2
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc new*(_: typedesc[Button]): Button =
  result = Button()
  result.size = vec2(96, 32)

proc draw*(gui: Gui, button: Button) =
  let path = Path.new()
  path.roundedRect(button.position, button.size, 3)

  gui.fillPath(path, rgb(31, 32, 34))

  if button.isDown:
    gui.fillPath(path, rgba(0, 0, 0, 8))

  elif gui.isHovered(button):
    gui.fillPath(path, rgba(255, 255, 255, 8))

proc update*(gui: Gui, button: Button, hover, press, release: bool) =
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

proc update*(gui: Gui, button: Button, mouseButton = MouseButton.Left) =
  gui.update(button,
    hover = gui.mouseHitTest(button.position, button.size),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )