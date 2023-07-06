import ../gui

type
  GuiButton* = ref object of GuiNode
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc setDefault*(button: GuiButton) =
  button.size = vec2(96, 32)

proc getButton*(node: GuiNode, id: string): GuiButton =
  result = node.getNode(id, GuiButton)
  if result.init:
    result.setDefault()

proc update*(button: GuiButton, hover, press, release: bool, draw = true) =
  GuiNode(button).update()

  button.pressed = false
  button.released = false
  button.clicked = false

  if button.isHovered and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true
    if button.mouseOver:
      button.clicked = true

  if button.pressed:
    button.captureHover()

  if button.released:
    button.releaseHover()

  if hover:
    button.requestHover()

  if not draw:
    return

  let path = Path.new()
  path.roundedRect(vec2(0, 0), button.size, 3)

  button.fillPath(path, rgb(31, 32, 34))
  if button.isDown:
    button.fillPath(path, rgba(0, 0, 0, 8))
  elif button.isHovered:
    button.fillPath(path, rgba(255, 255, 255, 8))

proc update*(button: GuiButton, mouseButton = MouseButton.Left, draw = true) =
  let m = button.mousePosition
  let mouseHit =
    m.x >= 0.0 and m.x <= button.size.x and
    m.y >= 0.0 and m.y <= button.size.y

  button.update(
    hover = mouseHit,
    press = button.mousePressed(mouseButton),
    release = button.mouseReleased(mouseButton),
    draw = draw,
  )