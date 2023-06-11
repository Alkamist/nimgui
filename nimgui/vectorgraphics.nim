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
    Translate
    # MoveTo
    # LineTo
    # QuadTo
    # ArcTo
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
    # StrokeWidth
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

  ClipCommand = object
    x, y, width, height: float

  TranslateCommand = object
    x, y: float

  DrawCommand = object
    case kind: DrawCommandKind
    of Rect: rect: RectCommand
    of RoundedRect: roundedRect: RoundedRectCommand
    of StrokeColor: strokeColor: StrokeColorCommand
    of FillColor: fillColor: FillColorCommand
    of Clip: clip: ClipCommand
    of Translate: translate: TranslateCommand
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

proc `fillColor=`*(vg: VectorGraphics, color: Color) =
  vg.commands.add(DrawCommand(kind: FillColor, fillColor: FillColorCommand(r: color.r, g: color.g, b: color.b, a: color.a)))

proc `strokeColor=`*(vg: VectorGraphics, color: Color) =
  vg.commands.add(DrawCommand(kind: StrokeColor, strokeColor: StrokeColorCommand(r: color.r, g: color.g, b: color.b, a: color.a)))


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

proc renderVectorGraphics*(ctx: VectorGraphicsContext, vg: VectorGraphics, bounds: Rect2) =
  nvgSave(ctx.nvgCtx)
  nvgScissor(ctx.nvgCtx, bounds.x, bounds.y, bounds.width, bounds.height)
  nvgTranslate(ctx.nvgCtx, bounds.x, bounds.y)

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
    of Translate:
      let c = command.translate
      nvgTranslate(ctx.nvgCtx, c.x, c.y)

  nvgRestore(ctx.nvgCtx)

  vg.commands.setLen(0)