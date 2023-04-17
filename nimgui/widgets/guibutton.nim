{.experimental: "overloadableEnums".}

import ../guimod
import ./frame
import ./guitext

type
  GuiButton* = ref object of GuiWidget
    isDown*: bool
    wasDown*: bool
    justClicked*: bool

proc justPressed*(button: GuiButton): bool = button.isDown and not button.wasDown
proc justReleased*(button: GuiButton): bool = button.wasDown and not button.isDown

proc updateButton(widget: GuiWidget, mouseButton: MouseButton) =
  let button = GuiButton(widget)
  let gui = button.gui

  button.justClicked = false
  button.wasDown = button.isDown

  if button.isHovered and gui.mouseJustPressed(mouseButton):
    button.isDown = true
    gui.mouseCapture = button

  if button.isDown and gui.mouseJustReleased(mouseButton):
    button.isDown = false
    gui.mouseCapture = nil
    if button.isHovered:
      button.justClicked = true

  button.updateChildren()

proc drawButton(widget: GuiWidget) =
  let button = GuiButton(widget)
  let gfx = button.gui.gfx

  # gfx.drawFrame(
  #   0, 0,
  #   button.width, button.height,
  #   1.0, 3.0,
  #   rgb(30, 31, 34),
  #   rgb(30, 31, 34).lighten(0.2),
  # )

  gfx.beginPath()
  gfx.roundedRect(
    0, 0,
    button.width, button.height,
    3.0,
  )
  gfx.fillColor = rgb(30, 31, 34)
  gfx.fill()

  button.drawChildren()

  if button.isDown:
    gfx.beginPath()
    gfx.roundedRect(
      0, 0,
      button.width, button.height,
      3.0,
    )
    gfx.fillColor = rgba(0, 0, 0, 8)
    gfx.fill()
  elif button.isHovered:
    gfx.beginPath()
    gfx.roundedRect(
      0, 0,
      button.width, button.height,
      3.0,
    )
    gfx.fillColor = rgba(255, 255, 255, 8)
    gfx.fill()

func addButton*(parent: GuiWidget, mouseButton = MouseButton.Left): GuiButton =
  result = parent.addWidget(GuiButton)
  result.size = vec2(96, 32)
  result.update = proc(widget: GuiWidget) =
    widget.updateButton(mouseButton)
  result.draw = drawButton

func addLabel*(button: GuiButton, label: string): GuiText {.discardable.} =
  result = button.addText()
  result.data = label
  result.alignX = Center
  result.alignY = Center
  result.color = rgb(242, 243, 245)
  result.passInput = true
  result.updateHook:
    self.size = self.parent.size