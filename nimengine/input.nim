{.experimental: "overloadableEnums".}

import ./math; export math

const densityPixelDpi* = 96.0

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

  InputFrame* = object
    time*: float
    pixelDensity*: float
    boundsPixels*: Rect2
    mousePositionPixels*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDown*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDown*: array[KeyboardKey, bool]
    text*: string
    isFocused*: bool
    isHovered*: bool

  Input* = ref object
    state*: InputFrame
    previousState*: InputFrame
    clipboardString: string

func newInput*(time: float): Input =
  Input(
    state: InputFrame(
      time: time,
      pixelDensity: 1.0,
      isFocused: true,
    ),
    previousState: InputFrame(
      time: time,
      pixelDensity: 1.0,
      isFocused: false,
    ),
  )

func time*(input: Input): float = input.state.time
func pixelDensity*(input: Input): float = input.state.pixelDensity
func boundsPixels*(input: Input): Rect2 = input.state.boundsPixels
func mousePositionPixels*(input: Input): Vec2 = input.state.mousePositionPixels
func mouseWheel*(input: Input): Vec2 = input.state.mouseWheel
func mousePresses*(input: Input): seq[MouseButton] = input.state.mousePresses
func mouseReleases*(input: Input): seq[MouseButton] = input.state.mouseReleases
func mouseDown*(input: Input, button: MouseButton): bool = input.state.mouseDown[button]
func keyPresses*(input: Input): seq[KeyboardKey] = input.state.keyPresses
func keyReleases*(input: Input): seq[KeyboardKey] = input.state.keyReleases
func keyDown*(input: Input, key: KeyboardKey): bool = input.state.keyDown[key]
func text*(input: Input): string = input.state.text

func deltaTime*(input: Input): float = input.state.time - input.previousState.time
func bounds*(input: Input): Rect2 = rect2(input.state.boundsPixels.position / input.state.pixelDensity, input.state.boundsPixels.size / input.state.pixelDensity)
func mousePosition*(input: Input): Vec2 = input.state.mousePositionPixels / input.state.pixelDensity
func positionPixels*(input: Input): Vec2 = input.state.boundsPixels.position
func position*(input: Input): Vec2 = input.state.boundsPixels.position / input.state.pixelDensity
func sizePixels*(input: Input): Vec2 = input.state.boundsPixels.size
func size*(input: Input): Vec2 = input.state.boundsPixels.size / input.state.pixelDensity
func scale*(input: Input): float = 1.0 / input.state.pixelDensity
func moved*(input: Input): bool = input.state.boundsPixels.position != input.previousState.boundsPixels.position
func resized*(input: Input): bool = input.state.boundsPixels.size != input.previousState.boundsPixels.size
func pixelDensityChanged*(input: Input): bool = input.state.pixelDensity != input.previousState.pixelDensity
func aspectRatio*(input: Input): float = input.bounds.size.x / input.bounds.size.y
func gainedFocus*(input: Input): bool = input.state.isFocused and not input.previousState.isFocused
func lostFocus*(input: Input): bool = input.previousState.isFocused and not input.state.isFocused
func mouseDeltaPixels*(input: Input): Vec2 = input.state.mousePositionPixels - input.previousState.mousePositionPixels
func mouseDelta*(input: Input): Vec2 = input.mouseDeltaPixels / input.state.pixelDensity
func mouseMoved*(input: Input): bool = input.state.mousePositionPixels != input.previousState.mousePositionPixels
func mouseEntered*(input: Input): bool = input.state.isHovered and not input.previousState.isHovered
func mouseExited*(input: Input): bool = input.previousState.isHovered and not input.state.isHovered
func mouseWheelMoved*(input: Input): bool = input.mouseWheel.x != 0.0 or input.mouseWheel.y != 0.0
func mousePressed*(input: Input, button: MouseButton): bool = input.state.mouseDown[button] and not input.previousState.mouseDown[button]
func mouseReleased*(input: Input, button: MouseButton): bool = input.previousState.mouseDown[button] and not input.state.mouseDown[button]
func anyMousePressed*(input: Input): bool = input.mousePresses.len > 0
func anyMouseReleased*(input: Input): bool = input.mouseReleases.len > 0
func keyPressed*(input: Input, key: KeyboardKey): bool = input.state.keyDown[key] and not input.previousState.keyDown[key]
func keyReleased*(input: Input, key: KeyboardKey): bool = input.previousState.keyDown[key] and not input.state.keyDown[key]
func anyKeyPressed*(input: Input): bool = input.keyPresses.len > 0
func anyKeyReleased*(input: Input): bool = input.keyReleases.len > 0

func beginFrame*(input: Input, time: float) =
  input.state.mouseWheel = vec2(0, 0)
  input.state.text = ""
  input.state.mousePresses.setLen(0)
  input.state.mouseReleases.setLen(0)
  input.state.keyPresses.setLen(0)
  input.state.keyReleases.setLen(0)
  input.state.time = time

func endFrame*(input: Input) =
  input.previousState = input.state

when defined(windows):
  import winim/lean as win32 except INPUT

  proc `clipboard=`*(input: Input, text: string) =
    let characterCount = MultiByteToWideChar(CP_UTF8, 0, text, -1, NULL, 0)
    if characterCount == 0:
      return

    let h = GlobalAlloc(GMEM_MOVEABLE, characterCount * sizeof(WCHAR))
    if h == 0:
      echo "Win32: Failed to allocate global handle for clipboard."
      return

    var buffer = cast[ptr WCHAR](GlobalLock(h))
    if buffer == nil:
      echo "Win32: Failed to lock global handle."
      GlobalFree(h)

    MultiByteToWideChar(CP_UTF8, 0, text, -1, buffer, characterCount)
    GlobalUnlock(h)

    if OpenClipboard(0) == 0:
      echo "Win32: Failed to open clipboard."
      GlobalFree(h)
      return

    EmptyClipboard()
    SetClipboardData(CF_UNICODETEXT, h)
    CloseClipboard()

  proc wideStringToUtf8(source: ptr WCHAR): string =
    let size = WideCharToMultiByte(CP_UTF8, 0, source, -1, NULL, 0, NULL, NULL)
    if size == 0:
      echo "Win32: Failed to convert string to UTF-8."
      return ""

    result = newString(size)

    if WideCharToMultiByte(CP_UTF8, 0, source, -1, result, size, NULL, NULL) == 0:
      echo "Win32: Failed to convert string to UTF-8."
      return ""

  proc clipboard*(input: Input): string =
    if OpenClipboard(0) == 0:
      echo "Win32: Failed to open clipboard"
      return ""

    let h = GetClipboardData(CF_UNICODETEXT)
    if h == 0:
      echo "Win32: Failed to convert clipboard to string."
      CloseClipboard()
      return ""

    let buffer = cast[ptr WCHAR](GlobalLock(h))
    if buffer == nil:
      echo "Win32: Failed to lock global handle."
      CloseClipboard()
      return ""

    input.clipboardString = wideStringToUtf8(buffer)

    GlobalUnlock(h)
    CloseClipboard()

    input.clipboardString