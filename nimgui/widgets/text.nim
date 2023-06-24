import ../gui

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

iterator splitTextLines(gui: Gui, position: Vec2, text: string, wrapWidth: float, wordWrap: bool): GuiTextLine =
  if text.len > 0:
    let measurements = gui.measureText(position, text)
    let lineHeight = gui.lineHeight
    let boxRight = position.x + wrapWidth

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
           measurements[i].right - lineXOffsetForGlyph > boxRight:
          var wordIsEntireLine = true

          block lastWordSearch:
            for lookback in countdown(i - 1, startOfLine, 1):
              if text[measurements[lookback].byteIndex] == ' ':
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
      for i in startOfLine ..< endOfLine:
        line.glyphs[i - startOfLine] = GuiGlyph(
          byteIndex: measurements[i].byteIndex - measurements[startOfLine].byteIndex,
          position: vec2(measurements[i].left - lineXOffsetForGlyph, lineY),
          size: vec2(measurements[i].right - measurements[i].left, lineHeight),
          drawX: measurements[i].x - lineXOffsetForGlyph,
        )

      yield line

      # Set up for next line.
      startOfLine = startOfNextLine
      lineY += lineHeight

iterator splitTextLines*(gui: Gui, position: Vec2, text: string): GuiTextLine =
  for line in gui.splitTextLines(position, text, 0.0, false):
    yield line

iterator splitTextLines*(gui: Gui, position: Vec2, text: string, wrapWidth: float): GuiTextLine =
  for line in gui.splitTextLines(position, text, wrapWidth, true):
    yield line

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

  # The entire line is to the left of the cull range.
  if not insideBox:
    return

  # The entire line is to the right of the cull range.
  if endOfLine == 0:
    return

  let endOfLineByteIndex =
    if endOfLine >= line.glyphs.len: line.text.len
    else: line.glyphs[endOfLine].byteIndex

  result.glyphs = line.glyphs[startOfLine ..< endOfLine]
  result.text = line.text[result.glyphs[0].byteIndex ..< endOfLineByteIndex]

  for i in 0 ..< result.glyphs.len:
    result.glyphs[i].byteIndex -= startOfLine

proc drawText*(gui: Gui, position: Vec2, text: string, wrapWidth: float) =
  let clip = gui.currentClip
  for line in gui.splitTextLines(position, text, wrapWidth):
    if line.position.y + gui.lineHeight < clip.position.y: continue
    if line.position.y > clip.position.y + clip.size.y: break
    let line = line.trimGlyphs(clip.position.x, clip.position.x + clip.size.x)
    gui.drawTextLine(line.position, line.text)