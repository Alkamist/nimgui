include ./platformdata

type
  MouseEventKind* {.pure.} = enum
    Moved
    EnteredClient
    ExitedClient
    ButtonPressed
    ButtonReleased
    WheelScrolled

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

  MouseState* = object
    lastPress*: MouseButton
    lastRelease*: MouseButton
    x*, y*: float
    previousX*, previousY*: float
    xChange*, yChange*: float
    wheelX*, wheelY*: float
    buttonStates*: array[MouseButton, bool]

  KeyboardEventKind* {.pure.} = enum
    KeyPressed
    KeyReleased
    CharacterInput

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

  KeyboardState* = object
    lastPress*: KeyboardKey
    lastRelease*: KeyboardKey
    character*: string
    keyStates*: array[KeyboardKey, bool]

  ClientEventKind* {.pure.} = enum
    Closed
    Focused
    LostFocus
    Resized

  Client* = ref object
    platform*: PlatformData
    mouse*: MouseState
    keyboard*: KeyboardState
    width*, height*: float
    widthPrevious*, heightPrevious*: float
    widthChange*, heightChange*: float
    isFocused*: bool
    mouseIsOver*: bool
    shouldClose*: bool
    virtualCursorPosX*: float
    virtualCursorPosY*: float
    cursorIsConfined*: bool
    cursorIsPinnedToCenter*: bool
    mouseMovedListeners: seq[proc()]
    mouseEnteredListeners: seq[proc()]
    mouseExitedListeners: seq[proc()]
    mouseWheelScrolledListeners: seq[proc()]
    mouseButtonPressedListeners: seq[proc()]
    mouseButtonReleasedListeners: seq[proc()]
    keyboardKeyPressedListeners: seq[proc()]
    keyboardKeyReleasedListeners: seq[proc()]
    keyboardCharacterInputListeners: seq[proc()]
    closedListeners: seq[proc()]
    focusedListeners: seq[proc()]
    lostFocusListeners: seq[proc()]
    resizedListeners: seq[proc()]

func isPressed*(client: Client, key: KeyboardKey): bool =
  client.keyboard.keyStates[key]

func isPressed*(client: Client, button: MouseButton): bool =
  client.mouse.buttonStates[button]

func aspectRatio*(client: Client): float =
  client.width / client.height

func newDefaultClient(width, height: float): Client =
  Client(
    mouse: MouseState(),
    keyboard: KeyboardState(),
    width: width,
    height: height,
    widthPrevious: width,
    heightPrevious: height,
  )

proc processMouseMoved(client: Client, x, y: float) =
  if client.mouse.x == x and client.mouse.y == y:
    return

  client.mouse.previousX = client.mouse.x
  client.mouse.previousY = client.mouse.y
  client.mouse.x = x
  client.mouse.y = y
  client.mouse.xChange = client.mouse.x - client.mouse.previousX
  client.mouse.yChange = client.mouse.y - client.mouse.previousY

  for listener in client.mouseMovedListeners:
    listener()

proc processMouseEntered(client: Client) =
  client.mouseIsOver = true
  for listener in client.mouseEnteredListeners:
    listener()

proc processMouseExited(client: Client) =
  client.mouseIsOver = false
  for listener in client.mouseExitedListeners:
    listener()

proc processMouseWheelScrolled(client: Client, x, y: float) =
  client.mouse.wheelX = x
  client.mouse.wheelY = y
  for listener in client.mouseWheelScrolledListeners:
    listener()

proc processMouseButtonPressed(client: Client, button: MouseButton) =
  client.mouse.lastPress = button
  client.mouse.buttonStates[button] = true
  for listener in client.mouseButtonPressedListeners:
    listener()

proc processMouseButtonReleased(client: Client, button: MouseButton) =
  client.mouse.lastRelease = button
  client.mouse.buttonStates[button] = false
  for listener in client.mouseButtonReleasedListeners:
    listener()

proc processKeyboardKeyPressed(client: Client, key: KeyboardKey) =
  client.keyboard.lastPress = key
  client.keyboard.keyStates[key] = true
  for listener in client.keyboardKeyPressedListeners:
    listener()

