import ./widget

type
  ContainerWidget* = ref object of Widget
    widgets*: seq[Widget]
    widgetsAwaitingRemoval*: seq[Widget]

func addWidget*(container: ContainerWidget, widget: Widget) =
  widget.canvas = container.canvas
  widget.input = container.input
  widget.parent = container
  container.widgets.add(widget)

func removeWidgetImmediately*(container: ContainerWidget, widget: Widget) =
  for i in 0 ..< container.widgets.len:
    if container.widgets[i] == widget:
      container.widgets.del(i)
  widget.canvas = nil
  widget.input = nil
  widget.parent = nil

func removeWidget*(container: ContainerWidget, widget: Widget) =
  container.widgetsAwaitingRemoval.add(widget)

func updateWidgets*(container: ContainerWidget) =
  for widget in container.widgets:
    widget.update()

  for widget in container.widgetsAwaitingRemoval:
    container.removeWidgetImmediately(widget)

func drawWidgets*(container: ContainerWidget) =
  for widget in container.widgets:
    widget.draw()