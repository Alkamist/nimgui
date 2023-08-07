import std/math
import std/times
import std/algorithm
import std/strformat
import opengl
import nanovg
import oswindow; export oswindow
import rect
import vec2; export vec2
import color; export color
import paint; export paint
import path; export path

proc toNvgColor(color: Color): NVGcolor =
  NVGcolor(r: color.r, g: color.g, b: color.b, a: color.a)

proc toNvgPaint(paint: Paint): NVGpaint =
  for i, value in paint.transform: result.xform[i] = value
  for i, value in paint.extent: result.extent[i] = value
  result.radius = paint.radius
  result.feather = paint.feather
  result.innerColor = paint.innerColor.toNvgColor
  result.outerColor = paint.outerColor.toNvgColor
  result.image = cint(paint.image)

type
  Widget* = ref object of RootObj

  Layer = object
    zIndex: int
    drawCommands: seq[DrawCommand]
    finalHoverRequest: Widget

  InteractionTracker* = object
    detectedHover*: bool
    detectedMouseOver*: bool

  Glyph* = object
    firstByte*: int
    lastByte*: int
    left*, right*: float
    drawOffsetX*: float

  Font* = ref object
    name*: string
    data*: string

  DrawCommandKind* = enum
    FillPath
    StrokePath
    FillText
    Clip

  FillPathCommand* = object
    path*: type Path()[]
    position*: Vec2
    paint*: Paint

  StrokePathCommand* = object
    path*: type Path()[]
    position*: Vec2
    paint*: Paint
    strokeWidth*: float

  FillTextCommand* = object
    font*: Font
    fontSize*: float
    position*: Vec2
    text*: string
    color*: Color

  ClipCommand* = object
    position*: Vec2
    size*: Vec2

  DrawCommand* = object
    case kind*: DrawCommandKind
    of FillPath: fillPath*: FillPathCommand
    of StrokePath: strokePath*: StrokePathCommand
    of FillText: fillText*: FillTextCommand
    of Clip: clip*: ClipCommand

  Window* = ref object of OsWindow
    onFrame*: proc(window: Window)
    backgroundColor*: Color

    time*: float
    previousTime*: float
    clientAreaHovered*: bool
    globalMousePosition*: Vec2
    previousGlobalMousePosition*: Vec2
    rootMousePosition*: Vec2
    mouseWheelState*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    hover*: Widget
    mouseOver*: Widget
    hoverCapture*: Widget

    highestZIndex*: int

    offsetStack: seq[Vec2]
    clipStack: seq[Rect]
    layerStack: seq[Layer]
    interactionTrackerStack: seq[InteractionTracker]
    layers: seq[Layer]

    defaultFont*: Font

    currentFont: Font
    currentFontSize: float = 16.0
    nvgCtx: NVGcontext

    cachedContentScale: float = 1.0

    loadedFonts: seq[Font]

var currentWindow* {.threadvar.}: Window

proc mouseDelta*(window: Window): Vec2 = window.globalMousePosition - window.previousGlobalMousePosition
proc deltaTime*(window: Window): float = window.time - window.previousTime
proc mouseDown*(window: Window, button: MouseButton): bool = window.mouseDownStates[button]
proc keyDown*(window: Window, key: KeyboardKey): bool = window.keyDownStates[key]
proc mouseWheel*(window: Window): Vec2 = window.mouseWheelState
proc mouseMoved*(window: Window): bool = window.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(window: Window): bool = window.mouseWheelState != vec2(0, 0)
proc mousePressed*(window: Window, button: MouseButton): bool = button in window.mousePresses
proc mouseReleased*(window: Window, button: MouseButton): bool = button in window.mouseReleases
proc anyMousePressed*(window: Window): bool = window.mousePresses.len > 0
proc anyMouseReleased*(window: Window): bool = window.mouseReleases.len > 0
proc keyPressed*(window: Window, key: KeyboardKey): bool = key in window.keyPresses
proc keyReleased*(window: Window, key: KeyboardKey): bool = key in window.keyReleases
proc anyKeyPressed*(window: Window): bool = window.keyPresses.len > 0
proc anyKeyReleased*(window: Window): bool = window.keyReleases.len > 0

