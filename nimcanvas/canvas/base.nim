{.experimental: "overloadableEnums".}

import opengl
import std/times
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

type
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
    text*: string
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
  canvas.text = ""
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