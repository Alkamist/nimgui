{.experimental: "overloadableEnums".}

import std/algorithm
import ./common; export common
import ./vec2; export vec2
import ./color; export color
import ./paint; export paint
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

proc globalOffset*(gui: Gui): Vec2 =
  if gui.globalOffsetStack.len > 0:
    return gui.globalOffsetStack[^1]

proc mousePosition*(gui: Gui): Vec2 =
  gui.globalMousePosition - gui.globalOffset


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

proc `fillPaint=`*(gui: Gui, paint: Paint) =
  gui.commands.add(DrawCommand(kind: FillPaint, fillPaint: FillPaintCommand(paint: paint)))

proc `strokePaint=`*(gui: Gui, paint: Paint) =
  gui.commands.add(DrawCommand(kind: StrokePaint, strokePaint: StrokePaintCommand(paint: paint)))

proc `pathWinding=`*(gui: Gui, winding: PathWinding) =
  gui.commands.add(DrawCommand(kind: DcPathWinding, pathWinding: PathWindingCommand(winding: winding)))

proc `pathWinding=`*(gui: Gui, solidity: PathSolidity) =
  let winding = case solidity:
    of Solid: CounterClockwise
    of Hole: Clockwise
  gui.commands.add(DrawCommand(kind: DcPathWinding, pathWinding: PathWindingCommand(winding: winding)))

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

proc measureText*(gui: Gui, position: Vec2, text: openArray[char]): seq[GuiTextMeasurement] =
  gui.vgCtx.measureText(position, text)


# ======================================================================
# Offset
# ======================================================================


proc pushOffset*(gui: Gui, offset: Vec2, global = false) =
  let offset =
    if global: offset
    else: gui.globalOffset + offset
  gui.globalOffsetStack.add(offset)
  gui.resetTransform()
  gui.visuallyTranslate(offset)

proc popOffset*(gui: Gui) =
  discard gui.globalOffsetStack.pop()
  gui.resetTransform()
  gui.visuallyTranslate(gui.globalOffset)


# ======================================================================
# Clip
# ======================================================================

# Clip rects are stored in global coordinates so
# they can easily be intersected with each other.

# The current clip rect in relative coordinates.
proc currentClip*(gui: Gui): GuiClip =
  result = gui.globalClipStack[^1]
  result.position -= gui.globalOffset

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
    if gui.globalClipStack.len == 0:
      GuiClip(position: position + gui.globalOffset, size: size)
    else:
      GuiClip(position: position + gui.globalOffset, size: size).intersect(gui.globalClipStack[^1])

  gui.globalClipStack.add(clip)
  gui.visuallyClip(clip.position - gui.globalOffset, clip.size)

proc popClip*(gui: Gui) =
  discard gui.globalClipStack.pop()
  # let clip = gui.globalClipStack.pop()

  # gui.beginPath()
  # gui.pathRect(clip.position + vec2(0.5, 0.5), clip.size - vec2(1.0, 1.0))
  # gui.strokeColor = rgb(0, 255, 0)
  # gui.stroke()

  if gui.globalClipStack.len > 0:
    let previousClip = gui.globalClipStack[^1]
    gui.visuallyClip(previousClip.position - gui.globalOffset, previousClip.size)

proc mouseHitTest*(gui: Gui, position, size: Vec2): bool =
  if not gui.globalClipStack[^1].contains(gui.globalMousePosition):
    return false
  let m = gui.mousePosition
  m.x >= position.x and m.x <= position.x + size.x and
  m.y >= position.y and m.y <= position.y + size.y


# ======================================================================
# Z Index
# ======================================================================


proc globalZIndex*(gui: Gui): int =
  if gui.zLayerStack.len > 0:
    return gui.zLayerStack[^1].zIndex

proc requestHover*(gui: Gui, control: GuiControl) = gui.zLayerStack[^1].finalHover = control
proc clearHover*(gui: Gui) = gui.hover = nil

proc pushZIndex*(gui: Gui, zIndex: int, global = false) =
  let zIndex =
    if global: zIndex
    else: gui.globalZIndex + zIndex
  gui.zLayerStack.add(GuiZLayer(zIndex: zIndex))

proc popZIndex*(gui: Gui) =
  let layer = gui.zLayerStack.pop()
  gui.activeZLayers.add(layer)


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

  assert(gui.zLayerStack.len == 0)
  assert(gui.globalOffsetStack.len == 0)
  assert(gui.globalClipStack.len == 0)

  # The layers are in reverse order because they were added in popZIndex.
  # Sort preserves the order of layers with the same z-index, so they
  # must first be reversed and then sorted to keep that ordering in tact.
  gui.activeZLayers.reverse()
  gui.activeZLayers.sort do (x, y: GuiZLayer) -> int:
    cmp(x.zIndex, y.zIndex)

  gui.hover = nil

  for layer in gui.activeZLayers:
    gui.renderDrawCommands(layer.drawCommands)
    if layer.finalHover != nil:
      gui.hover = layer.finalHover

  let highestZIndex = gui.activeZLayers[gui.activeZLayers.len - 1].zIndex
  if highestZIndex > gui.highestZIndex:
    gui.highestZIndex = highestZIndex

  gui.activeZLayers.setLen(0)
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
# Performance
# ======================================================================


type
  GuiPerformance* = ref object
    gui {.cursor.}: Gui
    frameTime*: float
    index: int
    deltaTimes: seq[float]

proc newPerformance*(gui: Gui): GuiPerformance =
  GuiPerformance(gui: gui)

proc fps*(performance: GuiPerformance): float =
  1.0 / performance.frameTime

