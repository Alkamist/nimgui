{.experimental: "overloadableEnums".}

import opengl
import std/times
import std/unicode
import ../nanovg/nanovg
import ../openglwrappers/openglcontext; export openglcontext
import ../tmath; export tmath

when defined(windows):
  import winim/lean as win32
  type
    PlatformData* = object
      moveTimer*: UINT_PTR

proc gladLoadGL(): int {.cdecl, importc.}
var gladIsInitialized = false

proc toNvgColor(color: Color): NVGcolor = nvgRGBAf(color.r, color.g, color.b, color.a)

type
  Paint* = NVGpaint

  Winding* = enum
    CounterClockwise = NVG_CCW
    Clockwise = NVG_CW

  Solidity* = enum
    Solid = NVG_SOLID
    Hole = NVG_HOLE

  LineCap* = enum
    Butt = NVG_BUTT
    Round = NVG_ROUND
    Square = NVG_SQUARE

  LineJoin* = enum
    Round = NVG_ROUND
    Bevel = NVG_BEVEL
    Miter = NVG_MITER

  MouseButton* = enum
    Unknown
    Left
    Middle
    Right
    Extra1
    Extra2
    Extra3
    Extra4
    Extra5

  KeyboardKey* = enum
    Unknown
    A
    B
    C
    D
    E
    F
    G
    H
    I
    J
    K
    L
    M
    N
    O
    P
    Q
    R
    S
    T
    U
    V
    W
    X
    Y
    Z
    Key1
    Key2
    Key3
    Key4
    Key5
    Key6
    Key7
    Key8
    Key9
    Key0
    Pad1
    Pad2
    Pad3
    Pad4
    Pad5
    Pad6
    Pad7
    Pad8
    Pad9
    Pad0
    F1
    F2
    F3
    F4
    F5
    F6
    F7
    F8
    F9
    F10
    F11
    F12
    Backtick
    Minus
    Equal
    Backspace
    Tab
    CapsLock
    Enter
    LeftShift
    RightShift
    LeftControl
    RightControl
    LeftAlt
    RightAlt
    LeftMeta
    RightMeta
    LeftBracket
    RightBracket
    Space
    Escape
    Backslash
    Semicolon
    Quote
    Comma
    Period
    Slash
    ScrollLock
    Pause
    Insert
    End
    PageUp
    Delete
    Home
    PageDown
    LeftArrow
    RightArrow
    DownArrow
    UpArrow
    NumLock
    PadDivide
    PadMultiply
    PadSubtract
    PadAdd
    PadEnter
    PadPeriod

  Canvas* = ref object
    onFrame*: proc()
    isOpen*: bool
    handle*: pointer
    isChild*: bool
    time*: float
    dpi*: float
    densityPixelDpi*: float
    positionPixels*: Vec2
    sizePixels*: Vec2
    mousePositionPixels*: Vec2
    mouseWheel*: Vec2
    textInput*: string
    mouseDownStates*: array[MouseButton, bool]
    keyDownStates*: array[KeyboardKey, bool]
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]

    previousTime*: float
    previousPositionPixels*: Vec2
    previousSizePixels*: Vec2
    previousMousePositionPixels*: Vec2
    previousMouseDownStates*: array[MouseButton, bool]
    previousKeyDownStates*: array[KeyboardKey, bool]

    openGlContext*: OpenGlContext
    nvgContext*: NVGcontext

    platform*: PlatformData

proc `=destroy`*(canvas: var type Canvas()[]) =
  nvgDeleteGL3(canvas.nvgContext)

proc newCanvasBase*(): Canvas =
  let time = cpuTime()
  result = Canvas(
    dpi: 96.0,
    densityPixelDpi: 96.0,
    time: time,
    previousTime: time,
  )

func scale*(canvas: Canvas): float =
  canvas.dpi / canvas.densityPixelDpi

func pixelThickness*(canvas: Canvas): float =
  canvas.densityPixelDpi / canvas.dpi

func delta*(canvas: Canvas): float =
  canvas.time - canvas.previousTime

func aspectRatio*(canvas: Canvas): float =
  canvas.sizePixels.x / canvas.sizePixels.y

# Mouse position

func mousePosition*(canvas: Canvas): Vec2 =
  let scale = canvas.scale
  vec2(canvas.mousePositionPixels.x / scale,
       canvas.mousePositionPixels.y / scale)

func mouseDeltaPixels*(canvas: Canvas): Vec2 =
  vec2(canvas.mousePositionPixels.x - canvas.previousMousePositionPixels.x,
       canvas.mousePositionPixels.y - canvas.previousMousePositionPixels.y)

