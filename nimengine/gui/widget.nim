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
    lastFocus*: Widget
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

func absolutePointIsInside*(widget: Widget, x, y: float): bool =
  let left = widget.absoluteX
  let right = left + widget.width
  let top = widget.absoluteY
  let bottom = top + widget.height
  let isInsideParent =
    if widget.parent == nil:
      true
    else:
      widget.parent.absolutePointIsInside(x, y)
  isInsideParent and x >= left and x <= right and y >= top and y <= bottom

func mouseIsInside*(widget: Widget, input: Input): bool =
  widget.absolutePointIsInside(input.mouseX, input.mouseY)

func addChild*(widget, child: Widget) =
  child.parent = widget
  widget.children.add(child)

func removeChild*(widget, child: Widget) =
  for i in 0 ..< widget.children.len:
    if widget.children[i] == child:
      widget.children.del(i)
  child.parent = nil

func updateChildren*(widget: Widget, input: Input) =
  let focusRequestedFocus =
    widget.focus != nil and
    widget.focus.requestFocus(input)

  for child in widget.children:
    if (not focusRequestedFocus) and child.requestFocus(input):
      widget.focus = child
      widget.lastFocus = child

    if widget.focus == child and child.releaseFocus(input):
      widget.focus = nil

    child.update(input)

func drawChildren*(widget: Widget, canvas: Canvas) =
  for child in widget.children:
    if child == widget.lastFocus:
      continue
    child.draw(canvas)

  if widget.lastFocus != nil:
    widget.lastFocus.draw(canvas)