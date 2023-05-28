{.experimental: "overloadableEnums".}

import ../math
import ../widget
# import ./frame
import ./text

type
  Button* = ref object of Widget
    isDown*: bool
    wasDown*: bool
    clicked*: bool
    mouseButton*: MouseButton

proc pressed*(button: Button): bool {.inline.} = button.isDown and not button.wasDown
proc released*(button: Button): bool {.inline.} = button.wasDown and not button.isDown

proc updateButton(widget: Widget) =
  let button = Button(widget)
  let isHovered = button.isHovered

  button.clicked = false
  button.wasDown = button.isDown

  if isHovered and button.mousePressed(button.mouseButton):
    button.isDown = true
    button.captureMouse()

  if button.isDown and button.mouseReleased(button.mouseButton):
    button.isDown = false
    button.releaseMouseCapture()
    if isHovered:
      button.clicked = true

  button.updateChildren()

proc drawButton(widget: Widget) =
  let button = Button(widget)
  let vg = button.vg

  # vg.drawFrame(
  #   0, 0,
  #   button.width, button.height,
  #   1.0, 3.0,
  #   rgb(30, 31, 34),
  #   rgb(30, 31, 34).lighten(0.2),
  # )

  vg.beginPath()
  vg.roundedRect(vec2(0, 0), button.size, 3.0)
  vg.fillColor = rgb(30, 31, 34)
  vg.fill()

  button.drawChildren()

  if button.isDown:
    vg.beginPath()
    vg.roundedRect(vec2(0, 0), button.size, 3.0)
    vg.fillColor = rgba(0, 0, 0, 8)
    vg.fill()
  elif button.isHovered:
    vg.beginPath()
    vg.roundedRect(vec2(0, 0), button.size, 3.0)
    vg.fillColor = rgba(255, 255, 255, 8)
    vg.fill()

func addButton*(parent: Widget, mouseButton = MouseButton.Left): Button =
  result = parent.addWidget(Button)
  result.mouseButton = mouseButton
  result.size = vec2(96, 32)
  result.update = updateButton
  result.draw = drawButton
  result.consumeInput = true
  result.clipInput = true
  result.clipDrawing = true

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