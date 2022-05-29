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
  LineMetric* = object
    width*: float
    runeStart*, runeLen*: int
    byteStart*, byteLen*: int

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

  TextAlignX* = enum
    Left = NVG_ALIGN_LEFT
    Center = NVG_ALIGN_CENTER
    Right = NVG_ALIGN_RIGHT

  TextAlignY* = enum
    Top = NVG_ALIGN_TOP
    Center = NVG_ALIGN_MIDDLE
    Bottom = NVG_ALIGN_BOTTOM
    Baseline = NVG_ALIGN_BASELINE

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

    textAlignX*: TextAlignX
    textAlignY*: TextAlignY

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
    textAlignX: Left,
    textAlignY: Baseline,
  )

func scale*(canvas: Canvas): float =
  canvas.dpi / canvas.densityPixelDpi

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

proc `pathWinding=`*(canvas: Canvas, winding: Winding) =
  nvgPathWinding(canvas.nvgContext, winding.cint)

proc arc*(canvas: Canvas, p: Vec2, r, a0, a1: float, winding: Winding) =
  nvgArc(canvas.nvgContext, p.x, p.y, r, a0, a1, winding.cint)

proc rect*(canvas: Canvas, rect: Rect2) =
  nvgRect(canvas.nvgContext, rect.position.x, rect.position.y, rect.size.x, rect.size.y)

proc roundedRect*(canvas: Canvas, rect: Rect2, radius: float) =
  nvgRoundedRect(canvas.nvgContext, rect.position.x, rect.position.y, rect.size.x, rect.size.y, radius)

proc roundedRect*(canvas: Canvas, rect: Rect2,
                      radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) =
  nvgRoundedRectVarying(canvas.nvgContext,
                        rect.position.x, rect.position.y, rect.size.x, rect.size.y,
                        radTopLeft, radTopRight, radBottomRight, radBottomLeft)

proc ellipse*(canvas: Canvas, c, r: Vec2) =
  nvgEllipse(canvas.nvgContext, c.x, c.y, r.x, r.y)

proc circle*(canvas: Canvas, c: Vec2, r: float) =
  nvgCircle(canvas.nvgContext, c.x, c.y, r)

proc fill*(canvas: Canvas) =
  nvgFill(canvas.nvgContext)

proc stroke*(canvas: Canvas) =
  nvgStroke(canvas.nvgContext)

proc save*(canvas: Canvas) =
  nvgSave(canvas.nvgContext)

proc restore*(canvas: Canvas) =
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

proc scissor*(canvas: Canvas, rect: Rect2, intersect = true) =
  if intersect:
    nvgIntersectScissor(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height)
  else:
    nvgScissor(canvas.nvgContext, rect.x, rect.y, rect.width, rect.height)

proc resetScissor*(canvas: Canvas) =
  nvgResetScissor(canvas.nvgContext)

proc addFont*(canvas: Canvas, name, fileName: string) =
  let font = nvgCreateFont(canvas.nvgContext, name.cstring, fileName.cstring)
  if font == -1:
    echo "Failed to load font: " & fileName

proc `font=`*(canvas: Canvas, name: string) =
  nvgFontFace(canvas.nvgContext, name.cstring)

proc `fontSize=`*(canvas: Canvas, size: float) =
  nvgFontSize(canvas.nvgContext, size)

proc `letterSpacing=`*(canvas: Canvas, spacing: float) =
  nvgTextLetterSpacing(canvas.nvgContext, spacing)

{.pop.}

template runeEnd(line: LineMetric): untyped =
  line.runeStart + line.runeLen - 1

template `runeEnd=`(line: var LineMetric, value: int): untyped =
  line.runeLen = (value - line.runeStart) + 1

