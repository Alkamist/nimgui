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
    bounds*: Rect2
    mousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDown*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDown*: array[KeyboardKey, bool]
    text*: string

  Input* = ref object
    state*: InputFrame
    previousState*: InputFrame

func newInput*(time: float): Input =
  Input(
    state: InputFrame(time: time, pixelDensity: 1.0),
    previousState: InputFrame(time: time, pixelDensity: 1.0),
  )

template time*(input: Input): float = input.state.time
template pixelDensity*(input: Input): float = input.state.pixelDensity
template bounds*(input: Input): Rect2 = input.state.bounds
template mousePosition*(input: Input): Vec2 = input.state.mousePosition
template mouseWheel*(input: Input): Vec2 = input.state.mouseWheel
template mousePresses*(input: Input): seq[MouseButton] = input.state.mousePresses
template mouseReleases*(input: Input): seq[MouseButton] = input.state.mouseReleases
template mouseDown*(input: Input, button: MouseButton): bool = input.state.mouseDown[button]
template keyPresses*(input: Input): seq[KeyboardKey] = input.state.keyPresses
template keyReleases*(input: Input): seq[KeyboardKey] = input.state.keyReleases
template keyDown*(input: Input, key: KeyboardKey): bool = input.state.keyDown[key]
template text*(input: Input): string = input.state.text

template deltaTime*(input: Input): float = input.state.time - input.previousState.time
template position*(input: Input): Vec2 = input.state.bounds.position
template size*(input: Input): Vec2 = input.state.bounds.size
template scale*(input: Input): float = 1.0 / input.state.pixelDensity
template moved*(input: Input): bool = input.state.bounds.position != input.previousState.bounds.position
template resized*(input: Input): bool = input.state.bounds.size != input.previousState.bounds.size
template pixelDensityChanged*(input: Input): bool = input.state.pixelDensity != input.previousState.pixelDensity
template aspectRatio*(input: Input): float = input.bounds.size.x / input.bounds.size.y
template mouseDelta*(input: Input): Vec2 = input.state.mousePosition - input.previousState.mousePosition
template mouseMoved*(input: Input): bool = input.state.mousePosition != input.previousState.mousePosition
template mousePressed*(input: Input, button: MouseButton): bool = input.state.mouseDown[button] and not input.previousState.mouseDown[button]
template mouseReleased*(input: Input, button: MouseButton): bool = input.previousState.mouseDown[button] and not input.state.mouseDown[button]
template keyPressed*(input: Input, key: KeyboardKey): bool = input.state.keyDown[key] and not input.previousState.keyDown[key]
template keyReleased*(input: Input, key: KeyboardKey): bool = input.previousState.keyDown[key] and not input.state.keyDown[key]

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