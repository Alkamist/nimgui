import ./common
import ./nanovg

proc saveState*(ctx: GuiVectorGraphicsContext) =
  nvgSave(ctx.nvgCtx)

proc restoreState*(ctx: GuiVectorGraphicsContext) =
  nvgRestore(ctx.nvgCtx)

proc setFont*(ctx: GuiVectorGraphicsContext, font: GuiFont) =
  nvgFontFaceId(ctx.nvgCtx, cint(font))

proc setFontSize*(ctx: GuiVectorGraphicsContext, size: float) =
  nvgFontSize(ctx.nvgCtx, size)

proc addFont*(ctx: GuiVectorGraphicsContext, data: string): GuiFont =
  let font = nvgCreateFontMem(ctx.nvgCtx, cstring"", cstring(data), cint(data.len), 0)
  if font == -1:
    echo "Failed to load font: " & $font
  font

proc calculateTextMetrics*(ctx: GuiVectorGraphicsContext): tuple[ascender, descender, lineHeight: float] =
  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(ctx.nvgCtx, addr(ascender), addr(descender), addr(lineHeight))
  (float(ascender), float(descender), float(lineHeight))

# iterator textGlyphs*(ctx: GuiVectorGraphicsContext, text: openArray[char]): GuiGlyph =
#   if text.len > 0:
#     let nvgCtx = ctx.nvgCtx

#     var nvgPositions = newSeq[NVGglyphPosition](text.len)
#     let positionCount = nvgTextGlyphPositions(
#       nvgCtx, 0, 0,
#       cast[cstring](unsafeAddr(text[0])),
#       nil,
#       addr(nvgPositions[0]),
#       cint(text.len),
#     )
#     nvgPositions.setLen(positionCount)

#     for nvgPosition in nvgPositions:
#       yield GuiGlyph(
#         index: int(cast[uint64](nvgPosition.str) - cast[uint64](unsafeAddr(text[0]))),
#         x: nvgPosition.x,
#         left: nvgPosition.minx,
#         right: nvgPosition.maxx,
#       )

proc measureText*(ctx: GuiVectorGraphicsContext, position: Vec2, text: openArray[char]): seq[GuiTextMeasurement] =
  if text.len > 0:
    let nvgCtx = ctx.nvgCtx

    var nvgPositions = newSeq[NVGglyphPosition](text.len)
    let positionCount = nvgTextGlyphPositions(
      nvgCtx, position.x, position.y,
      cast[cstring](unsafeAddr(text[0])),
      nil,
      addr(nvgPositions[0]),
      cint(text.len),
    )

    result.setLen(positionCount)

    for i in 0 ..< positionCount:
      let nvgPosition = nvgPositions[i]
      result[i] = GuiTextMeasurement(
        byteIndex: int(cast[uint64](nvgPosition.str) - cast[uint64](unsafeAddr(text[0]))),
        x: nvgPosition.x,
        left: nvgPosition.minx,
        right: nvgPosition.maxx,
      )

proc renderTextRaw(nvgCtx: NVGcontext, x, y: float, data: openArray[char]) =
  if data.len == 0:
    return
  discard nvgText(
    nvgCtx,
    x, y,
    cast[cstring](unsafeAddr(data[0])),
    cast[cstring](cast[uint64](unsafeAddr(data[data.len - 1])) + 1),
  )

proc renderDrawCommands*(gui: Gui, commands: openArray[DrawCommand]) =
  let nvgCtx = gui.vgCtx.nvgCtx

  # nvgSave(nvgCtx)

  for command in commands:
    case command.kind:
    of BeginPath: nvgBeginPath(nvgCtx)
    of ClosePath: nvgClosePath(nvgCtx)
    of Fill: nvgFill(nvgCtx)
    of Stroke: nvgStroke(nvgCtx)
    of ResetTransform: nvgResetTransform(nvgCtx)
    of Rect:
      let c = command.rect
      nvgRect(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)
    of RoundedRect:
      let c = command.roundedRect
      nvgRoundedRectVarying(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y, c.rTopLeft, c.rTopRight, c.rBottomRight, c.rBottomLeft)
    of Clip:
      let c = command.clip
      nvgScissor(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)
    of StrokeColor:
      let c = command.strokeColor
      nvgStrokeColor(nvgCtx, NVGcolor(r: c.color.r, g: c.color.g, b: c.color.b, a: c.color.a))
    of FillColor:
      let c = command.fillColor
      nvgFillColor(nvgCtx, NVGcolor(r: c.color.r, g: c.color.g, b: c.color.b, a: c.color.a))
    of StrokeWidth:
      let c = command.strokeWidth
      nvgStrokeWidth(nvgCtx, c.width)
    of Translate:
      let c = command.translate
      nvgTranslate(nvgCtx, c.amount.x, c.amount.y)
    of MoveTo:
      let c = command.moveTo
      nvgMoveTo(nvgCtx, c.position.x, c.position.y)
    of LineTo:
      let c = command.lineTo
      nvgLineTo(nvgCtx, c.position.x, c.position.y)
    of ArcTo:
      let c = command.arcTo
      nvgArcTo(nvgCtx, c.p0.x, c.p0.y, c.p1.x, c.p1.y, c.radius)
    of Text:
      var c = command.text
      nvgFontFaceId(nvgCtx, cint(c.font))
      nvgFontSize(nvgCtx, c.fontSize)
      renderTextRaw(nvgCtx, c.position.x, c.position.y, c.data)

  # nvgRestore(nvgCtx)