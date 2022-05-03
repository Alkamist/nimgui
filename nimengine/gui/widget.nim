import ../input
import ../canvas
import ../gmath

export input
export canvas
export gmath

type
  Widget* = ref object of RootObj
    parent*: Widget
    x*, y*: float
    width*, height*: float

method update*(widget: Widget, input: Input) {.base.} = discard
method draw*(widget: Widget, canvas: Canvas) {.base.} = discard

func absoluteX*(widget: Widget): float =
  if widget.parent.isNil: widget.x
  else: widget.parent.absoluteX + widget.x

func absoluteY*(widget: Widget): float =
  if widget.parent.isNil: widget.y
  else: widget.parent.absoluteY + widget.y

func absolutePointIsInside*(widget: Widget, x, y: float): bool =
  let left = widget.absoluteX
  let right = left + widget.width
  let top = widget.absoluteY
  let bottom = top + widget.height
  let isInsideParent =
    if widget.parent.isNil:
      true
    else:
      widget.parent.absolutePointIsInside(x, y)
  isInsideParent and x >= left and x <= right and y >= top and y <= bottom

func mouseIsInside*(widget: Widget, input: Input): bool =
  widget.absolutePointIsInside(input.mouseX, input.mouseY)