proc update*(performance: GuiPerformance, averageWindow = 100) =
  if performance.deltaTimes.len < averageWindow:
    performance.index = 0
    performance.deltaTimes = newSeq[float](averageWindow)

  performance.deltaTimes[performance.index] = performance.gui.deltaTime
  performance.index += 1
  if performance.index >= performance.deltaTimes.len:
    performance.index = 0

  performance.frameTime = 0.0

  for dt in performance.deltaTimes:
    performance.frameTime += dt

  performance.frameTime /= float(averageWindow)


# ======================================================================
# Text
# ======================================================================


type
  GuiGlyph* = object
    byteIndex*: int
    position*: Vec2
    size*: Vec2
    drawX*: float

  GuiTextLine* = object
    text*: string
    glyphs*: seq[GuiGlyph]

proc position*(line: GuiTextLine): Vec2 =
  if line.glyphs.len > 0:
    return vec2(line.glyphs[0].drawX, line.glyphs[0].position.y)

iterator splitTextLines*(gui: Gui, position: Vec2, text: string, width: float, alignment = 0.0, wordWrap = false): GuiTextLine =
  if text.len > 0:
    let alignment = alignment.clamp(0, 1)
    let measurements = gui.measureText(position, text)
    let lineHeight = gui.lineHeight
    let rangeRight = position.x + width

    var lineY = position.y
    var startOfLine = 0
    var endOfLine = measurements.len
    var startOfNextLine = endOfLine

    let maxLines = measurements.len
    for _ in 0 ..< maxLines:
      # If this is true we are done.
      if startOfLine >= measurements.len:
        break

      let lineXOffsetForGlyph = measurements[startOfLine].left - position.x

      # Find the end of this line and the start of the next line.
      for i in startOfLine ..< measurements.len:
        # Handle lines created by the newline character.
        if text[measurements[i].byteIndex] == '\n':
          endOfLine = i
          startOfNextLine = i + 1
          break

        # Handle lines created by the glyph extending outside the bounding box.
        if wordWrap and i > startOfLine and
           text[measurements[i].byteIndex] != ' ' and
           measurements[i].right - lineXOffsetForGlyph > rangeRight:
          var wordIsEntireLine = true

          block lastWordSearch:
            # Look back for a space (the previous word will start somewhere before it).
            for lookback in countdown(i - 1, startOfLine, 1):
              if text[measurements[lookback].byteIndex] == ' ':
                # Look back further for anything other than a space (should be where the previous word ends).
                for lookbackMore in countdown(lookback - 1, startOfLine, 1):
                  if text[measurements[lookbackMore].byteIndex] != ' ':
                    endOfLine = lookbackMore + 1
                    startOfNextLine = lookback + 1
                    wordIsEntireLine = false
                    break lastWordSearch

          if wordIsEntireLine:
            endOfLine = i
            startOfNextLine = i

          break

        # Handle reaching the end of the string.
        if i == measurements.len - 1:
          endOfLine = i + 1
          startOfNextLine = i + 2

      let endOfLineByteIndex =
        if endOfLine >= measurements.len: text.len
        else: measurements[endOfLine].byteIndex

      # Create a new line, preallocate the glyph buffer.
      var line = GuiTextLine(
        text: text[measurements[startOfLine].byteIndex ..< endOfLineByteIndex],
        glyphs: newSeq[GuiGlyph](endOfLine - startOfLine),
      )

      # Populate the glyph buffer.
      var alignmentXOffset = 0.0
      for i in countdown(endOfLine - 1, startOfLine, 1):
        if i == endOfLine - 1:
          let leftOverSpaceAtEndOfLine = rangeRight - (measurements[i].right - lineXOffsetForGlyph)
          alignmentXOffset = alignment * leftOverSpaceAtEndOfLine

        line.glyphs[i - startOfLine] = GuiGlyph(
          byteIndex: measurements[i].byteIndex - measurements[startOfLine].byteIndex,
          position: vec2(alignmentXOffset + measurements[i].left - lineXOffsetForGlyph, lineY),
          size: vec2(measurements[i].right - measurements[i].left, lineHeight),
          drawX: alignmentXOffset + measurements[i].x - lineXOffsetForGlyph,
        )

      yield line

      # Set up for next line.
      startOfLine = startOfNextLine
      lineY += lineHeight

proc trimGlyphs*(line: GuiTextLine, left, right: float): GuiTextLine =
  if right < left:
    return

  var insideBox = false
  var startOfLine = 0
  var endOfLine = line.glyphs.len

  for i, glyph in line.glyphs:
    if not insideBox and glyph.position.x + glyph.size.x > left:
      startOfLine = i
      insideBox = true

    if glyph.position.x > right:
      endOfLine = i
      break

  # The entire line is to the left of the trim range.
  if not insideBox:
    return

  # The entire line is to the right of the trim range.
  if endOfLine == 0:
    return

  let endOfLineByteIndex =
    if endOfLine >= line.glyphs.len: line.text.len
    else: line.glyphs[endOfLine].byteIndex

  result.glyphs = line.glyphs[startOfLine ..< endOfLine]
  result.text = line.text[result.glyphs[0].byteIndex ..< endOfLineByteIndex]

  # The intent here is to keep the byte indices matched with the new
  # sub string, however I haven't checked if this works.
  for i in 0 ..< result.glyphs.len:
    result.glyphs[i].byteIndex -= startOfLine

proc drawText*(gui: Gui, position: Vec2, text: string, width, alignment = 0.0, wordWrap = false) =
  let clip = gui.currentClip
  for line in gui.splitTextLines(position, text, width, alignment, wordWrap):
    if line.position.y + gui.lineHeight < clip.position.y: continue
    if line.position.y > clip.position.y + clip.size.y: break
    let line = line.trimGlyphs(clip.position.x, clip.position.x + clip.size.x)
    gui.drawTextLine(line.position, line.text)