{.experimental: "overloadableEnums".}

import ../guimod

template drawButton(button, gui, drawDown: untyped): untyped =
  let gfx = gui.drawList
  let isHovered = gui.isHovered(button)
  let bounds = button.bounds

  let bodyColor = rgb(33, 38, 45)
  let borderColor = rgb(52, 59, 66)
  # let textColor = rgb(201, 209, 217)

  let bodyColorHighlighted =
    if drawDown: bodyColor.darken(0.3)
    elif isHovered: bodyColor.lighten(0.05)
    else: bodyColor

  let borderColorHighlighted =
    if drawDown: borderColor.darken(0.1)
    elif isHovered: borderColor.lighten(0.4)
    else: borderColor

  gfx.drawFrame(
    bounds = bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = bodyColorHighlighted,
    borderColor = borderColorHighlighted,
  )

type
  InvisibleButtonWidget* = ref object of Widget
    label*: string
    isDown*: bool
    wasDown*: bool
    clicked*: bool

template pressed*(button: InvisibleButtonWidget): bool = button.isDown and not button.wasDown
template released*(button: InvisibleButtonWidget): bool = button.wasDown and not button.isDown

proc new*(T: type InvisibleButtonWidget, gui: Gui): T =
  result = T()
  result.size = vec2(96, 32)

proc update*(button: InvisibleButtonWidget, gui: Gui) =
  let isHovered = gui.isHovered(button)

  button.clicked = false
  button.wasDown = button.isDown

  if isHovered and gui.mousePressed(Left):
    button.isDown = true

  if button.isDown and gui.mouseReleased(Left):
    button.isDown = false
    if isHovered:
      button.clicked = true

implementWidget(invisibleButton, InvisibleButtonWidget)

type
  ButtonWidget* = ref object of InvisibleButtonWidget

proc update*(button: ButtonWidget, gui: Gui) =
  InvisibleButtonWidget(button).update(gui)
  drawButton(button, gui, button.isDown)

implementWidget(button, ButtonWidget)

# type
#   MultiButtonWidget* = ref object of Widget
#     label*: string
#     mouseButtons*: set[MouseButton]
#     isDownStates*: array[MouseButton, bool]
#     wasDownStates*: array[MouseButton, bool]
#     clickedStates*: array[MouseButton, bool]

# template isDown*(button: MultiButtonWidget, mb: MouseButton): bool = button.isDownStates[mb]
# template pressed*(button: MultiButtonWidget, mb: MouseButton): bool = button.isDownStates[mb] and not button.wasDownStates[mb]
# template released*(button: MultiButtonWidget, mb: MouseButton): bool = button.wasDownStates[mb] and not button.isDownStates[mb]
# template clicked*(button: MultiButtonWidget, mb: MouseButton): bool = button.clickedStates[mb]

# proc isDown*(button: MultiButtonWidget): bool =
#   for mb in MouseButton:
#     if button.isDown(mb):
#       return true

# proc pressed*(button: MultiButtonWidget): bool =
#   for mb in MouseButton:
#     if button.pressed(mb):
#       return true

# proc released*(button: MultiButtonWidget): bool =
#   for mb in MouseButton:
#     if button.released(mb):
#       return true

# proc clicked*(button: MultiButtonWidget): bool =
#   for mb in MouseButton:
#     if button.clicked(mb):
#       return true

# proc new*(T: type MultiButtonWidget, gui: Gui): T =
#   result = T()
#   result.size = vec2(96, 32)
#   result.mouseButtons = {Left}

# proc update*(button: MultiButtonWidget, gui: Gui) =
#   let gfx = gui.drawList
#   let isHovered = gui.isHovered(button)

#   var drawDown = false

#   for mb in MouseButton:
#     if mb in button.mouseButtons:
#       button.clickedStates[mb] = false
#       button.wasDownStates[mb] = button.isDownStates[mb]

#       if isHovered and gui.mousePressed(mb):
#         button.isDownStates[mb] = true

#       if button.isDownStates[mb]:
#         drawDown = true

#       if button.isDownStates[mb] and gui.mouseReleased(mb):
#         button.isDownStates[mb] = false
#         if isHovered:
#           button.clickedStates[mb] = true

#   drawButton(button, gui, drawDown)

# implementWidget(multiButton, MultiButtonWidget)

# type
#   ClosureButtonWidget* = ref object of Widget
#     label*: string
#     isDown*: bool
#     wasDown*: bool
#     clicked*: bool
#     activation*: proc(button: ClosureButtonWidget): bool
#     deactivation*: proc(button: ClosureButtonWidget): bool

# template pressed*(button: ClosureButtonWidget): bool = button.isDown and not button.wasDown
# template released*(button: ClosureButtonWidget): bool = button.wasDown and not button.isDown

# proc new*(T: type ClosureButtonWidget, gui: Gui): T =
#   result = T()
#   result.size = vec2(96, 32)
#   result.activation = proc(button: ClosureButtonWidget): bool =
#     gui.isHovered(button) and gui.mousePressed(Left)
#   result.deactivation = proc(button: ClosureButtonWidget): bool =
#     gui.mouseReleased(Left)

# proc update*(button: ClosureButtonWidget, gui: Gui) =
#   buttonBehavior(button, gui, button.activation(button), button.deactivation(button))

# implementWidget(closureButton, ClosureButtonWidget)