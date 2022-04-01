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

  Mouse* = ref object
    moveListeners*: seq[proc()]
    enterListeners*: seq[proc()]
    exitListeners*: seq[proc()]
    pressListeners*: seq[proc()]
    releaseListeners*: seq[proc()]
    scrollListeners*: seq[proc()]
    press*: MouseButton
    release*: MouseButton
    x*, y*: float
    xPrevious*, yPrevious*: float
    xChange*, yChange*: float
    wheelX*, wheelY*: float
    isOver*: bool

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

  Keyboard* = ref object
    pressListeners*: seq[proc()]
    releaseListeners*: seq[proc()]
    characterListeners*: seq[proc()]
    press*: KeyboardKey
    release*: KeyboardKey
    character*: string

  Client* = ref object
    mouse*: Mouse
    keyboard*: Keyboard
    closeListeners*: seq[proc()]
    focusListeners*: seq[proc()]
    loseFocusListeners*: seq[proc()]
    resizeListeners*: seq[proc()]
    width*, height*: float
    widthPrevious*, heightPrevious*: float
    widthChange*, heightChange*: float
    isFocused*: bool

proc processMove*(self: Mouse, x, y: float) =
  self.xPrevious = self.x
  self.yPrevious = self.y
  self.x = x
  self.y = y
  self.xChange = self.x - self.xPrevious
  self.yChange = self.y - self.yPrevious
  for listener in self.moveListeners:
    listener()

proc processEnter*(self: Mouse) =
  self.isOver = true
  for listener in self.enterListeners:
    listener()

proc processExit*(self: Mouse) =
  self.isOver = false
  for listener in self.exitListeners:
    listener()

proc processScroll*(self: Mouse, x, y: float) =
  self.wheelX = x
  self.wheelY = y
  for listener in self.scrollListeners:
    listener()

proc processPress*(self: Mouse, button: MouseButton) =
  self.press = button
  for listener in self.pressListeners:
    listener()

proc processRelease*(self: Mouse, button: MouseButton) =
  self.release = button
  for listener in self.releaseListeners:
    listener()

proc processPress*(self: Keyboard, key: KeyboardKey) =
  self.press = key
  for listener in self.pressListeners:
    listener()

proc processRelease*(self: Keyboard, key: KeyboardKey) =
  self.release = key
  for listener in self.releaseListeners:
    listener()

proc processCharacter*(self: Keyboard, character: string) =
  self.character = character
  for listener in self.characterListeners:
    listener()

proc processClose*(self: Client) =
  for listener in self.closeListeners:
    listener()

proc processFocus*(self: Client) =
  for listener in self.focusListeners:
    listener()

proc processLoseFocus*(self: Client) =
  for listener in self.loseFocusListeners:
    listener()

proc processResize*(self: Client, width, height: float) =
  self.widthPrevious = self.width
  self.heightPrevious = self.height
  self.width = width
  self.height = height
  self.widthChange = self.width - self.widthPrevious
  self.heightChange = self.height - self.heightPrevious
  for listener in self.resizeListeners:
    listener()

proc new*(_: type Client, width, height: float): Client =
  Client(
    mouse: Mouse(),
    keyboard: Keyboard(),
    width: width,
    height: height,
    widthPrevious: width,
    heightPrevious: height,
  )