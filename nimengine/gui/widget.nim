{.experimental: "overloadableEnums".}

import ../window; export window

type
  Widget* = ref object of RootObj
    isHovered*: bool
    bounds*: Rect2
    mouseDownStates*: array[MouseButton, bool]
    previousMouseDownStates*: array[MouseButton, bool]

template position*(widget: Widget): float = widget.bounds.position
template x*(widget: Widget): float = widget.bounds.position.x
template y*(widget: Widget): float = widget.bounds.position.y
template size*(widget: Widget): float = widget.bounds.size
template width*(widget: Widget): float = widget.bounds.size.x
template `width=`*(widget: Widget, value: float) = widget.bounds.size.x = value
template height*(widget: Widget): float = widget.bounds.size.y
template `height=`*(widget: Widget, value: float) = widget.bounds.size.y = value

template mouseDown*(widget: Widget, button: MouseButton): bool =
  widget.mouseDownStates[button]

template mousePressed*(widget: Widget, button: MouseButton): bool =
  widget.mouseDownStates[button] and not widget.previousMouseDownStates[button]

template mouseReleased*(widget: Widget, button: MouseButton): bool =
  widget.previousMouseDownStates[button] and not widget.mouseDownStates[button]

template mouseClicked*(widget: Widget, button: MouseButton): bool =
  widget.isHovered and widget.mouseReleased(button)

proc updateWidget*(widget: Widget, window: Window) =
  widget.previousMouseDownStates = widget.mouseDownStates
  widget.isHovered = widget.bounds.contains(window.mousePosition)

  for button in MouseButton:
    if widget.isHovered and window.mousePressed(button):
      widget.mouseDownStates[button] = true

    elif widget.mouseDownStates[button] and window.mouseReleased(button):
      widget.mouseDownStates[button] = false

# method update*(widget: Widget, window: Window) {.base.} =
#   widget.updateWidget(window)

# method draw*(widget: Widget, window: Window) {.base.} =
#   discard