proc currentLayer(window: Window): var Layer =
  window.layerStack[^1]

proc isHovered*(window: Window, widget: Widget): bool =
  window.hover == widget

proc mouseIsOver*(window: Window, widget: Widget): bool =
  window.mouseOver == widget

proc requestHover*(window: Window, widget: Widget) =
  window.currentLayer.finalHoverRequest = widget

  if window.hover == widget:
    window.interactionTrackerStack[^1].detectedHover = true

  if window.mouseOver == widget:
    window.interactionTrackerStack[^1].detectedMouseOver = true

proc captureHover*(window: Window, widget: Widget) =
  if window.hoverCapture == nil:
    window.hoverCapture = widget

proc releaseHover*(window: Window, widget: Widget) =
  if window.hoverCapture == widget:
    window.hoverCapture = nil

proc currentZIndex*(window: Window): int =
  window.currentLayer.zIndex

proc currentOffset*(window: Window): Vec2 =
  window.offsetStack[^1]

proc currentClip*(window: Window, global = false): Rect =
  result = window.clipStack[^1]
  if not global:
    result.position -= window.currentOffset

proc interactionTracker*(window: Window): InteractionTracker =
  window.interactionTrackerStack[^1]

proc mousePosition*(window: Window): Vec2 =
  window.globalMousePosition - window.currentOffset

proc beginInteractionTracker*(window: Window) =
  window.interactionTrackerStack.add(InteractionTracker())

proc endInteractionTracker*(window: Window): InteractionTracker {.discardable.} =
  result = window.interactionTrackerStack.pop()
  if result.detectedHover:
    window.interactionTrackerStack[^1].detectedHover = true
  if result.detectedMouseOver:
    window.interactionTrackerStack[^1].detectedMouseOver = true

proc beginOffset*(window: Window, offset: Vec2, global = false) =
  if global:
    window.offsetStack.add(offset)
  else:
    window.offsetStack.add(window.currentOffset + offset)

proc endOffset*(window: Window): Vec2 {.discardable.} =
  window.offsetStack.pop()

proc beginClip*(window: Window, position, size: Vec2, global = false, intersect = true) =
  var rect = (position: position, size: size)

  if not global:
    rect.position += window.currentOffset

  if intersect:
    rect = rect.intersect(window.clipStack[^1])

  window.clipStack.add(rect)
  window.currentLayer.drawCommands.add(DrawCommand(kind: Clip, clip: ClipCommand(
    position: rect.position,
    size: rect.size,
  )))

proc endClip*(window: Window): Rect {.discardable.} =
  result = window.clipStack.pop()

  if window.clipStack.len == 0:
    return

  let clipRect = window.clipStack[^1]
  window.currentLayer.drawCommands.add(DrawCommand(kind: Clip, clip: ClipCommand(
    position: clipRect.position,
    size: clipRect.size,
  )))

proc beginZIndex*(window: Window, zIndex: int, global = false) =
  if global:
    window.layerStack.add(Layer(zIndex: zIndex))
  else:
    window.layerStack.add(Layer(zIndex: window.currentZIndex + zIndex))

proc endZIndex*(window: Window): int {.discardable.} =
  let layer = window.layerStack.pop()
  window.layers.add(layer)
  layer.zIndex

proc mouseHitTest*(window: Window, position, size: Vec2): bool =
  let m = window.mousePosition
  m.x >= position.x and m.x <= position.x + size.x and
  m.y >= position.y and m.y <= position.y + size.y and
  window.currentClip.contains(window.mousePosition)

proc width*(glyph: Glyph): float =
  glyph.right - glyph.left

