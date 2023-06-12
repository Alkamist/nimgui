{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import std/algorithm
import ./math; export math
import ./layout
import ./vectorgraphics; export vectorgraphics
import oswindow; export oswindow

type
  GuiId* = Hash

  GuiState* = ref object of RootObj
    id*: GuiId
    init*: bool

  GuiControl* = ref object of GuiState
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    previousEngage: bool

  GuiLayer = object
    vg: VectorGraphics
    offset: Vec2
    zIndex: int
    finalHover: GuiId

  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    globalMousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    defaultItemSize*: Vec2
    itemSpacing*: Vec2

    hover*: GuiId
    focus*: GuiId
    currentId*: GuiId
    currentBounds*: Rect2
    highestZIndex*: int
    cursorStyle*: CursorStyle

    retainedState: Table[GuiId, GuiState]

    idStack: seq[GuiId]
    layoutStack: seq[GuiLayout]
    layerStack: seq[GuiLayer]
    layers: seq[GuiLayer]

    vgCtx: VectorGraphicsContext

    previousTime: float
    previousGlobalMousePosition: Vec2

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

proc getId*[T: not GuiId](gui: Gui, x: T): GuiId =
  if gui.idStack.len > 0:
    result = !$(gui.idStack[^1] !& hash(x))
  else:
    result = hash(x)
  gui.currentId = result

proc beginIdSpace*(gui: Gui, id: GuiId) =
  gui.idStack.add(id)

proc beginIdSpace*(gui: Gui, str: string) =
  gui.beginIdSpace(gui.getId(str))

proc endIdSpace*(gui: Gui) =
  discard gui.idStack.pop()

proc currentIdSpace*(gui: Gui): GuiId =
  gui.idStack[gui.idStack.len - 1]

proc currentLayer(gui: Gui): var GuiLayer =
  gui.layerStack[gui.layerStack.len - 1]

proc mousePosition*(gui: Gui): Vec2 =
  gui.globalMousePosition - gui.currentLayer.offset

proc vg*(gui: Gui): VectorGraphics =
  gui.currentLayer.vg

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

proc currentLayout(gui: Gui): var GuiLayout =
  gui.layoutStack[gui.layoutStack.len - 1]

proc row*(gui: Gui, widths: openArray[float], height: float) =
  gui.currentLayout.row(widths, height)

proc getNextBounds*(gui: Gui): Rect2 =
  result = gui.currentLayout.getNextBounds()
  gui.currentBounds = result

proc beginLayout*(gui: Gui, bounds: Rect2, scroll = vec2(0, 0)) =
  gui.layoutStack.add GuiLayout(
    itemSpacing: gui.itemSpacing,
    defaultItemSize: gui.defaultItemSize,
    bounds: rect2(
      bounds.x - scroll.x, bounds.y - scroll.y,
      bounds.width, bounds.height,
    ),
    max: vec2(low(float), low(float)),
  )
  gui.row([0.0], 0.0)

proc endLayout*(gui: Gui) =
  discard gui.layoutStack.pop()

proc beginColumn*(gui: Gui) =
  gui.beginLayout(gui.getNextBounds(), vec2(0, 0))

proc endColumn*(gui: Gui) =
  let b = gui.layoutStack.pop()
  var a = gui.layoutStack[gui.layoutStack.len - 1]
  a.rowSize.x = max(a.rowSize.x, b.rowSize.x + b.bounds.x - a.bounds.x)
  a.nextRow = max(a.nextRow, b.nextRow + b.bounds.y - a.bounds.y)
  a.max.x = max(a.max.x, b.max.x)
  a.max.y = max(a.max.y, b.max.y)
  gui.layoutStack[gui.layoutStack.len - 1] = a

proc setNextBounds*(gui: Gui, bounds: Rect2, positioning = GuiPositioning.Relative) =
  gui.currentLayout.setNextBounds(bounds, positioning)

proc beginLayer*(gui: Gui, offset = vec2(0, 0), zIndex = 0) =
  gui.layerStack.add(GuiLayer(
    vg: VectorGraphics.new(),
    offset: offset,
    zIndex: zIndex,
  ))

proc endLayer*(gui: Gui) =
  gui.layers.add(gui.layerStack.pop())

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()
  result.defaultItemSize = vec2(50, 50)
  result.itemSpacing = vec2(10, 20)

proc beginFrame*(gui: Gui, time: float) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)

  gui.previousTime = gui.time
  gui.time = time
  gui.cursorStyle = Arrow

  gui.beginLayer()
  gui.beginLayout(rect2(vec2(0, 0), gui.size), vec2(0, 0))

proc endFrame*(gui: Gui) =
  gui.endLayout()
  gui.endLayer()

  assert(gui.idStack.len == 0)
  assert(gui.layoutStack.len == 0)
  assert(gui.layerStack.len == 0)

  gui.layers.reverse() # The layers are in reverse order because they were added in endLayer.
  gui.layers.sort do (x, y: GuiLayer) -> int:
    cmp(x.zIndex, y.zIndex)

  gui.hover = 0

  for layer in gui.layers:
    gui.vgCtx.renderVectorGraphics(layer.vg, layer.offset)
    if layer.finalHover != 0:
      gui.hover = layer.finalHover

  let highestZIndex = gui.layers[gui.layers.len - 1].zIndex
  if highestZIndex > gui.highestZIndex:
    gui.highestZIndex = highestZIndex

  gui.layers.setLen(0)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.previousGlobalMousePosition = gui.globalMousePosition

  gui.vgCtx.endFrame()

proc control*(gui: Gui, id: GuiId, hover, engage: bool): GuiControl =
  let control = gui.getState(id, GuiControl)

  let press = engage and not control.previousEngage
  let release = control.previousEngage and not engage
  control.previousEngage = engage

  # Update gui hover.
  if engage and not press and gui.hover == id:
    gui.hover = 0

  # Main logic.
  control.pressed = false
  control.released = false
  control.clicked = false

  if gui.hover == id and not control.isDown and press:
    control.isDown = true
    control.pressed = true

  if control.isDown and release:
    control.isDown = false
    control.released = true
    if gui.hover == id:
      control.clicked = true

  if hover:
    gui.currentLayer.finalHover = id

  # Update gui focus.
  if control.pressed:
    gui.focus = id

  if press and gui.focus == id and gui.hover != id:
    gui.focus = 0

  control