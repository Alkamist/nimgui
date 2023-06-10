{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import std/options
import std/algorithm
import ./math
import ./vectorgraphics; export vectorgraphics
import oswindow; export oswindow

const themeItemSize = vec2(50, 50)
const themeSpacing = 5.0

type
  GuiId* = Hash

  GuiState* = ref object of RootObj
    id*: GuiId
    init*: bool

  GuiPositioning* = enum
    Relative
    Absolute

  FreelyPositionedRect2* = object
    positioning*: GuiPositioning
    bounds*: Rect2

  GuiLayout* = object
    bounds*: Rect2
    max*: Vec2
    nextPosition*: Vec2
    rowSize*: Vec2
    widths*: seq[float]
    indexInRow*: int
    nextRow*: float
    indent*: float
    freeBox*: Option[FreelyPositionedRect2]

  GuiContainer* = ref object of GuiState
    vg*: VectorGraphics
    bounds*: Rect2
    scroll*: Vec2
    zIndex*: int
    currentMouseOver*: GuiId
    finalMouseOver*: GuiId

  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    mousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    hover*: GuiId
    hoverContainer*: GuiId
    focus*: GuiId
    currentId*: GuiId
    currentBounds*: Rect2
    highestZIndex*: int

    idStack: seq[GuiId]
    layoutStack: seq[GuiLayout]
    containerStack: seq[GuiContainer]
    activeContainers: seq[GuiContainer]
    retainedState: Table[GuiId, GuiState]
    vgCtx: VectorGraphicsContext

    timePrevious: float
    mousePositionPrevious: Vec2

template position*(container: GuiContainer): untyped = container.bounds.position
template `position=`*(container: GuiContainer, value: untyped): untyped = container.bounds.position = value
template size*(container: GuiContainer): untyped = container.bounds.size
template `size=`*(container: GuiContainer, value: untyped): untyped = container.bounds.size = value
template x*(container: GuiContainer): untyped = container.position.x
template `x=`*(container: GuiContainer, value: untyped): untyped = container.position.x = value
template y*(container: GuiContainer): untyped = container.position.y
template `y=`*(container: GuiContainer, value: untyped): untyped = container.position.y = value
template width*(container: GuiContainer): untyped = container.size.x
template `width=`*(container: GuiContainer, value: untyped): untyped = container.size.x = value
template height*(container: GuiContainer): untyped = container.size.y
template `height=`*(container: GuiContainer, value: untyped): untyped = container.size.y = value

proc mouseDelta*(gui: Gui): Vec2 = gui.mousePosition - gui.mousePositionPrevious
proc deltaTime*(gui: Gui): float = gui.time - gui.timePrevious
proc mouseDown*(gui: Gui, button: MouseButton): bool = gui.mouseDownStates[button]
proc keyDown*(gui: Gui, key: KeyboardKey): bool = gui.keyDownStates[key]
proc mouseMoved*(gui: Gui): bool = gui.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(gui: Gui): bool = gui.mouseWheel != vec2(0, 0)
proc mousePressed*(gui: Gui, button: MouseButton): bool = button in gui.mousePresses
proc mouseReleased*(gui: Gui, button: MouseButton): bool = button in gui.mouseReleases
proc anyMousePressed*(gui: Gui): bool = gui.mousePresses.len > 0
proc anyMouseReleased*(gui: Gui): bool = gui.mouseReleases.len > 0
proc keyPressed*(gui: Gui, key: KeyboardKey): bool = key in gui.keyPresses
proc keyReleased*(gui: Gui, key: KeyboardKey): bool = key in gui.keyReleases
proc anyKeyPressed*(gui: Gui): bool = gui.keyPresses.len > 0
proc anyKeyReleased*(gui: Gui): bool = gui.keyReleases.len > 0

proc currentContainer*(gui: Gui): GuiContainer =
  gui.containerStack[gui.containerStack.len - 1]

proc getId*[T: not GuiId](gui: Gui, x: T): GuiId =
  if gui.idStack.len > 0:
    result = !$(gui.idStack[^1] !& hash(x))
  else:
    result = hash(x)
  gui.currentId = result

proc pushId*(gui: Gui, id: GuiId) =
  gui.idStack.add(id)

proc pushId*(gui: Gui, str: string) =
  gui.pushId(gui.getId(str))

proc popId*(gui: Gui) =
  discard gui.idStack.pop()

proc bringToFront*(gui: Gui, container: GuiContainer) =
  gui.highestZIndex += 1
  container.zIndex = gui.highestZIndex

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.id = id
    when T is GuiContainer:
      result.vg = VectorGraphics.new()
    gui.retainedState[id] = result

proc getState*(gui: Gui, str: string, T: typedesc): T =
  gui.getState(gui.getId(str), T)

proc currentLayout*(gui: Gui): ptr GuiLayout =
  addr(gui.layoutStack[gui.layoutStack.len - 1])

proc newRow(gui: Gui, height: float) =
  let layout = gui.currentLayout
  layout.nextPosition.x = layout.indent
  layout.nextPosition.y = layout.nextRow
  layout.rowSize.y = height
  layout.indexInRow = 0

proc row*(gui: Gui, widths: openArray[float], height: float) =
  let layout = gui.currentLayout
  layout.widths.setLen(widths.len)
  for i in 0 ..< widths.len:
    layout.widths[i] = widths[i]
  gui.newRow(height)

proc getNextBounds*(gui: Gui): Rect2 =
  let layout = gui.currentLayout

  if layout.freeBox.isSome:
    let freeBox = layout.freeBox.get
    layout.freeBox = none(FreelyPositionedRect2)

    result = freeBox.bounds

    if freeBox.positioning == Relative:
      result.x += layout.bounds.x
      result.y += layout.bounds.y

  else:
    if layout.indexInRow == layout.widths.len:
      gui.newRow(layout.rowSize.y)

    result.position = layout.nextPosition

    result.width =
      if layout.widths.len > 0:
        layout.widths[layout.indexInRow]
      else:
        layout.rowSize.x

    result.height = layout.rowSize.y

    if result.width == 0:
      result.width = themeItemSize.x

    if result.height == 0:
      result.height = themeItemSize.y

    if result.width < 0:
      result.width += layout.bounds.width - result.x + 1

    if result.height < 0:
      result.height += layout.bounds.height - result.y + 1

    layout.indexInRow += 1

    layout.nextPosition.x += result.width + themeSpacing
    layout.nextRow = max(layout.nextRow, result.y + result.height + themeSpacing)

    result.x += layout.bounds.x
    result.y += layout.bounds.y

  layout.max.x = max(layout.max.x, result.x + result.width)
  layout.max.y = max(layout.max.y, result.y + result.height)

  gui.currentBounds = result

proc pushLayout*(gui: Gui, bounds: Rect2, scroll: Vec2) =
  gui.layoutStack.add GuiLayout(
    bounds: rect2(
      bounds.x - scroll.x, bounds.y - scroll.y,
      bounds.width, bounds.height,
    ),
    max: vec2(low(float), low(float)),
  )
  gui.row([0.0], 0.0)

proc popLayout*(gui: Gui) =
  discard gui.layoutStack.pop()

proc beginColumn*(gui: Gui) =
  gui.pushLayout(gui.getNextBounds(), vec2(0, 0))

proc endColumn*(gui: Gui) =
  let b = gui.layoutStack.pop()
  let a = gui.currentLayout
  a.rowSize.x = max(a.rowSize.x, b.rowSize.x + b.bounds.x - a.bounds.x)
  a.nextRow = max(a.nextRow, b.nextRow + b.bounds.y - a.bounds.y)
  a.max.x = max(a.max.x, b.max.x)
  a.max.y = max(a.max.y, b.max.y)

proc setNextBounds*(gui: Gui, bounds: Rect2, positioning = GuiPositioning.Relative) =
  gui.currentLayout.freeBox = some(FreelyPositionedRect2(
    positioning: positioning,
    bounds: bounds,
  ))

proc pushContainer*(gui: Gui, container: GuiContainer) =
  gui.containerStack.add(container)
  gui.activeContainers.add(container)
  gui.pushLayout(container.bounds, container.scroll)
  gui.pushId(container.id)

proc popContainer*(gui: Gui) =
  let container = gui.currentContainer
  container.finalMouseOver = container.currentMouseOver
  gui.popId()
  gui.popLayout()
  discard gui.containerStack.pop()

proc vg*(gui: Gui): VectorGraphics =
  gui.currentContainer.vg

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(gui: Gui, time: float) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)

  gui.timePrevious = gui.time
  gui.time = time

  let mainId = gui.getId("MainContainer")
  let mainContainer = gui.getState(mainId, GuiContainer)
  mainContainer.bounds = rect2(vec2(0, 0), gui.size)
  gui.pushId(mainId)
  gui.pushContainer(mainContainer)

proc endFrame*(gui: Gui) =
  gui.popContainer()
  gui.popId()

  assert(gui.idStack.len == 0)
  assert(gui.layoutStack.len == 0)
  assert(gui.containerStack.len == 0)

  gui.activeContainers.sort do (x, y: GuiContainer) -> int:
    cmp(x.zIndex, y.zIndex)

  for container in gui.activeContainers:
    gui.vgCtx.renderVectorGraphics(container.vg)
    if container.bounds.contains(gui.mousePosition):
      gui.hoverContainer = container.id

  gui.activeContainers.setLen(0)

  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.mousePositionPrevious = gui.mousePosition

  gui.vgCtx.endFrame()

proc updateHoverAndFocus*(gui: Gui, id: GuiId, bounds: Rect2) =
  let container = gui.currentContainer
  let mouseOver = bounds.contains(gui.mousePosition) and gui.hoverContainer == container.id
  let mousePressed = gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

  if mouseOver:
    container.currentMouseOver = id

  if container.finalMouseOver == id:
    gui.hover = id

  if not mouseOver and gui.hover == id:
    gui.hover = 0

  if mousePressed and gui.hover == id:
    gui.focus = id

  if mousePressed and not mouseOver and gui.focus == id:
    gui.focus = 0