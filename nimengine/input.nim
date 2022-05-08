{.experimental: "overloadableEnums".}

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

  Input* = ref object
    lastMousePress*: MouseButton
    lastMouseRelease*: MouseButton
    mouseX*, mouseY*: float
    mouseXChange*, mouseYChange*: float
    previousMouseX*, previousMouseY*: float
    mouseWheelX*, mouseWheelY*: float
    mouseDown*: array[MouseButton, bool]
    mousePressed*: array[MouseButton, bool]
    mouseReleased*: array[MouseButton, bool]
    previousMouseDown*: array[MouseButton, bool]
    lastKeyPress*: KeyboardKey
    lastKeyRelease*: KeyboardKey
    keyDown*: array[KeyboardKey, bool]
    keyPressed*: array[KeyboardKey, bool]
    keyReleased*: array[KeyboardKey, bool]
    previousKeyDown*: array[KeyboardKey, bool]
    text*: string

func newInput*(): Input =
  Input()

func update*(input: Input) =
  input.mouseXChange = input.mouseX - input.previousMouseX
  input.mouseYChange = input.mouseY - input.previousMouseY
  input.previousMouseX = input.mouseX
  input.previousMouseY = input.mouseY

  for button in MouseButton:
    input.mousePressed[button] = input.mouseDown[button] and not input.previousMouseDown[button]
    input.mouseReleased[button] = input.previousMouseDown[button] and not input.mouseDown[button]

  input.previousMouseDown = input.mouseDown

  for key in KeyboardKey:
    input.keyPressed[key] = input.keyDown[key] and not input.previousKeyDown[key]
    input.keyReleased[key] = input.previousKeyDown[key] and not input.keyDown[key]

  input.previousKeyDown = input.keyDown

  input.text = ""