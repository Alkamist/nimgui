import ../gui

type
  Text* = ref object of Widget
    data*: string
    position*: Vec2
    size*: Vec2
    alignment*: Vec2
    color*: Color
    font*: Font
    fontSize*: float
    lineHeight*: float
    ascender*: float
    descender*: float

proc init*(text: Text) =
  text.alignment = vec2(0, 0)
  text.color = rgb(255, 255, 255)
  text.font = Font(0)
  text.fontSize = 13.0

iterator splitLinesIndices(s: openArray[char]): tuple[first, last: int] =
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
  if text.data.len == 0:
    return

  let gui = text.gui
  let position = text.position
  let size = text.size
  let alignment = text.alignment
  let font = text.font
  let fontSize = text.fontSize
  let color = text.color

  let metrics = gui.textMetrics(font, fontSize)
  let lineHeight = metrics.lineHeight
  let ascender = metrics.ascender
  let descender = metrics.descender

  text.lineHeight = lineHeight
  text.ascender = ascender
  text.descender = descender

  let clipRect = gui.clipRect
  # let clipLeft = clipRect.position.x
  # let clipRight = clipRect.position.x + clipRect.size.x
  let clipTop = clipRect.position.y
  let clipBottom = clipRect.position.y + clipRect.size.y

  var linePosition = position
  linePosition.y += (size.y - lineHeight) * alignment.y

  for first, last in text.data.splitLinesIndices:
    if linePosition.y >= clipBottom:
      return

    if linePosition.y + lineHeight < clipTop or first == last:
      linePosition.y += lineHeight
      continue

    var alignmentXOffset = 0.0
    if size.x > 0:
      var glyphs = gui.measureGlyphs(text.data.toOpenArray(first, last), font, fontSize)
      if glyphs.len == 0:
        linePosition.y += lineHeight
        continue

      for glyph in glyphs.mitems:
        glyph.firstByte += first
        glyph.lastByte += first

      let leftOverSpaceAtEndOfLine = size.x - glyphs[^1].right
      alignmentXOffset = alignment.x * leftOverSpaceAtEndOfLine

    gui.fillTextLine(cast[string](text.data[first .. last]),
      linePosition + vec2(alignmentXOffset, 0),
      color,
      font,
      fontSize,
    )

    linePosition.y += lineHeight