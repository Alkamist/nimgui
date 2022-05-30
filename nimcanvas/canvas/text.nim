{.experimental: "overloadableEnums".}

import std/unicode
import ../tmath

const newLineRune = "\n".runeAt(0)

type
  TextAlignX* = enum
    Left
    Center
    Right

  TextAlignY* = enum
    Top
    Center
    Bottom
    Baseline

  Glyph* = tuple
    byteIndex: int
    rune: Rune
    width: float

  TextLine* = tuple
    startIndex, endIndex: int

  Text* = ref object
    data*: string
    ascender*, descender*: float
    lineHeight*: float
    glyphs*: seq[Glyph]
    lines*: seq[TextLine]

# TODO: Figure out how to preserve indentation while wordwrapping.
func updateLines*(text: Text, wordWrap: bool, wrapWidth = 0.0) =
  var rawLines = @[(startIndex: 0, endIndex: text.glyphs.len - 1)]

  block:
    var lineBreakCount = 0
    var wasWhiteSpace = false
    var isWhiteSpace = false
    var lineWordCount = 0
    var previousWordEnd = 0
    var x = 0.0
    var i = 0

    template currentLine(): auto = rawLines[rawLines.len - 1]
    template breakLine(previousLineEndIndex, newLineStartIndex: int) =
      inc lineBreakCount
      x = 0.0
      lineWordCount = 0
      currentLine.endIndex = previousLineEndIndex
      rawLines.add (newLineStartIndex, text.glyphs.len - 1)

    while i < text.glyphs.len and lineBreakCount < text.glyphs.len:
      let glyph = text.glyphs[i]
      let rune = glyph.rune

      wasWhiteSpace = isWhiteSpace
      isWhiteSpace = rune.isWhiteSpace

      # Entered whitespace from word.
      if isWhiteSpace and not wasWhiteSpace:
        lineWordCount += 1
        previousWordEnd = i - 1

      if rune == newLineRune:
        breakLine(i - 1, i + 1)
        inc i
        continue

      if wordWrap and x + glyph.width > wrapWidth and i > 0:
        if lineWordCount > 0:
          breakLine(previousWordEnd, previousWordEnd + 2)
          i = currentLine.startIndex
          continue
        else:
          breakLine(i - 1, i)

      x += glyph.width
      inc i

  block:
    text.lines.setLen(rawLines.len)
    var i = 0
    for line in rawLines:
      if line.startIndex < text.glyphs.len and
         line.endIndex < text.glyphs.len:
        text.lines[i] = line
        inc i
    text.lines.setLen(i)

proc drawLines*(text: Text,
                bounds: Rect2,
                alignX: TextAlignX,
                alignY: TextAlignY,
                wordWrap: bool,
                cullOutOfBounds: bool,
                drawLine: proc(text: Text, line: TextLine, lineBounds: Rect2)) =
  text.updateLines(wordWrap, bounds.width)

  let yAdjustment = case alignY:
    of Top: 0.0
    of Center: 0.5 * (bounds.height - (text.lineHeight * text.lines.len.float))
    of Bottom: bounds.height - (text.lineHeight * text.lines.len.float)
    of Baseline: -text.ascender

  var y = bounds.y + yAdjustment

  let lineBoundsHeight = text.lineHeight - text.descender

  for line in text.lines:
    var lineWidth = 0.0
    for i in line.startIndex .. line.endIndex:
      lineWidth += text.glyphs[i].width

    let xAdjustment = case alignX:
      of Left: 0.0
      of Center: 0.5 * (bounds.width - lineWidth)
      of Right: bounds.width - lineWidth

    let lineBounds = rect2(bounds.x + xAdjustment, y, lineWidth, lineBoundsHeight)

    if cullOutOfBounds:
      if bounds.contains(lineBounds):
        drawLine(text, line, lineBounds)
    else:
      drawLine(text, line, lineBounds)

    y += text.lineHeight