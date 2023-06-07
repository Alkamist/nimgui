{.experimental: "overloadableEnums".}

import ../gui

type
  GuiButton* = ref object of GuiNode
    isDown*: bool
    press*: bool
    release*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    wasDown: bool

proc defaultDraw*(button: GuiButton) =
  let vg = button.vg

  template drawBody(color: Color): untyped =
    vg.beginPath()
    vg.roundedRect(vec2(0, 0), button.size, 3.0)
    vg.fillColor = color
    vg.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif button.isHovered:
    drawBody(rgba(255, 255, 255, 8))

proc update*(button: GuiButton) =
  button.wasDown = button.isDown
  button.pressed = false
  button.released = false
  button.clicked = false

  if button.isHovered and not button.isDown and button.press:
    button.isDown = true
    button.captureMouse()
    button.pressed = true

  if button.isDown and button.release:
    button.isDown = false
    button.releaseMouse()
    button.released = true
    if button.isHovered:
      button.clicked = true

createVariant(GuiNode, GuiButton, addButton):
  self.draw:
    self.defaultDraw()

  if self.firstAccessThisFrame:
    self.press = self.mousePressed(Left)
    self.release = self.mouseReleased(Left)