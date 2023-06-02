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

template press*(widget: Button, code: untyped): untyped =
  widget.pressProc = proc(self {.inject.}: Button): bool =
    {.hint[XDeclaredButNotUsed]: off.}
    let `widget` {.inject.} = self
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    code

template release*(widget: Button, code: untyped): untyped =
  widget.releaseProc = proc(self {.inject.}: Button): bool =
    {.hint[XDeclaredButNotUsed]: off.}
    let `widget` {.inject.} = self
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    code

template onPress*(widget: Button, code: untyped): untyped =
  widget.onPressProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let `widget` {.inject.} = self
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    code

template onRelease*(widget: Button, code: untyped): untyped =
  widget.onReleaseProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let `widget` {.inject.} = self
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    code

template onClick*(widget: Button, code: untyped): untyped =
  widget.onClickProc = proc(self {.inject.}: Button) =
    {.hint[XDeclaredButNotUsed]: off.}
    let `widget` {.inject.} = self
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    code

proc defaultDraw*(button: Button) =
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

Button.implementWidget(button):
  let isHovered = self.isHovered
  self.wasDown = self.isDown

  if isHovered and not self.isDown and self.pressProc != nil and self.pressProc(self):
    self.isDown = true
    gui.mouseCapture = self

    if self.onPressProc != nil:
      self.onPressProc(self)

  if self.isDown and self.releaseProc != nil and self.releaseProc(self):
    self.isDown = false
    gui.mouseCapture = nil

    if self.onReleaseProc != nil:
      self.onReleaseProc(self)

    if isHovered:
      if self.onClickProc != nil:
        self.onClickProc(self)