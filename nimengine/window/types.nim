import ../renderer
export renderer

when defined(windows):
  import winim/lean
  type
    WindowPlatformData* = object
      handle*: HWND
      lastCursorPosX*: float
      lastCursorPosY*: float
      restoreCursorPosX*: float
      restoreCursorPosY*: float
      isTrackingMouse*: bool

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

  Window* = ref object
    time*: float
    previousTime*: float
    delta*: float

    x*, y*: float
    previousX*, previousY*: float
    xChange*, yChange*: float
    width*, height*: float
    previousWidth*, previousHeight*: float
    widthChange*, heightChange*: float
    isFocused*: bool
    isClosed*: bool
    isChild*: bool

    cursorIsOver*: bool
    cursorIsConfined*: bool
    cursorIsPinnedToCenter*: bool
    cursorIsHidden*: bool

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

    onUpdate*: proc()
    onClose*: proc()
    onFocus*: proc()
    onLoseFocus*: proc()
    onMove*: proc()
    onResize*: proc()
    onMouseMove*: proc()
    onMouseEnter*: proc()
    onMouseExit*: proc()
    onMouseWheel*: proc()
    onMousePress*: proc()
    onMouseRelease*: proc()
    onKeyPress*: proc()
    onKeyRelease*: proc()
    onCharacter*: proc()

    platform*: WindowPlatformData
    renderer*: Renderer