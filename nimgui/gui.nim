{.experimental: "overloadableEnums".}

import std/math
import std/hashes
import std/tables
import std/algorithm
import ./vectorgraphics; export vectorgraphics

type
  CursorStyle* = enum
    Arrow
    IBeam
    Crosshair
    PointingHand
    ResizeLeftRight
    ResizeTopBottom
    ResizeTopLeftBottomRight
    ResizeTopRightBottomLeft

  MouseButton* = enum
    Unknown,
    Left, Middle, Right,
    Extra1, Extra2, Extra3,
    Extra4, Extra5,

  KeyboardKey* = enum
    Unknown,
    A, B, C, D, E, F, G, H, I,
    J, K, L, M, N, O, P, Q, R,
    S, T, U, V, W, X, Y, Z,
    Key1, Key2, Key3, Key4, Key5,
    Key6, Key7, Key8, Key9, Key0,
    Pad1, Pad2, Pad3, Pad4, Pad5,
    Pad6, Pad7, Pad8, Pad9, Pad0,
    F1, F2, F3, F4, F5, F6, F7,
    F8, F9, F10, F11, F12,
    Backtick, Minus, Equal, Backspace,
    Tab, CapsLock, Enter, LeftShift,
    RightShift, LeftControl, RightControl,
    LeftAlt, RightAlt, LeftMeta, RightMeta,
    LeftBracket, RightBracket, Space,
    Escape, Backslash, Semicolon, Quote,
    Comma, Period, Slash, ScrollLock,
    Pause, Insert, End, PageUp, Delete,
    Home, PageDown, LeftArrow, RightArrow,
    DownArrow, UpArrow, NumLock, PadDivide,
    PadMultiply, PadSubtract, PadAdd, PadEnter,
    PadPeriod, PrintScreen,

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

  StateHolder[T] = ref object of RootRef
    value: T

  Layer = object
    zIndex: int
    drawCommands: seq[DrawCommand]
    finalHoverRequest: GuiId

  InteractionTracker* = object
    detectedHover*: bool
    detectedMouseOver*: bool

  Gui* = ref object
    cursorStyle*: CursorStyle
    backendData*: pointer
    onFrame*: proc(gui: Gui)

    # Input
    currentlyIsHovered: bool
    currentTime: float
    currentContentScale: float
    currentSize: Vec2
    currentGlobalMousePosition: Vec2
    mouseWheelState: Vec2
    mousePresses: seq[MouseButton]
    mouseReleases: seq[MouseButton]
    mouseDownStates: array[MouseButton, bool]
    keyPresses: seq[KeyboardKey]
    keyReleases: seq[KeyboardKey]
    keyDownStates: array[KeyboardKey, bool]
    textInput: string

    # State and ids
    hover: GuiId
    mouseOver: GuiId
    hoverCapture: GuiId
    retainedState: Table[GuiId, RootRef]

    # Stacks
    idStack: seq[GuiId]
    offsetStack: seq[Vec2]
    clipRectStack: seq[ClipRect]
    layerStack: seq[Layer]
    interactionTrackerStack: seq[InteractionTracker]

    # Layer
    layers: seq[Layer]

    # Vector graphics
    vgCtx: VectorGraphicsContext

    # Previous frame state
    previousTime: float
    previousGlobalMousePosition: Vec2

proc inputTime*(gui: Gui, time: float) =
  gui.currentTime = time

proc inputContentScale*(gui: Gui, scale: float) =
  gui.currentContentScale = scale

proc inputSize*(gui: Gui, x, y: float) =
  gui.currentSize = vec2(x, y)

proc inputMouseMove*(gui: Gui, x, y: float) =
  gui.currentGlobalMousePosition = vec2(x, y)

proc inputMouseEnter*(gui: Gui) =
  gui.currentlyIsHovered = true

proc inputMouseExit*(gui: Gui) =
  gui.currentlyIsHovered = false

proc inputMouseWheel*(gui: Gui, x, y: float) =
  gui.mouseWheelState = vec2(x, y)

proc inputMousePress*(gui: Gui, button: MouseButton) =
  gui.mouseDownStates[button] = true
  gui.mousePresses.add(button)

proc inputMouseRelease*(gui: Gui, button: MouseButton) =
  gui.mouseDownStates[button] = false
  gui.mouseReleases.add(button)

proc inputKeyPress*(gui: Gui, key: KeyboardKey) =
  gui.keyDownStates[key] = true
  gui.keyPresses.add(key)

proc inputKeyRelease*(gui: Gui, key: KeyboardKey) =
  gui.keyDownStates[key] = false
  gui.keyReleases.add(key)

