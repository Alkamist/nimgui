{.experimental: "overloadableEnums".}

import std/macros; export macros
import std/tables
import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  WidgetId* = string

  Widget* = ref object of RootObj
    container* {.cursor.}: WidgetContainer
    position*: Vec2 # The relative position of the widget inside its container.
    size*: Vec2
    justCreated*: bool
    noSize*: bool

  WidgetContainer* = ref object of Widget
    beginDrawList*: DrawList
    endDrawList*: DrawList
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

template drawList*(container: WidgetContainer): DrawList = container.beginDrawList

func absolutePosition*(widget: Widget): Vec2 =
  if widget.container == nil:
    widget.position
  else:
    widget.position + widget.container.absolutePosition

func absoluteBounds*(widget: Widget): Rect2 =
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
template xPixels*(gui: Gui): float = gui.osWindow.xPixels
template yPixels*(gui: Gui): float = gui.osWindow.yPixels
template position*(gui: Gui): Vec2 = gui.osWindow.position
template x*(gui: Gui): float = gui.osWindow.x
template y*(gui: Gui): float = gui.osWindow.y
template sizePixels*(gui: Gui): Vec2 = gui.osWindow.sizePixels
template widthPixels*(gui: Gui): float = gui.osWindow.widthPixels
template heightPixels*(gui: Gui): float = gui.osWindow.heightPixels
template size*(gui: Gui): Vec2 = gui.osWindow.size
template width*(gui: Gui): float = gui.osWindow.width
template height*(gui: Gui): float = gui.osWindow.height
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

func findHover*(container: WidgetContainer, position: Vec2): Widget =
  # This could probably be cleaned up quite a bit.
  for i in countdown(container.childZOrder.len - 1, 0, 1):
    let child = container.childZOrder[i]
    if child of WidgetContainer:
      if child.noSize:
        let hoverOfChild = cast[WidgetContainer](child).findHover(position)
        if hoverOfChild == nil:
          continue
        else:
          return hoverOfChild
      else:
        if child.absoluteBounds.contains(position):
          let hoverOfChild = cast[WidgetContainer](child).findHover(position)
          if hoverOfChild == nil:
            return child
          else:
            return hoverOfChild
    else:
      if child.absoluteBounds.contains(position):
        return child

func clearForFrame*(container: WidgetContainer) =
  container.activeWidgets.setLen(0)
  container.beginDrawList.clearCommands()
  container.endDrawList.clearCommands()
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
  result.root.beginDrawList = newDrawList()
  result.root.endDrawList = newDrawList()
  result.root.justCreated = true

proc renderContainer(gui: Gui, container: WidgetContainer) =
  gui.renderer.render(container.beginDrawList)
  for child in container.childZOrder:
    if child of WidgetContainer:
      gui.renderContainer(cast[WidgetContainer](child))
  gui.renderer.render(container.endDrawList)

proc beginFrame*(gui: Gui) =
  gui.renderer.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.root.size = gui.size
  gui.root.clearForFrame()
  gui.containerStack = @[gui.root]

proc endFrame*(gui: Gui) =
  gui.hover = gui.root.findHover(gui.mousePosition)
  gui.renderContainer(gui.root)
  gui.renderer.endFrame(gui.sizePixels)
  gui.root.justCreated = false

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()

func isHovered*(gui: Gui, widget: Widget): bool =
  gui.hover == widget

func isHoveredIncludingChildren*(gui: Gui, container: WidgetContainer): bool =
  if gui.hover == container:
    return true
  for child in container.childZOrder:
    if gui.hover == child:
      return true

func addWidget*(gui: Gui, id: WidgetId, T: typedesc): T {.discardable.} =
  let container = gui.containerStack[^1]

  if container.widgets.hasKey(id):
    result = cast[T](container.widgets[id])
    result.justCreated = false
  else:
    result = T()
    result.container = container
    result.justCreated = true
    container.widgets[id] = result
    container.childZOrder.add result

  container.activeWidgets.add result

func currentContainer*(gui: Gui, T: typedesc): T =
  T(gui.containerStack[^1])

func drawList*(gui: Gui): DrawList =
  gui.containerStack[^1].beginDrawList

func endDrawList*(gui: Gui): DrawList =
  gui.containerStack[^1].endDrawList

func beginContainer*(gui: Gui, name: string, T: typedesc): T {.discardable.} =
  let container = gui.addWidget(name, T)
  if container.justCreated:
    container.beginDrawList = newDrawList()
    container.endDrawList = newDrawList()
  gui.containerStack.add container
  container

func endContainer*(gui: Gui) =
  gui.containerStack.setLen(gui.containerStack.len - 1)

# template widgetMacroDefinition(name, T: untyped): untyped {.dirty.} =
#   when T is WidgetContainer:
#     template widgetInjection(gui, widget, idString, code: untyped): untyped =
#       let `widget` {.inject.} = gui.addWidget(idString, T)
#       gui.containerStack.add widget
#       when compiles(widget.preUpdate()):
#         widget.preUpdate()
#       code
#       when compiles(widget.postUpdate()):
#         widget.postUpdate()
#       gui.containerStack.setLen(gui.containerStack.len - 1)

#     macro `name`*(gui: Gui, widget, code: untyped): untyped =
#       case widget.kind:
#       of nnkIdent:
#         let widgetAsString = widget.strVal
#         let id = quote do:
#           `widgetAsString`
#         result = getAst(widgetInjection(gui, widget, id, code))
#       of nnkBracketExpr:
#         let widgetAsString = widget[0].strVal
#         let iteration = widget[1]
#         let id = quote do:
#           `widgetAsString` & "_iteration_" & $`iteration`
#         result = getAst(widgetInjection(gui, widget[0], id, code))
#       else:
#         error("Widget identifiers must be in the form name, or name[i].")
#   else:
#     template widgetInjection(gui, widget, idString: untyped): untyped =
#       let `widget` {.inject.} = gui.addWidget(idString, T)
#       when compiles(widget.update()):
#         widget.update()

#     macro `name`*(gui: Gui, widget: untyped): untyped =
#       case widget.kind:
#       of nnkIdent:
#         let widgetAsString = widget.strVal
#         let id = quote do:
#           `widgetAsString`
#         result = getAst(widgetInjection(gui, widget, id))
#       of nnkBracketExpr:
#         let widgetAsString = widget[0].strVal
#         let iteration = widget[1]
#         let id = quote do:
#           `widgetAsString` & "_iteration_" & $`iteration`
#         result = getAst(widgetInjection(gui, widget[0], id))
#       else:
#         error("Widget identifiers must be in the form name, or name[i].")

# macro implementWidget*(name, T: untyped): untyped =
#   getAst(widgetMacroDefinition(name, T))