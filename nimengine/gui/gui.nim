import ../input
import ../canvas
import ../gmath

export input
export canvas
export gmath

type
  Gui* = ref object
    canvas*: Canvas
    input*: Input
    widgets*: seq[Widget]

  Widget* = ref object of RootObj
    gui*: Gui
    parent*: Widget
    x*, y*: float
    width*, height*: float

method update*(widget: Widget) {.base, locks: "unknown".} = discard
method draw*(widget: Widget) {.base.} = discard

func canvas*(widget: Widget): Canvas = widget.gui.canvas
func input*(widget: Widget): Input = widget.gui.input

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

func mouseIsInside*(widget: Widget): bool =
  widget.absolutePointIsInside(
    widget.input.mouseX,
    widget.canvas.height - widget.input.mouseY,
  )

func newGui*(input: Input): Gui =
  Gui(
    canvas: newCanvas(),
    input: input,
  )

func update*(gui: Gui) =
  for widget in gui.widgets:
    widget.update()

func draw*(gui: Gui) =
  gui.canvas.reset()
  for widget in gui.widgets:
    widget.draw()

func addWidget*(gui: Gui, widget: Widget) =
  widget.gui = gui
  gui.widgets.add(widget)