proc inputText*(gui: Gui, text: string) =
  gui.textInput &= text

proc isHovered*(gui: Gui): bool = gui.currentlyIsHovered
proc time*(gui: Gui): float = gui.currentTime
proc contentScale*(gui: Gui): float = gui.currentContentScale
proc size*(gui: Gui): Vec2 = gui.currentSize
proc globalMousePosition*(gui: Gui): Vec2 = gui.currentGlobalMousePosition
proc mouseDelta*(gui: Gui): Vec2 = gui.currentGlobalMousePosition - gui.previousGlobalMousePosition
proc deltaTime*(gui: Gui): float = gui.currentTime - gui.previousTime
proc mouseDown*(gui: Gui, button: MouseButton): bool = gui.mouseDownStates[button]
proc keyDown*(gui: Gui, key: KeyboardKey): bool = gui.keyDownStates[key]
proc mouseWheel*(gui: Gui): Vec2 = gui.mouseWheelState
proc mouseMoved*(gui: Gui): bool = gui.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(gui: Gui): bool = gui.mouseWheelState != vec2(0, 0)
proc mousePressed*(gui: Gui, button: MouseButton): bool = button in gui.mousePresses
proc mouseReleased*(gui: Gui, button: MouseButton): bool = button in gui.mouseReleases
proc anyMousePressed*(gui: Gui): bool = gui.mousePresses.len > 0
proc anyMouseReleased*(gui: Gui): bool = gui.mouseReleases.len > 0
proc keyPressed*(gui: Gui, key: KeyboardKey): bool = key in gui.keyPresses
proc keyReleased*(gui: Gui, key: KeyboardKey): bool = key in gui.keyReleases
proc anyKeyPressed*(gui: Gui): bool = gui.keyPresses.len > 0
proc anyKeyReleased*(gui: Gui): bool = gui.keyReleases.len > 0

proc currentLayer(gui: Gui): var Layer =
  gui.layerStack[^1]

proc zIndex*(gui: Gui): int =
  gui.currentLayer.zIndex

proc offset*(gui: Gui): Vec2 =
  gui.offsetStack[^1]

proc idSpace*(gui: Gui): GuiId =
  gui.idStack[^1]

proc clipRect*(gui: Gui, global = false): ClipRect =
  result = gui.clipRectStack[^1]
  if not global:
    result.position -= gui.offset

proc interactionTracker*(gui: Gui): InteractionTracker =
  gui.interactionTrackerStack[^1]

proc mousePosition*(gui: Gui): Vec2 =
  gui.currentGlobalMousePosition - gui.offset

proc isHovered*(gui: Gui, id: GuiId): bool =
  gui.hover == id

proc mouseIsOver*(gui: Gui, id: GuiId): bool =
  gui.mouseOver == id

proc requestHover*(gui: Gui, id: GuiId) =
  gui.currentLayer.finalHoverRequest = id

  if gui.isHovered(id):
    gui.interactionTrackerStack[^1].detectedHover = true

  if gui.mouseIsOver(id):
    gui.interactionTrackerStack[^1].detectedMouseOver = true

proc captureHover*(gui: Gui, id: GuiId) =
  if gui.hoverCapture == 0:
    gui.hoverCapture = id

proc releaseHover*(gui: Gui, id: GuiId) =
  if gui.hoverCapture == id:
    gui.hoverCapture = 0

proc pushInteractionTracker*(gui: Gui) =
  gui.interactionTrackerStack.add(InteractionTracker())

proc popInteractionTracker*(gui: Gui): InteractionTracker {.discardable.} =
  result = gui.interactionTrackerStack.pop()
  if result.detectedHover:
    gui.interactionTrackerStack[^1].detectedHover = true
  if result.detectedMouseOver:
    gui.interactionTrackerStack[^1].detectedMouseOver = true

proc getId*(gui: Gui, x: auto, global = false): GuiId =
  if global:
    hash(x)
  else:
    !$(gui.idStack[^1] !& hash(x))

proc pushIdSpace*(gui: Gui, id: GuiId) =
  gui.idStack.add(id)

proc popIdSpace*(gui: Gui): GuiId {.discardable.} =
  gui.idStack.pop()

proc getState*[T](gui: Gui, id: GuiId, initialValue: T): T =
  if gui.retainedState.hasKey(id):
    when T is RootRef:
      T(gui.retainedState[id])
    else:
      StateHolder[T](gui.retainedState[id]).value
  else:
    when T is RootRef:
      gui.retainedState[id] = initialValue
      initialValue
    else:
      gui.retainedState[id] = StateHolder[T](value: initialValue)
      initialValue

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  gui.getState(id, T())

