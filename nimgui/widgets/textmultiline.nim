import std/math
import std/options
import ../gui

type
  TextLine* = object
    firstGlyphIndex*: int
    lastGlyphIndex*: int

  Text* = ref object
    data*: string
    position*: Vec2
    size*: Vec2
    contentSize*: Vec2
    alignment*: Vec2
    font*: Font
    fontSize*: float
    lineHeight*: float
    ascender*: float
    descender*: float
    glyphs*: seq[Glyph]
    lines*: seq[TextLine]
    mouseOverLine*: Option[int]
    mouseOverGlyph*: Option[int]

proc refreshGlyphsAndMetrics(gui: Gui, editor: Text) =
  let font = editor.font
  let fontSize = editor.fontSize
  let metrics = gui.textMetrics(font, fontSize)
  editor.lineHeight = metrics.lineHeight
  editor.ascender = metrics.ascender
  editor.descender = metrics.descender
  editor.glyphs = gui.measureGlyphs(editor.data, font, fontSize)

proc refreshLines(gui: Gui, editor: Text) =
  editor.lines.setLen(0)

  var firstIndex = 0

  for i in 0 ..< editor.glyphs.len:
    if i < firstIndex:
      continue

    let glyph = editor.glyphs[i]

    if editor.data[glyph.firstByte] in {'\r', '\n'}:
      editor.lines.add(TextLine(
        firstGlyphIndex: firstIndex,
        lastGlyphIndex: i - 1,
      ))
      firstIndex = i + 1
      continue

proc lineWidth(gui: Gui, editor: Text, index: int): float =
  let line = editor.lines[index]
  let firstGlyph = editor.glyphs[line.firstGlyphIndex]
  let lastGlyph = editor.glyphs[line.lastGlyphIndex]
  lastGlyph.right - firstGlyph.left

proc linePosition(gui: Gui, editor: Text, index: int): Vec2 =
  let lineHeight = editor.lineHeight
  let alignment = editor.alignment
  result.x = (editor.size.x - gui.lineWidth(editor, index)) * alignment.x
  result.y = (lineHeight * float(index)) + (editor.size.y - lineHeight) * alignment.y

proc lineDrawPosition(gui: Gui, editor: Text, index: int): Vec2 =
  let xOffset = editor.glyphs[editor.lines[index].firstGlyphIndex].drawOffsetX
  gui.linePosition(editor, index) + vec2(xOffset, 0)

proc refreshMouseOverInfo(gui: Gui, editor: Text) =
  editor.mouseOverLine = none(int)
  editor.mouseOverGlyph = none(int)

  # if not editor.isHovered:
  #   return

  let mousePosition = gui.mousePosition
  let lineIndex = int(floor(mousePosition.y / editor.lineHeight))
  if lineIndex < 0 or lineIndex >= editor.lines.len:
    return

  editor.mouseOverLine = some(lineIndex)

  let line = editor.lines[lineIndex]
  if line.firstGlyphIndex < 0 or line.firstGlyphIndex >= editor.glyphs.len or
     line.lastGlyphIndex < 0 or line.lastGlyphIndex >= editor.glyphs.len:
    return

  let firstGlyphLeft = editor.glyphs[editor.lines[lineIndex].firstGlyphIndex].left
  let xOffset = gui.linePosition(editor, lineIndex).x - firstGlyphLeft

  for i in line.firstGlyphIndex .. line.lastGlyphIndex:
    let glyph = editor.glyphs[i]
    let left = glyph.left + xOffset
    let right = glyph.right + xOffset
    if mousePosition.x >= left and mousePosition.x < right:
      editor.mouseOverGlyph = some(i)

proc new*(_: typedesc[Text]): Text =
  result = Text()
  result.alignment = vec2(0, 0)
  result.font = Font(0)
  result.fontSize = 13.0

proc update*(gui: Gui, editor: Text) =
  # if gui.mouseHitTest(editor.position, editor.size):
  #   editor.requestHover()

  gui.beginOffset(editor.position)

  gui.refreshGlyphsAndMetrics(editor)
  gui.refreshLines(editor)
  gui.refreshMouseOverInfo(editor)

  # Draw line text.
  for i in 0 ..< editor.lines.len:
    let line = editor.lines[i]
    let firstByte = editor.glyphs[line.firstGlyphIndex].firstByte
    let lastByte = editor.glyphs[line.lastGlyphIndex].lastByte
    gui.fillTextLine(cast[string](editor.data[firstByte .. lastByte]),
      gui.lineDrawPosition(editor, i),
      rgb(255, 255, 255),
      editor.font,
      editor.fontSize,
    )

  # if editor.mouseOverLine.isSome:
  #   let mouseOverLine = editor.mouseOverLine.get
  #   let path = Path.new()
  #   path.rect(
  #     editor.linePosition(mouseOverLine),
  #     editor.lineSize(mouseOverLine),
  #   )
  #   gui.fillPath(path, rgba(255, 255, 0, 64))

  if editor.mouseOverGlyph.isSome:
    let mouseOverLine = editor.mouseOverLine.get
    let mouseOverGlyph = editor.mouseOverGlyph.get
    let glyph = editor.glyphs[mouseOverGlyph]

    let firstGlyphLeft = editor.glyphs[editor.lines[mouseOverLine].firstGlyphIndex].left
    let glyphPosition = gui.linePosition(editor, mouseOverLine) + vec2(glyph.left - firstGlyphLeft, 0)
    let glyphSize = vec2(glyph.width, editor.lineHeight)

    let path = Path.new()
    path.rect(glyphPosition, glyphSize)
    gui.fillPath(path, rgba(255, 255, 0, 64))

  gui.endOffset()