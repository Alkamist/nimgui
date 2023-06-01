{.experimental: "overloadableEnums".}

import ../gui

type
  Button* = ref object of Widget
    isDown*: bool
    pressProc*: proc(button: Button): bool
    releaseProc*: proc(button: Button): bool
    onPressProc*: proc(button: Button)
    onReleaseProc*: proc(button: Button)
    onClickProc*: proc(button: Button)
    wasDown: bool

proc update*(button: Button) =
  let gui = button.gui
  let isHovered = button.isHovered
  button.wasDown = button.isDown

  if isHovered and not button.isDown and button.pressProc != nil and button.pressProc(button):
    button.isDown = true
    gui.mouseCapture = button
    if button.onPressProc != nil:
      button.onPressProc(button)

  if button.isDown and button.releaseProc != nil and button.releaseProc(button):
    button.isDown = false
    gui.mouseCapture = nil
    if button.onReleaseProc != nil:
      button.onReleaseProc(button)
    if isHovered:
      if button.onClickProc != nil:
        button.onClickProc(button)

proc draw*(button: Button) =
  let vg = button.gui.vg

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

template press*(b: Button, code: untyped): untyped =
  b.pressProc = proc(self {.inject.}: Button): bool =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = self.gui
    code

template release*(b: Button, code: untyped): untyped =
  b.releaseProc = proc(self {.inject.}: Button): bool =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = self.gui
    code

template onPress*(b: Button, code: untyped): untyped =
  b.onPressProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = self.gui
    code

template onRelease*(b: Button, code: untyped): untyped =
  b.onReleaseProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = self.gui
    code

template onClick*(b: Button, code: untyped): untyped =
  b.onClickProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = self.gui
    code

proc init*(button: Button) =
  button.size = vec2(96, 32)
  button.dontDraw = false
  button.clipDrawing = true
  button.clipInput = true
  button.consumeInput = true
  button.press:
    gui.mousePressed(Left)
  button.release:
    gui.mouseReleased(Left)