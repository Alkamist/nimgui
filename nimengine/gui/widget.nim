import ../tmath
import ../client
import ../gfx/canvas

export tmath
export client
export canvas

type
  Widget* = ref object of RootObj
    client*: Client
    canvas*: Canvas
    children*: seq[Widget]
    parent*: Widget
    position*: tuple[x, y: float]
    absolutePosition*: tuple[x, y: float]
    size*: tuple[x, y: float]
    mousePosition*: tuple[x, y: float]
    mouseIsInside*: bool
    mouseIsOver*: bool
    isFocused*: bool
    mouseOver*: Widget
    focus*: Widget

func newWidget*(client: Client, canvas: Canvas): Widget =
  Widget(client: client, canvas: canvas)

func updateChildren*(widget: Widget)
func drawChildren*(widget: Widget)

method requestFocus*(widget: Widget): bool {.base.} = false
method releaseFocus*(widget: Widget): bool {.base.} = false

method update*(widget: Widget) {.base, locks: "unknown".} =
  if widget.parent == nil:
    widget.mouseIsInside = true
    widget.mouseIsOver = true
    widget.isFocused = true
  widget.size = widget.canvas.size
  widget.updateChildren()

method draw*(widget: Widget) {.base, locks: "unknown".} =
  widget.drawChildren()

func updateChildren*(widget: Widget) =
  var mouseOverIsSet = false
  var focusChanged = false
  var focusIndex = 0

  widget.mouseOver = nil

  for i in countup(0, widget.children.len - 1, 1):
    let child = widget.children[i]

    child.parent = widget
    child.client = widget.client
    child.canvas = widget.canvas

    child.absolutePosition = widget.absolutePosition + child.position
    child.mousePosition = widget.client.mousePosition - child.absolutePosition

    child.mouseIsInside = ((0.0, 0.0), child.size).contains(child.mousePosition)

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