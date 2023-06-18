import ../gui

type
  GuiButton* = ref object of GuiControl
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    inputHeld: bool

proc update*(gui: Gui, button: GuiButton, hover, press, release: bool) =
  let id = button.id
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

proc update*(gui: Gui, button: GuiButton, mouseButton = MouseButton.Left) =
  gui.update(
    button,
    hover = gui.mouseIsOver(button),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )

proc draw*(gui: Gui, button: GuiButton) =
  template drawBody(color: Color): untyped =
    gui.beginPath()
    gui.pathRoundedRect(button.position, button.size, 3.0)
    gui.fillColor = color
    gui.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == button.id:
    drawBody(rgba(255, 255, 255, 8))