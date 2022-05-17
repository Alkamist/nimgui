{.experimental: "overloadableEnums".}

import std/times
export times

when defined(windows):
  import winim/lean as win32
  type
    PlatformData* = object
      moveTimer*: UINT_PTR

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

  Client* = ref object
    onFrame*: proc()
    isOpen*: bool
    handle*: pointer
    isChild*: bool
    time*: float
    dpi*: float
    densityPixelDpi*: float
    positionPixels*: tuple[x, y: int]
    sizePixels*: tuple[x, y: int]
    mousePositionPixels*: tuple[x, y: int]
    mouseWheel*: tuple[x, y: float]
    text*: string
    mouseDown*: array[MouseButton, bool]
    keyDown*: array[KeyboardKey, bool]
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]

    previousTime*: float
    previousPositionPixels*: tuple[x, y: int]
    previousSizePixels*: tuple[x, y: int]
    previousMousePositionPixels*: tuple[x, y: int]
    previousMouseDown*: array[MouseButton, bool]
    previousKeyDown*: array[KeyboardKey, bool]

    platform*: PlatformData

proc newClientBase*(): Client =
  let time = cpuTime()
  Client(
    dpi: 96.0,
    densityPixelDpi: 96.0,
    time: time,
    previousTime: time,
  )

func densityPixelsPerPixel*(client: Client): float =
  client.densityPixelDpi / client.dpi

func delta*(client: Client): float =
  client.time - client.previousTime

func aspectRatio*(client: Client): float =
  client.sizePixels.x / client.sizePixels.y

# Mouse position

func mousePosition*(client: Client): tuple[x, y: float] =
  let dp = client.densityPixelsPerPixel
  (client.mousePositionPixels.x.float / dp,
   client.mousePositionPixels.y.float / dp)

func mouseDeltaPixels*(client: Client): tuple[x, y: int] =
  (client.mousePositionPixels.x - client.previousMousePositionPixels.x,
   client.mousePositionPixels.y - client.previousMousePositionPixels.y)

func mouseDelta*(client: Client): tuple[x, y: float] =
  let delta = client.mouseDeltaPixels
  let dp = client.densityPixelsPerPixel
  (delta.x.float / dp, delta.y.float / dp)

func mouseMoved*(client: Client): bool =
  let delta = client.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Position

func position*(client: Client): tuple[x, y: float] =
  let dp = client.densityPixelsPerPixel
  (client.positionPixels.x.float / dp,
   client.positionPixels.y.float / dp)

func positionDeltaPixels*(client: Client): tuple[x, y: int] =
  (client.positionPixels.x - client.previousPositionPixels.x,
   client.positionPixels.y - client.previousPositionPixels.y)

func positionDelta*(client: Client): tuple[x, y: float] =
  let delta = client.positionDeltaPixels
  let dp = client.densityPixelsPerPixel
  (delta.x.float / dp, delta.y.float / dp)

func moved*(client: Client): bool =
  let delta = client.positionDeltaPixels
  delta.x != 0 or delta.y != 0

# Size

func size*(client: Client): tuple[x, y: float] =
  let dp = client.densityPixelsPerPixel
  (client.sizePixels.x.float / dp, client.sizePixels.y.float / dp)

func sizeDeltaPixels*(client: Client): tuple[x, y: int] =
  (client.sizePixels.x - client.previousSizePixels.x,
   client.sizePixels.y - client.previousSizePixels.y)

func sizeDelta*(client: Client): tuple[x, y: float] =
  let delta = client.sizeDeltaPixels
  let dp = client.densityPixelsPerPixel
  (delta.x.float / dp, delta.y.float / dp)

func resized*(client: Client): bool =
  let delta = client.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Mouse buttons

func mouseDown*(client: Client, button: MouseButton): bool =
  client.mouseDown[button]

func mousePressed*(client: Client, button: MouseButton): bool =
  client.mouseDown[button] and not client.previousMouseDown[button]

func mouseReleased*(client: Client, button: MouseButton): bool =
  client.previousMouseDown[button] and not client.mouseDown[button]

# Keyboard keys

func keyDown*(client: Client, key: KeyboardKey): bool =
  client.keyDown[key]

func keyPressed*(client: Client, key: KeyboardKey): bool =
  client.keyDown[key] and not client.previousKeyDown[key]

func keyReleased*(client: Client, key: KeyboardKey): bool =
  client.previousKeyDown[key] and not client.keyDown[key]

# State updating

template processFrame*(client: Client, code: untyped): untyped =
  client.previousTime = client.time
  client.previousPositionPixels = client.positionPixels
  client.previousSizePixels = client.sizePixels
  client.previousMousePositionPixels = client.mousePositionPixels
  client.previousMouseDown = client.mouseDown
  client.previousKeyDown = client.keyDown
  client.mouseWheel = (0.0, 0.0)
  client.text = ""
  client.mousePresses.setLen(0)
  client.mouseReleases.setLen(0)
  client.keyPresses.setLen(0)
  client.keyReleases.setLen(0)

  client.time = cpuTime()

  code

  if client.onFrame != nil:
    client.onFrame()