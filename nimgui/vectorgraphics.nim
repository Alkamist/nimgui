import ./nanovg
import ./vec2; export vec2
import ./color; export color
import ./paint; export paint
import ./path; export path

type
  Font* = int

type
  VectorGraphicsContext* = ref VectorGraphicsContextObj
  VectorGraphicsContextObj* = object
    nvgCtx*: NVGcontext
    currentFont: Font
    currentFontSize: float

proc `=destroy`*(ctx: var VectorGraphicsContextObj) =
  nvgDelete(ctx.nvgCtx)

proc new*(_: typedesc[VectorGraphicsContext]): VectorGraphicsContext =
  VectorGraphicsContext(nvgCtx: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES))

proc beginFrame*(ctx: VectorGraphicsContext, size: Vec2, contentScale: float) =
  nvgBeginFrame(ctx.nvgCtx, size.x, size.y, contentScale)
  nvgTextAlign(ctx.nvgCtx, NVG_ALIGN_LEFT or NVG_ALIGN_TOP)
  ctx.currentFont = 0
  ctx.currentFontSize = 16.0

proc endFrame*(ctx: VectorGraphicsContext) =
  nvgEndFrame(ctx.nvgCtx)

proc setFont(ctx: VectorGraphicsContext, font: Font) =
  if font == ctx.currentFont:
    return
  nvgFontFaceId(ctx.nvgCtx, cint(font))
  ctx.currentFont = font

proc setFontSize(ctx: VectorGraphicsContext, fontSize: float) =
  if fontSize == ctx.currentFontSize:
    return
  nvgFontSize(ctx.nvgCtx, fontSize)
  ctx.currentFontSize = fontSize

type
  TextMetrics* = object
    ascender*: float
    descender*: float
    lineHeight*: float

  Glyph* = object
    firstByte*: int
    lastByte*: int
    left*, right*: float
    drawOffsetX*: float

  DrawCommandKind* = enum
    FillPath
    StrokePath
    FillText
    Clip

  FillPathCommand* = object
    path*: type Path()[]
    position*: Vec2
    paint*: Paint

  StrokePathCommand* = object
    path*: type Path()[]
    position*: Vec2
    paint*: Paint
    strokeWidth*: float

  FillTextCommand* = object
    font*: Font
    fontSize*: float
    position*: Vec2
    text*: string
    color*: Color

  ClipCommand* = object
    position*: Vec2
    size*: Vec2

  DrawCommand* = object
    case kind*: DrawCommandKind
    of FillPath: fillPath*: FillPathCommand
    of StrokePath: strokePath*: StrokePathCommand
    of FillText: fillText*: FillTextCommand
    of Clip: clip*: ClipCommand

proc width*(glyph: Glyph): float =
  glyph.right - glyph.left

proc toNvgColor(color: Color): NVGcolor =
  NVGcolor(r: color.r, g: color.g, b: color.b, a: color.a)

proc toNvgPaint(paint: Paint): NVGpaint =
  for i, value in paint.transform: result.xform[i] = value
  for i, value in paint.extent: result.extent[i] = value
  result.radius = paint.radius
  result.feather = paint.feather
  result.innerColor = paint.innerColor.toNvgColor
  result.outerColor = paint.outerColor.toNvgColor
  result.image = cint(paint.image)

proc addFont*(ctx: VectorGraphicsContext, data: string): Font =
  let font = nvgCreateFontMem(ctx.nvgCtx, cstring"", cstring(data), cint(data.len), 0)
  if font == -1:
    echo "Failed to load font: " & $font
  font

proc textMetrics*(ctx: VectorGraphicsContext, font: Font, fontSize: float): TextMetrics =
  ctx.setFont(font)
  ctx.setFontSize(fontSize)

  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(ctx.nvgCtx, addr(ascender), addr(descender), addr(lineHeight))

  result.ascender = float(ascender)
  result.descender = float(descender)
  result.lineHeight = float(lineHeight)

proc measureGlyphs*(ctx: VectorGraphicsContext, text: openArray[char], font: Font, fontSize: float): seq[Glyph] =
  if text.len == 0:
    return

  ctx.setFont(font)
  ctx.setFontSize(fontSize)

  var nvgPositions = newSeq[NVGglyphPosition](text.len)
  let positionCount = nvgTextGlyphPositions(
    ctx.nvgCtx, 0, 0,
    cast[cstring](unsafeAddr(text[0])),
    cast[cstring](cast[uint64](unsafeAddr(text[text.len - 1])) + 1),
    addr(nvgPositions[0]),
    cint(text.len),
  )

  result = newSeq[Glyph](positionCount)

  for i in 0 ..< positionCount:
    let byteOffset = cast[uint64](unsafeAddr(text[0]))

    let lastByte =
      if i == positionCount - 1:
        text.len - 1
      else:
        int(cast[uint64](nvgPositions[i + 1].str) - byteOffset - 1)

    result[i] = Glyph(
      firstByte: int(cast[uint64](nvgPositions[i].str) - byteOffset),
      lastByte: lastByte,
      left: nvgPositions[i].minx,
      right: nvgPositions[i].maxx,
      drawOffsetX: nvgPositions[i].x - nvgPositions[i].minx,
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

proc processPath(nvgCtx: NVGcontext, path: type Path()[]) =
  nvgBeginPath(nvgCtx)
  for command in path.commands:
    case command.kind:
    of Close:
      nvgClosePath(nvgCtx)
    of Rect:
      let c = command.rect
      nvgRect(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)
    of RoundedRect:
      let c = command.roundedRect
      nvgRoundedRectVarying(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y, c.rTopLeft, c.rTopRight, c.rBottomRight, c.rBottomLeft)
    of MoveTo:
      let c = command.moveTo
      nvgMoveTo(nvgCtx, c.position.x, c.position.y)
    of LineTo:
      let c = command.lineTo
      nvgLineTo(nvgCtx, c.position.x, c.position.y)
    of ArcTo:
      let c = command.arcTo
      nvgArcTo(nvgCtx, c.p0.x, c.p0.y, c.p1.x, c.p1.y, c.radius)
    of Winding:
      let c = command.winding
      let value = case c.winding:
        of PathWinding.Positive: cint(1)
        of PathWinding.Negative: cint(2)
      nvgPathWinding(nvgCtx, value)

proc renderDrawCommands*(ctx: VectorGraphicsContext, commands: openArray[DrawCommand]) =
  let nvgCtx = ctx.nvgCtx
  for command in commands:
    case command.kind:
    of FillPath:
      let c = command.fillPath
      nvgSave(nvgCtx)
      nvgTranslate(nvgCtx, c.position.x, c.position.y)
      processPath(nvgCtx, c.path)
      nvgFillPaint(nvgCtx, c.paint.toNvgPaint)
      nvgFill(nvgCtx)
      nvgRestore(nvgCtx)
    of StrokePath:
      let c = command.strokePath
      nvgSave(nvgCtx)
      nvgTranslate(nvgCtx, c.position.x, c.position.y)
      processPath(nvgCtx, c.path)
      nvgStrokeWidth(nvgCtx, c.strokeWidth)
      nvgStrokePaint(nvgCtx, c.paint.toNvgPaint)
      nvgStroke(nvgCtx)
      nvgRestore(nvgCtx)
    of FillText:
      var c = command.fillText
      ctx.setFont(c.font)
      ctx.setFontSize(c.fontSize)
      nvgFillColor(nvgCtx, c.color.toNvgColor)
      renderTextRaw(nvgCtx, c.position.x, c.position.y, c.text)
    of Clip:
      let c = command.clip
      nvgScissor(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)