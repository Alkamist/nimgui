import std/math
import std/hashes
import std/tables
# import std/strutils
# import std/algorithm
import oswindow; export oswindow
import ./vectorgraphics; export vectorgraphics

type
  ClipRect* = object
    position*: Vec2
    size*: Vec2

proc intersect*(a, b: ClipRect): ClipRect =
  let x1 = max(a.position.x, b.position.x)
  let y1 = max(a.position.y, b.position.y)
  var x2 = min(a.position.x + a.size.x, b.position.x + b.size.x)
  var y2 = min(a.position.y + a.size.y, b.position.y + b.size.y)
  if x2 < x1: x2 = x1
  if y2 < y1: y2 = y1
  ClipRect(position: vec2(x1, y1), size: vec2(x2 - x1, y2 - y1))

proc contains*(a: ClipRect, b: Vec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

type
  GuiId* = Hash

  GuiStateHolder*[T] = ref object of RootRef
    value*: T

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

    # State and ids
    hover: GuiId
    mouseOver: GuiId
    hoverCapture: GuiId
    retainedState: Table[GuiId, RootRef]
    idStack: seq[GuiId]
    finalHoverRequest: GuiId

    # Offset
    offsetStack: seq[Vec2]

    # Vector graphics
    vgCtx: VectorGraphicsContext
    drawCommands: seq[DrawCommand]

    # Previous frame state
    previousTime: float
    previousGlobalMousePosition: Vec2

proc mouseDelta*(gui: Gui): Vec2 = gui.globalMousePosition - gui.previousGlobalMousePosition
proc deltaTime*(gui: Gui): float = gui.time - gui.previousTime
proc mouseDown*(gui: Gui, button: MouseButton): bool = gui.mouseDownStates[button]
proc keyDown*(gui: Gui, key: KeyboardKey): bool = gui.keyDownStates[key]
proc mouseWheel*(gui: Gui): Vec2 = gui.mouseWheel
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

proc currentOffset*(gui: Gui): Vec2 =
  gui.offsetStack[^1]

proc mousePosition*(gui: Gui): Vec2 =
  gui.globalMousePosition - gui.currentOffset

proc isHovered*(gui: Gui, id: GuiId): bool =
  gui.hover == id

proc mouseIsOver*(gui: Gui, id: GuiId): bool =
  gui.mouseOver == id

proc requestHover*(gui: Gui, id: GuiId) =
  gui.finalHoverRequest = id

proc captureHover*(gui: Gui, id: GuiId) =
  if gui.hoverCapture == 0:
    gui.hoverCapture = id

proc releaseHover*(gui: Gui, id: GuiId) =
  if gui.hoverCapture == id:
    gui.hoverCapture = 0

proc getGlobalId*(gui: Gui, x: auto): GuiId =
  hash(x)

proc getId*(gui: Gui, x: auto): GuiId =
  if gui.idStack.len > 0:
    result = !$(gui.idStack[^1] !& hash(x))
  else:
    result = hash(x)

proc pushId*(gui: Gui, id: GuiId) = gui.idStack.add(id)
proc popId*(gui: Gui): GuiId {.discardable.} = gui.idStack.pop()

proc getState*[T](gui: Gui, id: GuiId, initialValue: T): T =
  if gui.retainedState.hasKey(id):
    GuiStateHolder[T](gui.retainedState[id]).value
  else:
    gui.retainedState[id] = GuiStateHolder[T](value: initialValue)
    initialValue

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  gui.getState(id, T())

proc setState*[T](gui: Gui, id: GuiId, value: T) =
  GuiStateHolder[T](gui.retainedState[id]).value = value

proc pushOffset*(gui: Gui, offset: Vec2, global = false) =
  if global:
    gui.offsetStack.add(offset)
  else:
    gui.offsetStack.add(gui.currentOffset + offset)

proc popOffset*(gui: Gui): Vec2 {.discardable.} =
  gui.offsetStack.pop()

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(gui: Gui) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)
  gui.cursorStyle = Arrow
  gui.finalHoverRequest = 0

  gui.pushId(gui.getGlobalId("Root"))
  gui.pushOffset(vec2(0, 0), global = true)

proc endFrame*(gui: Gui) =
  gui.popOffset()
  gui.popId()

  assert(gui.offsetStack.len == 0)
  assert(gui.idStack.len == 0)

  gui.vgCtx.renderDrawCommands(gui.drawCommands)

  let hoverRequest = gui.finalHoverRequest

  if gui.hoverCapture != 0:
    gui.hover = gui.hoverCapture
  else:
    gui.hover = hoverRequest

  gui.mouseOver = hoverRequest

  gui.drawCommands.setLen(0)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.previousGlobalMousePosition = gui.globalMousePosition
  gui.previousTime = gui.time

  gui.vgCtx.endFrame()


