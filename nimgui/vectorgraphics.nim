import ./math

type
  DrawCommandKind = enum
    BeginPath
    ClosePath
    Fill
    Stroke
    Rect
    RoundedRect
    Clip
    StrokeColor
    FillColor
    StrokeWidth
    Translate
    MoveTo
    LineTo
    # QuadTo
    ArcTo
    # Arc
    # RoundedRect
    # Ellipse
    # Circle
    # SaveState
    # RestoreState
    # Reset
    # ResetTransform
    # PathWinding
    # ShapeAntiAlias
    # FillPaint
    # MiterLimit
    # LineCap
    # LineJoin
    # GlobalAlpha
    # Text
    # TextAlign
    # Font
    # FontSize
    # LetterSpacing
    # Scale

  RectCommand = object
    x, y, width, height: float

  RoundedRectCommand = object
    x, y, width, height: float
    rTopLeft, rTopRight: float
    rBottomRight, rBottomLeft: float

  StrokeColorCommand = object
    r, g, b, a: float

  FillColorCommand = object
    r, g, b, a: float

  StrokeWidthCommand = object
    width: float

  ClipCommand = object
    x, y, width, height: float

  TranslateCommand = object
    x, y: float

  MoveToCommand = object
    x, y: float

  LineToCommand = object
    x, y: float

  ArcToCommand = object
    x0, y0, x1, y1, radius: float

  DrawCommand = object
    case kind: DrawCommandKind
    of Rect: rect: RectCommand
    of RoundedRect: roundedRect: RoundedRectCommand
    of StrokeColor: strokeColor: StrokeColorCommand
    of FillColor: fillColor: FillColorCommand
    of StrokeWidth: strokeWidth: StrokeWidthCommand
    of Clip: clip: ClipCommand
    of Translate: translate: TranslateCommand
    of MoveTo: moveTo: MoveToCommand
    of LineTo: lineTo: LineToCommand
    of ArcTo: arcTo: ArcToCommand
    else: discard

  # Paint* = object
  #   transform*: array[6, float]
  #   extent*: array[2, float]
  #   radius*: float
  #   feather*: float
  #   innerColor*: Color
  #   outerColor*: Color
  #   image*: int

  VectorGraphics* = ref object
    commands: seq[DrawCommand]

proc beginPath*(vg: VectorGraphics) =
  vg.commands.add(DrawCommand(kind: BeginPath))


proc closePath*(vg: VectorGraphics) =
  vg.commands.add(DrawCommand(kind: ClosePath))


proc fill*(vg: VectorGraphics) =
  vg.commands.add(DrawCommand(kind: Fill))


proc stroke*(vg: VectorGraphics) =
  vg.commands.add(DrawCommand(kind: Stroke))


proc rect*(vg: VectorGraphics, x, y, width, height: float) =
  vg.commands.add(DrawCommand(kind: Rect, rect: RectCommand(x: x, y: y, width: width, height: height)))

proc rect*(vg: VectorGraphics, position, size: Vec2) =
  vg.rect(position.x, position.y, size.x, size.y)

proc rect*(vg: VectorGraphics, rect: Rect2) =
  vg.rect(rect.position, rect.size)


proc roundedRect*(vg: VectorGraphics, x, y, width, height, rTopLeft, rTopRight, rBottomRight, rBottomLeft: float) =
  vg.commands.add(DrawCommand(kind: RoundedRect, roundedRect: RoundedRectCommand(
    x: x, y: y, width: width, height: height,
    rTopLeft: rTopLeft, rTopRight: rTopRight, rBottomRight: rBottomRight, rBottomLeft: rBottomLeft
  )))

proc roundedRect*(vg: VectorGraphics, position, size: Vec2, rTopLeft, rTopRight, rBottomRight, rBottomLeft: float) =
  vg.roundedRect(position.x, position.y, size.x, size.y, rTopLeft, rTopRight, rBottomRight, rBottomLeft)

proc roundedRect*(vg: VectorGraphics, rect: Rect2, rTopLeft, rTopRight, rBottomRight, rBottomLeft: float) =
  vg.roundedRect(rect.position, rect.size, rTopLeft, rTopRight, rBottomRight, rBottomLeft)

proc roundedRect*(vg: VectorGraphics, x, y, width, height, rounding: float) =
  vg.roundedRect(x, y, width, height, rounding, rounding, rounding, rounding)

proc roundedRect*(vg: VectorGraphics, position, size: Vec2, rounding: float) =
  vg.roundedRect(position, size, rounding, rounding, rounding, rounding)

proc roundedRect*(vg: VectorGraphics, rect: Rect2, rounding: float) =
  vg.roundedRect(rect, rounding, rounding, rounding, rounding)


proc clip*(vg: VectorGraphics, x, y, width, height: float) =
  vg.commands.add(DrawCommand(kind: Clip, clip: ClipCommand(x: x, y: y, width: width, height: height)))

proc clip*(vg: VectorGraphics, position, size: Vec2) =
  vg.clip(position.x, position.y, size.x, size.y)

proc clip*(vg: VectorGraphics, rect: Rect2) =
  vg.clip(rect.position, rect.size)


proc translate*(vg: VectorGraphics, value: Vec2) =
  vg.commands.add(DrawCommand(kind: Translate, translate: TranslateCommand(x: value.x, y: value.y)))


