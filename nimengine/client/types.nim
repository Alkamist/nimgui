when defined(win32):
  import pkg/winim
  type
    NativeHandle = HWND

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
    press*: MouseButton
    release*: MouseButton
    x*, y*: float
    xPrevious*, yPrevious*: float
    xChange*, yChange*: float
    wheelX*, wheelY*: float

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
    press*: KeyboardKey
    release*: KeyboardKey
    character*: string

  ClientEventKind* {.pure.} = enum
    Closed
    Focused
    LostFocus
    Resized

  Client* = ref object
    nativeHandle*: NativeHandle
    mouse*: MouseState
    keyboard*: KeyboardState
    width*, height*: float
    widthPrevious*, heightPrevious*: float
    widthChange*, heightChange*: float
    isFocused*: bool
    mouseIsOver*: bool
    shouldClose*: bool
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