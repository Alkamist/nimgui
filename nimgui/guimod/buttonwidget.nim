{.experimental: "overloadableEnums".}

import std/macros
import ../guimod

template defineButtonBehavior*(T: typedesc): untyped {.dirty.} =
  template pressed*(widget: T): bool =
    widget.isDown and not widget.wasDown

  template released*(widget: T): bool =
    widget.wasDown and not widget.isDown

  proc buttonBehaviorGeneral(widget: T, gui: Gui, activate, deactivate: bool) =
    let isHovered = gui.hover == widget

    widget.wasDown = widget.isDown

    if isHovered and activate:
      widget.isDown = true

    if widget.isDown and deactivate:
      widget.isDown = false

  proc buttonBehavior*(widget: T, gui: Gui, keyboardKey: KeyboardKey) =
    buttonBehaviorGeneral(widget, gui, gui.keyPressed(keyboardKey), gui.keyReleased(keyboardKey))

  proc buttonBehavior*(widget: T, gui: Gui, mouseButton: MouseButton) =
    buttonBehaviorGeneral(widget, gui, gui.mousePressed(mouseButton), gui.mouseReleased(mouseButton))

type
  ButtonWidget* = ref object of Widget
    label*: string
    isDown*: bool
    wasDown*: bool

defineButtonBehavior(ButtonWidget)

proc draw*(button: ButtonWidget, gui: Gui) =
  let gfx = gui.gfx
  let bounds = button.bounds
  let isHovered = gui.hover == button

  let bodyColor = rgb(33, 38, 45)
  let borderColor = rgb(52, 59, 66)
  let textColor = rgb(201, 209, 217)

  let bodyColorHighlighted =
    if button.isDown: bodyColor.darken(0.3)
    elif isHovered: bodyColor.lighten(0.05)
    else: bodyColor

  let borderColorHighlighted =
    if button.isDown: borderColor.darken(0.1)
    elif isHovered: borderColor.lighten(0.4)
    else: borderColor

  gfx.saveState()

  gfx.drawFrameWithoutHeader(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

  gfx.fontSize = 13
  gfx.fillColor = textColor
  gfx.drawText(
    text = gfx.newText(button.label),
    bounds = bounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  gfx.restoreState()

macro button*(gui: Gui, id, iteration, code: untyped): untyped =
  var idString = id.strVal
  quote do:
    let `id` {.inject.} = `gui`.addWidget(`idString` & "_iteration_" & $`iteration`, ButtonWidget(
      size: vec2(96, 32),
    ))

    `id`.update = proc(widget: Widget) =
      let `id` {.inject.} = cast[ButtonWidget](widget)
      buttonBehavior(`id`, `gui`, Left)
      `code`
      `id`.draw(`gui`)

macro button*(gui: Gui, id, code: untyped): untyped =
  var idString = id.strVal
  quote do:
    let `id` {.inject.} = `gui`.addWidget(`idString`, ButtonWidget(
      size: vec2(96, 32),
    ))

    `id`.update = proc(widget: Widget) =
      let `id` {.inject.} = cast[ButtonWidget](widget)
      buttonBehavior(`id`, `gui`, Left)
      `code`
      `id`.draw(`gui`)

# macro button*(gui: Gui, id, iteration, code: untyped): untyped =
#   var captureProcIdent = ident(id.strVal & "CaptureIterator")
#   var idString = id.strVal
#   quote do:
#     proc `captureProcIdent`(`iteration`: int): ButtonWidget =
#       result = `gui`.addWidget(`idString` & "_iteration_" & $`iteration`, ButtonWidget(
#         size: vec2(96, 32),
#       ))

#       result.update = proc(widget: Widget) =
#         let `id` {.inject.} = cast[ButtonWidget](widget)
#         buttonBehavior(`id`, `gui`, Left)
#         `code`
#         `id`.draw(`gui`)

#     let `id` {.inject.} = `captureProcIdent`(`iteration`)