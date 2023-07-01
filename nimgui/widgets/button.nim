import ../gui

type
  GuiButton* = ref object of GuiNode
    position*: Vec2
    size*: Vec2
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    inputHeld: bool

proc update*(button: GuiButton, hover, press, release: bool) =
  let isHovered = button.isHovered

  if press: button.inputHeld = true
  if release: button.inputHeld = false

  button.pressed = false
  button.released = false
  button.clicked = false

  if isHovered and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true
    if isHovered:
      button.clicked = true

  if hover:
    button.requestHover()

  if button.inputHeld and not press:
    button.clearHover()

proc update*(button: GuiButton, mouseButton = MouseButton.Left, invisible = false) =
  button.register()

  let position = button.position
  let size = button.size

  let m = button.mousePosition
  let mouseHit =
    m.x >= position.x and m.x <= position.x + size.x and
    m.y >= position.y and m.y <= position.y + size.y

  button.update(
    hover = mouseHit,
    press = button.mousePressed(mouseButton),
    release = button.mouseReleased(mouseButton),
  )

  if not invisible:
    let path = Path.new()
    path.roundedRect(position, size, 3)

    button.fillPath(path, rgb(31, 32, 34))
    if button.isDown:
      button.fillPath(path, rgba(0, 0, 0, 8))
    elif button.isHovered:
      button.fillPath(path, rgba(255, 255, 255, 8))