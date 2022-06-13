{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import ../ui; export ui

type
  WidgetId* = Hash

  Widget* = ref object of RootObj
    isFreelyPositionable*: bool
    isReadyForDraw*: bool
    bounds*: Rect2
    relativePosition*: Vec2
    minimumSize*: Vec2

  WidgetContainer* = ref object of Widget
    widgets*: Table[WidgetId, Widget]
    widgetZOrder*: seq[Widget]
    widgetDeclarationOrder*: seq[Widget]

  Gui* = ref object
    osWindow*: Window
    root*: WidgetContainer
    containerStack*: seq[WidgetContainer]
    widgetStack*: seq[Widget]
    hover*: Widget
    hoverParents*: seq[WidgetContainer]
    focus*: Widget

method draw*(widget: Widget, gui: Gui) {.base.} = discard

template position*(widget: Widget): auto = widget.bounds.position
template size*(widget: Widget): auto = widget.bounds.size
template x*(widget: Widget): auto = widget.bounds.position.x
template y*(widget: Widget): auto = widget.bounds.position.y
template width*(widget: Widget): auto = widget.bounds.size.x
template height*(widget: Widget): auto = widget.bounds.size.y

func newGui*(osWindow: Window): Gui =
  Gui(osWindow: osWindow, root: WidgetContainer())

template gfx*(gui: Gui): Gfx = gui.osWindow.gfx
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

func drawChildrenInRows*(gui: Gui, container: WidgetContainer) =
  let bounds = container.bounds
  let padding = 5.0
  let paddingX2 = padding * 2.0
  let spacing = 5.0

  let widgetArea = rect2(
    bounds.x + padding,
    bounds.y + padding,
    bounds.width - paddingX2,
    bounds.height - paddingX2,
  )

  let childCount = container.widgetZOrder.len
  let childYAdvance = widgetArea.height / childCount.float
  var childBounds = rect2(
    widgetArea.x,
    widgetArea.y,
    widgetArea.width,
    childYAdvance - spacing,
  )

  for child in container.widgetDeclarationOrder:
    if child.isFreelyPositionable:
      child.bounds.position = bounds.position + child.relativePosition
    else:
      child.bounds = childBounds
      childBounds.position.y += childYAdvance

    if child.isReadyForDraw:
      child.draw(gui)

    child.isReadyForDraw = true

func getHover(gui: Gui, container: WidgetContainer): Widget =
  for i in countdown(container.widgetZOrder.len - 1, 0, 1):
    let child = container.widgetZOrder[i]
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

func clearForFrame(gui: Gui, widget: Widget) =
  if widget of WidgetContainer:
    let container = cast[WidgetContainer](widget)
    container.widgetDeclarationOrder.setLen(0)
    for child in container.widgetZOrder:
      gui.clearForFrame(child)

func bringToTop(container: WidgetContainer, child: Widget) =
  var foundChild = false

  for i in 0 ..< container.widgetZOrder.len - 1:
    if not foundChild and container.widgetZOrder[i] == child:
      foundChild = true
    if foundChild:
      container.widgetZOrder[i] = container.widgetZOrder[i + 1]

  if foundChild:
    container.widgetZOrder[^1] = child

func updateFocus(gui: Gui) =
  if gui.hover != nil:
    if gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right):
      gui.focus = gui.hover
      for i in 0 ..< gui.hoverParents.len - 1:
        gui.hoverParents[i].bringToTop(gui.hoverParents[i + 1])
      gui.hoverParents[^1].bringToTop(gui.focus)

proc beginFrame*(gui: Gui) =
  gui.root.bounds.size = gui.osWindow.size
  gui.clearForFrame(gui.root)
  gui.hoverParents.setLen(0)
  gui.containerStack.setLen(0)
  gui.widgetStack.setLen(0)

proc endFrame*(gui: Gui) =
  gui.hover = gui.getHover(gui.root)
  gui.updateFocus()
  gui.drawChildrenInRows(gui.root)

func currentContainer*(gui: Gui, T: typedesc = WidgetContainer): T =
  cast[T](
    if gui.containerStack.len > 0:
      gui.containerStack[gui.containerStack.len - 1]
    else:
      gui.root
  )

func currentWidget*(gui: Gui, T: typedesc = Widget): T =
  cast[T](
    if gui.widgetStack.len > 0:
      gui.widgetStack[gui.widgetStack.len - 1]
    else:
      gui.root
  )

func pushContainer*(gui: Gui, container: WidgetContainer) =
  gui.containerStack.add container

func popContainer*(gui: Gui) =
  gui.containerStack.setLen(gui.containerStack.len - 1)

func getWidget*[T](gui: Gui, id: WidgetId, initialState: T): auto =
  var res: T

  let container = gui.currentContainer

  if container.widgets.hasKey(id):
    res = cast[T](container.widgets[id])
  else:
    res = initialState
    container.widgets[id] = res
    container.widgetZOrder.add res

  gui.widgetStack.add res
  container.widgetDeclarationOrder.add res

  res

func getWidget*[T](gui: Gui, label: string, initialState: T): auto =
  gui.getWidget(hash(label), initialState)

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