proc processKeyboardKeyReleased*(client: Client, key: KeyboardKey) =
  client.keyboard.lastRelease = key
  client.keyboard.keyStates[key] = false
  for listener in client.keyboardKeyReleasedListeners:
    listener()

proc processKeyboardCharacterInput(client: Client, character: string) =
  client.keyboard.character = character
  for listener in client.keyboardCharacterInputListeners:
    listener()

proc processClosed(client: Client) =
  for listener in client.closedListeners:
    listener()

proc processFocused(client: Client) =
  for listener in client.focusedListeners:
    listener()

proc processLostFocus(client: Client) =
  for listener in client.lostFocusListeners:
    listener()

proc processResized(client: Client, width, height: float) =
  client.widthPrevious = client.width
  client.heightPrevious = client.height
  client.width = width
  client.height = height
  client.widthChange = client.width - client.widthPrevious
  client.heightChange = client.height - client.heightPrevious
  for listener in client.resizedListeners:
    listener()

template delListener(listeners: seq[untyped], listenerToDelete: proc()): untyped =
  for listenerId in 0 ..< listeners.len:
    if listeners[listenerId] == listenerToDelete:
      listeners.del listenerId
      break

func addListener*(client: Client, kind: MouseEventKind, listener: proc()) =
  case kind:
  of MouseEventKind.Moved: client.mouseMovedListeners.add listener
  of MouseEventKind.EnteredClient: client.mouseEnteredListeners.add listener
  of MouseEventKind.ExitedClient: client.mouseExitedListeners.add listener
  of MouseEventKind.ButtonPressed: client.mouseButtonPressedListeners.add listener
  of MouseEventKind.ButtonReleased: client.mouseButtonReleasedListeners.add listener
  of MouseEventKind.WheelScrolled: client.mouseWheelScrolledListeners.add listener

func removeListener*(client: Client, kind: MouseEventKind, listener: proc()) =
  case kind:
  of MouseEventKind.Moved: client.mouseMovedListeners.delListener listener
  of MouseEventKind.EnteredClient: client.mouseEnteredListeners.delListener listener
  of MouseEventKind.ExitedClient: client.mouseExitedListeners.delListener listener
  of MouseEventKind.ButtonPressed: client.mouseButtonPressedListeners.delListener listener
  of MouseEventKind.ButtonReleased: client.mouseButtonReleasedListeners.delListener listener
  of MouseEventKind.WheelScrolled: client.mouseWheelScrolledListeners.delListener listener

func addListener*(client: Client, kind: KeyboardEventKind, listener: proc()) =
  case kind:
  of KeyboardEventKind.KeyPressed: client.keyboardKeyPressedListeners.add listener
  of KeyboardEventKind.KeyReleased: client.keyboardKeyReleasedListeners.add listener
  of KeyboardEventKind.CharacterInput: client.keyboardCharacterInputListeners.add listener

func removeListener*(client: Client, kind: KeyboardEventKind, listener: proc()) =
  case kind:
  of KeyboardEventKind.KeyPressed: client.keyboardKeyPressedListeners.delListener listener
  of KeyboardEventKind.KeyReleased: client.keyboardKeyReleasedListeners.delListener listener
  of KeyboardEventKind.CharacterInput: client.keyboardCharacterInputListeners.delListener listener

func addListener*(client: Client, kind: ClientEventKind, listener: proc()) =
  case kind:
  of ClientEventKind.Closed: client.closedListeners.add listener
  of ClientEventKind.Focused: client.focusedListeners.add listener
  of ClientEventKind.LostFocus: client.lostFocusListeners.add listener
  of ClientEventKind.Resized: client.resizedListeners.add listener

func removeListener*(client: Client, kind: ClientEventKind, listener: proc()) =
  case kind:
  of ClientEventKind.Closed: client.closedListeners.delListener listener
  of ClientEventKind.Focused: client.focusedListeners.delListener listener
  of ClientEventKind.LostFocus: client.lostFocusListeners.delListener listener
  of ClientEventKind.Resized: client.resizedListeners.delListener listener