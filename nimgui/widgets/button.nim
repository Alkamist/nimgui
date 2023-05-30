{.experimental: "overloadableEnums".}

import ../widget
import ./text

type
  Button* = ref object of Widget
    isDown*: bool
    wasDown*: bool
    clicked*: bool
    inputPress*: proc(button: Button): bool
    inputRelease*: proc(button: Button): bool

template pressed*(button: Button): bool = button.isDown and not button.wasDown
template released*(button: Button): bool = button.wasDown and not button.isDown

proc update*(button: Button) =
  let isHovered = button.isHovered

  button.clicked = false
  button.wasDown = button.isDown

  if isHovered and button.inputPress(button):
    button.isDown = true
    button.captureMouse()

  if button.isDown and button.inputRelease(button):
    button.isDown = false
    button.releaseMouse()
    if isHovered:
      button.clicked = true

  button.updateChildren()

proc drawBody(button: Button, color: Color) =
  let vg = button.vg
  vg.beginPath()
  vg.roundedRect(vec2(0, 0), button.size, 3.0)
  vg.fillColor = color
  vg.fill()

proc draw*(button: Button) =
  button.drawBody(rgb(30, 31, 34))
  button.drawChildren()
  if button.isDown:
    button.drawBody(rgba(0, 0, 0, 8))
  elif button.isHovered:
    button.drawBody(rgba(255, 255, 255, 8))

func addButton*(parent: Widget, mb = MouseButton.Left): Button =
  result = parent.addWidget(Button)
  result.size = vec2(96, 32)
  result.dontDraw = false
  result.consumeInput = true
  result.clipInput = true
  result.clipDrawing = true
  result.inputPress = proc(button: Button): bool =
    button.mousePressed(mb)
  result.inputRelease = proc(button: Button): bool =
    button.mouseReleased(mb)

func addLabel*(button: Button, label: string): Text {.discardable.} =
  result = button.addText()
  result.data = label
  result.alignX = Center
  result.alignY = Center
  result.color = rgb(242, 243, 245)
  result.consumeInput = false
  result.clipInput = false
  result.clipDrawing = false
  result.updateHook:
    self.size = self.parent.size