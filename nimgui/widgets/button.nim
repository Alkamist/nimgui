import ../gui
import ../math

type
  GuiButton* = ref object of GuiState
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    inputHeld: bool

proc button*(gui: Gui, button: GuiButton, hover, press, release: bool) =
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

  if button.inputHeld and not press and isHovered:
    gui.clearHover()

proc button*(gui: Gui, button: GuiButton, bounds: Rect2, mouseButton = MouseButton.Left) =
  gui.button(button,
    hover = bounds.contains(gui.mousePosition),
    press = gui.mousePressed(mouseButton),
    release = gui.mouseReleased(mouseButton),
  )

proc draw*(gui: Gui, button: GuiButton, bounds: Rect2) =
  let vg = gui.vg

  template drawBody(color: Color): untyped =
    vg.beginPath()
    vg.roundedRect(bounds.position, bounds.size, 3.0)
    vg.fillColor = color
    vg.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == button.id:
    drawBody(rgba(255, 255, 255, 8))

proc button*(gui: Gui, id: auto, mouseButton = MouseButton.Left): GuiButton =
  let bounds = gui.getNextBounds()
  result = gui.getState(id, GuiButton)
  gui.button(result, bounds, mouseButton)
  gui.draw(result, bounds)