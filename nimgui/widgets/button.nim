import ../gui

type
  ButtonState* = object
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool

proc update*(button: var ButtonState, isHovered, mouseIsOver, press, release: bool) =
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

proc button*(gui: Gui, id: GuiId,
  position = vec2(0, 0),
  size = vec2(96, 32),
  mouseButton = MouseButton.Left,
  draw = true,
): ButtonState {.discardable.} =
  let isHovered = gui.isHovered(id)

  var state = gui.getState(id, ButtonState())
  state.update(
    isHovered = isHovered,
    mouseIsOver = gui.mouseIsOver(id),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )
  gui.setState(id, state)

  if state.pressed:
    gui.captureHover(id)

  if state.released:
    gui.releaseHover(id)

  if gui.mouseHitTest(position, size):
    gui.requestHover(id)

  if draw:
    let path = Path.new()
    path.roundedRect(position, size, 3)

    gui.fillPath(path, rgb(31, 32, 34))
    if state.isDown:
      gui.fillPath(path, rgba(0, 0, 0, 8))
    elif isHovered:
      gui.fillPath(path, rgba(255, 255, 255, 8))

  state

proc button*(gui: Gui, id: string,
  position = vec2(0, 0),
  size = vec2(96, 32),
  mouseButton = MouseButton.Left,
  draw = true,
): ButtonState {.discardable.} =
  gui.button(gui.getId(id), position, size, mouseButton, draw)