proc setState*[T](gui: Gui, id: GuiId, value: T) =
  when T is RootRef:
    gui.retainedState[id] = value
  else:
    if gui.retainedState.hasKey(id):
      StateHolder[T](gui.retainedState[id]).value = value
    else:
      gui.retainedState[id] = StateHolder[T](value: value)

proc pushOffset*(gui: Gui, offset: Vec2, global = false) =
  if global:
    gui.offsetStack.add(offset)
  else:
    gui.offsetStack.add(gui.offset + offset)

proc popOffset*(gui: Gui): Vec2 {.discardable.} =
  gui.offsetStack.pop()

proc pushClipRect*(gui: Gui, position, size: Vec2, global = false, intersect = true) =
  var clipRect = ClipRect(
    position: position,
    size: size,
  )

  if not global:
    clipRect.position += gui.offset

  if intersect:
    clipRect = clipRect.intersect(gui.clipRectStack[^1])

  gui.clipRectStack.add(clipRect)

  gui.currentLayer.drawCommands.add(DrawCommand(kind: Clip, clip: ClipCommand(
    position: clipRect.position,
    size: clipRect.size,
  )))

proc popClipRect*(gui: Gui): ClipRect {.discardable.} =
  result = gui.clipRectStack.pop()

  if gui.clipRectStack.len == 0:
    return

  let clipRect = gui.clipRectStack[^1]
  gui.currentLayer.drawCommands.add(DrawCommand(kind: Clip, clip: ClipCommand(
    position: clipRect.position,
    size: clipRect.size,
  )))

proc pushZIndex*(gui: Gui, zIndex: int, global = false) =
  if global:
    gui.layerStack.add(Layer(zIndex: zIndex))
  else:
    gui.layerStack.add(Layer(zIndex: gui.zIndex + zIndex))

proc popZIndex*(gui: Gui): int {.discardable.} =
  let layer = gui.layerStack.pop()
  gui.layers.add(layer)
  layer.zIndex

proc mouseHitTest*(gui: Gui, position, size: Vec2): bool =
  let m = gui.mousePosition
  m.x >= position.x and m.x <= position.x + size.x and
  m.y >= position.y and m.y <= position.y + size.y and
  gui.clipRect.contains(gui.mousePosition)

proc beginPadding*(gui: Gui, position, size, padding: Vec2): tuple[position, size: Vec2] =
  result.position = vec2(
    min(position.x + size.x * 0.5, position.x + padding.x),
    min(position.y + size.y * 0.5, position.y + padding.y),
  )
  result.size = vec2(
    max(0, size.x - padding.x * 2),
    max(0, size.y - padding.y * 2),
  )
  gui.pushOffset(result.position)

proc endPadding*(gui: Gui) =
  gui.popOffset()

proc setupVectorGraphics*(gui: Gui) =
  gui.vgCtx = VectorGraphicsContext.new()

proc new*(_: typedesc[Gui]): Gui =
  Gui(currentContentScale: 1.0)

proc beginFrame*(gui: Gui) =
  gui.vgCtx.beginFrame(gui.currentSize, gui.currentContentScale)
  gui.cursorStyle = Arrow

  gui.pushIdSpace(gui.getId("Root", global = true))
  gui.pushZIndex(0, global = true)
  gui.pushOffset(vec2(0, 0), global = true)
  gui.pushClipRect(vec2(0, 0), gui.currentSize, global = true, intersect = false)
  gui.interactionTrackerStack.add(InteractionTracker())

proc endFrame*(gui: Gui) =
  discard gui.interactionTrackerStack.pop()
  gui.popClipRect()
  gui.popOffset()
  gui.popZIndex()
  gui.popIdSpace()

  assert(gui.idStack.len == 0)
  assert(gui.offsetStack.len == 0)
  assert(gui.layerStack.len == 0)
  assert(gui.clipRectStack.len == 0)
  assert(gui.interactionTrackerStack.len == 0)

  # The layers are in reverse order because they were added in popZIndex.
  # Sort preserves the order of layers with the same z index, so they
  # must first be reversed and then sorted to keep that ordering in tact.
  gui.layers.reverse()
  gui.layers.sort(proc(x, y: Layer): int =
    cmp(x.zIndex, y.zIndex)
  )

  gui.hover = 0
  gui.mouseOver = 0

  for layer in gui.layers:
    gui.vgCtx.renderDrawCommands(layer.drawCommands)
    let hoverRequest = layer.finalHoverRequest
    if hoverRequest != 0:
      gui.hover = hoverRequest
      gui.mouseOver = hoverRequest

  if gui.hoverCapture != 0:
    gui.hover = gui.hoverCapture

  gui.layers.setLen(0)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheelState = vec2(0, 0)
  gui.previousGlobalMousePosition = gui.currentGlobalMousePosition
  gui.previousTime = gui.currentTime

  gui.vgCtx.endFrame()


