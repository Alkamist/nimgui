import std/options
import ../gui

type
  Text* = ref object
    gui*: Gui
    data*: string
    position*: Vec2
    font*: Font
    fontSize*: float
    color*: Color
    lineHeight*: float
    ascender*: float
    descender*: float
    glyphs*: seq[Glyph]

proc size*(text: Text): Vec2 =
  result.y = text.lineHeight
  if text.glyphs.len > 0:
    result.x = text.glyphs[^1].right - text.glyphs[0].left
  else:
    result.x = 0

proc drawOffset*(text: Text): Vec2 =
  if text.glyphs.len == 0:
    return
  result.x = text.glyphs[0].drawOffsetX

proc glyphAt*(text: Text, position: Vec2): Option[tuple[index: int, glyph: Glyph]] =
  let gui = text.gui
  if not gui.isHovered(text):
    return

  let textPosition = text.position
  if position.y < textPosition.y or
     position.y >= textPosition.y + text.lineHeight:
    return

  for i in 0 ..< text.glyphs.len:
    let glyph = text.glyphs[i]
    let left = textPosition.x + glyph.left
    let right = textPosition.x + glyph.right
    if position.x >= left and position.x < right:
      return some((i, glyph))

proc init*(text: Text) =
  text.font = Font(0)
  text.fontSize = 13.0
  text.color = rgb(255, 255, 255)

proc update*(text: Text) =
  let gui = text.gui

  let font = text.font
  let fontSize = text.fontSize
  let metrics = gui.textMetrics(font, fontSize)
  text.lineHeight = metrics.lineHeight
  text.ascender = metrics.ascender
  text.descender = metrics.descender
  text.glyphs = gui.measureGlyphs(text.data, font, fontSize)

proc draw*(text: Text) =
  let gui = text.gui

  if text.glyphs.len > 0:
    let firstByte = text.glyphs[0].firstByte
    let lastByte = text.glyphs[^1].lastByte
    gui.fillTextLine(cast[string](text.data[firstByte .. lastByte]),
      text.position + text.drawOffset,
      text.color,
      text.font,
      text.fontSize,
    )

  let mouseOverGlyphOption = text.glyphAt(gui.mousePosition)
  if mouseOverGlyphOption.isSome:
    let mouseOverGlyph = mouseOverGlyphOption.get
    let glyph = mouseOverGlyph.glyph

    let glyphPosition = text.position + vec2(glyph.left, 0)
    let glyphSize = vec2(glyph.width, text.lineHeight)

    let path = Path.new()
    path.rect(glyphPosition + 0.5, glyphSize - 1.0)
    gui.strokePath(path, rgb(0, 255, 0))