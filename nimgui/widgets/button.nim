{.experimental: "overloadableEnums".}

import ../gui

type
  Button* = ref object of GuiNode
    isDown*: bool
    press*: bool
    release*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    wasDown: bool

proc defaultDraw*(button: Button) =
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

proc update*(button: Button) =
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

  button.press = false
  button.release = false

proc addButton*(node: GuiNode, id: string, mouseButton = MouseButton.Left): Button {.discardable.} =
  let button = node.addNode(id, Button)

  button.draw:
    button.defaultDraw()

  button.press = button.mousePressed(mouseButton)
  button.release = button.mouseReleased(mouseButton)

  button