func mouseDelta*(canvas: Canvas): Vec2 =
  let delta = canvas.mouseDeltaPixels
  let scale = canvas.scale
  vec2(delta.x / scale, delta.y / scale)

func mouseMoved*(canvas: Canvas): bool =
  let delta = canvas.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Position

func position*(canvas: Canvas): Vec2 =
  let scale = canvas.scale
  vec2(canvas.positionPixels.x.float / scale,
       canvas.positionPixels.y.float / scale)

func x*(canvas: Canvas): float = canvas.position.x
func y*(canvas: Canvas): float = canvas.position.y

func positionDeltaPixels*(canvas: Canvas): Vec2 =
  vec2(canvas.positionPixels.x - canvas.previousPositionPixels.x,
       canvas.positionPixels.y - canvas.previousPositionPixels.y)

func positionDelta*(canvas: Canvas): Vec2 =
  let delta = canvas.positionDeltaPixels
  let scale = canvas.scale
  vec2(delta.x / scale, delta.y / scale)

func moved*(canvas: Canvas): bool =
  let delta = canvas.positionDeltaPixels
  delta.x != 0 or delta.y != 0

# Size

func size*(canvas: Canvas): Vec2 =
  let scale = canvas.scale
  vec2(canvas.sizePixels.x / scale, canvas.sizePixels.y / scale)

func width*(canvas: Canvas): float = canvas.size.x
func height*(canvas: Canvas): float = canvas.size.y

func sizeDeltaPixels*(canvas: Canvas): Vec2 =
  vec2(canvas.sizePixels.x - canvas.previousSizePixels.x,
       canvas.sizePixels.y - canvas.previousSizePixels.y)

func sizeDelta*(canvas: Canvas): Vec2 =
  let delta = canvas.sizeDeltaPixels
  let scale = canvas.scale
  vec2(delta.x / scale, delta.y / scale)

func resized*(canvas: Canvas): bool =
  let delta = canvas.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Mouse buttons

func mouseDown*(canvas: Canvas, button: MouseButton): bool =
  canvas.mouseDownStates[button]

func mousePressed*(canvas: Canvas, button: MouseButton): bool =
  canvas.mouseDownStates[button] and not canvas.previousMouseDownStates[button]

func mouseReleased*(canvas: Canvas, button: MouseButton): bool =
  canvas.previousMouseDownStates[button] and not canvas.mouseDownStates[button]

# Keyboard keys

func keyDown*(canvas: Canvas, key: KeyboardKey): bool =
  canvas.keyDownStates[key]

func keyPressed*(canvas: Canvas, key: KeyboardKey): bool =
  canvas.keyDownStates[key] and not canvas.previousKeyDownStates[key]

func keyReleased*(canvas: Canvas, key: KeyboardKey): bool =
  canvas.previousKeyDownStates[key] and not canvas.keyDownStates[key]

# Base functions

proc updatePreviousState*(canvas: Canvas) =
  canvas.previousTime = canvas.time
  canvas.previousPositionPixels = canvas.positionPixels
  canvas.previousSizePixels = canvas.sizePixels
  canvas.previousMousePositionPixels = canvas.mousePositionPixels
  canvas.previousMouseDownStates = canvas.mouseDownStates
  canvas.previousKeyDownStates = canvas.keyDownStates
  canvas.mouseWheel = vec2(0, 0)
  canvas.textInput = ""
  canvas.mousePresses.setLen(0)
  canvas.mouseReleases.setLen(0)
  canvas.keyPresses.setLen(0)
  canvas.keyReleases.setLen(0)
  canvas.time = cpuTime()

proc initBase*(canvas: Canvas) =
  canvas.openGlContext = newOpenGlContext(canvas.handle)
  canvas.openGlContext.select()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)

  if not gladIsInitialized:
    if gladLoadGL() <= 0:
      quit "Failed to initialise glad."
    gladIsInitialized = true

  canvas.nvgContext = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES)

proc beginFrameBase*(canvas: Canvas) =
  canvas.openGlContext.select()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)
  glViewport(0.GLint, 0.GLint, canvas.sizePixels.x.GLsizei, canvas.sizePixels.y.GLsizei)
  glScissor(0.GLint, 0.GLint, canvas.sizePixels.x.GLsizei, canvas.sizePixels.y.GLsizei)
  glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
  nvgBeginFrame(canvas.nvgContext, canvas.size.x, canvas.size.y, canvas.scale)
  nvgResetScissor(canvas.nvgContext)

proc endFrameBase*(canvas: Canvas) =
  nvgEndFrame(canvas.nvgContext)
  canvas.openGlContext.swapBuffers()

# Drawing

{.push inline.}

proc pixelAlign*(canvas: Canvas, value: float): float =
  let scale = canvas.scale
  (value * scale).round / scale

