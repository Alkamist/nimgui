{.experimental: "overloadableEnums".}

import std/hashes; export hashes
import std/tables; export tables
import std/options; export options
import std/algorithm
import ./math; export math
import ./vectorgraphics; export vectorgraphics
import oswindow; export oswindow

type
  GuiId* = Hash

  GuiState* = ref object of RootObj
    id*: GuiId
    init*: bool

  GuiZLayer* = object
    vg*: VectorGraphics
    zIndex*: int
    finalHover*: GuiId

  GuiLayout* = object
    bounds*: Rect2
    itemSize*: Vec2
    itemSpacing*: Vec2
    rowItemIndex*: int
    rowIndex*: int
    itemIsOnSameRow*: bool
    currentRowHeight*: float
    currentRowWidth*: float
    heightOfAllRowsBefore*: float
    nextOffset*: Option[Vec2]
    nextSize*: Option[Vec2]
    nextFreeBounds*: Option[Rect2]

  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    cursorStyle*: CursorStyle

    # Input
    mousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    # Ids and state
    hover*: GuiId
    focus*: GuiId
    currentId*: GuiId
    retainedState*: Table[GuiId, GuiState]
    idStack*: seq[GuiId]

    # Z index
    highestZIndex*: int
    zLayerStack*: seq[GuiZLayer]
    zLayers*: seq[GuiZLayer]

    # Layout
    layoutStack*: seq[GuiLayout]

    # Vector graphics
    vgCtx*: VectorGraphicsContext

    # Previous frame state
    previousTime*: float
    previousMousePosition*: Vec2

proc mouseDelta*(gui: Gui): Vec2 = gui.mousePosition - gui.previousMousePosition
proc deltaTime*(gui: Gui): float = gui.time - gui.previousTime
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


# ======================================================================
# Ids and State
# ======================================================================


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

proc stackId*(gui: Gui): GuiId =
  gui.idStack[gui.idStack.len - 1]

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.id = id
    gui.retainedState[id] = result

proc getState*(gui: Gui, str: string, T: typedesc): T =
  gui.getState(gui.getId(str), T)


# ======================================================================
# Z Index
# ======================================================================


proc zLayer(gui: Gui): ptr GuiZLayer =
  addr(gui.zLayerStack[gui.zLayerStack.len - 1])

proc currentZIndex*(gui: Gui): int =
  gui.zLayer.zIndex

proc requestHover*(gui: Gui, id: GuiId) =
  gui.zLayer.finalHover = id

proc pushZIndex*(gui: Gui, zIndex: int) =
  gui.zLayerStack.add(GuiZLayer(
    vg: VectorGraphics.new(),
    zIndex: zIndex,
  ))

proc popZIndex*(gui: Gui) =
  let layer = gui.zLayerStack.pop()
  gui.zLayers.add(layer)

proc vg*(gui: Gui): VectorGraphics =
  gui.zLayer.vg


# ======================================================================
# Layout
# ======================================================================


proc layout(gui: Gui): ptr GuiLayout =
  addr(gui.layoutStack[gui.layoutStack.len - 1])

proc getNextBounds*(gui: Gui): Rect2 =
  let layout = gui.layout

  if layout.nextFreeBounds.isSome:
    result = layout.nextFreeBounds.get
    layout.nextFreeBounds = none(Rect2)
    return

  if layout.itemIsOnSameRow:
    layout.rowItemIndex += 1
  else:
    layout.heightOfAllRowsBefore += layout.currentRowHeight
    layout.currentRowWidth = 0
    layout.currentRowHeight = 0
    layout.rowIndex += 1
    layout.rowItemIndex = 0

  if layout.nextSize.isSome:
    result.size = layout.nextSize.get
    layout.nextSize = none(Vec2)
  else:
    result.size = layout.itemSize

  result.position = layout.bounds.position

  if layout.nextOffset.isSome:
    result.position += layout.nextOffset.get
    layout.nextOffset = none(Vec2)

  let spacingX = if layout.rowItemIndex > 0: layout.itemSpacing.x else: 0.0
  let spacingY = if layout.rowIndex > 0: layout.itemSpacing.y else: 0.0

  result.position.x += layout.currentRowWidth + spacingX
  result.position.y += layout.heightOfAllRowsBefore + spacingY

  let itemRight = result.position.x + result.size.x
  let itemBottom = result.position.y + result.size.y

  layout.currentRowWidth = max(layout.currentRowWidth, itemRight - layout.bounds.position.x)
  layout.currentRowHeight = max(layout.currentRowHeight, itemBottom - layout.heightOfAllRowsBefore - layout.bounds.position.y)

  layout.itemIsOnSameRow = false

proc peekNextBounds*(gui: Gui): Rect2 =
  let layoutCopy = gui.layout[]
  result = gui.getNextBounds()
  gui.layout[] = layoutCopy

proc sameRow*(gui: Gui) =
  gui.layout.itemIsOnSameRow = true

proc `nextFreeBounds=`*(gui: Gui, bounds: Rect2) =
  gui.layout.nextFreeBounds = some(bounds)

proc `nextOffset=`*(gui: Gui, offset: Vec2) =
  gui.layout.nextOffset = some(offset)

proc `nextPosition=`*(gui: Gui, position: Vec2) =
  gui.nextOffset = position - gui.peekNextBounds.position

proc `nextSize=`*(gui: Gui, size: Vec2) =
  gui.layout.nextSize = some(size)

proc `nextBounds`*(gui: Gui, bounds: Rect2) =
  gui.nextPosition = bounds.position
  gui.nextSize = bounds.size

proc pushLayout*(gui: Gui, bounds: Rect2) =
  gui.layoutStack.add(GuiLayout(
    bounds: bounds.expand(-300),
    itemSize: vec2(96, 32),
    itemSpacing: vec2(5, 5),
  ))

proc popLayout*(gui: Gui) =
  discard gui.layoutStack.pop()


# ======================================================================
# Gui
# ======================================================================


proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(gui: Gui) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)
  gui.cursorStyle = Arrow
  gui.pushZIndex(0)
  gui.pushLayout(rect2(vec2(0, 0), gui.size))

proc endFrame*(gui: Gui) =
  gui.popLayout()
  gui.popZIndex()

  assert(gui.idStack.len == 0)
  assert(gui.layoutStack.len == 0)
  assert(gui.zLayerStack.len == 0)

  gui.zLayers.reverse() # The zLayers are in reverse order because they were added in popZIndex.
  gui.zLayers.sort do (x, y: GuiZLayer) -> int:
    cmp(x.zIndex, y.zIndex)

  gui.hover = 0

  for layer in gui.zLayers:
    gui.vgCtx.renderVectorGraphics(layer.vg)
    if layer.finalHover != 0:
      gui.hover = layer.finalHover

  let highestZIndex = gui.zLayers[gui.zLayers.len - 1].zIndex
  if highestZIndex > gui.highestZIndex:
    gui.highestZIndex = highestZIndex

  gui.zLayers.setLen(0)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.previousMousePosition = gui.mousePosition
  gui.previousTime = gui.time

  gui.vgCtx.endFrame()