import ./widget

type
  ContainerWidget* = ref object of Widget
    children*: seq[Widget]

func addChild*(container: ContainerWidget, widget: Widget) =
  widget.parent = container
  container.children.add(widget)

func removeChild*(container: ContainerWidget, widget: Widget) =
  for i in 0 ..< container.children.len:
    if container.children[i] == widget:
      container.children.del(i)
  widget.parent = nil

func updateChildren*(container: ContainerWidget, input: Input) =
  for i in 0 ..< container.children.len:
    container.children[i].update(input)

func drawChildren*(container: ContainerWidget, canvas: Canvas) =
  for i in 0 ..< container.children.len:
    container.children[i].draw(canvas)