proc pixelAlign*(canvas: Canvas, position: Vec2): Vec2 =
  let scale = canvas.scale
  (position * scale).round / scale

proc pixelAlign*(canvas: Canvas, bounds: Rect2): Rect2 =
  let scale = canvas.scale
  rect2(
    (bounds.x * scale).round / scale,
    (bounds.y * scale).round / scale,
    (bounds.width * scale).round / scale,
    (bounds.height * scale).round / scale,
  )

proc `backgroundColor=`*(canvas: Canvas, color: Color) =
  canvas.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)

proc beginPath*(canvas: Canvas) =
  nvgBeginPath(canvas.nvgContext)

proc moveTo*(canvas: Canvas, p: Vec2) =
  nvgMoveTo(canvas.nvgContext, p.x, p.y)

proc lineTo*(canvas: Canvas, p: Vec2) =
  nvgLineTo(canvas.nvgContext, p.x, p.y)

proc bezierTo*(canvas: Canvas, c0, c1, p: Vec2) =
  nvgBezierTo(canvas.nvgContext, c0.x, c0.y, c1.x, c1.y, p.x, p.y)

proc quadTo*(canvas: Canvas, c, p: Vec2) =
  nvgQuadTo(canvas.nvgContext, c.x, c.y, p.x, p.y)

proc arcTo*(canvas: Canvas, p0, p1: Vec2, radius: float) =
  nvgArcTo(canvas.nvgContext, p0.x, p0.y, p1.x, p1.y, radius)

proc closePath*(canvas: Canvas) =
  nvgClosePath(canvas.nvgContext)

proc `pathWinding=`*(canvas: Canvas, winding: Winding or Solidity) =
  nvgPathWinding(canvas.nvgContext, winding.cint)

proc arc*(canvas: Canvas, p: Vec2, r, a0, a1: float, winding: Winding) =
  nvgArc(canvas.nvgContext, p.x, p.y, r, a0, a1, winding.cint)

proc rect*(canvas: Canvas, rect: Rect2) =
  nvgRect(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height)

proc roundedRect*(canvas: Canvas, rect: Rect2, radius: float) =
  nvgRoundedRect(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height, radius)

proc roundedRect*(canvas: Canvas, rect: Rect2, radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) =
  nvgRoundedRectVarying(canvas.nvgContext,
                        rect.x, rect.y, rect.width, rect.height,
                        radTopLeft, radTopRight, radBottomRight, radBottomLeft)

proc ellipse*(canvas: Canvas, c, r: Vec2) =
  nvgEllipse(canvas.nvgContext, c.x, c.y, r.x, r.y)

proc circle*(canvas: Canvas, c: Vec2, r: float) =
  nvgCircle(canvas.nvgContext, c.x, c.y, r)

proc fill*(canvas: Canvas) =
  nvgFill(canvas.nvgContext)

proc stroke*(canvas: Canvas) =
  nvgStroke(canvas.nvgContext)

proc saveState*(canvas: Canvas) =
  nvgSave(canvas.nvgContext)

proc restoreState*(canvas: Canvas) =
  nvgRestore(canvas.nvgContext)

proc reset*(canvas: Canvas) =
  nvgReset(canvas.nvgContext)

proc `shapeAntiAlias=`*(canvas: Canvas, enabled: bool) =
  nvgShapeAntiAlias(canvas.nvgContext, enabled.cint)

proc `strokeColor=`*(canvas: Canvas, color: Color) =
  nvgStrokeColor(canvas.nvgContext, color.toNvgColor)

proc `strokePaint=`*(canvas: Canvas, paint: Paint) =
  nvgStrokePaint(canvas.nvgContext, paint)

proc `fillColor=`*(canvas: Canvas, color: Color) =
  nvgFillColor(canvas.nvgContext, color.toNvgColor)

proc `fillPaint=`*(canvas: Canvas, paint: Paint) =
  nvgFillPaint(canvas.nvgContext, paint)

proc `miterLimit=`*(canvas: Canvas, limit: float) =
  nvgMiterLimit(canvas.nvgContext, limit)

proc `strokeWidth=`*(canvas: Canvas, width: float) =
  nvgStrokeWidth(canvas.nvgContext, width)

proc `lineCap=`*(canvas: Canvas, cap: LineCap) =
  nvgLineCap(canvas.nvgContext, cap.cint)

proc `lineJoin=`*(canvas: Canvas, join: LineJoin) =
  nvgLineJoin(canvas.nvgContext, join.cint)

proc `globalAlpha=`*(canvas: Canvas, alpha: float) =
  nvgGlobalAlpha(canvas.nvgContext, alpha)

