import ../guimod

type
  RowWidget* = ref object of WidgetContainer

proc initialize*(row: RowWidget) =
  row.size = vec2(row.container.width, 24)

proc postUpdate*(row: RowWidget) =
  for i, child in row.activeWidgets:
    child.width = row.width / row.activeWidgets.len.float
    child.height = row.height
    child.x = i.float * child.width

implementWidget(row, RowWidget)