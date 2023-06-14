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
    max*: Vec2
    spacing*: Vec2
    nextPosition*: Vec2
    rowSize*: Vec2
    widths*: seq[float]
    indexInRow*: int
    nextRow*: float
    indent*: float

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


proc getId*(gui: Gui, x: auto): GuiId =
  when x is GuiId:
    result = x
  else:
    if gui.idStack.len > 0:
      result = !$(gui.idStack[^1] !& hash(x))
    else:
      result = hash(x)
  gui.currentId = result

proc pushId*(gui: Gui, id: auto) = gui.idStack.add(gui.getId(id))
proc popId*(gui: Gui) = discard gui.idStack.pop()
proc stackId*(gui: Gui): GuiId = gui.idStack[gui.idStack.len - 1]

proc getState*(gui: Gui, id: auto, T: typedesc): T =
  let id = gui.getId(id)
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.id = id
    gui.retainedState[id] = result


# ======================================================================
# Z Index
# ======================================================================


proc zLayer(gui: Gui): ptr GuiZLayer =
  addr(gui.zLayerStack[gui.zLayerStack.len - 1])

proc currentZIndex*(gui: Gui): int = gui.zLayer.zIndex
proc requestHover*(gui: Gui, id: auto) = gui.zLayer.finalHover = gui.getId(id)
proc vg*(gui: Gui): VectorGraphics = gui.zLayer.vg

proc pushZIndex*(gui: Gui, zIndex: int) =
  gui.zLayerStack.add(GuiZLayer(
    vg: VectorGraphics.new(),
    zIndex: zIndex,
  ))

proc popZIndex*(gui: Gui) =
  let layer = gui.zLayerStack.pop()
  gui.zLayers.add(layer)


# ======================================================================
# Layout
# ======================================================================


proc layout(gui: Gui): ptr GuiLayout =
  addr(gui.layoutStack[gui.layoutStack.len - 1])

proc newRow(gui: Gui) =
  let layout = gui.layout
  layout.nextPosition.x = layout.indent
  layout.nextPosition.y = layout.nextRow
  layout.indexInRow = 0

proc `rowWidths=`*[T](gui: Gui, widths: openArray[T]) =
  let layout = gui.layout
  layout.widths.setLen(widths.len)
  for i in 0 ..< widths.len:
    layout.widths[i] = float(widths[i])
  gui.newRow()

proc `rowHeight=`*(gui: Gui, height: float) = gui.layout.rowSize.y = height
proc layoutBounds*(gui: Gui): Rect2 = gui.layout.bounds
proc layoutSize*(gui: Gui): Vec2 = gui.layout.bounds.size
proc layoutWidth*(gui: Gui): float = gui.layout.bounds.size.x
proc layoutHeight*(gui: Gui): float = gui.layout.bounds.size.y

proc splitWidth*(gui: Gui, divisions: float): float =
  let layout = gui.layout
  let full = layout.bounds.size.x
  let spacing = layout.spacing.x
  (full - spacing * (divisions - 1.0)) / divisions

proc splitHeight*(gui: Gui, divisions: float): float =
  let layout = gui.layout
  let full = layout.bounds.size.y
  let spacing = layout.spacing.y
  (full - spacing * (divisions - 1.0)) / divisions

# proc evenWidth*(gui: Gui, divisions: float): float =
#   let layout = gui.layout
#   let fullWidth = layout.bounds.size.x
#   let spacing = layout.spacing.x
#   (fullWidth - spacing * (divisions - 1.0)) / divisions

# proc evenHeight*(gui: Gui, divisions: float): float =
#   let layout = gui.layout
#   let fullWidth = layout.bounds.size.y
#   let spacing = layout.spacing.y
#   (fullWidth - spacing * (divisions - 1.0)) / divisions

proc getNextBounds*(gui: Gui): Rect2 =
  let layout = gui.layout

  if layout.indexInRow == layout.widths.len:
    gui.newRow()

  result.position = layout.bounds.position + layout.nextPosition

  result.width =
    if layout.widths.len > 0:
      layout.widths[layout.indexInRow]
    else:
      layout.rowSize.x

  result.height = layout.rowSize.y

  if result.width < 0:
    result.width += layout.bounds.width - result.x + 1

  if result.height < 0:
    result.height += layout.bounds.height - result.y + 1

  layout.indexInRow += 1

  layout.nextPosition.x += result.width + layout.spacing.x
  layout.nextRow = max(layout.nextRow, result.y + result.height + layout.spacing.y)

  layout.max.x = max(layout.max.x, result.x + result.width)
  layout.max.y = max(layout.max.y, result.y + result.height)

proc pushLayout*(gui: Gui, bounds: Rect2) =
  gui.layoutStack.add(GuiLayout(
    bounds: bounds,
    spacing: vec2(3, 3),
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