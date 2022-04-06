include ./platformdata

type
  MouseButton* {.pure.} = enum
    Unknown
    Left
    Middle
    Right
    Extra1
    Extra2
    Extra3
    Extra4
    Extra5

  KeyboardKey* {.pure.} = enum
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
    platform*: PlatformData

    widthPixels*, heightPixels*: int

    width*, height*: float
    widthPrevious*, heightPrevious*: float
    widthChange*, heightChange*: float
    isFocused*: bool
    shouldClose*: bool

    mouseIsOver*: bool
    mouseIsConfined*: bool
    mouseIsPinnedToCenter*: bool
    mousePress*: MouseButton
    mouseRelease*: MouseButton
    mouseX*, mouseY*: float
    previousMouseX*, previousMouseY*: float
    mouseXChange*, mouseYChange*: float
    mouseWheelX*, mouseWheelY*: float
    mouseButtonStates*: array[MouseButton, bool]

    keyPress*: KeyboardKey
    keyRelease*: KeyboardKey
    character*: string
    keyStates*: array[KeyboardKey, bool]

    onClose*: proc(client: Client)
    onFocus*: proc(client: Client)
    onLoseFocus*: proc(client: Client)
    onResize*: proc(client: Client)
    onMouseMove*: proc(client: Client)
    onMouseEnter*: proc(client: Client)
    onMouseExit*: proc(client: Client)
    onMouseWheel*: proc(client: Client)
    onMousePress*: proc(client: Client)
    onMouseRelease*: proc(client: Client)
    onKeyPress*: proc(client: Client)
    onKeyRelease*: proc(client: Client)
    onCharacter*: proc(client: Client)

func isPressed*(client: Client, key: KeyboardKey): bool =
  client.keyStates[key]

func isPressed*(client: Client, button: MouseButton): bool =
  client.mouseButtonStates[button]

func aspectRatio*(client: Client): float =
  client.width / client.height

func newDefaultClient(width, height: float): Client =
  Client(
    width: width,
    height: height,
    widthPrevious: width,
    heightPrevious: height,
  )

proc processMouseMove(client: Client, x, y: float) =
  if client.mouseX == x and client.mouseY == y:
    return

  client.previousMouseX = client.mouseX
  client.previousMouseY = client.mouseY
  client.mouseX = x
  client.mouseY = y
  client.mouseXChange = client.mouseX - client.previousMouseX
  client.mouseYChange = client.mouseY - client.previousMouseY

  if client.onMouseMove != nil:
    client.onMouseMove(client)

proc processMouseEnter(client: Client) =
  client.mouseIsOver = true
  if client.onMouseEnter != nil:
    client.onMouseEnter(client)

proc processMouseExit(client: Client) =
  client.mouseIsOver = false
  if client.onMouseExit != nil:
    client.onMouseExit(client)

proc processMouseWheel(client: Client, x, y: float) =
  client.mouseWheelX = x
  client.mouseWheelY = y
  if client.onMouseWheel != nil:
    client.onMouseWheel(client)

proc processMousePress(client: Client, button: MouseButton) =
  client.mousePress = button
  client.mouseButtonStates[button] = true
  if client.onMousePress != nil:
    client.onMousePress(client)

proc processMouseRelease(client: Client, button: MouseButton) =
  client.mouseRelease = button
  client.mouseButtonStates[button] = false
  if client.onMouseRelease != nil:
    client.onMouseRelease(client)

proc processKeyPress(client: Client, key: KeyboardKey) =
  client.keyPress = key
  client.keyStates[key] = true
  if client.onKeyPress != nil:
    client.onKeyPress(client)

proc processKeyRelease*(client: Client, key: KeyboardKey) =
  client.keyRelease = key
  client.keyStates[key] = false
  if client.onKeyRelease != nil:
    client.onKeyRelease(client)

proc processCharacter(client: Client, character: string) =
  client.character = character
  if client.onCharacter != nil:
    client.onCharacter(client)

proc processClose(client: Client) =
  if client.onClose != nil:
    client.onClose(client)

proc processFocus(client: Client) =
  if client.onFocus != nil:
    client.onFocus(client)

proc processLoseFocus(client: Client) =
  if client.onLoseFocus != nil:
    client.onLoseFocus(client)

proc processResize(client: Client, width, height: float) =
  client.widthPrevious = client.width
  client.heightPrevious = client.height
  client.width = width
  client.height = height
  client.widthChange = client.width - client.widthPrevious
  client.heightChange = client.height - client.heightPrevious
  if client.onResize != nil:
    client.onResize(client)