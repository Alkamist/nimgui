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
      gui.beginPath()

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

proc drawText*(gui: Gui, position: Vec2, text: string) =
  for line in gui.textLines(position, text):
    gui.drawTextLine(line.position, line.text)