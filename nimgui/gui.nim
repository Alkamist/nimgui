{.experimental: "overloadableEnums".}

import std/algorithm
import ./common; export common
import ./vec2; export vec2
import ./color; export color
import ./implnanovg; export implnanovg
import ./imploswindow; export imploswindow

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
# Draw Commands
# ======================================================================


template commands(gui: Gui): untyped =
  gui.zLayerStack[^1].drawCommands

proc beginPath*(gui: Gui) = gui.commands.add(DrawCommand(kind: BeginPath))
proc closePath*(gui: Gui) = gui.commands.add(DrawCommand(kind: ClosePath))
proc fill*(gui: Gui) = gui.commands.add(DrawCommand(kind: Fill))
proc stroke*(gui: Gui) = gui.commands.add(DrawCommand(kind: Stroke))
proc resetTransform*(gui: Gui) = gui.commands.add(DrawCommand(kind: ResetTransform))

proc pathMoveTo*(gui: Gui, position: Vec2) =
  gui.commands.add(DrawCommand(kind: MoveTo, moveTo: MoveToCommand(position: position)))

proc pathLineTo*(gui: Gui, position: Vec2) =
  gui.commands.add(DrawCommand(kind: LineTo, lineTo: LineToCommand(position: position)))

proc pathArcTo*(gui: Gui, p0, p1: Vec2, radius: float) =
  gui.commands.add(DrawCommand(kind: ArcTo, arcTo: ArcToCommand(p0: p0, p1: p1, radius: radius)))

proc pathRect*(gui: Gui, position, size: Vec2) =
  gui.commands.add(DrawCommand(kind: Rect, rect: RectCommand(position: position, size: size)))

proc pathRoundedRect*(gui: Gui, position, size: Vec2, rTopLeft, rTopRight, rBottomRight, rBottomLeft: float) =
  gui.commands.add(DrawCommand(kind: RoundedRect, roundedRect: RoundedRectCommand(
    position: position, size: size,
    rTopLeft: rTopLeft, rTopRight: rTopRight, rBottomRight: rBottomRight, rBottomLeft: rBottomLeft
  )))

proc pathRoundedRect*(gui: Gui, position, size: Vec2, rounding: float) =
  gui.pathRoundedRect(position, size, rounding, rounding, rounding, rounding)

proc visuallyClip*(gui: Gui, position, size: Vec2) =
  gui.commands.add(DrawCommand(kind: Clip, clip: ClipCommand(position: position, size: size)))

proc visuallyTranslate*(gui: Gui, amount: Vec2) =
  gui.commands.add(DrawCommand(kind: Translate, translate: TranslateCommand(amount: amount)))

proc drawTextLine*(gui: Gui, position: Vec2, text: string) =
  gui.commands.add(DrawCommand(kind: Text, text: TextCommand(
    font: gui.currentFont,
    fontSize: gui.currentFontSize,
    position: position,
    data: text,
  )))

proc `fillColor=`*(gui: Gui, color: Color) =
  gui.commands.add(DrawCommand(kind: FillColor, fillColor: FillColorCommand(color: color)))

proc `strokeColor=`*(gui: Gui, color: Color) =
  gui.commands.add(DrawCommand(kind: StrokeColor, strokeColor: StrokeColorCommand(color: color)))

proc `strokeWidth=`*(gui: Gui, width: float) =
  gui.commands.add(DrawCommand(kind: StrokeWidth, strokeWidth: StrokeWidthCommand(width: width)))

proc updateTextMetrics(gui: Gui) =
  gui.vgCtx.setFont(gui.currentFont)
  gui.vgCtx.setFontSize(gui.currentFontSize)
  let metrics = gui.vgCtx.calculateTextMetrics()
  gui.textAscender = metrics.ascender
  gui.textDescender = metrics.descender
  gui.lineHeight = metrics.lineHeight

proc addFont*(gui: Gui, data: string): GuiFont {.discardable.} =
  result = gui.vgCtx.addFont(data)
  gui.currentFont = result

proc font*(gui: Gui): GuiFont =
  gui.currentFont

proc fontSize*(gui: Gui): float =
  gui.currentFontSize

proc `font=`*(gui: Gui, font: GuiFont) =
  gui.currentFont = font
  gui.updateTextMetrics()

proc `fontSize=`*(gui: Gui, size: float) =
  gui.currentFontSize = size
  gui.updateTextMetrics()

# template textGlyphs*(gui: Gui, text: openArray[char]): untyped =
#   gui.vgCtx.textGlyphs(text)

proc measureText*(gui: Gui, position: Vec2, text: openArray[char]): seq[GuiTextMeasurement] =
  gui.vgCtx.measureText(position, text)


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

proc pushZIndex*(gui: Gui, zIndex: int) =
  gui.zLayerStack.add(GuiZLayer(zIndex: zIndex))

proc popZIndex*(gui: Gui) =
  let layer = gui.zLayerStack.pop()
  gui.zLayers.add(layer)


# ======================================================================
# Offset
# ======================================================================


proc pushOffset*(gui: Gui, offset: Vec2) =
  gui.offsetStack.add(offset)
  gui.globalPositionOffset += offset
  gui.resetTransform()
  gui.visuallyTranslate(gui.globalPositionOffset)

proc popOffset*(gui: Gui) =
  let offset = gui.offsetStack.pop()
  gui.globalPositionOffset -= offset
  gui.resetTransform()
  gui.visuallyTranslate(gui.globalPositionOffset)


# ======================================================================
# Clip
# ======================================================================

# Clip rects are stored in global coordinates so
# they can easily be intersected with each other.

# The current clip rect in relative coordinates.
proc currentClip*(gui: Gui): GuiClip =
  result = gui.clipStack[^1]
  result.position -= gui.globalPositionOffset

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
  gui.visuallyClip(clip.position - gui.globalPositionOffset, clip.size)

proc popClip*(gui: Gui) =
  discard gui.clipStack.pop()

  # let clip = gui.clipStack.pop()
  # gui.beginPath()
  # gui.pathRect(clip.position + vec2(0.5, 0.5), clip.size - vec2(1.0, 1.0))
  # gui.strokeColor = rgb(0, 255, 0)
  # gui.stroke()

  if gui.clipStack.len > 0:
    let previousClip = gui.clipStack[^1]
    gui.visuallyClip(previousClip.position - gui.globalPositionOffset, previousClip.size)


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
  result.vgCtx = GuiVectorGraphicsContext.new()
  result.currentFontSize = 13.0

proc beginFrame*(gui: Gui) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)
  gui.cursorStyle = Arrow
  gui.pushId("Root")
  gui.pushZIndex(0)
  gui.pushClip(vec2(0, 0), gui.size)
  gui.pushOffset(vec2(0, 0))

  if gui.originalFontSize == 0:
    gui.originalFontSize = gui.currentFontSize
  else:
    gui.currentFontSize = gui.originalFontSize

  gui.updateTextMetrics()

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
    gui.renderDrawCommands(layer.drawCommands)
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