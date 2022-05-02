import ./widget

type
  ContainerWidget* = ref object of Widget
    children*: seq[Widget]

func addChild*(container: ContainerWidget, widget: Widget) =
  widget.canvas = container.canvas
  widget.input = container.input
  widget.parent = container
  container.children.add(widget)

func removeChild*(container: ContainerWidget, widget: Widget) =
  for i in 0 ..< container.children.len:
    if container.children[i] == widget:
      container.children.del(i)
  widget.canvas = nil
  widget.input = nil
  widget.parent = nil

func updateChildren*(container: ContainerWidget) =
  for i in 0 ..< container.children.len:
    container.children[i].update()

func drawChildren*(container: ContainerWidget) =
  for i in 0 ..< container.children.len:
    container.children[i].draw()