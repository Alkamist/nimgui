import ../input
import ../gfx/canvas

export input
export canvas

type
  Widget* = ref object of RootObj
    children*: seq[Widget]
    parent*: Widget
    canvas*: Canvas
    input*: Input
    x*, y*: float
    absoluteX*, absoluteY*: float
    width*, height*: float
    mouseX*, mouseY*: float
    mouseIsInside*: bool
    mouseIsOver*: bool
    isFocused*: bool
    mouseOver*: Widget
    focus*: Widget

func newWidget*(canvas: Canvas, input: Input): Widget =
  Widget(canvas: canvas, input: input)

func updateChildren*(widget: Widget)
func drawChildren*(widget: Widget)

method requestFocus*(widget: Widget): bool {.base.} = false
method releaseFocus*(widget: Widget): bool {.base.} = false

method update*(widget: Widget) {.base, locks: "unknown".} =
  if widget.parent == nil:
    widget.mouseIsInside = true
    widget.mouseIsOver = true
    widget.isFocused = true
  widget.width = widget.canvas.width
  widget.height = widget.canvas.height
  widget.updateChildren()

method draw*(widget: Widget) {.base, locks: "unknown".} =
  widget.drawChildren()

template mouseDown*(widget: Widget): untyped = widget.input.mouseDown
template mousePressed*(widget: Widget): untyped = widget.input.mousePressed
template mouseReleased*(widget: Widget): untyped = widget.input.mouseReleased
template keyDown*(widget: Widget): untyped = widget.input.keyDown
template keyPressed*(widget: Widget): untyped = widget.input.keyPressed
template keyReleased*(widget: Widget): untyped = widget.input.keyReleased

template mouseXChange*(widget: Widget): untyped = widget.input.mouseXChange
template mouseYChange*(widget: Widget): untyped = widget.input.mouseYChange

func updateChildren*(widget: Widget) =
  var mouseOverIsSet = false
  var focusChanged = false
  var focusIndex = 0

  widget.mouseOver = nil

  for i in countup(0, widget.children.len - 1, 1):
    let child = widget.children[i]

    child.parent = widget
    child.input = widget.input
    child.canvas = widget.canvas

    child.absoluteX = widget.absoluteX + child.x
    child.absoluteY = widget.absoluteY + child.y

    child.mouseX = widget.input.mouseX - child.absoluteX
    child.mouseY = widget.input.mouseY - child.absoluteY

    child.mouseIsInside =
      child.mouseX >= 0 and child.mouseX <= child.width and
      child.mouseY >= 0 and child.mouseY <= child.height

    if not mouseOverIsSet and child.mouseIsInside and widget.mouseIsOver:
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