proc setFont(window: Window, font: Font) =
  if not (font in window.loadedFonts):
    let id = nvgCreateFontMem(window.nvgCtx, cstring(font.name), cstring(font.data), cint(font.data.len), 0)
    if id == -1:
      debugEcho &"Failed to load font: {font.name}"
      return
    window.loadedFonts.add(font)

  if font == window.currentFont:
    return

  nvgFontFace(window.nvgCtx, cstring(font.name))
  window.currentFont = font

proc setFontSize(window: Window, fontSize: float) =
  if fontSize == window.currentFontSize:
    return
  nvgFontSize(window.nvgCtx, fontSize)
  window.currentFontSize = fontSize

proc textMetrics*(window: Window, font: Font, fontSize: float): tuple[ascender, descender, lineHeight: float] =
  window.setFont(font)
  window.setFontSize(fontSize)
  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(window.nvgCtx, addr(ascender), addr(descender), addr(lineHeight))
  (float(ascender), float(descender), float(lineHeight))

proc measureGlyphs*(window: Window, text: openArray[char], font: Font, fontSize: float): seq[Glyph] =
  if text.len == 0:
    return

  window.setFont(font)
  window.setFontSize(fontSize)

  var nvgPositions = newSeq[NVGglyphPosition](text.len)
  let positionCount = nvgTextGlyphPositions(
    window.nvgCtx, 0, 0,
    cast[cstring](unsafeAddr(text[0])),
    cast[cstring](cast[uint64](unsafeAddr(text[text.len - 1])) + 1),
    addr(nvgPositions[0]),
    cint(text.len),
  )

  result = newSeq[Glyph](positionCount)

  for i in 0 ..< positionCount:
    let byteOffset = cast[uint64](unsafeAddr(text[0]))

    let lastByte =
      if i == positionCount - 1:
        text.len - 1
      else:
        int(cast[uint64](nvgPositions[i + 1].str) - byteOffset - 1)

    result[i] = Glyph(
      firstByte: int(cast[uint64](nvgPositions[i].str) - byteOffset),
      lastByte: lastByte,
      left: nvgPositions[i].minx,
      right: nvgPositions[i].maxx,
      drawOffsetX: nvgPositions[i].x - nvgPositions[i].minx,
    )

proc renderTextRaw(nvgCtx: NVGcontext, x, y: float, data: openArray[char]) =
  if data.len == 0:
    return
  discard nvgText(
    nvgCtx,
    x, y,
    cast[cstring](unsafeAddr(data[0])),
    cast[cstring](cast[uint64](unsafeAddr(data[data.len - 1])) + 1),
  )

proc processPath(nvgCtx: NVGcontext, path: type Path()[]) =
  nvgBeginPath(nvgCtx)
  for command in path.commands:
    case command.kind:
    of Close:
      nvgClosePath(nvgCtx)
    of Rect:
      let c = command.rect
      nvgRect(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)
    of RoundedRect:
      let c = command.roundedRect
      nvgRoundedRectVarying(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y, c.rTopLeft, c.rTopRight, c.rBottomRight, c.rBottomLeft)
    of MoveTo:
      let c = command.moveTo
      nvgMoveTo(nvgCtx, c.position.x, c.position.y)
    of LineTo:
      let c = command.lineTo
      nvgLineTo(nvgCtx, c.position.x, c.position.y)
    of ArcTo:
      let c = command.arcTo
      nvgArcTo(nvgCtx, c.p0.x, c.p0.y, c.p1.x, c.p1.y, c.radius)
    of Winding:
      let c = command.winding
      let value = case c.winding:
        of PathWinding.Positive: cint(1)
        of PathWinding.Negative: cint(2)
      nvgPathWinding(nvgCtx, value)