proc lineMetrics*(canvas: Canvas, text: string, bounds: Rect2, wordWrap = false): seq[LineMetric] =
  template addLine(): untyped = result.add LineMetric()
  template currentLine(): untyped = result[result.len - 1]
  addLine()

  const newLineRune = "\n".runeAt(0)
  let runes = text.toRunes

  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(canvas.nvgContext, ascender.addr, descender.addr, lineHeight.addr)

  var positions = newSeq[NVGglyphPosition](runes.len)
  discard nvgTextGlyphPositions(canvas.nvgContext, 0, 0, text, nil, positions[0].addr, runes.len.cint)

  var glyphWidths = newSeq[float](runes.len)

  # Set the last glyphWidth with nvgTextBounds, because
  # positions.maxx and positions.minx seem to be inaccurate.
  let lastGlyphStart = cast[cstring](text[text.len - runes[^1].size].unsafeAddr)
  let lastGlyphEnd = cast[cstring](cast[uint](text[0].unsafeAddr) + text.len.uint)
  var lastGlyphBounds: array[4, cfloat]
  discard nvgTextBounds(canvas.nvgContext, bounds.x, bounds.y, lastGlyphStart, lastGlyphEnd, lastGlyphBounds[0].addr)
  glyphWidths[^1] = lastGlyphBounds[2] - lastGlyphBounds[0]

  block:
    var lastWhitespace = 0
    var x = 0.0
    var i = 0
    while i < runes.len:
      let rune = runes[i]

      if i + 1 < runes.len:
        glyphWidths[i] = positions[i + 1].x - positions[i].x

      if rune.isWhiteSpace:
        lastWhitespace = i

      if rune == newLineRune:
        x = 0.0
        currentLine.runeEnd = i - 1
        addLine()
        inc i
        currentLine.runeStart = i
        continue

      let outOfBounds = x + glyphWidths[i] > bounds.width

      if wordWrap and outOfBounds and i > 0:
        x = 0.0
        if lastWhitespace > currentLine.runeStart:
          currentLine.runeEnd = lastWhitespace
          addLine()
          currentLine.runeStart = lastWhitespace + 1
          i = currentLine.runeStart
          continue
        else:
          currentLine.runeEnd = i - 1
          addLine()
          currentLine.runeStart = i

      x += glyphWidths[i]
      inc i

    currentLine.runeEnd = i - 1

  block:
    var glyphByteInfo = newSeq[tuple[index, len: int]](runes.len)
    var byteI = 0
    for i in 0 ..< runes.len:
      let runeLen = runes[i].size
      glyphByteInfo[i].index = byteI
      glyphByteInfo[i].len = runeLen
      byteI += runeLen

    var lineCount = 0
    for lineI in 0 ..< result.len:
      template line: untyped = result[lineI]

      let runeStart = line.runeStart
      if runeStart >= runes.len:
        break

      let runeEnd = line.runeEnd
      line.byteStart = glyphByteInfo[runeStart].index

      for i in runeStart .. runeEnd:
        line.byteLen += glyphByteInfo[i].len
        line.width += glyphWidths[i]

      lineCount += 1

    result.setLen(lineCount)

proc drawText*(canvas: Canvas,
               text: string,
               bounds: Rect2,
               alignX = TextAlignX.Right,
               alignY = TextAlignY.Top,
               wordWrap = true) =
  var ascender, descender, lineHeight: cfloat
  nvgTextMetrics(canvas.nvgContext, ascender.addr, descender.addr, lineHeight.addr)

  let lines = canvas.lineMetrics(text, bounds, wordWrap)

  let yAdjustment = case alignY:
    of Top: 0.0
    of Center: 0.5 * (bounds.size.y - (lineHeight * lines.len.float))
    of Bottom: bounds.size.y - (lineHeight * lines.len.float)
    of Baseline: -ascender

  var y = bounds.y + yAdjustment + ascender

  for line in lines:
    let xAdjustment = case alignX:
      of Left: 0.0
      of Center: 0.5 * (bounds.width - line.width)
      of Right: bounds.width - line.width

    let lineStartAddr = cast[uint](text[line.byteStart].unsafeAddr)
    let lineFinishAddr = lineStartAddr + line.byteLen.uint
    discard nvgText(canvas.nvgContext, bounds.x + xAdjustment, y, cast[cstring](lineStartAddr), cast[cstring](lineFinishAddr))
    y += lineHeight