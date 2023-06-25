import ../gui

type
  GuiButton* = ref object of GuiState
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    inputHeld: bool

proc invisibleButton*(gui: Gui, id: GuiId, hover, press, release: bool): GuiButton =
  let button = gui.getState(id, GuiButton)

  let isHovered = gui.hover == id

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
    gui.requestHover(id)

  if button.inputHeld and not press:
    gui.clearHover()

  button

proc invisibleButton*(gui: Gui, id: GuiId, position, size: Vec2, mouseButton = MouseButton.Left): GuiButton =
  gui.invisibleButton(
    id,
    hover = gui.mouseIsOverBox(position, size),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )

proc button*(gui: Gui, id: GuiId, position, size: Vec2, mouseButton = MouseButton.Left): GuiButton =
  let button = gui.invisibleButton(id, position, size, mouseButton)

  template drawBody(color: Color): untyped =
    gui.beginPath()
    gui.pathRoundedRect(position, size, 3.0)
    gui.fillColor = color
    gui.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == id:
    drawBody(rgba(255, 255, 255, 8))

  button

proc invisibleButton*(gui: Gui, id: string, hover, press, release: bool): GuiButton =
  gui.invisibleButton(gui.getId(id), hover, press, release)

proc invisibleButton*(gui: Gui, id: string, position, size: Vec2, mouseButton = MouseButton.Left): GuiButton =
  gui.invisibleButton(gui.getId(id), position, size, mouseButton)

proc button*(gui: Gui, id: string, position, size: Vec2, mouseButton = MouseButton.Left): GuiButton =
  gui.button(gui.getId(id), position, size, mouseButton)