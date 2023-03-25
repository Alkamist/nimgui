{.experimental: "overloadableEnums".}

import std/macros
import std/hashes
import std/tables
import ./gfxmod; export gfxmod
when defined(windows):
  import ./guimod/oswindowwin32; export oswindowwin32

type
  WidgetId* = Hash

  Widget* = ref object of RootObj
    justCreated*: bool
    update*: proc(widget: Widget)
    id*: WidgetId
    position*: Vec2 # The relative position of the widget inside the container.
    size*: Vec2 # The size of the widget.
    parentPosition: Vec2
    # isFreelyPositionable*: bool

  WidgetContainer* = ref object of Widget
    widgets*: Table[WidgetId, Widget]
    childStack*: seq[Widget]
    childZOrder*: seq[Widget]
    # previousChildBounds*: Rect2

  GuiTheme* = ref object
    containerPadding*: float
    widgetSpacing*: float

  Gui* = ref object
    osWindow*: OsWindow # The operating system window that the gui is hosted in.
    gfx*: Gfx # The nanovg wrapper responsible for drawing vector graphics in the window.
    theme*: GuiTheme # The theme that the gui uses.
    root*: WidgetContainer # The top level dummy container for the operating system window.
    containerStack*: seq[WidgetContainer] # A stack of containers to keep track of heirarchy.
    # widgetStack*: seq[Widget] # A stack of widgets to keep track of heirarchy.
    hover*: Widget # The current widget that the mouse is hovering over.
    hoverParents*: seq[WidgetContainer]
    focus*: Widget # The current widget that is focused.
    # nextWidgetSizeStack*: seq[Vec2]
    # placeNextWidgetInSameRow*: bool
    storedBackgroundColor: Color # The background color of the operating system window stored in case it needs to be accessed later.

# method draw*(widget: Widget, gui: Gui) {.base.} = discard

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
  result.gfx = newGfx()
  result.theme = theme
  result.root = WidgetContainer()

func getHover*(gui: Gui, container: WidgetContainer): Widget =
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

func clearForFrame*(gui: Gui, widget: Widget) =
  if widget of WidgetContainer:
    let container = cast[WidgetContainer](widget)
    container.childStack.setLen(0)
    # container.previousChildBounds = rect2(
    #   container.position + gui.theme.containerPadding,
    #   vec2(0, 0),
    # )
    for child in container.childZOrder:
      gui.clearForFrame(child)

func bringToTop(container: WidgetContainer, child: Widget) =
  var foundChild = false

  for i in 0 ..< container.childZOrder.len - 1:
    if not foundChild and container.childZOrder[i] == child:
      foundChild = true
    if foundChild:
      container.childZOrder[i] = container.childZOrder[i + 1]

  if foundChild:
    container.childZOrder[^1] = child

func updateFocus*(gui: Gui) =
  if gui.hover != nil:
    if gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right):
      gui.focus = gui.hover
      for i in 0 ..< gui.hoverParents.len - 1:
        gui.hoverParents[i].bringToTop(gui.hoverParents[i + 1])
      gui.hoverParents[^1].bringToTop(gui.focus)

# proc drawChildren*(container: WidgetContainer, gui: Gui) =
#   for child in container.childZOrder:
#     if child of WidgetContainer:
#       child.draw(gui)
#       cast[WidgetContainer](child).drawChildren(gui)
#     else:
#       child.draw(gui)

proc updateChildren*(container: WidgetContainer, gui: Gui) =
  for child in container.childZOrder:
    child.update(child)

proc beginFrame*(gui: Gui) =
  gui.gfx.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.root.size = gui.size
  gui.clearForFrame(gui.root)
  gui.hoverParents.setLen(0)
  gui.containerStack.setLen(0)
  # gui.widgetStack.setLen(0)

proc endFrame*(gui: Gui) =
  gui.hover = gui.getHover(gui.root)
  gui.updateFocus()
  gui.root.updateChildren(gui)
  gui.gfx.endFrame()

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

# func currentWidget*(gui: Gui, T: typedesc = Widget): T =
#   cast[T](
#     if gui.widgetStack.len > 0:
#       gui.widgetStack[gui.widgetStack.len - 1]
#     else:
#       gui.root
#   )

func pushContainer*(gui: Gui, container: WidgetContainer) =
  gui.containerStack.add container

func popContainer*(gui: Gui) =
  gui.containerStack.setLen(gui.containerStack.len - 1)

# func pushWidgetSize*(gui: Gui, size: Vec2) =
#   gui.nextWidgetSizeStack.add size

# func popWidgetSize*(gui: Gui) =
#   gui.nextWidgetSizeStack.setLen(gui.nextWidgetSizeStack.len - 1)

# func nextWidgetBounds*(gui: Gui, container = gui.currentContainer()): Rect2 =
#   const fontHeight = 13.0
#   const widgetInnerPadding = 3.0

#   let padding = gui.theme.containerPadding
#   let spacing = gui.theme.widgetSpacing
#   let last = container.previousChildBounds

