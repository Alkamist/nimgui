{.experimental: "overloadableEnums".}

import std/math; export math
import std/hashes; export hashes
import std/tables; export tables
import oswindow; export oswindow

type
  Vec2* = object
    x*, y*: float

  Color* = object
    r*, g*, b*, a*: float

func `~=`*(a, b: float): bool {.inline.} = (a - b).abs <= 0.000001

# ===========================================================
# Nanovg Implementation
# ===========================================================

import nanovg

type
  GuiVectorGraphicsContext* = ref GuiVectorGraphicsContextObj
  GuiVectorGraphicsContextObj* = object
    nvgCtx*: NVGcontext

proc `=destroy`*(ctx: var GuiVectorGraphicsContextObj) =
  nvgDelete(ctx.nvgCtx)

proc new*(_: typedesc[GuiVectorGraphicsContext]): GuiVectorGraphicsContext =
  GuiVectorGraphicsContext(nvgCtx: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES))

proc beginFrame*(ctx: GuiVectorGraphicsContext, size: Vec2, scale: float) =
  nvgBeginFrame(ctx.nvgCtx, size.x / scale, size.y / scale, scale)
  nvgTextAlign(ctx.nvgCtx, NVG_ALIGN_LEFT or NVG_ALIGN_TOP)

proc endFrame*(ctx: GuiVectorGraphicsContext) =
  nvgEndFrame(ctx.nvgCtx)

# ===========================================================

type
  GuiId* = Hash
  GuiFont* = int

  GuiState* = ref object of RootObj
    id*: GuiId
    init*: bool

  GuiControl* = ref object of GuiState
    position*: Vec2
    size*: Vec2

  GuiTextMeasurement* = object
    index*: int
    x*: float
    width*: float
    logicalX*: float

  GuiClip* = object
    position*: Vec2
    size*: Vec2

  GuiZLayer* = object
    drawCommands*: seq[DrawCommand]
    zIndex*: int
    finalHover*: GuiId

  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    cursorStyle*: CursorStyle

    # Input
    globalMousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    # Ids and state
    hover*: GuiId
    currentId*: GuiId
    retainedState*: Table[GuiId, GuiState]
    idStack*: seq[GuiId]

    # Z index
    highestZIndex*: int
    zLayerStack*: seq[GuiZLayer]
    zLayers*: seq[GuiZLayer]

    # Offset
    offsetStack*: seq[Vec2]
    globalPositionOffset*: Vec2

    # Clipping
    clipStack*: seq[GuiClip]

    # Vector graphics
    currentFont*: GuiFont
    currentFontSize*: float
    originalFontSize*: float
    textAscender*: float
    textDescender*: float
    lineHeight*: float
    vgCtx*: GuiVectorGraphicsContext

    # Previous frame state
    previousTime*: float
    previousGlobalMousePosition*: Vec2

  DrawCommandKind* = enum
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
    ResetTransform
    # PathWinding
    # ShapeAntiAlias
    # FillPaint
    # MiterLimit
    # LineCap
    # LineJoin
    # GlobalAlpha
    Text
    # Scale

  RectCommand* = object
    position*, size*: Vec2

  RoundedRectCommand* = object
    position*, size*: Vec2
    rTopLeft*, rTopRight*: float
    rBottomRight*, rBottomLeft*: float

  StrokeColorCommand* = object
    color*: Color

  FillColorCommand* = object
    color*: Color

  StrokeWidthCommand* = object
    width*: float

  ClipCommand* = object
    position*, size*: Vec2

  TranslateCommand* = object
    amount*: Vec2

  MoveToCommand* = object
    position*: Vec2

  LineToCommand* = object
    position*: Vec2

  ArcToCommand* = object
    p0*, p1*: Vec2
    radius*: float

  TextCommand* = object
    font*: GuiFont
    fontSize*: float
    position*: Vec2
    data*: string

  DrawCommand* = object
    case kind*: DrawCommandKind
    of Rect: rect*: RectCommand
    of RoundedRect: roundedRect*: RoundedRectCommand
    of StrokeColor: strokeColor*: StrokeColorCommand
    of FillColor: fillColor*: FillColorCommand
    of StrokeWidth: strokeWidth*: StrokeWidthCommand
    of Clip: clip*: ClipCommand
    of Translate: translate*: TranslateCommand
    of MoveTo: moveTo*: MoveToCommand
    of LineTo: lineTo*: LineToCommand
    of ArcTo: arcTo*: ArcToCommand
    of Text: text*: TextCommand
    else: discard