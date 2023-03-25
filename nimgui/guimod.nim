{.experimental: "overloadableEnums".}

import std/macros; export macros
import std/hashes
import std/tables
import ./guimod/drawlist; export drawlist
import ./guimod/drawlistrenderernanovg

when defined(windows):
  import ./guimod/oswindowwin32; export oswindowwin32

type
  WidgetId* = Hash

  Widget* = ref object of RootObj
    justCreated*: bool
    position*: Vec2 # The relative position of the widget inside the container.
    size*: Vec2 # The size of the widget.
    parentPosition: Vec2 # The position of the parent for absolute bounds calculation.

  WidgetContainer* = ref object of Widget
    drawList*: DrawList
    widgets*: Table[WidgetId, Widget]
    childZOrder*: seq[Widget]

  GuiTheme* = ref object
    containerPadding*: float
    widgetSpacing*: float

  Gui* = ref object
    osWindow*: OsWindow # The operating system window that the gui is hosted in.
    renderer*: DrawListRenderer # The backend for rendering the draw list to the screen.
    theme*: GuiTheme # The theme that the gui uses.
    root*: WidgetContainer # The top level dummy container for the operating system window.
    containerStack*: seq[WidgetContainer] # A stack of containers to keep track of heirarchy.
    hover*: Widget # The current widget that the mouse is hovering over.
    hoverParents*: seq[WidgetContainer]
    focus*: Widget # The current widget that is focused.
    storedBackgroundColor: Color # The background color of the operating system window stored in case it needs to be accessed later.

template x*(widget: Widget): auto = widget.position.x
template `x=`*(widget: Widget, value: float) = widget.position.x = value
template y*(widget: Widget): auto = widget.position.y
template `y=`*(widget: Widget, value: float) = widget.position.y = value
template width*(widget: Widget): auto = widget.size.x
template `width=`*(widget: Widget, value: float) = widget.size.x = value
template height*(widget: Widget): auto = widget.size.y
template `height=`*(widget: Widget, value: float) = widget.size.y = value

# This is the absolute bounds of the widget within the operating system window.
proc bounds*(widget: Widget): Rect2 =
  rect2(widget.position + widget.parentPosition, widget.size)

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

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

func defaultTheme*(): GuiTheme =
  GuiTheme(
    containerPadding: 5.0,
    widgetSpacing: 5.0,
  )

proc newGui*(theme = defaultTheme()): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.theme = theme
  result.root = WidgetContainer(drawList: newDrawList())

func getHover(gui: Gui, container: WidgetContainer): Widget =
  for i in countdown(container.childZOrder.len - 1, 0, 1):
    let child = container.childZOrder[i]
    if child.bounds.contains(gui.mousePosition):
      gui.hoverParents.add container
      if child of WidgetContainer:
        let hoverOfChild = gui.getHover(cast[WidgetContainer](child))
        if hoverOfChild == nil:
          return child
        else:
          return hoverOfChild
      else:
        return child

func bringToTop(container: WidgetContainer, child: Widget) =
  var foundChild = false

  for i in 0 ..< container.childZOrder.len - 1:
    if not foundChild and container.childZOrder[i] == child:
      foundChild = true
    if foundChild:
      container.childZOrder[i] = container.childZOrder[i + 1]

  if foundChild:
    container.childZOrder[^1] = child

func updateFocus(gui: Gui) =
  if gui.hover != nil:
    if gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right):
      gui.focus = gui.hover
      for i in 0 ..< gui.hoverParents.len - 1:
        gui.hoverParents[i].bringToTop(gui.hoverParents[i + 1])
      gui.hoverParents[^1].bringToTop(gui.focus)

func clearForFrame(container: WidgetContainer) =
  container.drawList.clearCommands()
  for child in container.childZOrder:
    if child of WidgetContainer:
      cast[WidgetContainer](child).clearForFrame()

proc renderChildren(container: WidgetContainer, gui: Gui) =
  gui.renderer.render(container.drawList)
  for child in container.childZOrder:
    if child of WidgetContainer:
      cast[WidgetContainer](child).renderChildren(gui)

proc beginFrame*(gui: Gui) =
  gui.renderer.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.root.size = gui.size
  gui.root.clearForFrame()
  gui.hoverParents.setLen(0)
  gui.containerStack.setLen(0)

proc endFrame*(gui: Gui) =
  gui.hover = gui.getHover(gui.root)
  gui.updateFocus()
  gui.root.renderChildren(gui)
  gui.renderer.endFrame(gui.sizePixels)

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()

func currentContainer*(gui: Gui, T: typedesc = WidgetContainer): T =
  cast[T](
    if gui.containerStack.len > 0:
      gui.containerStack[gui.containerStack.len - 1]
    else:
      gui.root
  )

func drawList*(gui: Gui): DrawList =
  gui.currentContainer.drawList

func pushContainer*(gui: Gui, container: WidgetContainer) =
  gui.containerStack.add container

func popContainer*(gui: Gui) =
  gui.containerStack.setLen(gui.containerStack.len - 1)

func addWidget*(gui: Gui, id: WidgetId, T: typedesc): T {.discardable.} =
  let container = gui.currentContainer

  if container.widgets.hasKey(id):
    result = cast[T](container.widgets[id])
    result.justCreated = false
  else:
    result = T.new()
    when T is WidgetContainer:
      result.drawList = newDrawList()
    result.justCreated = true

    container.widgets[id] = result
    container.childZOrder.add result

  result.parentPosition = container.position + container.parentPosition

