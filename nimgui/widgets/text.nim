# import std/strutils
import ../gui

type
  Glyph* = object
    firstByte*: int
    lastByte*: int
    position*: Vec2
    size*: Vec2
    drawX*: float

  TextLine* = object
    glyphs*: seq[Glyph]

proc position*(line: TextLine): Vec2 =
  if line.glyphs.len > 0:
    return vec2(line.glyphs[0].drawX, line.glyphs[0].position.y)

proc trim*(line: TextLine, left, right: float): TextLine =
  if right <= left:
    return

  for glyph in line.glyphs:
    if glyph.position.x > right:
      return

    if glyph.position.x + glyph.size.x > left:
      result.glyphs.add(glyph)

type
  Text* = ref object of GuiNode
    data*: string
    font*: Font
    fontSize*: float
    color*: Color
    wordWrap*: bool
    lineHeight*: float
    lines*: seq[TextLine]
    currentAlignment: float

proc alignment*(text: Text): float =
  text.currentAlignment

proc `alignment=`*(text: Text, value: float) =
  text.currentAlignment = value.clamp(0, 1)

proc fontLineHeight*(text: Text): float =
  text.root.vgCtx.textMetrics(text.font, text.fontSize).lineHeight

proc setDefault*(text: Text) =
  text.clipChildren = true
  text.size = text.parent.size
  text.color = rgb(255, 255, 255)
  text.font = 0
  text.fontSize = 13.0
  text.lineHeight = text.fontLineHeight
  text.wordWrap = false
  text.currentAlignment = 0.0

proc getText*(node: GuiNode, name: string): Text =
  result = node.getNode(name, Text)
  if result.init:
    result.setDefault()

# TODO: Allow passing in a maximum width for optimization.
proc getTextLine(text: Text, firstByte, lastByte: int, position: Vec2): TextLine =
  let data = text.data[firstByte .. lastByte]

  let font = text.font
  let fontSize = text.fontSize
  let lineHeight = text.lineHeight

  for measurement in text.measureText(data, font, fontSize):
    if result.glyphs.len > 0:
      result.glyphs[^1].lastByte = firstByte + measurement.byteIndex - 1

    result.glyphs.add Glyph(
      firstByte: firstByte + measurement.byteIndex,
      position: vec2(position.x + measurement.left, position.y),
      size: vec2(measurement.right - measurement.left, lineHeight),
      drawX: position.x + measurement.x,
    )

  if result.glyphs.len > 0:
    result.glyphs[^1].lastByte = lastByte

iterator splitLinesByteIndices(s: string): tuple[first, last: int] =
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

proc glyphString(text: Text, glyph: Glyph): string =
  text.data[glyph.firstByte .. glyph.lastByte]

proc update*(text: Text) =
  GuiNode(text).update()

  text.lines.setLen(0)

  if text.data.len == 0:
    return

  let font = text.font
  let fontSize = text.fontSize
  let lineHeight = text.lineHeight
  let wordWrap = text.wordWrap
  let wrapRight = text.size.x
  let color = text.color
  let clipRect = text.clipRect
  let clipLeft = clipRect.position.x
  let clipRight = clipRect.position.x + clipRect.size.x
  let clipTop = clipRect.position.y
  let clipBottom = clipRect.position.y + clipRect.size.y

  var lineY = 0.0

  for firstByte, lastByte in text.data.splitLinesByteIndices:
    if text.data[firstByte .. lastByte] == "":
      lineY += lineHeight
      continue

    var startByte = firstByte

    while true:
      if lineY >= clipBottom:
        break

      if startByte >= lastByte:
        break

      var line = text.getTextLine(startByte, lastByte, vec2(0, lineY))
      if line.glyphs.len == 0:
        break

      if wordWrap:
        var endOfLastWord = -1
        var startOfNextLine = -1

        if line.glyphs.len > 0 and
           line.glyphs[^1].position.x + line.glyphs[^1].size.x < wrapRight:
          startByte = line.glyphs[^1].lastByte + 1

        else:
          for i in 0 ..< line.glyphs.len - 1:
            let glyph = line.glyphs[i]
            let glyphIsWhitespace = text.glyphString(glyph) == " "
            let glyphInBounds = glyph.position.x + glyph.size.x < wrapRight

            let nextGlyph = line.glyphs[i + 1]
            let nextGlyphIsWhitespace = text.glyphString(nextGlyph) == " "
            let nextGlyphInBounds = nextGlyph.position.x + nextGlyph.size.x < wrapRight

            if glyphInBounds and nextGlyphIsWhitespace and not glyphIsWhitespace:
              endOfLastWord = i

            if glyphIsWhitespace and not nextGlyphIsWhitespace:
              startOfNextLine = i + 1

            if not nextGlyphInBounds and not nextGlyphIsWhitespace:
              if startOfNextLine == -1:
                startOfNextLine = i + 1

              startByte = line.glyphs[startOfNextLine].firstByte

              if endOfLastWord == -1:
                line.glyphs.setLen(i + 1)
              else:
                line.glyphs.setLen(endOfLastWord + 1)

              break

      if lineY + lineHeight >= clipTop:
        let line = line.trim(clipLeft, clipRight)
        if line.glyphs.len > 0:
          let subString = text.data[line.glyphs[0].firstByte .. line.glyphs[^1].lastByte]
          text.fillTextRaw(subString, line.position, color, font, fontSize)

      lineY += lineHeight

      if not wordWrap:
        break