proc fillColor*(vg: VectorGraphics, r, g, b, a: float) =
  vg.commands.add(DrawCommand(kind: FillColor, fillColor: FillColorCommand(r: r, g: g, b: b, a: a)))

proc fillColor*(vg: VectorGraphics, r, g, b: float) =
  vg.fillColor(r, g, b, 1)

proc fillColor*(vg: VectorGraphics, color: Color) =
  vg.fillColor(color.r, color.g, color.b, color.a)


proc strokeColor*(vg: VectorGraphics, r, g, b, a: float) =
  vg.commands.add(DrawCommand(kind: StrokeColor, strokeColor: StrokeColorCommand(r: r, g: g, b: b, a: a)))

proc strokeColor*(vg: VectorGraphics, r, g, b: float) =
  vg.strokeColor(r, g, b, 1)

proc strokeColor*(vg: VectorGraphics, color: Color) =
  vg.strokeColor(color.r, color.g, color.b, color.a)


proc strokeWidth*(vg: VectorGraphics, width: float) =
  vg.commands.add(DrawCommand(kind: StrokeWidth, strokeWidth: StrokeWidthCommand(width: width)))


proc moveTo*(vg: VectorGraphics, x, y: float) =
  vg.commands.add(DrawCommand(kind: MoveTo, moveTo: MoveToCommand(x: x, y: y)))

proc moveTo*(vg: VectorGraphics, position: Vec2) =
  vg.moveTo(position.x, position.y)


proc lineTo*(vg: VectorGraphics, x, y: float) =
  vg.commands.add(DrawCommand(kind: LineTo, lineTo: LineToCommand(x: x, y: y)))

proc lineTo*(vg: VectorGraphics, position: Vec2) =
  vg.lineTo(position.x, position.y)


proc arcTo*(vg: VectorGraphics, x0, y0, x1, y1, radius: float) =
  vg.commands.add(DrawCommand(kind: ArcTo, arcTo: ArcToCommand(x0: x0, y0: y0, x1: x1, y1: y1, radius: radius)))

proc arcTo*(vg: VectorGraphics, p0, p1: Vec2, radius: float) =
  vg.arcTo(p0.x, p0.y, p1.x, p1.y, radius)


# ==========================================================================================
# Nanovg Implementation
# ==========================================================================================


import ./nanovg

type
  VectorGraphicsContext* = ref VectorGraphicsContextObj
  VectorGraphicsContextObj* = object
    nvgCtx: NVGcontext

proc `=destroy`*(ctx: var VectorGraphicsContextObj) =
  nvgDelete(ctx.nvgCtx)

proc new*(_: typedesc[VectorGraphicsContext]): VectorGraphicsContext =
  VectorGraphicsContext(nvgCtx: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES))

proc beginFrame*(ctx: VectorGraphicsContext, size: Vec2, scale: float) =
  nvgBeginFrame(ctx.nvgCtx, size.x / scale, size.y / scale, scale)

proc endFrame*(ctx: VectorGraphicsContext) =
  nvgEndFrame(ctx.nvgCtx)

proc renderVectorGraphics*(ctx: VectorGraphicsContext, vg: VectorGraphics, offset: Vec2) =
  nvgSave(ctx.nvgCtx)
  nvgTranslate(ctx.nvgCtx, offset.x, offset.y)

  for command in vg.commands:
    case command.kind:
    of BeginPath: nvgBeginPath(ctx.nvgCtx)
    of ClosePath: nvgClosePath(ctx.nvgCtx)
    of Fill: nvgFill(ctx.nvgCtx)
    of Stroke: nvgStroke(ctx.nvgCtx)
    of Rect:
      let c = command.rect
      nvgRect(ctx.nvgCtx, c.x, c.y, c.width, c.height)
    of RoundedRect:
      let c = command.roundedRect
      nvgRoundedRectVarying(ctx.nvgCtx, c.x, c.y, c.width, c.height, c.rTopLeft, c.rTopRight, c.rBottomRight, c.rBottomLeft)
    of Clip:
      let c = command.clip
      nvgScissor(ctx.nvgCtx, c.x, c.y, c.width, c.height)
    of StrokeColor:
      let c = command.strokeColor
      nvgStrokeColor(ctx.nvgCtx, NVGcolor(r: c.r, g: c.g, b: c.b, a: c.a))
    of FillColor:
      let c = command.fillColor
      nvgFillColor(ctx.nvgCtx, NVGcolor(r: c.r, g: c.g, b: c.b, a: c.a))
    of StrokeWidth:
      let c = command.strokeWidth
      nvgStrokeWidth(ctx.nvgCtx, c.width)
    of Translate:
      let c = command.translate
      nvgTranslate(ctx.nvgCtx, c.x, c.y)
    of MoveTo:
      let c = command.moveTo
      nvgMoveTo(ctx.nvgCtx, c.x, c.y)
    of LineTo:
      let c = command.lineTo
      nvgLineTo(ctx.nvgCtx, c.x, c.y)
    of ArcTo:
      let c = command.arcTo
      nvgArcTo(ctx.nvgCtx, c.x0, c.y0, c.x1, c.y1, c.radius)

  nvgRestore(ctx.nvgCtx)

  vg.commands.setLen(0)