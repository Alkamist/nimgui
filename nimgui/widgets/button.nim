{.experimental: "overloadableEnums".}

import ../gui

type
  Button* = ref object of Widget
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    wasDown: bool
    shouldPress: bool
    shouldRelease: bool

proc press*(button: Button) =
  button.shouldPress = true

proc release*(button: Button) =
  button.shouldRelease = true

proc behavior*(button: Button) =
  let gui = button.gui

  let isHovered = button.isHovered
  button.wasDown = button.isDown
  button.pressed = false
  button.released = false
  button.clicked = false

  if isHovered and not button.isDown and button.shouldPress:
    button.isDown = true
    gui.mouseCapture = button
    button.pressed = true

  if button.isDown and button.shouldRelease:
    button.isDown = false
    gui.mouseCapture = nil
    button.released = true
    if isHovered:
      button.clicked = true

  button.shouldPress = false
  button.shouldRelease = false

template invisibleButton*(gui: Gui, id: string, code: untyped): untyped =
  gui.newWidget(id, Button):
    if gui.mousePressed(Left):
      self.press()

    if gui.mouseReleased(Left):
      self.release()

    self.behavior()

    code

proc defaultDraw*(button: Button) =
  let gfx = button.vg

  template drawBody(color: Color): untyped =
    gfx.beginPath()
    gfx.roundedRect(vec2(0, 0), button.size, 3.0)
    gfx.fillColor = color
    gfx.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif button.isHovered:
    drawBody(rgba(255, 255, 255, 8))

template button*(gui: Gui, id: string, code: untyped): untyped =
  gui.newWidget(id, Button):
    if gui.mousePressed(Left):
      self.press()

    if gui.mouseReleased(Left):
      self.release()

    self.behavior()
    code

    self.draw:
      self.defaultDraw()