proc renderDrawCommands*(window: Window, commands: openArray[DrawCommand]) =
  let nvgCtx = window.nvgCtx
  for command in commands:
    case command.kind:
    of FillPath:
      let c = command.fillPath
      nvgSave(nvgCtx)
      nvgTranslate(nvgCtx, c.position.x, c.position.y)
      processPath(nvgCtx, c.path)
      nvgFillPaint(nvgCtx, c.paint.toNvgPaint)
      nvgFill(nvgCtx)
      nvgRestore(nvgCtx)
    of StrokePath:
      let c = command.strokePath
      nvgSave(nvgCtx)
      nvgTranslate(nvgCtx, c.position.x, c.position.y)
      processPath(nvgCtx, c.path)
      nvgStrokeWidth(nvgCtx, c.strokeWidth)
      nvgStrokePaint(nvgCtx, c.paint.toNvgPaint)
      nvgStroke(nvgCtx)
      nvgRestore(nvgCtx)
    of FillText:
      var c = command.fillText
      window.setFont(c.font)
      window.setFontSize(c.fontSize)
      nvgFillColor(nvgCtx, c.color.toNvgColor)
      renderTextRaw(nvgCtx, c.position.x, c.position.y, c.text)
    of Clip:
      let c = command.clip
      nvgScissor(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)

proc pixelAlign*(window: Window, value: float): float =
  let contentScale = window.cachedContentScale
  round(value * contentScale) / contentScale

proc pixelAlign*(window: Window, position: Vec2): Vec2 =
  vec2(window.pixelAlign(position.x), window.pixelAlign(position.y))

proc fillPath*(window: Window, path: Path, paint: Paint) =
  window.currentLayer.drawCommands.add(DrawCommand(kind: FillPath, fillPath: FillPathCommand(
    path: path[],
    paint: paint,
    position: window.pixelAlign(window.currentOffset),
  )))

proc fillPath*(window: Window, path: Path, color: Color) =
  window.fillPath(path, solidColorPaint(color))

proc strokePath*(window: Window, path: Path, paint: Paint, strokeWidth = 1.0) =
  window.currentLayer.drawCommands.add(DrawCommand(kind: StrokePath, strokePath: StrokePathCommand(
    path: path[],
    paint: paint,
    strokeWidth: strokeWidth,
    position: window.pixelAlign(window.currentOffset),
  )))

proc strokePath*(window: Window, path: Path, color: Color, strokeWidth = 1.0) =
  window.strokePath(path, solidColorPaint(color), strokeWidth)

proc fillTextLine*(window: Window,
  text: string,
  position: Vec2,
  color = rgb(255, 255, 255),
  font = window.defaultFont,
  fontSize = 13.0,
) =
  window.currentLayer.drawCommands.add(DrawCommand(kind: FillText, fillText: FillTextCommand(
    font: font,
    fontSize: fontSize,
    position: window.pixelAlign(window.currentOffset + position),
    text: text,
    color: color,
  )))

proc beginFrame(window: Window) =
  currentWindow = window

  let bg = window.backgroundColor
  glClearColor(bg.r, bg.g, bg.b, bg.a)
  glClear(GL_COLOR_BUFFER_BIT)

  let size = window.size
  glViewport(0, 0, GLsizei(size.x), GLsizei(size.y))

  nvgBeginFrame(window.nvgCtx, window.size.x, window.size.y, window.contentScale)
  nvgTextAlign(window.nvgCtx, NVG_ALIGN_LEFT or NVG_ALIGN_TOP)
  window.currentFont = window.defaultFont
  window.currentFontSize = 16.0

  window.time = cpuTime()
  window.cachedContentScale = window.contentScale

  window.beginZIndex(0, global = true)
  window.beginOffset(vec2(0, 0), global = true)
  window.beginClip(vec2(0, 0), size, global = true, intersect = false)
  window.interactionTrackerStack.add(InteractionTracker())

