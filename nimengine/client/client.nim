{.experimental: "overloadableEnums".}

import std/times

when defined(windows):
  import winim/lean as win32
  type
    PlatformData* = object
      moveTimer*: UINT_PTR
      isInFrame*: bool

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

    # During poll.
    isOpen*: bool
    handle*: pointer
    isChild*: bool
    time*: float
    defaultDpi*: float
    dpi*: float
    posPixels*: tuple[x, y: int]
    sizePixels*: tuple[x, y: int]
    mousePosPixels*: tuple[x, y: int]
    mouseWheel*: tuple[x, y: float]
    text*: string
    mouseDown*: array[MouseButton, bool]
    keyDown*: array[KeyboardKey, bool]
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]

    # Post poll.
    delta*: float
    scale*: float
    aspectRatio*: float
    pos*: tuple[x, y: float]
    size*: tuple[x, y: float]
    mouseDeltaPixels*: tuple[x, y: int]
    mousePos*: tuple[x, y: float]
    mouseDelta*: tuple[x, y: float]
    mousePressed*: array[MouseButton, bool]
    mouseReleased*: array[MouseButton, bool]
    keyPressed*: array[KeyboardKey, bool]
    keyReleased*: array[KeyboardKey, bool]

    # Pre poll.
    previousTime*: float
    previousMousePosPixels*: tuple[x, y: int]
    previousMouseDown*: array[MouseButton, bool]
    previousKeyDown*: array[KeyboardKey, bool]

    # Platform specific.
    platform*: PlatformData

proc newClientBase*(): Client =
  let time = cpuTime()
  Client(
    dpi: 96.0,
    defaultDpi: 96.0,
    scale: 1.0,
    time: time,
    previousTime: time,
  )

proc prePoll*(client: Client) =
  client.previousTime = client.time
  client.previousMousePosPixels = client.mousePosPixels
  client.previousMouseDown = client.mouseDown
  client.previousKeyDown = client.keyDown
  client.mouseWheel = (0.0, 0.0)
  client.text = ""
  client.mousePresses.setLen(0)
  client.mouseReleases.setLen(0)
  client.keyPresses.setLen(0)
  client.keyReleases.setLen(0)

  client.time = cpuTime()

proc postPoll*(client: Client) =
  client.delta = client.time - client.previousTime

  # client.scale = client.dpi / client.defaultDpi

  client.aspectRatio = client.sizePixels.x / client.sizePixels.y

  client.pos.x = client.posPixels.x.float / client.scale
  client.pos.y = client.posPixels.y.float / client.scale

  client.size.x = client.sizePixels.x.float / client.scale
  client.size.y = client.sizePixels.y.float / client.scale

  client.mouseDeltaPixels.x = client.mousePosPixels.x - client.previousMousePosPixels.x
  client.mouseDeltaPixels.y = client.mousePosPixels.y - client.previousMousePosPixels.y

  client.mousePos.x = client.mousePosPixels.x.float / client.scale
  client.mousePos.y = client.mousePosPixels.y.float / client.scale

  client.mouseDelta.x = client.mouseDeltaPixels.x.float / client.scale
  client.mouseDelta.y = client.mouseDeltaPixels.y.float / client.scale

  for button in MouseButton:
    client.mousePressed[button] = client.mouseDown[button] and not client.previousMouseDown[button]
    client.mouseReleased[button] = client.previousMouseDown[button] and not client.mouseDown[button]

  for key in KeyboardKey:
    client.keyPressed[key] = client.keyDown[key] and not client.previousKeyDown[key]
    client.keyReleased[key] = client.previousKeyDown[key] and not client.keyDown[key]