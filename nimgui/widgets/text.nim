# import std/strutils
import ../gui

type
  TextLine* = object
    position*: Vec2
    height*: float
    glyphs*: seq[Glyph]

proc drawPosition*(line: TextLine): Vec2 =
  if line.glyphs.len > 0:
    line.position + vec2(line.glyphs[0].left + line.glyphs[0].logicalXOffset, 0)
  else:
    line.position

proc size*(line: TextLine): Vec2 =
  result.y = line.height
  if line.glyphs.len > 0:
    result.x = line.glyphs[^1].right - line.glyphs[0].left
  else:
    result.x = 0.0

proc trim*(line: TextLine, left, right: float): TextLine =
  result.position = line.position
  result.height = line.height
  for glyph in line.glyphs:
    if glyph.left > right:
      break
    if glyph.right > left:
      result.glyphs.add(glyph)

type
  Text* = ref object of GuiNode
    data*: string
    font*: Font
    fontSize*: float
    color*: Color
    wordWrap*: bool
    lines*: seq[TextLine]
    currentAlignment: float

proc alignment*(text: Text): float =
  text.currentAlignment

proc `alignment=`*(text: Text, value: float) =
  text.currentAlignment = value.clamp(0, 1)

proc lineHeight*(text: Text): float =
  text.root.vgCtx.textMetrics(text.font, text.fontSize).lineHeight

proc setDefault*(text: Text) =
  text.clipChildren = true
  text.size = text.parent.size
  text.color = rgb(255, 255, 255)
  text.font = 0
  text.fontSize = 13.0
  text.wordWrap = false
  text.currentAlignment = 0.0

proc getText*(node: GuiNode, name: string): Text =
  result = node.getNode(name, Text)
  if result.init:
    result.setDefault()

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

proc refreshLinesWithoutWordWrap(text: Text) =
  let font = text.font
  let fontSize = text.fontSize
  let lineHeight = text.lineHeight
  let alignment = text.alignment
  let rangeRight = text.size.x

  let clipRect = text.clipRect
  let clipLeft = clipRect.position.x
  let clipRight = clipRect.position.x + clipRect.size.x
  let clipTop = clipRect.position.y
  let clipBottom = clipRect.position.y + clipRect.size.y

  var lineY = 0.0

  for firstByte, lastByte in text.data.splitLinesByteIndices:
    if lineY + lineHeight < clipTop:
      lineY += lineHeight
      continue

    if lineY >= clipBottom:
      return

    # Empty line.
    if text.data[firstByte .. lastByte] == "":
      let alignmentXOffset = alignment * rangeRight
      text.lines.add(TextLine(
        position: vec2(alignmentXOffset, lineY),
        height: lineHeight,
      ))
      lineY += lineHeight
      continue

    var glyphs = text.measureLineGlyphs(text.data.toOpenArray(firstByte, lastByte), font, fontSize)
    if glyphs.len == 0:
      continue

    for glyph in glyphs.mitems:
      glyph.firstByte += firstByte
      glyph.lastByte += firstByte

    let leftOverSpaceAtEndOfLine = rangeRight - glyphs[^1].right
    let alignmentXOffset = alignment * leftOverSpaceAtEndOfLine

    text.lines.add(TextLine(
      position: vec2(alignmentXOffset, lineY),
      height: lineHeight,
      glyphs: glyphs,
    ).trim(clipLeft - alignmentXOffset, clipRight - alignmentXOffset))

    lineY += lineHeight

# proc glyphString(text: Text, glyph: Glyph): string =
#   text.data[glyph.firstByte .. glyph.lastByte]

# proc refreshLinesWithWordWrap(text: Text) =
#   let lineHeight = text.lineHeight
#   let alignment = text.alignment
#   let rangeRight = text.size.x

#   let clipRect = text.clipRect
#   let clipLeft = clipRect.position.x
#   let clipRight = clipRect.position.x + clipRect.size.x
#   let clipTop = clipRect.position.y
#   let clipBottom = clipRect.position.y + clipRect.size.y

#   var lineY = 0.0

#   for firstByte, lastByte in text.data.splitLinesByteIndices:
#     if lineY >= clipBottom:
#       return

#     # Empty line.
#     if text.data[firstByte .. lastByte] == "":
#       if lineY + lineHeight >= clipTop:
#         text.lines.add(TextLine(lineHeight: lineHeight))
#       lineY += lineHeight
#       continue

#     var startByte = firstByte

#     while true:
#       if lineY >= clipBottom:
#         break

#       if startByte >= lastByte:
#         break

#       var line = text.getTextLine(startByte, lastByte, vec2(0, lineY))
#       if line.glyphs.len == 0:
#         continue

#       var endOfLastWord = -1
#       var startOfNextLine = -1

#       if line.glyphs.len > 0 and
#           line.glyphs[^1].position.x + line.glyphs[^1].size.x < rangeRight:
#         startByte = line.glyphs[^1].lastByte + 1

#       else:
#         for i in 0 ..< line.glyphs.len - 1:
#           let glyph = line.glyphs[i]
#           let glyphIsWhitespace = text.glyphString(glyph) == " "
#           let glyphInBounds = glyph.position.x + glyph.size.x < rangeRight

#           let nextGlyph = line.glyphs[i + 1]
#           let nextGlyphIsWhitespace = text.glyphString(nextGlyph) == " "
#           let nextGlyphInBounds = nextGlyph.position.x + nextGlyph.size.x < rangeRight

#           if glyphInBounds and nextGlyphIsWhitespace and not glyphIsWhitespace:
#             endOfLastWord = i

#           if glyphIsWhitespace and not nextGlyphIsWhitespace:
#             startOfNextLine = i + 1

#           if not nextGlyphInBounds and not nextGlyphIsWhitespace:
#             if startOfNextLine == -1:
#               startOfNextLine = i + 1

#             startByte = line.glyphs[startOfNextLine].firstByte

#             if endOfLastWord == -1:
#               line.glyphs.setLen(i + 1)
#             else:
#               line.glyphs.setLen(endOfLastWord + 1)

#             break

#       # Adjust glyph positions based on alignment.
#       let leftOverSpaceAtEndOfLine = rangeRight - (line.glyphs[^1].position.x + line.glyphs[^1].size.x)
#       let alignmentXOffset = alignment * leftOverSpaceAtEndOfLine
#       for i in 0 ..< line.glyphs.len:
#         line.glyphs[i].position.x += alignmentXOffset

#       text.lines.add(line.trim(clipLeft, clipRight))

#       lineY += lineHeight

proc update*(text: Text) =
  GuiNode(text).update()

  text.lines.setLen(0)

  if text.data.len == 0:
    return

  text.refreshLinesWithoutWordWrap()

  let font = text.font
  let fontSize = text.fontSize
  let color = text.color
  for line in text.lines:
    if line.glyphs.len > 0:
      let subString = text.data[line.glyphs[0].firstByte .. line.glyphs[^1].lastByte]
      text.fillTextRaw(subString, line.drawPosition, color, font, fontSize)