# ======================================================================
# Vector graphics
# ======================================================================


proc pixelAlign*(gui: Gui, globalValue: float): float =
  let currentContentScale = gui.currentContentScale
  round(globalValue * currentContentScale) / currentContentScale

proc pixelAlign*(gui: Gui, globalPosition: Vec2): Vec2 =
  vec2(gui.pixelAlign(globalPosition.x), gui.pixelAlign(globalPosition.y))

proc fillPath*(gui: Gui, path: Path, paint: Paint) =
  gui.currentLayer.drawCommands.add(DrawCommand(kind: FillPath, fillPath: FillPathCommand(
    path: path[],
    paint: paint,
    position: gui.pixelAlign(gui.offset),
  )))

proc fillPath*(gui: Gui, path: Path, color: Color) =
  gui.fillPath(path, solidColorPaint(color))

proc strokePath*(gui: Gui, path: Path, paint: Paint, strokeWidth = 1.0) =
  gui.currentLayer.drawCommands.add(DrawCommand(kind: StrokePath, strokePath: StrokePathCommand(
    path: path[],
    paint: paint,
    strokeWidth: strokeWidth,
    position: gui.pixelAlign(gui.offset),
  )))

proc strokePath*(gui: Gui, path: Path, color: Color, strokeWidth = 1.0) =
  gui.strokePath(path, solidColorPaint(color), strokeWidth)

proc addFont*(gui: Gui, data: string): Font {.discardable.} =
  gui.vgCtx.addFont(data)

proc measureGlyphs*(gui: Gui, text: openArray[char], font: Font, fontSize: float): seq[Glyph] =
  gui.vgCtx.measureGlyphs(text, font, fontSize)

proc textMetrics*(gui: Gui, font: Font, fontSize: float): TextMetrics =
  gui.vgCtx.textMetrics(font, fontSize)

proc fillTextRaw*(gui: Gui, text: string,
  position: Vec2,
  color = rgb(255, 255, 255),
  font = Font(0),
  fontSize = 13.0,
) =
  gui.currentLayer.drawCommands.add(DrawCommand(kind: FillText, fillText: FillTextCommand(
    font: font,
    fontSize: fontSize,
    position: gui.pixelAlign(gui.offset + position),
    text: text,
    color: color,
  )))

iterator splitLinesIndices(s: openArray[char]): tuple[first, last: int] =
  var first = 0
  var last = 0
  var eolpos = 0
  while true:
    while last < s.len and s[last] notin {'\c', '\l'}: inc(last)

    eolpos = last
    if last < s.len:
      if s[last] == '\l': inc(last)
      elif s[last] == '\c':
        inc(last)
        if last < s.len and s[last] == '\l': inc(last)

    yield (first, eolpos - 1)

    # no eol characters consumed means that the string is over
    if eolpos == last:
      break

    first = last

proc fillText*(gui: Gui, text: openArray[char],
  position: Vec2,
  size = vec2(0, 0),
  alignment = vec2(0, 0),
  color = rgb(255, 255, 255),
  font = Font(0),
  fontSize = 13.0,
) =
  if text.len == 0:
    return

  let lineHeight = gui.textMetrics(font, fontSize).lineHeight

  let clipRect = gui.clipRect
  # let clipLeft = clipRect.position.x
  # let clipRight = clipRect.position.x + clipRect.size.x
  let clipTop = clipRect.position.y
  let clipBottom = clipRect.position.y + clipRect.size.y

  var linePosition = position
  linePosition.y += (size.y - lineHeight) * alignment.y

  for first, last in text.splitLinesIndices:
    if linePosition.y >= clipBottom:
      return

    if linePosition.y + lineHeight < clipTop or first == last:
      linePosition.y += lineHeight
      continue

    var alignmentXOffset = 0.0
    if size.x > 0:
      var glyphs = gui.measureGlyphs(text.toOpenArray(first, last), font, fontSize)
      if glyphs.len == 0:
        linePosition.y += lineHeight
        continue

      for glyph in glyphs.mitems:
        glyph.firstByte += first
        glyph.lastByte += first

      let leftOverSpaceAtEndOfLine = size.x - glyphs[^1].right
      alignmentXOffset = alignment.x * leftOverSpaceAtEndOfLine

    let line = cast[string](text[first .. last])
    gui.fillTextRaw(line, linePosition + vec2(alignmentXOffset, 0), color, font, fontSize)

    linePosition.y += lineHeight