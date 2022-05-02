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
  let bottom = widget.absoluteY
  let top = bottom + widget.height
  let isInsideParent =
    if widget.parent.isNil:
      true
    else:
      widget.parent.absolutePointIsInside(x, y)
  isInsideParent and x >= left and x <= right and y >= bottom and y <= top

func relativePointIsInside*(widget: Widget, x, y: float): bool =
  let left = widget.x
  let right = left + widget.width
  let bottom = widget.y
  let top = bottom + widget.height
  let isInsideParent =
    if widget.parent.isNil:
      true
    else:
      x <= widget.parent.width and y <= widget.parent.height
  isInsideParent and x >= left and x <= right and y >= bottom and y <= top

func mouseIsInside*(widget: Widget, input: Input): bool =
  widget.absolutePointIsInside(input.mouseX, input.mouseYInverted)