import ../tmath; export tmath
import ../canvas; export canvas

type
  Widget* = ref object of RootObj
    canvas*: Canvas
    children*: seq[Widget]
    parent*: Widget
    position*: Vec2
    size*: Vec2
    relativePosition*: Vec2
    mouseIsOver*: bool
    isFocused*: bool
    mouseOver*: Widget
    focus*: Widget

func newWidget*(canvas: Canvas): Widget =
  Widget(canvas: canvas)

template bounds*(widget: Widget): Rect2 =
  rect2(widget.position, widget.size)

template relativeX*(widget: Widget): float = widget.relativePosition.x
template `relativeX=`*(widget: Widget, value: float) = widget.relativePosition.x = value
template relativeY*(widget: Widget): float = widget.relativePosition.y
template `relativeY=`*(widget: Widget, value: float) = widget.relativePosition.y = value
template width*(widget: Widget): float = widget.size.x
template `width=`*(widget: Widget, value: float) = widget.size.x = value
template height*(widget: Widget): float = widget.size.y
template `height=`*(widget: Widget, value: float) = widget.size.y = value

func updateChildren*(widget: Widget)
func drawChildren*(widget: Widget)

method requestFocus*(widget: Widget): bool {.base.} = false
method releaseFocus*(widget: Widget): bool {.base.} = false

method update*(widget: Widget) {.base, locks: "unknown".} =
  if widget.parent == nil:
    widget.mouseIsOver = true
    widget.isFocused = true
  widget.size = widget.canvas.size
  widget.updateChildren()

method draw*(widget: Widget) {.base, locks: "unknown".} =
  widget.drawChildren()

func updateChildren*(widget: Widget) =
  let canvas = widget.canvas
  var mouseOverIsSet = false
  var focusChanged = false
  var focusIndex = 0

  widget.mouseOver = nil

  for i in countup(0, widget.children.len - 1, 1):
    let child = widget.children[i]

    child.parent = widget
    child.canvas = canvas

    child.position = widget.position + child.relativePosition
    child.position = canvas.pixelAlign(child.position)
    child.size = canvas.pixelAlign(child.size)

    let mouseIsInside = child.bounds.contains(child.canvas.mousePosition)

    if not mouseOverIsSet and mouseIsInside and widget.mouseIsOver:
      widget.mouseOver = child
      mouseOverIsSet = true

    child.mouseIsOver = child == widget.mouseOver

    if child.mouseIsOver and child.requestFocus():
      widget.focus = child
      focusChanged = true
      focusIndex = i

    if widget.focus == child and child.releaseFocus():
      widget.focus = nil

  # Order children by most recently focused. That way you can
  # draw them in reverse, which feels like the most natural
  # way for windows to work.
  if focusChanged:
    for i in countdown(focusIndex, 1, 1):
      widget.children[i] = widget.children[i - 1]
    widget.children[0] = widget.focus

  for i in countup(0, widget.children.len - 1, 1):
    let child = widget.children[i]
    child.isFocused = widget.focus == child
    child.update()

func drawChildren*(widget: Widget) =
  for i in countdown(widget.children.len - 1, 0, 1):
    widget.children[i].draw()