import std/strutils
import ../gui

type
  GuiTextLine = object
    text*: string
    position*: Vec2
    glyphs*: seq[GuiGlyph]

iterator textLines*(gui: Gui, position: Vec2, text: string): GuiTextLine =
  let clip = gui.currentClip
  let clipLeft = clip.position.x
  let clipRight = clip.position.x + clip.size.x
  let clipTop = clip.position.y
  let clipBottom = clip.position.y + clip.size.y

  let lineHeight = gui.lineHeight
  var linePosition = position

  for line in text.splitLines:
    if linePosition.y > clipBottom:
      break

    if linePosition.y + lineHeight > clipTop:
      var startIndex = 0
      var stopIndex = line.len
      var firstVisibleGlyph = false

      var textLine = GuiTextLine(position: linePosition)

      for glyph in gui.textGlyphs(line):
        let glyphX = linePosition.x + glyph.x
        let glyphLeft = linePosition.x + glyph.left
        let glyphWidth = glyph.right - glyph.left
        let glyphRight = glyphLeft + glyphWidth

        if firstVisibleGlyph:
          textLine.position.x = glyphX
          startIndex = glyph.index
          firstVisibleGlyph = false

        if glyphRight < clipLeft:
          firstVisibleGlyph = true
          continue

        if glyphLeft > clipRight:
          stopIndex = glyph.index
          break

        textLine.glyphs.add(GuiGlyph(
          index: glyph.index,
          x: glyphX - textLine.position.x,
          left: glyphLeft - textLine.position.x,
          right: glyphRight - textLine.position.x,
        ))

      # This check is needed to handle the edge case where
      # the entire line is to the left of the clip rect.
      # This bool is true in that case so you can just
      # leave textLine.text as nil.
      if not firstVisibleGlyph:
        textLine.text = line[startIndex..<stopIndex]

      yield textLine

    linePosition.y += lineHeight

# proc drawText*(gui: Gui, position: Vec2, text: string) =
#   for line in gui.textLines(position, text):
#     gui.drawTextLine(line.position, line.text)

iterator textBoxLines*(gui: Gui, position, size: Vec2, text: string, wordWrap = true): GuiTextLine =
  if text.len > 0:
    let lineHeight = gui.lineHeight
    var lineYOffset = 0.0

    let glyphs = gui.calculateGlyphs(text)

    var start = 0

    for _ in 0 ..< glyphs.len:
      if lineYOffset > size.y:
        break

      var endOfLine = glyphs.len - 1
      var nextStart = endOfLine

      var textLine = GuiTextLine(position: position + vec2(0, lineYOffset))
      let glyphXOffset = -glyphs[start].x

      for i in start ..< glyphs.len:
        let glyph = glyphs[i]

        if text[glyph.index] == '\n':
          endOfLine = i - 1
          nextStart = i + 1
          break

        if wordWrap and i > start and text[glyph.index] != ' ' and glyph.right + glyphXOffset > size.x:
          var wordIsEntireLine = true

          block lastWordSearch:
            for lookback in countdown(i - 1, start, 1):
              if text[glyphs[lookback].index] == ' ':
                for lookbackMore in countdown(lookback - 1, start, 1):
                  if text[glyphs[lookbackMore].index] != ' ':
                    endOfLine = lookbackMore
                    nextStart = lookback + 1
                    wordIsEntireLine = false
                    break lastWordSearch

          if wordIsEntireLine:
            endOfLine = i - 1
            nextStart = i

          break

      if endOfLine >= 0:
        let glyphCount = endOfLine + 1 - start
        textLine.glyphs.setLen(glyphCount)

        for i in 0 ..< glyphCount:
          let glyph = glyphs[start + i]
          textLine.glyphs[i] = GuiGlyph(
            index: glyph.index,
            x: glyph.x + glyphXOffset,
            left: glyph.left + glyphXOffset,
            right: glyph.right + glyphXOffset,
          )

        textLine.text = text[glyphs[start].index .. glyphs[endOfLine].index]

        yield textLine

      if nextStart >= glyphs.len - 1:
        break

      start = nextStart
      lineYOffset += lineHeight