# ======================================================================
# Vector graphics
# ======================================================================


proc pixelAlign*(gui: Gui, globalValue: float): float =
  let scale = gui.scale
  round(globalValue * scale) / scale

proc pixelAlign*(gui: Gui, globalPosition: Vec2): Vec2 =
  vec2(gui.pixelAlign(globalPosition.x), gui.pixelAlign(globalPosition.y))

proc fillPath*(gui: Gui, path: Path, paint: Paint) =
  gui.drawCommands.add(DrawCommand(kind: FillPath, fillPath: FillPathCommand(
    path: path[],
    paint: paint,
    position: gui.currentOffset,
  )))

proc fillPath*(gui: Gui, path: Path, color: Color) =
  gui.fillPath(path, solidColorPaint(color))

proc strokePath*(gui: Gui, path: Path, paint: Paint, strokeWidth = 1.0) =
  gui.drawCommands.add(DrawCommand(kind: StrokePath, strokePath: StrokePathCommand(
    path: path[],
    paint: paint,
    strokeWidth: strokeWidth,
    position: gui.currentOffset,
  )))

proc strokePath*(gui: Gui, path: Path, color: Color, strokeWidth = 1.0) =
  gui.strokePath(path, solidColorPaint(color), strokeWidth)

proc addFont*(gui: Gui, data: string): Font {.discardable.} =
  gui.vgCtx.addFont(data)

proc measureGlyphs*(gui: Gui, text: openArray[char], font: Font, fontSize: float): seq[Glyph] =
  gui.vgCtx.measureGlyphs(text, font, fontSize)

proc fillTextRaw*(gui: Gui, text: string, position: Vec2, color: Color, font: Font, fontSize: float) =
  gui.drawCommands.add(DrawCommand(kind: FillText, fillText: FillTextCommand(
    font: font,
    fontSize: fontSize,
    position: gui.currentOffset + position,
    text: text,
    color: color,
  )))

# proc fillText*(gui: Gui, text: string, position: Vec2, color = rgb(255, 255, 255), font = Font(0), fontSize = 13.0) =
#   if text.len == 0:
#     return

#   let lineHeight = node.gui.vgCtx.textMetrics(font, fontSize).lineHeight

#   let clipRect = node.clipRect
#   # let clipLeft = clipRect.position.x
#   # let clipRight = clipRect.position.x + clipRect.size.x
#   let clipTop = clipRect.position.y
#   let clipBottom = clipRect.position.y + clipRect.size.y

#   var linePosition = position

#   for line in text.splitLines:
#     if linePosition.y >= clipBottom:
#       return

#     if linePosition.y + lineHeight < clipTop or line == "":
#       linePosition.y += lineHeight
#       continue

#     node.fillTextRaw(line, linePosition, color, font, fontSize)

#     linePosition.y += lineHeight


# ======================================================================
# OsWindow binding
# ======================================================================


const densityPixelDpi = 96.0

proc toScale(dpi: float): float =
  dpi / densityPixelDpi

proc toDensityPixels(pixels: int, dpi: float): float =
  float(pixels) * dpi / densityPixelDpi

proc attachToOsWindow*(gui: Gui, window: OsWindow) =
  GcRef(gui)
  window.userData = cast[pointer](gui)

  let dpi = window.dpi
  gui.scale = dpi.toScale

  let (width, height) = window.size
  gui.size.x = width.toDensityPixels(dpi)
  gui.size.y = height.toDensityPixels(dpi)

  window.onClose = proc(window: OsWindow) =
    let gui = cast[Gui](window.userData)
    GcUnref(gui)

  window.onResize = proc(window: OsWindow, width, height: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.size.x = width.toDensityPixels(dpi)
    gui.size.y = height.toDensityPixels(dpi)

  window.onMouseMove = proc(window: OsWindow, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)
    window.setCursorStyle(gui.cursorStyle)

  window.onMousePress = proc(window: OsWindow, button: MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = true
    gui.mousePresses.add(button)
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = false
    gui.mouseReleases.add(button)
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMouseWheel = proc(window: OsWindow, x, y: float) =
    let gui = cast[Gui](window.userData)
    gui.mouseWheel.x = x
    gui.mouseWheel.y = y

  window.onKeyPress = proc(window: OsWindow, key: KeyboardKey) =
    let gui = cast[Gui](window.userData)
    gui.keyDownStates[key] = true
    gui.keyPresses.add(key)

  window.onKeyRelease = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let gui = cast[Gui](window.userData)
    gui.keyDownStates[key] = false
    gui.keyReleases.add(key)

  window.onTextInput = proc(window: OsWindow, text: string) =
    let gui = cast[Gui](window.userData)
    gui.textInput &= text

  window.onDpiChange = proc(window: OsWindow, dpi: float) =
    let gui = cast[Gui](window.userData)
    gui.scale = dpi.toScale