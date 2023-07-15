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

proc draw*(button: Button, gui: Gui) =
  let path = Path.new()
  path.roundedRect(button.position, button.size, 3)

  gui.fillPath(path, rgb(31, 32, 34))

  if button.isDown:
    gui.fillPath(path, rgba(0, 0, 0, 8))

  elif button.isHovered(gui):
    gui.fillPath(path, rgba(255, 255, 255, 8))

proc update*(button: Button, gui: Gui, hover, press, release: bool) =
  let isHovered = button.isHovered(gui)
  let mouseIsOver = button.mouseIsOver(gui)

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
    button.captureHover(gui)

  if button.released:
    button.releaseHover(gui)

  if hover:
    button.requestHover(gui)

proc update*(button: Button, gui: Gui, mouseButton = MouseButton.Left) =
  button.update(gui,
    hover = gui.mouseHitTest(button.position, button.size),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )