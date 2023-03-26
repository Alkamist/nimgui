{.experimental: "overloadableEnums".}

import std/macros; export macros
import std/hashes
import std/tables
import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  WidgetId* = Hash

  Widget* = ref object of RootObj
    gui* {.cursor.}: Gui
    container* {.cursor.}: WidgetContainer
    position*: Vec2 # The relative position of the widget inside the container.
    size*: Vec2 # The size of the widget.
    justCreated*: bool

  WidgetContainer* = ref object of Widget
    drawList*: DrawList
    widgets*: Table[WidgetId, Widget]
    childZOrder*: seq[Widget]
    activeWidgets*: seq[Widget]

  Gui* = ref object
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    root*: WidgetContainer
    containerStack*: seq[WidgetContainer]
    hover*: Widget
    storedBackgroundColor: Color

func absolutePosition*(widget: Widget): Vec2 =
  if widget.container == nil:
    widget.position
  else:
    widget.position + widget.container.absolutePosition

# This is the absolute bounds of the widget.
func bounds*(widget: Widget): Rect2 =
  rect2(widget.absolutePosition, widget.size)

template x*(widget: Widget): auto = widget.position.x
template `x=`*(widget: Widget, value: float) = widget.position.x = value
template y*(widget: Widget): auto = widget.position.y
template `y=`*(widget: Widget, value: float) = widget.position.y = value
template width*(widget: Widget): auto = widget.size.x
template `width=`*(widget: Widget, value: float) = widget.size.x = value
template height*(widget: Widget): auto = widget.size.y
template `height=`*(widget: Widget, value: float) = widget.size.y = value

template update*(gui: Gui) = gui.osWindow.update()
template isOpen*(gui: Gui): bool = gui.osWindow.isOpen
template time*(gui: Gui): float = gui.osWindow.time
template isFocused*(gui: Gui): bool = gui.osWindow.isFocused
template isHovered*(gui: Gui): bool = gui.osWindow.isHovered
template pixelDensity*(gui: Gui): float = gui.osWindow.pixelDensity
template boundsPixels*(gui: Gui): Rect2 = gui.osWindow.boundsPixels
template mousePositionPixels*(gui: Gui): Vec2 = gui.osWindow.mousePositionPixels
template mouseWheel*(gui: Gui): Vec2 = gui.osWindow.mouseWheel
template mousePresses*(gui: Gui): seq[MouseButton] = gui.osWindow.mousePresses
template mouseReleases*(gui: Gui): seq[MouseButton] = gui.osWindow.mouseReleases
template mouseDown*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseDown(button)
template keyPresses*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyPresses
template keyReleases*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyReleases
template keyDown*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyDown(key)
template text*(gui: Gui): string = gui.osWindow.text
template deltaTime*(gui: Gui): float = gui.osWindow.deltaTime
template mousePosition*(gui: Gui): Vec2 = gui.osWindow.mousePosition
template mouseDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.mouseDeltaPixels
template mouseDelta*(gui: Gui): Vec2 = gui.osWindow.mouseDelta
template mouseMoved*(gui: Gui): bool = gui.osWindow.mouseMoved
template mouseWheelMoved*(gui: Gui): bool = gui.osWindow.mouseWheelMoved
template mousePressed*(gui: Gui, button: MouseButton): bool = gui.osWindow.mousePressed(button)
template mouseReleased*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseReleased(button)
template anyMousePressed*(gui: Gui): bool = gui.osWindow.anyMousePressed
template anyMouseReleased*(gui: Gui): bool = gui.osWindow.anyMouseReleased
template keyPressed*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyPressed(key)
template keyReleased*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyReleased(key)
template anyKeyPressed*(gui: Gui): bool = gui.osWindow.anyKeyPressed
template anyKeyReleased*(gui: Gui): bool = gui.osWindow.anyKeyReleased
template bounds*(gui: Gui): Rect2 = gui.osWindow.bounds
template positionPixels*(gui: Gui): Vec2 = gui.osWindow.positionPixels
template position*(gui: Gui): Vec2 = gui.osWindow.position
template sizePixels*(gui: Gui): Vec2 = gui.osWindow.sizePixels
template size*(gui: Gui): Vec2 = gui.osWindow.size
template scale*(gui: Gui): float = gui.osWindow.scale
template moved*(gui: Gui): bool = gui.osWindow.moved
template positionDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.positionDeltaPixels
template positionDelta*(gui: Gui): Vec2 = gui.osWindow.positionDelta
template resized*(gui: Gui): bool = gui.osWindow.resized
template sizeDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.sizeDeltaPixels
template sizeDelta*(gui: Gui): Vec2 = gui.osWindow.sizeDelta
template pixelDensityChanged*(gui: Gui): bool = gui.osWindow.pixelDensityChanged
template aspectRatio*(gui: Gui): float = gui.osWindow.aspectRatio
template gainedFocus*(gui: Gui): bool = gui.osWindow.gainedFocus
template lostFocus*(gui: Gui): bool = gui.osWindow.lostFocus
template mouseEntered*(gui: Gui): bool = gui.osWindow.mouseEntered
template mouseExited*(gui: Gui): bool = gui.osWindow.mouseExited

func getHover*(container: WidgetContainer): Widget =
  let gui = container.gui
  for i in countdown(container.childZOrder.len - 1, 0, 1):
    let child = container.childZOrder[i]
    if child.bounds.contains(gui.mousePosition):
      if child of WidgetContainer:
        let hoverOfChild = cast[WidgetContainer](child).getHover()
        if hoverOfChild == nil:
          return child
        else:
          return hoverOfChild
      else:
        return child

func isHovered*(widget: Widget): bool =
  widget.gui.hover == widget

func isHoveredIncludingChildren*(container: WidgetContainer): bool =
  if container.gui.hover == container:
    return true
  for child in container.childZOrder:
    if container.gui.hover == child:
      return true

func clearForFrame*(container: WidgetContainer) =
  container.activeWidgets.setLen(0)
  container.drawList.clearCommands()
  for child in container.childZOrder:
    if child of WidgetContainer:
      cast[WidgetContainer](child).clearForFrame()

func bringToTop*(widget: Widget) =
  let container = widget.container

  var found = false
  for i in 0 ..< container.childZOrder.len - 1:
    if not found and container.childZOrder[i] == widget:
      found = true
    if found:
      container.childZOrder[i] = container.childZOrder[i + 1]

  if found:
    container.childZOrder[^1] = widget

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

proc newGui*(): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.root = WidgetContainer()
  result.root.gui = result
  result.root.drawList = newDrawList()
  result.root.justCreated = true

proc renderContainer(gui: Gui, container: WidgetContainer) =
  gui.renderer.render(container.drawList)
  for child in container.childZOrder:
    if child of WidgetContainer:
      gui.renderContainer(cast[WidgetContainer](child))

proc beginFrame*(gui: Gui) =
  gui.renderer.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.root.size = gui.size
  gui.root.clearForFrame()
  gui.containerStack = @[gui.root]

proc endFrame*(gui: Gui) =
  gui.hover = gui.root.getHover()
  gui.renderContainer(gui.root)
  gui.renderer.endFrame(gui.sizePixels)
  gui.root.justCreated = false

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()

func addWidget*(gui: Gui, id: WidgetId, T: typedesc): T {.discardable.} =
  let container = gui.containerStack[^1]

  if container.widgets.hasKey(id):
    result = cast[T](container.widgets[id])
    result.justCreated = false
  else:
    result = T()
    result.gui = gui
    result.container = container
    result.justCreated = true

    when T is WidgetContainer:
      result.drawList = newDrawList()

    when compiles(result.initialize()):
      result.initialize()

    container.widgets[id] = result
    container.childZOrder.add result
    container.activeWidgets.add result

func addWidget*(gui: Gui, name: string, T: typedesc): T {.discardable.} =
  gui.addWidget(hash(name), T)

# Template and macro wizardry to enable streamlined implementation of widgets.

template widgetMacroDefinition(name, T: untyped): untyped {.dirty.} =
  when T is WidgetContainer:
    template widgetInjection(gui, widget, idString, code: untyped): untyped =
      let `widget` {.inject.} = gui.addWidget(idString, T)
      gui.pushContainer widget
      widget.update()
      code
      gui.popContainer()

    macro `name`*(gui: Gui, widget, code: untyped): untyped =
      case widget.kind:
      of nnkIdent:
        let widgetAsString = widget.strVal
        let id = quote do:
          `widgetAsString`
        result = getAst(widgetInjection(gui, widget, id, code))
      of nnkBracketExpr:
        let widgetAsString = widget[0].strVal
        let iteration = widget[1]
        let id = quote do:
          `widgetAsString` & "_iteration_" & $`iteration`
        result = getAst(widgetInjection(gui, widget[0], id, code))
      else:
        error("Widget identifiers must be in the form name, or name[i].")
  else:
    template widgetInjection(gui, widget, idString: untyped): untyped =
      let `widget` {.inject.} = gui.addWidget(idString, T)
      widget.update()

    macro `name`*(gui: Gui, widget: untyped): untyped =
      case widget.kind:
      of nnkIdent:
        let widgetAsString = widget.strVal
        let id = quote do:
          `widgetAsString`
        result = getAst(widgetInjection(gui, widget, id))
      of nnkBracketExpr:
        let widgetAsString = widget[0].strVal
        let iteration = widget[1]
        let id = quote do:
          `widgetAsString` & "_iteration_" & $`iteration`
        result = getAst(widgetInjection(gui, widget[0], id))
      else:
        error("Widget identifiers must be in the form name, or name[i].")

macro implementWidget*(name, T: untyped): untyped =
  getAst(widgetMacroDefinition(name, T))