#   result.position =
#     if gui.placeNextWidgetInSameRow:
#       vec2(
#         last.x + last.width + spacing,
#         last.y,
#       )
#     else:
#       vec2(
#         padding,
#         if container.childStack.len > 0:
#           last.y + last.height + spacing
#         else:
#           last.y + last.height
#       )

#   result.size =
#     if gui.nextWidgetSizeStack.len == 0:
#       vec2(
#         gui.currentContainer.width - padding * 2.0,
#         fontHeight + widgetInnerPadding * 2.0,
#       )
#     else:
#       gui.nextWidgetSizeStack[gui.nextWidgetSizeStack.len - 1]

# func sameRow*(gui: Gui) =
#   gui.placeNextWidgetInSameRow = true

func addWidget*[T](gui: Gui, id: WidgetId, initialState: T): T {.discardable.} =
  let container = gui.currentContainer

  if container.widgets.hasKey(id):
    result = cast[T](container.widgets[id])
    result.justCreated = false
  else:
    result = initialState
    result.id = id
    result.justCreated = true
    container.widgets[id] = result
    container.childZOrder.add result

  result.parentPosition = container.position + container.parentPosition
  # if not result.isFreelyPositionable:
  #   result.bounds = gui.nextWidgetBounds(container)

  # container.previousChildBounds = result.bounds
  # gui.placeNextWidgetInSameRow = false

  container.childStack.add result
  # gui.widgetStack.add result

func addWidget*[T](gui: Gui, label: string, initialState: T): T {.discardable.} =
  gui.addWidget(hash(label), initialState)

template macroDefinition(name, initialState, behavior: untyped): untyped {.dirty.} =
  template widgetInjection(gui, widget, idString, code: untyped): untyped =
    let `widget` {.inject.} = gui.addWidget(idString, initialState)
    widget.update = proc(widgetBase: Widget) =
      let `widget` {.inject.} = cast[initialState.typeof](widgetBase)
      behavior

  macro `name`*(gui: Gui, widget, iteration, code: untyped): untyped =
    let idStr = widget.strVal
    let id = quote do:
      `idStr` & "_iteration_" & $`iteration`
    getAst(widgetInjection(gui, widget, id, code))

  macro `name`*(gui: Gui, widget, code: untyped): untyped =
    getAst(widgetInjection(gui, widget, widget.strVal, code))

macro implementWidget*(name, initialState, behavior: untyped): untyped =
  getAst(macroDefinition(name, initialState, behavior))

func drawFrameWithoutHeader*(gfx: Gfx,
                             bounds: Rect2,
                             borderThickness: float,
                             cornerRadius: float,
                             bodyColor, borderColor: Color) =
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(gfx)

  let leftOuter = bounds.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = bounds.x + bounds.width
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = bounds.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let bottomOuter = bounds.y + bounds.height
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Body fill.
  gfx.beginPath()
  gfx.roundedRect(
    rect2(
      leftMiddle,
      topMiddle,
      rightMiddle - leftMiddle,
      bottomMiddle - topMiddle,
    ),
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(bounds, cornerRadius)

  # Body inner hole.
  gfx.roundedRect(
    rect2(
      leftInner,
      topInner,
      rightInner - leftInner,
      bottomInner - topInner,
    ),
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
  )
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()

func drawFrameWithHeader*(gfx: Gfx,
                          bounds: Rect2,
                          borderThickness, headerHeight: float,
                          cornerRadius: float,
                          bodyColor, headerColor, borderColor: Color) =
  let headerHeight = headerHeight.pixelAlign(gfx)
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(gfx)

  let leftOuter = bounds.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = bounds.x + bounds.width
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = bounds.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let headerOuter = bounds.y + headerHeight
  let headerMiddle = headerOuter - halfBorderThickness
  let headerInner = headerMiddle - halfBorderThickness
  let bottomOuter = bounds.y + bounds.height
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let innerWidth = rightInner - leftInner
  let middleWidth = rightMiddle - leftMiddle

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Header fill.
  gfx.beginPath()
  gfx.roundedRect(
    rect2(
      leftMiddle,
      topMiddle,
      middleWidth,
      headerMiddle - topMiddle,
    ),
    middleCornerRadius,
    middleCornerRadius,
    0, 0,
  )
  gfx.fillColor = headerColor
  gfx.fill()

  # Body fill.
  gfx.beginPath()
  gfx.roundedRect(
    rect2(
      leftMiddle,
      headerMiddle,
      middleWidth,
      bottomMiddle - headerMiddle,
    ),
    0, 0,
    middleCornerRadius,
    middleCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(bounds, cornerRadius)

  # Header inner hole.
  gfx.roundedRect(
    rect2(
      leftInner,
      topInner,
      innerWidth,
      headerInner - topInner,
    ),
    innerCornerRadius,
    innerCornerRadius,
    0, 0,
  )
  gfx.pathWinding = Hole

  # Body inner hole.
  gfx.roundedRect(
    rect2(
      leftInner,
      headerOuter,
      innerWidth,
      bottomInner - headerOuter,
    ),
    0, 0,
    innerCornerRadius,
    innerCornerRadius,
  )
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()