import ../input
import ../canvas
import ../gmath

export input
export canvas
export gmath

type
  Widget* = ref object of RootObj
    parent*: Widget
    focus*: Widget
    mouseOver*: Widget
    children*: seq[Widget]
    x*, y*: float
    width*, height*: float

func newWidget*(): Widget =
  Widget()

func updateChildren*(widget: Widget, input: Input)
func drawChildren*(widget: Widget, canvas: Canvas)

method requestFocus*(widget: Widget, input: Input): bool {.base.} = false
method releaseFocus*(widget: Widget, input: Input): bool {.base.} = false

method update*(widget: Widget, input: Input) {.base.} =
  widget.updateChildren(input)

method draw*(widget: Widget, canvas: Canvas) {.base.} =
  widget.drawChildren(canvas)

func isFocused*(widget: Widget): bool =
  widget.parent.focus == widget

func absoluteX*(widget: Widget): float =
  if widget.parent == nil: widget.x
  else: widget.parent.absoluteX + widget.x

func absoluteY*(widget: Widget): float =
  if widget.parent == nil: widget.y
  else: widget.parent.absoluteY + widget.y

func absolutePointIsInside(widget: Widget, x, y: float): bool =
  let left = widget.absoluteX
  let right = left + widget.width
  let top = widget.absoluteY
  let bottom = top + widget.height
  x >= left and x <= right and y >= top and y <= bottom

func absolutePointIsInsideWidgetAndAllParents(widget: Widget, x, y: float): bool =
  let isInsideParent =
    if widget.parent == nil:
      true
    else:
      widget.parent.absolutePointIsInsideWidgetAndAllParents(x, y)
  isInsideParent and widget.absolutePointIsInside(x, y)

func widgetThatAbsolutePointIsOver(widget: Widget, x, y: float): Widget =
  if widget.focus != nil and
     widget.focus.absolutePointIsInsideWidgetAndAllParents(x, y):
    return widget.focus

  for i in countdown(widget.children.len - 1, 0, 1):
    let child = widget.children[i]
    if child == widget.focus: continue
    if child.absolutePointIsInsideWidgetAndAllParents(x, y):
      return child

func mouseIsOver*(widget: Widget, input: Input): bool =
  if widget.parent == nil:
    widget.absolutePointIsInside(input.mouseX, input.mouseY)
  else:
    widget.parent.mouseOver == widget and
    widget.parent.mouseIsOver(input)

func addChild*(widget, child: Widget) =
  child.parent = widget
  widget.children.add(child)

func removeChild*(widget, child: Widget) =
  for i in 0 ..< widget.children.len:
    if widget.children[i] == child:
      widget.children.del(i)
  child.parent = nil

func updateChildren*(widget: Widget, input: Input) =
  widget.mouseOver = widget.widgetThatAbsolutePointIsOver(input.mouseX, input.mouseY)

  let focusRequestedFocus =
    widget.focus != nil and
    widget.focus.requestFocus(input)

  var focusChanged = false
  var focusIndex = 0

  # Change focus if needed and update children.
  for i, child in widget.children:
    if (not focusRequestedFocus) and child.requestFocus(input):
      widget.focus = child
      focusChanged = true
      focusIndex = i

    if widget.focus == child and child.releaseFocus(input):
      widget.focus = nil

    child.update(input)

  # If the focus is changed, move it to the end of the list
  # so the widget's children are rendered with more recent
  # focuses on top.
  if focusChanged and widget.children.len > 1:
    let lastIndex = widget.children.len - 1
    for i in focusIndex ..< lastIndex:
      widget.children[i] = widget.children[i + 1]
    widget.children[lastIndex] = widget.focus

func drawChildren*(widget: Widget, canvas: Canvas) =
  for child in widget.children:
    child.draw(canvas)