func addWidget*(gui: Gui, label: string, T: typedesc): T {.discardable.} =
  gui.addWidget(hash(label), T)

# Template and macro wizardry to enable streamlined implementation of widgets.
# It's kind of messy because there are two versions copy pasted and you need
# to call the right version between normal and container widgets.
# Ideally this would somehow be overloaded at compiletime so you can just
# call implementWidget and not have to worry but I will figure that out later.

template widgetMacroDefinition(name, T: untyped): untyped {.dirty.} =
  template widgetInjection(gui, widget, idString: untyped): untyped =
    let `widget` {.inject.} = gui.addWidget(idString, T)
    widget.update(gui)

  macro `name`*(gui: Gui, widget, iteration: untyped): untyped =
    let idStr = widget.strVal
    let id = quote do:
      `idStr` & "_iteration_" & $`iteration`
    getAst(widgetInjection(gui, widget, id))

  macro `name`*(gui: Gui, widget: untyped): untyped =
    getAst(widgetInjection(gui, widget, widget.strVal))

macro implementWidget*(name, T: untyped): untyped =
  getAst(widgetMacroDefinition(name, T))

# Container version:

template containerWidgetMacroDefinition(name, T: untyped): untyped {.dirty.} =
  template widgetInjection(gui, widget, idString, code: untyped): untyped =
    let `widget` {.inject.} = gui.addWidget(idString, T)
    gui.pushContainer widget
    widget.update(gui)
    code
    gui.popContainer()

  macro `name`*(gui: Gui, widget, iteration, code: untyped): untyped =
    let idStr = widget.strVal
    let id = quote do:
      `idStr` & "_iteration_" & $`iteration`
    getAst(widgetInjection(gui, widget, id, code))

  macro `name`*(gui: Gui, widget, code: untyped): untyped =
    getAst(widgetInjection(gui, widget, widget.strVal, code))

macro implementContainerWidget*(name, T: untyped): untyped =
  getAst(containerWidgetMacroDefinition(name, T))

# func drawFrameWithHeader*(gfx: Gfx,
#                           bounds: Rect2,
#                           borderThickness, headerHeight: float,
#                           cornerRadius: float,
#                           bodyColor, headerColor, borderColor: Color) =
#   let headerHeight = headerHeight.pixelAlign(gfx)
#   let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
#   let halfBorderThickness = borderThickness * 0.5
#   let bounds = bounds.pixelAlign(gfx)

#   let leftOuter = bounds.x
#   let leftMiddle = leftOuter + halfBorderThickness
#   let leftInner = leftMiddle + halfBorderThickness
#   let rightOuter = bounds.x + bounds.width
#   let rightMiddle = rightOuter - halfBorderThickness
#   let rightInner = rightMiddle - halfBorderThickness
#   let topOuter = bounds.y
#   let topMiddle = topOuter + halfBorderThickness
#   let topInner = topMiddle + halfBorderThickness
#   let headerOuter = bounds.y + headerHeight
#   let headerMiddle = headerOuter - halfBorderThickness
#   let headerInner = headerMiddle - halfBorderThickness
#   let bottomOuter = bounds.y + bounds.height
#   let bottomMiddle = bottomOuter - halfBorderThickness
#   let bottomInner = bottomMiddle - halfBorderThickness

#   let innerWidth = rightInner - leftInner
#   let middleWidth = rightMiddle - leftMiddle

#   let outerCornerRadius = cornerRadius
#   let middleCornerRadius = outerCornerRadius - halfBorderThickness
#   let innerCornerRadius = middleCornerRadius - halfBorderThickness

#   # Header fill.
#   gfx.beginPath()
#   gfx.roundedRect(
#     rect2(
#       leftMiddle,
#       topMiddle,
#       middleWidth,
#       headerMiddle - topMiddle,
#     ),
#     middleCornerRadius,
#     middleCornerRadius,
#     0, 0,
#   )
#   gfx.fillColor = headerColor
#   gfx.fill()

#   # Body fill.
#   gfx.beginPath()
#   gfx.roundedRect(
#     rect2(
#       leftMiddle,
#       headerMiddle,
#       middleWidth,
#       bottomMiddle - headerMiddle,
#     ),
#     0, 0,
#     middleCornerRadius,
#     middleCornerRadius,
#   )
#   gfx.fillColor = bodyColor
#   gfx.fill()

#   # Border outer.
#   gfx.beginPath()
#   gfx.roundedRect(bounds, cornerRadius)

#   # Header inner hole.
#   gfx.roundedRect(
#     rect2(
#       leftInner,
#       topInner,
#       innerWidth,
#       headerInner - topInner,
#     ),
#     innerCornerRadius,
#     innerCornerRadius,
#     0, 0,
#   )
#   gfx.pathWinding = Hole

#   # Body inner hole.
#   gfx.roundedRect(
#     rect2(
#       leftInner,
#       headerOuter,
#       innerWidth,
#       bottomInner - headerOuter,
#     ),
#     0, 0,
#     innerCornerRadius,
#     innerCornerRadius,
#   )
#   gfx.pathWinding = Hole

#   gfx.fillColor = borderColor
#   gfx.fill()