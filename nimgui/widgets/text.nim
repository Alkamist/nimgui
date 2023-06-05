{.experimental: "overloadableEnums".}

import ../gui

type
  Text* = ref object of Widget
    data*: string
    glyphs*: seq[Glyph]
    font*: string
    fontSize*: float
    lineHeight*: float
    ascender*: float
    descender*: float
    alignX*: TextAlignX
    alignY*: TextAlignY
    color*: Color

proc drawPosition*(text: Text): Vec2 =
  result.x = case text.alignX:
    of Left: 0.0
    of Center: 0.5 * text.size.x
    of Right: text.size.y
  result.y = case text.alignY:
    of Top: 0.0
    of Center: 0.5 * text.size.y
    of Bottom: text.size.y
    of Baseline: text.lineHeight

proc update*(text: Text) =
  let vg = text.vg
  vg.font = text.font
  vg.fontSize = text.fontSize

  let metrics = vg.textMetrics
  text.lineHeight = metrics.lineHeight
  text.ascender = metrics.ascender
  text.descender = metrics.descender

  vg.textAlign(text.alignX, text.alignY)

  text.glyphs = vg.getGlyphs(vec2(0, 0), text.data)

proc defaultDraw*(text: Text) =
  let vg = text.vg
  vg.fillColor = text.color
  vg.textAlign(text.alignX, text.alignY)
  vg.font = text.font
  vg.fontSize = text.fontSize
  vg.text(text.drawPosition, text.data)

proc addText*(widget: Widget, id: string): Text =
  let text = widget.addWidget(id, Text)

  if text.init:
    text.passInput = true
    text.font = "consola"
    text.fontSize = 13
    text.alignX = Center
    text.alignY = Center
    text.color = rgb(242, 243, 245)

  text.draw:
    text.defaultDraw()

  text