proc endFrame(window: Window) =
  discard window.interactionTrackerStack.pop()
  window.endClip()
  window.endOffset()
  window.endZIndex()

  nvgEndFrame(window.nvgCtx)

  assert(window.offsetStack.len == 0)
  assert(window.layerStack.len == 0)
  assert(window.clipStack.len == 0)
  assert(window.interactionTrackerStack.len == 0)

  # The layers are in reverse order because they were added in popZIndex.
  # Sort preserves the order of layers with the same z index, so they
  # must first be reversed and then sorted to keep that ordering in tact.
  window.layers.reverse()
  window.layers.sort(proc(x, y: Layer): int =
    cmp(x.zIndex, y.zIndex)
  )

  window.hover = nil
  window.mouseOver = nil
  window.highestZIndex = low(int)

  for layer in window.layers:
    if layer.zIndex > window.highestZIndex:
      window.highestZIndex = layer.zIndex

    window.renderDrawCommands(layer.drawCommands)
    let hoverRequest = layer.finalHoverRequest
    if hoverRequest != nil:
      window.hover = hoverRequest
      window.mouseOver = hoverRequest

  if window.hoverCapture != nil:
    window.hover = window.hoverCapture

  window.layers.setLen(0)

  window.mousePresses.setLen(0)
  window.mouseReleases.setLen(0)
  window.keyPresses.setLen(0)
  window.keyReleases.setLen(0)
  window.textInput.setLen(0)
  window.mouseWheelState = vec2(0, 0)
  window.previousGlobalMousePosition = window.globalMousePosition
  window.previousTime = window.time

proc open*(window: Window): bool {.discardable.} =
  if not oswindow.open(window):
    return false

  window.loadedFonts.setLen(0)
  window.userData = cast[pointer](window)

  window.activateContext()
  window.nvgCtx = nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES)

  window.backendCallbacks.onClose = proc(oswindow: OsWindow) =
    let window = cast[Window](oswindow.userData)
    nvgDelete(window.nvgCtx)

  window.backendCallbacks.onMouseMove = proc(oswindow: OsWindow, position, rootPosition: Vec2) =
    let window = cast[Window](oswindow.userData)
    window.globalMousePosition = position
    window.rootMousePosition = rootPosition

  window.backendCallbacks.onMouseEnter = proc(oswindow: OsWindow) =
    let window = cast[Window](oswindow.userData)
    window.clientAreaHovered = true

  window.backendCallbacks.onMouseExit = proc(oswindow: OsWindow) =
    let window = cast[Window](oswindow.userData)
    window.clientAreaHovered = false

  window.backendCallbacks.onMouseWheel = proc(oswindow: OsWindow, amount: Vec2) =
    let window = cast[Window](oswindow.userData)
    window.mouseWheelState = amount

  window.backendCallbacks.onMousePress = proc(oswindow: OsWindow, button: MouseButton) =
    let window = cast[Window](oswindow.userData)
    window.mouseDownStates[button] = true
    window.mousePresses.add(button)

  window.backendCallbacks.onMouseRelease = proc(oswindow: OsWindow, button: MouseButton) =
    let window = cast[Window](oswindow.userData)
    window.mouseDownStates[button] = false
    window.mouseReleases.add(button)

  window.backendCallbacks.onKeyPress = proc(oswindow: OsWindow, key: KeyboardKey) =
    let window = cast[Window](oswindow.userData)
    window.keyDownStates[key] = true
    window.keyPresses.add(key)

  window.backendCallbacks.onKeyRelease = proc(oswindow: OsWindow, key: KeyboardKey) =
    let window = cast[Window](oswindow.userData)
    window.keyDownStates[key] = false
    window.keyReleases.add(key)

  window.backendCallbacks.onText = proc(oswindow: OsWindow, text: string) =
    let window = cast[Window](oswindow.userData)
    window.textInput &= text

  window.backendCallbacks.onDraw = proc(oswindow: OsWindow) =
    let window = cast[Window](oswindow.userData)
    window.beginFrame()
    if window.onFrame != nil:
      window.onFrame(window)
    window.endFrame()