proc clip*(canvas: Canvas, rect: Rect2, intersect = true) =
  if intersect:
    nvgIntersectScissor(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height)
  else:
    nvgScissor(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height)

proc resetClip*(canvas: Canvas) =
  nvgResetScissor(canvas.nvgContext)

proc addFont*(canvas: Canvas, name, data: string) =
  let font = nvgCreateFontMem(canvas.nvgContext, name.cstring, data.cstring, data.len.cint, 0)
  if font == -1:
    echo "Failed to load font: " & name

proc `font=`*(canvas: Canvas, name: string) =
  nvgFontFace(canvas.nvgContext, name.cstring)

proc `fontSize=`*(canvas: Canvas, size: float) =
  nvgFontSize(canvas.nvgContext, size)

proc `letterSpacing=`*(canvas: Canvas, spacing: float) =
  nvgTextLetterSpacing(canvas.nvgContext, spacing)

proc linearGradient*(canvas: Canvas, startPosition, endPosition: Vec2, startColor, endColor: Color): Paint =
  nvgLinearGradient(canvas.nvgContext, startPosition.x, startPosition.y, endPosition.x, endPosition.y, startColor.toNvgColor, endColor.toNvgColor)

proc boxGradient*(canvas: Canvas, bounds: Rect2, cornerRadius, feather: float, innerColor, outerColor: Color): Paint =
  nvgBoxGradient(canvas.nvgContext, bounds.x, bounds.y, bounds.width, bounds.height, cornerRadius, feather, innerColor.toNvgColor, outerColor.toNvgColor)

proc radialGradient*(canvas: Canvas, center: Vec2, innerRadius, outerRadius: float, innerColor, outerColor: Color): Paint =
  nvgRadialGradient(canvas.nvgContext, center.x, center.y, innerRadius, outerRadius, innerColor.toNvgColor, outerColor.toNvgColor)

{.pop.}

import ./text; export text

proc newText*(canvas: Canvas, data: string): Text =
  let runes = data.toRunes
  result = Text(
    data: data,
    glyphs: newSeq[Glyph](runes.len),
    lines: @[(startIndex: 0, endIndex: runes.len - 1)]
  )

  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(canvas.nvgContext, ascender.addr, descender.addr, lineHeight.addr)
  result.ascender = ascender
  result.descender = descender
  result.lineHeight = lineHeight

  var positions = newSeq[NVGglyphPosition](runes.len)
  discard nvgTextGlyphPositions(canvas.nvgContext, 0, 0, data, nil, positions[0].addr, runes.len.cint)

  let lastGlyphStart = cast[cstring](data[data.len - runes[^1].size].unsafeAddr)
  let lastGlyphEnd = cast[cstring](cast[uint](data[0].unsafeAddr) + data.len.uint)
  var lastGlyphBounds: array[4, cfloat]
  discard nvgTextBounds(canvas.nvgContext, 0, 0, lastGlyphStart, lastGlyphEnd, lastGlyphBounds[0].addr)
  result.glyphs[^1].width = lastGlyphBounds[2] - lastGlyphBounds[0]

  var byteIndex = 0
  for i in 0 ..< runes.len:
    let rune = runes[i]
    result.glyphs[i].rune = rune
    result.glyphs[i].byteIndex = byteIndex
    if i + 1 < runes.len:
      result.glyphs[i].width = positions[i + 1].x - positions[i].x
    byteIndex += rune.size

proc drawText*(canvas: Canvas,
               text: Text,
               bounds: Rect2,
               alignX = TextAlignX.Left,
               alignY = TextAlignY.Top,
               wordWrap = false,
               clip = true) =
  proc drawLine(text: Text, line: TextLine, lineBounds: Rect2) =
    let startGlyph = text.glyphs[line.startIndex]
    let endGlyph = text.glyphs[line.endIndex]
    let lineStartAddr = cast[uint](text.data[startGlyph.byteIndex].unsafeAddr)
    let lineByteLen = (endGlyph.byteIndex + endGlyph.rune.size) - startGlyph.byteIndex
    let lineEndAddr = lineStartAddr + lineByteLen.uint
    # canvas.saveState()
    # canvas.beginPath()
    # canvas.roundedRect lineBounds, 2
    # canvas.fillColor = rgb(0, 120, 0)
    # canvas.fill()
    # canvas.restoreState()
    discard nvgText(canvas.nvgContext, lineBounds.x, lineBounds.y + text.ascender, cast[cstring](lineStartAddr), cast[cstring](lineEndAddr))

  if clip:
    canvas.saveState()
    canvas.clip(bounds)

  text.drawLines(bounds, alignX, alignY, wordWrap, clip, drawLine)

  if clip:
    canvas.restoreState()