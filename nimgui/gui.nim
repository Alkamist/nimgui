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

  GuiControl* = ref object of GuiState
    position*: Vec2
    size*: Vec2

  GuiClip* = object
    position*: Vec2
    size*: Vec2

  GuiZLayer* = object
    vg*: VectorGraphics
    zIndex*: int
    finalHover*: GuiId

  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    cursorStyle*: CursorStyle

    # Input
    globalMousePosition*: Vec2
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
    currentId*: GuiId
    retainedState*: Table[GuiId, GuiState]
    idStack*: seq[GuiId]

    # Z index
    highestZIndex*: int
    zLayerStack*: seq[GuiZLayer]
    zLayers*: seq[GuiZLayer]

    # Offset
    offsetStack*: seq[Vec2]
    globalPositionOffset*: Vec2

    # Clipping
    clipStack*: seq[GuiClip]

    # Vector graphics
    vgCtx*: VectorGraphicsContext

    # Previous frame state
    previousTime*: float
    previousGlobalMousePosition*: Vec2

proc mouseDelta*(gui: Gui): Vec2 = gui.globalMousePosition - gui.previousGlobalMousePosition
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

proc mousePosition*(gui: Gui): Vec2 =
  gui.globalMousePosition - gui.globalPositionOffset


# ======================================================================
# Ids and State
# ======================================================================


proc getId*(gui: Gui, x: auto): GuiId =
  if gui.idStack.len > 0:
    result = !$(gui.idStack[^1] !& hash(x))
  else:
    result = hash(x)
  gui.currentId = result

proc pushId*(gui: Gui, id: GuiId) = gui.idStack.add(id)
proc pushId*(gui: Gui, id: string) = gui.idStack.add(gui.getId(id))
proc popId*(gui: Gui) = discard gui.idStack.pop()
proc stackId*(gui: Gui): GuiId = gui.idStack[gui.idStack.len - 1]

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.id = id
    gui.retainedState[id] = result

proc getState*[X: not GuiId](gui: Gui, x: X, T: typedesc): T =
  gui.getState(gui.getId(x), T)


# ======================================================================
# Z Index
# ======================================================================


proc currentZIndex*(gui: Gui): int = gui.zLayerStack[^1].zIndex
proc requestHover*(gui: Gui, id: GuiId) = gui.zLayerStack[^1].finalHover = id
proc clearHover*(gui: Gui) = gui.hover = 0
proc vg*(gui: Gui): VectorGraphics = gui.zLayerStack[^1].vg

proc pushZIndex*(gui: Gui, zIndex: int) =
  gui.zLayerStack.add(GuiZLayer(
    vg: VectorGraphics.new(),
    zIndex: zIndex,
  ))

proc popZIndex*(gui: Gui) =
  let layer = gui.zLayerStack.pop()
  gui.zLayers.add(layer)

# proc splitWidth*(gui: Gui, divisions: auto): float =
#   let layout = gui.layout
#   let full = layout.bounds.size.x
#   let spacing = layout.spacing.x
#   let divisions = float(divisions)
#   (full - spacing * (divisions - 1.0)) / divisions


# ======================================================================
# Offset
# ======================================================================


proc pushOffset*(gui: Gui, offset: Vec2) =
  gui.offsetStack.add(offset)
  gui.globalPositionOffset += offset
  let vg = gui.vg
  vg.resetTransform()
  vg.translate(gui.globalPositionOffset)

proc popOffset*(gui: Gui) =
  let offset = gui.offsetStack.pop()
  gui.globalPositionOffset -= offset
  let vg = gui.vg
  vg.resetTransform()
  vg.translate(gui.globalPositionOffset)


# ======================================================================
# Clip
# ======================================================================


proc intersect*(a, b: GuiClip): GuiClip =
  let x1 = max(a.position.x, b.position.x)
  let y1 = max(a.position.y, b.position.y)
  var x2 = min(a.position.x + a.size.x, b.position.x + b.size.x)
  var y2 = min(a.position.y + a.size.y, b.position.y + b.size.y)
  if x2 < x1: x2 = x1
  if y2 < y1: y2 = y1
  GuiClip(position: vec2(x1, y1), size: vec2(x2 - x1, y2 - y1))

proc contains*(a: GuiClip, b: Vec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

proc pushClip*(gui: Gui, position, size: Vec2) =
  let clip =
    if gui.clipStack.len == 0:
      GuiClip(position: position + gui.globalPositionOffset, size: size)
    else:
      GuiClip(position: position + gui.globalPositionOffset, size: size).intersect(gui.clipStack[^1])

  gui.clipStack.add(clip)
  gui.vg.clip(clip.position - gui.globalPositionOffset, clip.size)

proc popClip*(gui: Gui) =
  let clip = gui.clipStack.pop()
  gui.vg.clip(clip.position - gui.globalPositionOffset, clip.size)


# ======================================================================
# Control
# ======================================================================


proc x*(control: GuiControl): var float = control.position.x
proc `x=`*(control: GuiControl, value: float) = control.position.x = value
proc y*(control: GuiControl): var float = control.position.y
proc `y=`*(control: GuiControl, value: float) = control.position.y = value
proc width*(control: GuiControl): var float = control.size.x
proc `width=`*(control: GuiControl, value: float) = control.size.x = value
proc height*(control: GuiControl): var float = control.size.y
proc `height=`*(control: GuiControl, value: float) = control.size.y = value

proc mouseIsOver*(gui: Gui, control: GuiControl): bool =
  if not gui.clipStack[^1].contains(gui.globalMousePosition):
    return false

  let m = gui.mousePosition
  let c = control
  m.x >= c.x and m.x <= c.x + c.width and
  m.y >= c.y and m.y <= c.y + c.height


# ======================================================================
# Gui
# ======================================================================


proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(gui: Gui) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)
  gui.cursorStyle = Arrow
  gui.pushId("Root")
  gui.pushZIndex(0)
  gui.pushClip(vec2(0, 0), gui.size)
  gui.pushOffset(vec2(0, 0))

proc endFrame*(gui: Gui) =
  gui.popOffset()
  gui.popClip()
  gui.popZIndex()
  gui.popId()

  assert(gui.idStack.len == 0)
  assert(gui.zLayerStack.len == 0)
  assert(gui.offsetStack.len == 0)
  assert(gui.clipStack.len == 0)

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

  gui.globalPositionOffset = vec2(0, 0)
  gui.zLayers.setLen(0)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.previousGlobalMousePosition = gui.globalMousePosition
  gui.previousTime = gui.time

  gui.vgCtx.endFrame()