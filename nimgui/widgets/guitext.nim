{.experimental: "overloadableEnums".}

import ../guimod
import ./frame

type
  GuiText* = ref object of GuiWidget
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

proc drawPosition(text: GuiText): Vec2 =
  result.x = case text.alignX:
    of Left: 0.0
    of Center: 0.5 * text.width
    of Right: text.width
  result.y = case text.alignY:
    of Top: 0.0
    of Center: 0.5 * text.height
    of Bottom: text.height
    of Baseline: text.lineHeight

proc updateText(widget: GuiWidget) =
  let text = GuiText(widget)
  let gfx = text.gui.gfx
  gfx.font = text.font
  gfx.fontSize = text.fontSize

  let metrics = gfx.textMetrics
  text.lineHeight = metrics.lineHeight
  text.ascender = metrics.ascender
  text.descender = metrics.descender

  gfx.setTextAlign(text.alignX, text.alignY)

  text.glyphs = gfx.getGlyphs(text.drawPosition, text.data)

  text.updateChildren()

proc drawText(widget: GuiWidget) =
  let text = GuiText(widget)
  let gfx = text.gui.gfx
  gfx.font = text.font
  gfx.fontSize = text.fontSize

  gfx.setTextAlign(text.alignX, text.alignY)

  gfx.fillColor = text.color
  gfx.drawText(text.drawPosition, text.data)

  text.drawChildren()

func addText*(parent: GuiWidget): GuiText =
  result = parent.addWidget(GuiText)
  result.update = updateText
  result.draw = drawText
  result.fontSize = 13
  result.font = "consola"
  result.alignX = Center
  result.alignY = Baseline
  result.color = rgb(255, 255, 255)