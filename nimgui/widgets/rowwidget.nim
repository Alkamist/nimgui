import ../guimod

type
  RowWidget* = ref object of WidgetContainer

proc new*(T: type RowWidget, gui: Gui): T =
  result = T()
  result.size = vec2(gui.containerParent.width, 24)

proc update*(row: RowWidget, gui: Gui) =
  for child in row.activeWidgets:
    child.width = row.width / row.activeWidgets.len.float
    child.height = row.height

implementWidget(row, RowWidget)