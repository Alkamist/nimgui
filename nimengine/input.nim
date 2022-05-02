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

  Input* = ref object
    lastMousePress*: MouseButton
    lastMouseRelease*: MouseButton
    mouseX*, mouseY*: float
    previousMouseX*, previousMouseY*: float
    mouseWheelX*, mouseWheelY*: float
    mouseButtonStates*: array[MouseButton, bool]
    previousMouseButtonStates*: array[MouseButton, bool]
    lastKeyPress*: KeyboardKey
    lastKeyRelease*: KeyboardKey
    text*: string
    keyStates*: array[KeyboardKey, bool]
    previousKeyStates*: array[KeyboardKey, bool]
    windowHeight*: float

func newInput*(): Input =
  Input()

func mouseXChange*(input: Input): float =
  input.mouseX - input.previousMouseX

func mouseYChange*(input: Input): float =
  input.mouseY - input.previousMouseY

func mouseYInverted*(input: Input): float =
  input.windowHeight - input.mouseY

func isPressed*(input: Input, key: KeyboardKey): bool =
  input.keyStates[key]

func justPressed*(input: Input, key: KeyboardKey): bool =
  input.keyStates[key] and not input.previousKeyStates[key]

func justReleased*(input: Input, key: KeyboardKey): bool =
  input.previousKeyStates[key] and not input.keyStates[key]

func isPressed*(input: Input, button: MouseButton): bool =
  input.mouseButtonStates[button]

func justPressed*(input: Input, button: MouseButton): bool =
  input.mouseButtonStates[button] and not input.previousMouseButtonStates[button]

func justReleased*(input: Input, button: MouseButton): bool =
  input.previousMouseButtonStates[button] and not input.mouseButtonStates[button]

func update*(input: Input) =
  input.text = ""
  input.previousKeyStates = input.keyStates
  input.previousMouseButtonStates = input.mouseButtonStates
  input.previousMouseX = input.mouseX
  input.previousMouseY = input.mouseY