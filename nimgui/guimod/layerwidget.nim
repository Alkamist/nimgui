import ../guimod

type
  LayerWidget* = ref object of WidgetContainer

implementContainerWidget(layer, LayerWidget()):
  let gfx = gui.gfx
  gfx.saveState()
  code
  widget.updateChildren(gui)
  gfx.restoreState()