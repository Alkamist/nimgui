{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import ../ui; export ui

type
  WidgetId* = Hash

  Widget* = ref object of RootObj
    parent*: WidgetContainer
    bounds*: Rect2
    draw*: proc()

  WidgetContainer* = ref object of Widget
    widgets*: Table[WidgetId, Widget]
    widgetDeclarationOrder*: seq[Widget]
    widgetZOrder*: seq[Widget]
    hover*: Widget

template position*(widget: Widget): auto = widget.bounds.position
template size*(widget: Widget): auto = widget.bounds.size
template x*(widget: Widget): auto = widget.bounds.position.x
template y*(widget: Widget): auto = widget.bounds.position.y
template width*(widget: Widget): auto = widget.bounds.size.x
template height*(widget: Widget): auto = widget.bounds.size.y

func isHovered*(container: WidgetContainer, widget: Widget): bool =
  if container.hover == widget:
    true
  elif container.hover of WidgetContainer:
    let hoverAsContainer = cast[WidgetContainer](container.hover)
    hoverAsContainer.isHovered(widget)
  else:
    false

template getWidget*(container: WidgetContainer, id: WidgetId, initialState: untyped): auto =
  var res: typeof(initialState)

  if container.widgets.hasKey(id):
    res = cast[typeof(initialState)](container.widgets[id])
  else:
    res = initialState
    res.parent = container
    container.widgets[id] = res
    container.widgetZOrder.add res

  container.widgetDeclarationOrder.add res

  res

template getWidget*(container: WidgetContainer, label: string, initialState: untyped): auto =
  container.getWidget(hash(label), initialState)

func beginFrame*(widget: Widget) =
  if widget of WidgetContainer:
    let container = cast[WidgetContainer](widget)
    container.widgetDeclarationOrder.setLen(0)
    for child in container.widgetZOrder:
      child.beginFrame()

proc endFrame*(widget: Widget, window: Window) =
  let mousePosition = window.mousePosition

  if widget.draw != nil:
    widget.draw()

  if widget of WidgetContainer:
    let container = cast[WidgetContainer](widget)

    # Update hover.
    container.hover = nil
    for i in countdown(container.widgetZOrder.len - 1, 0, 1):
      let child = container.widgetZOrder[i]
      if child.bounds.contains(mousePosition):
        container.hover = child
        break

    # Update children in z order.
    for child in container.widgetZOrder:
      child.endFrame(window)