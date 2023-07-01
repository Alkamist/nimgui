import ./nanovg
import ./vec2; export vec2
import ./color; export color
import ./paint; export paint
import ./path; export path

type
  VectorGraphicsContext* = ref VectorGraphicsContextObj
  VectorGraphicsContextObj* = object
    nvgCtx*: NVGcontext

proc `=destroy`*(ctx: var VectorGraphicsContextObj) =
  nvgDelete(ctx.nvgCtx)

proc new*(_: typedesc[VectorGraphicsContext]): VectorGraphicsContext =
  VectorGraphicsContext(nvgCtx: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES))

proc beginFrame*(ctx: VectorGraphicsContext, size: Vec2, scale: float) =
  nvgBeginFrame(ctx.nvgCtx, size.x / scale, size.y / scale, scale)
  nvgTextAlign(ctx.nvgCtx, NVG_ALIGN_LEFT or NVG_ALIGN_TOP)

proc endFrame*(ctx: VectorGraphicsContext) =
  nvgEndFrame(ctx.nvgCtx)

type
  Font* = int

  TextMeasurement* = object
    byteIndex*: int
    x*: float
    left*, right*: float

  DrawCommandKind* = enum
    FillPath
    StrokePath
    FillText
    Clip

  FillPathCommand* = object
    path*: Path
    paint*: Paint

  StrokePathCommand* = object
    path*: Path
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

proc calculateTextMetrics*(ctx: VectorGraphicsContext): tuple[ascender, descender, lineHeight: float] =
  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(ctx.nvgCtx, addr(ascender), addr(descender), addr(lineHeight))
  (float(ascender), float(descender), float(lineHeight))

proc measureText*(ctx: VectorGraphicsContext, position: Vec2, text: openArray[char]): seq[TextMeasurement] =
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
      result[i] = TextMeasurement(
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

proc processPath(nvgCtx: NVGcontext, path: Path) =
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

  # nvgSave(nvgCtx)
  # nvgTranslate(nvgCtx, offset.x, offset.y)

  for command in commands:
    case command.kind:
    of FillPath:
      let c = command.fillPath
      processPath(nvgCtx, c.path)
      nvgFillPaint(nvgCtx, c.paint.toNvgPaint)
      nvgFill(nvgCtx)
    of StrokePath:
      let c = command.strokePath
      processPath(nvgCtx, c.path)
      nvgStrokeWidth(nvgCtx, c.strokeWidth)
      nvgStrokePaint(nvgCtx, c.paint.toNvgPaint)
      nvgStroke(nvgCtx)
    of FillText:
      var c = command.fillText
      nvgFontFaceId(nvgCtx, cint(c.font))
      nvgFontSize(nvgCtx, c.fontSize)
      nvgFillColor(nvgCtx, c.color.toNvgColor)
      renderTextRaw(nvgCtx, c.position.x, c.position.y, c.text)
    of Clip:
      let c = command.clip
      nvgScissor(nvgCtx, c.position.x, c.position.y, c.size.x, c.size.y)

  # nvgRestore(nvgCtx)