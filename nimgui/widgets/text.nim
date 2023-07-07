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

proc getTextLine(text: Text, firstByte, lastByte: int, position: Vec2, clipLeft, clipRight: float): TextLine =
  if clipRight <= clipLeft:
    return

  let data = text.data[firstByte .. lastByte]

  let font = text.font
  let fontSize = text.fontSize
  let lineHeight = text.lineHeight

  var start = false
  var lastMeasurement: TextMeasurement

  for measurement in text.measureText(data, font, fontSize):
    if start:
      result.glyphs.add Glyph(
        firstByte: firstByte + lastMeasurement.byteIndex,
        lastByte: firstByte + measurement.byteIndex - 1,
        position: vec2(position.x + lastMeasurement.left, position.y),
        size: vec2(lastMeasurement.right - lastMeasurement.left, lineHeight),
        drawX: position.x + lastMeasurement.x,
      )

    if not start and position.x + measurement.right > clipLeft:
      start = true

    if position.x + measurement.left > clipRight:
      return

    lastMeasurement = measurement

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
    var startByte = firstByte

    while true:
      if lineY >= clipBottom:
        break

      if startByte >= lastByte:
        break

      var line = text.getTextLine(startByte, lastByte, vec2(0, lineY), clipLeft, clipRight)
      if line.glyphs.len == 0:
        break

      if wordWrap:
        var wordIsEntireLine = true

        block lastWordSearch:
          # Look back for a space (the previous word will start somewhere before it).
          for lookback in countdown(line.glyphs.len - 1, 0, 1):
            if text.data[line.glyphs[lookback].firstByte .. line.glyphs[lookback].lastByte] == " ":
              # Look back further for anything other than a space (should be where the previous word ends).
              for lookbackMore in countdown(lookback - 1, 0, 1):
                if text.data[line.glyphs[lookbackMore].firstByte .. line.glyphs[lookbackMore].lastByte] != " ":
                  startByte = line.glyphs[lookback].lastByte + 1
                  line.glyphs.setLen(lookbackMore + 1)
                  wordIsEntireLine = false
                  break lastWordSearch

        if wordIsEntireLine:
          startByte = line.glyphs[^1].lastByte + 1

      if lineY + lineHeight >= clipTop:
        let subString = text.data[line.glyphs[0].firstByte .. line.glyphs[^1].lastByte]
        text.fillTextRaw(subString, line.position, color, font, fontSize)

      lineY += lineHeight

      if not wordWrap:
        break







# proc update*(text: Text) =
#   GuiNode(text).update()

#   text.lines.setLen(0)

#   if text.data.len == 0:
#     return

#   let font = text.font
#   let fontSize = text.fontSize
#   let lineHeight = text.lineHeight
#   let wordWrap = text.wordWrap
#   let color = text.color
#   let clipRect = text.clipRect
#   let clipLeft = clipRect.position.x
#   let clipRight = clipRect.position.x + clipRect.size.x
#   let clipTop = clipRect.position.y
#   let clipBottom = clipRect.position.y + clipRect.size.y

#   var lineY = 0.0

#   for firstByte, lastByte in text.data.splitLinesByteIndices:
#     var startByte = firstByte

#     while true:
#       if lineY >= clipBottom:
#         break

#       if startByte >= lastByte:
#         break

#       let line = text.getTextLine(startByte, lastByte, vec2(0, lineY), clipLeft, clipRight)
#       if line.glyphs.len == 0:
#         break

#       if lineY + lineHeight >= clipTop:
#         let subString = text.data[line.glyphs[0].firstByte .. line.glyphs[^1].lastByte]
#         text.fillTextRaw(subString, line.position, color, font, fontSize)

#       lineY += lineHeight

#       if wordWrap:
#         startByte = line.glyphs[^1].lastByte + 1
#       else:
#         break









# proc refreshLines*(text: Text) =
#   text.lines.setLen(0)

#   if text.data.len == 0:
#     return

#   let font = text.font
#   let fontSize = text.fontSize
#   let alignment = text.currentAlignment
#   let lineHeight = text.lineHeight
#   let wordWrap = text.wordWrap
#   let position = vec2(0, 0)
#   let rangeRight = position.x + text.size.x

#   let measurements = text.measureText(text.data, position, font, fontSize)

#   var lineY = position.y
#   var startOfLine = 0
#   var endOfLine = measurements.len
#   var startOfNextLine = endOfLine

#   let maxLines = measurements.len
#   for _ in 0 ..< maxLines:
#     # If this is true we are done.
#     if startOfLine >= measurements.len:
#       break

#     let lineXOffsetForGlyph = measurements[startOfLine].left - position.x

#     # Find the end of this line and the start of the next line.
#     for i in startOfLine ..< measurements.len:
#       # Handle lines created by the newline character.
#       if text.data[measurements[i].byteIndex] == '\n':
#         endOfLine = i
#         startOfNextLine = i + 1
#         break

#       # Handle lines created by the glyph extending outside the bounding box.
#       if wordWrap and i > startOfLine and
#           text.data[measurements[i].byteIndex] != ' ' and
#           measurements[i].right - lineXOffsetForGlyph > rangeRight:
#         var wordIsEntireLine = true

#         block lastWordSearch:
#           # Look back for a space (the previous word will start somewhere before it).
#           for lookback in countdown(i - 1, startOfLine, 1):
#             if text.data[measurements[lookback].byteIndex] == ' ':
#               # Look back further for anything other than a space (should be where the previous word ends).
#               for lookbackMore in countdown(lookback - 1, startOfLine, 1):
#                 if text.data[measurements[lookbackMore].byteIndex] != ' ':
#                   endOfLine = lookbackMore + 1
#                   startOfNextLine = lookback + 1
#                   wordIsEntireLine = false
#                   break lastWordSearch

#         if wordIsEntireLine:
#           endOfLine = i
#           startOfNextLine = i

#         break

#       # Handle reaching the end of the string.
#       if i == measurements.len - 1:
#         endOfLine = i + 1
#         startOfNextLine = i + 2

#     # Create a new line, preallocate the glyph buffer.
#     var line = TextLine(
#       # data: text.data[measurements[startOfLine].byteIndex ..< endOfLineByteIndex],
#       glyphs: newSeq[Glyph](endOfLine - startOfLine),
#     )

#     # Populate the glyph buffer.
#     var alignmentXOffset = 0.0
#     for i in countdown(endOfLine - 1, startOfLine, 1):
#       if i == endOfLine - 1:
#         let leftOverSpaceAtEndOfLine = rangeRight - (measurements[i].right - lineXOffsetForGlyph)
#         alignmentXOffset = alignment * leftOverSpaceAtEndOfLine

#       let relativeIndex = i - startOfLine
#       line.glyphs[relativeIndex] = Glyph(
#         byteStart: measurements[i].byteIndex,
#         position: vec2(alignmentXOffset + measurements[i].left - lineXOffsetForGlyph, lineY),
#         size: vec2(measurements[i].right - measurements[i].left, lineHeight),
#         drawX: alignmentXOffset + measurements[i].x - lineXOffsetForGlyph,
#       )
#       if relativeIndex > 0:
#         line.glyphs[relativeIndex - 1].byteEnd = measurements[i].byteIndex - 1

#     if line.glyphs.len > 0:
#       line.glyphs[^1].byteEnd =
#         if endOfLine >= measurements.len: text.data.len - 1
#         else: measurements[endOfLine].byteIndex - 1

#     text.lines.add(line)

#     # Set up for next line.
#     startOfLine = startOfNextLine
#     lineY += lineHeight