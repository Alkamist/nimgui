import ../guimod

type
  RowWidget* = ref object of WidgetContainer
    spacing*: float

proc beginRow*(gui: Gui, id: WidgetId): RowWidget {.discardable.} =
  let row = gui.beginContainer(id, RowWidget)
  if row.justCreated:
    row.spacing = 5.0
  row.size = vec2(row.container.width, row.container.height)
  row

proc endRow*(gui: Gui) =
  let row = gui.currentContainer(RowWidget)
  var cursor = 0.0
  for i, child in row.activeWidgets:
    child.x = cursor
    cursor += child.width + row.spacing
  gui.endContainer()