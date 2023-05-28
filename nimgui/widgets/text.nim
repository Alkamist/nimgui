{.experimental: "overloadableEnums".}

import ../math
import ../widget

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

proc drawPosition(text: Text): Vec2 =
  result.x = case text.alignX:
    of Left: 0.0
    of Center: 0.5 * text.size.x
    of Right: text.size.y
  result.y = case text.alignY:
    of Top: 0.0
    of Center: 0.5 * text.size.y
    of Bottom: text.size.y
    of Baseline: text.lineHeight

proc updateText(widget: Widget) =
  let text = Text(widget)
  let vg = text.vg
  vg.font = text.font
  vg.fontSize = text.fontSize

  let metrics = vg.textMetrics
  text.lineHeight = metrics.lineHeight
  text.ascender = metrics.ascender
  text.descender = metrics.descender

  vg.setTextAlign(text.alignX, text.alignY)

  text.glyphs = vg.getGlyphs(text.drawPosition, text.data)

  text.updateChildren()

proc drawText(widget: Widget) =
  let text = Text(widget)
  let vg = text.vg
  vg.font = text.font
  vg.fontSize = text.fontSize

  vg.setTextAlign(text.alignX, text.alignY)

  vg.fillColor = text.color
  vg.text(text.drawPosition, text.data)

  text.drawChildren()

func addText*(parent: Widget): Text =
  result = parent.addWidget(Text)
  result.update = updateText
  result.draw = drawText
  result.fontSize = 13
  result.font = "consola"
  result.alignX = Center
  result.alignY = Baseline
  result.color = rgb(255, 255, 255)
  result.consumeInput = false
  result.clipInput = false
  result.clipDrawing = false