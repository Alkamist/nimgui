{.experimental: "overloadableEnums".}

import std/times
export times

import ../tmath
export tmath

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

    platform*: PlatformData

proc newClientBase*(): Client =
  let time = cpuTime()
  Client(
    dpi: 96.0,
    densityPixelDpi: 96.0,
    time: time,
    previousTime: time,
  )

func scale*(client: Client): float =
  client.dpi / client.densityPixelDpi

func delta*(client: Client): float =
  client.time - client.previousTime

func aspectRatio*(client: Client): float =
  client.sizePixels.x / client.sizePixels.y

# Mouse position

func mousePosition*(client: Client): Vec2 =
  let scale = client.scale
  vec2(client.mousePositionPixels.x / scale,
       client.mousePositionPixels.y / scale)

func mouseDeltaPixels*(client: Client): Vec2 =
  vec2(client.mousePositionPixels.x - client.previousMousePositionPixels.x,
       client.mousePositionPixels.y - client.previousMousePositionPixels.y)

func mouseDelta*(client: Client): Vec2 =
  let delta = client.mouseDeltaPixels
  let scale = client.scale
  vec2(delta.x / scale, delta.y / scale)

func mouseMoved*(client: Client): bool =
  let delta = client.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Position

func position*(client: Client): Vec2 =
  let scale = client.scale
  vec2(client.positionPixels.x.float / scale,
       client.positionPixels.y.float / scale)

func positionDeltaPixels*(client: Client): Vec2 =
  vec2(client.positionPixels.x - client.previousPositionPixels.x,
       client.positionPixels.y - client.previousPositionPixels.y)

func positionDelta*(client: Client): Vec2 =
  let delta = client.positionDeltaPixels
  let scale = client.scale
  vec2(delta.x / scale, delta.y / scale)

func moved*(client: Client): bool =
  let delta = client.positionDeltaPixels
  delta.x != 0 or delta.y != 0

# Size

func size*(client: Client): Vec2 =
  let scale = client.scale
  vec2(client.sizePixels.x / scale, client.sizePixels.y / scale)

func sizeDeltaPixels*(client: Client): Vec2 =
  vec2(client.sizePixels.x - client.previousSizePixels.x,
       client.sizePixels.y - client.previousSizePixels.y)

func sizeDelta*(client: Client): Vec2 =
  let delta = client.sizeDeltaPixels
  let scale = client.scale
  vec2(delta.x / scale, delta.y / scale)

func resized*(client: Client): bool =
  let delta = client.mouseDeltaPixels
  delta.x != 0 or delta.y != 0

# Mouse buttons

func mouseDown*(client: Client, button: MouseButton): bool =
  client.mouseDownStates[button]

func mousePressed*(client: Client, button: MouseButton): bool =
  client.mouseDownStates[button] and not client.previousMouseDownStates[button]

func mouseReleased*(client: Client, button: MouseButton): bool =
  client.previousMouseDownStates[button] and not client.mouseDownStates[button]

# Keyboard keys

func keyDown*(client: Client, key: KeyboardKey): bool =
  client.keyDownStates[key]

func keyPressed*(client: Client, key: KeyboardKey): bool =
  client.keyDownStates[key] and not client.previousKeyDownStates[key]

func keyReleased*(client: Client, key: KeyboardKey): bool =
  client.previousKeyDownStates[key] and not client.keyDownStates[key]

# State updating

template processFrame*(client: Client, code: untyped): untyped =
  client.previousTime = client.time
  client.previousPositionPixels = client.positionPixels
  client.previousSizePixels = client.sizePixels
  client.previousMousePositionPixels = client.mousePositionPixels
  client.previousMouseDownStates = client.mouseDownStates
  client.previousKeyDownStates = client.keyDownStates
  client.mouseWheel = vec2(0, 0)
  client.text = ""
  client.mousePresses.setLen(0)
  client.mouseReleases.setLen(0)
  client.keyPresses.setLen(0)
  client.keyReleases.setLen(0)

  client.time = cpuTime()

  code

  if client.onFrame != nil:
    client.onFrame()