{.experimental: "overloadableEnums".}

import ../math; export math

const densityPixelDpi* = 96.0

type
  MouseButton* = enum
    Unknown,
    Left, Middle, Right,
    Extra1, Extra2, Extra3,
    Extra4, Extra5,

  KeyboardKey* = enum
    Unknown,
    A, B, C, D, E, F, G, H, I,
    J, K, L, M, N, O, P, Q, R,
    S, T, U, V, W, X, Y, Z,
    Key1, Key2, Key3, Key4, Key5,
    Key6, Key7, Key8, Key9, Key0,
    Pad1, Pad2, Pad3, Pad4, Pad5,
    Pad6, Pad7, Pad8, Pad9, Pad0,
    F1, F2, F3, F4, F5, F6, F7,
    F8, F9, F10, F11, F12,
    Backtick, Minus, Equal, Backspace,
    Tab, CapsLock, Enter, LeftShift,
    RightShift, LeftControl, RightControl,
    LeftAlt, RightAlt, LeftMeta, RightMeta,
    LeftBracket, RightBracket, Space,
    Escape, Backslash, Semicolon, Quote,
    Comma, Period, Slash, ScrollLock,
    Pause, Insert, End, PageUp, Delete,
    Home, PageDown, LeftArrow, RightArrow,
    DownArrow, UpArrow, NumLock, PadDivide,
    PadMultiply, PadSubtract, PadAdd, PadEnter,
    PadPeriod, PrintScreen,

  InputState* = object
    isHovered*: bool
    position*: Vec2
    previousPosition*: Vec2
    size*: Vec2
    previousSize*: Vec2
    time*: float
    previousTime*: float
    pixelDensity*: float
    previousPixelDensity*: float
    mousePosition*: Vec2
    previousMousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseIsDown*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyIsDown*: array[KeyboardKey, bool]
    textInput*: string

template defineOsWindowBaseTemplates*(T: typedesc): untyped {.dirty.} =
  import std/times

  template initInputState*(window: T) =
    let time = cpuTime()
    window.inputState = InputState(
      time: time,
      previousTime: time,
      pixelDensity: 1.0,
      previousPixelDensity: 1.0,
    )

  template updateInputState*(window: T) =
    window.inputState.previousPosition = window.inputState.position
    window.inputState.previousSize = window.inputState.size
    window.inputState.previousTime = window.inputState.time
    window.inputState.previousPixelDensity = window.inputState.pixelDensity
    window.inputState.previousMousePosition = window.inputState.mousePosition
    window.inputState.mouseWheel = vec2(0, 0)
    window.inputState.textInput = ""
    window.inputState.mousePresses.setLen(0)
    window.inputState.mouseReleases.setLen(0)
    window.inputState.keyPresses.setLen(0)
    window.inputState.keyReleases.setLen(0)
    window.inputState.time = cpuTime()

  template isHovered*(window: T): bool = window.inputState.isHovered
  template position*(window: T): Vec2 = window.inputState.position
  template positionPixels*(window: T): Vec2 = window.inputState.position * window.inputState.pixelDensity
  template size*(window: T): Vec2 = window.inputState.size
  template sizePixels*(window: T): Vec2 = window.inputState.size * window.inputState.pixelDensity
  template time*(window: T): float = window.inputState.time
  template pixelDensity*(window: T): float = window.inputState.pixelDensity
  template mousePosition*(window: T): Vec2 = window.inputState.mousePosition
  template mouseWheel*(window: T): Vec2 = window.inputState.mouseWheel
  template mousePresses*(window: T): seq[MouseButton] = window.inputState.mousePresses
  template mouseReleases*(window: T): seq[MouseButton] = window.inputState.mouseReleases
  template mouseIsDown*(window: T, button: MouseButton): bool = window.inputState.mouseIsDown[button]
  template keyPresses*(window: T): seq[KeyboardKey] = window.inputState.keyPresses
  template keyReleases*(window: T): seq[KeyboardKey] = window.inputState.keyReleases
  template keyIsDown*(window: T, key: KeyboardKey): bool = window.inputState.keyIsDown[key]
  template textInput*(window: T): string = window.inputState.textInput

  template justMoved*(window: T): bool = window.inputState.position != window.inputState.previousPosition
  template positionDelta*(window: T): Vec2 = window.inputState.position - window.inputState.previousPosition
  template x*(window: T): float = window.inputState.position.x
  template y*(window: T): float = window.inputState.position.y

  template justResized*(window: T): bool = window.inputState.size != window.inputState.previousSize
  template sizeDelta*(window: T): Vec2 = window.inputState.size - window.inputState.previousSize
  template width*(window: T): float = window.inputState.size.x
  template height*(window: T): float = window.inputState.size.y

  template deltaTime*(window: T): float = window.inputState.time - window.inputState.previousTime

  template pixelDensityChanged*(window: T): bool = window.inputState.pixelDensity != window.inputState.previousPixelDensity
  template scale*(window: T): float = 1.0 / window.inputState.pixelDensity
  template aspectRatio*(window: T): float = window.inputState.size.x / window.inputState.size.y

  template mouseJustMoved*(window: T): bool = window.inputState.mousePosition != window.inputState.previousMousePosition
  template mouseDelta*(window: T): Vec2 = window.inputState.mousePosition - window.inputState.previousMousePosition
  template mouseWheelJustMoved*(window: T): bool = window.inputState.mouseWheel.x != 0.0 or window.inputState.mouseWheel.y != 0.0
  template mouseJustPressed*(window: T, button: MouseButton): bool = button in window.inputState.mousePresses
  template mouseJustReleased*(window: T, button: MouseButton): bool = button in window.inputState.mouseReleases
  template anyMouseJustPressed*(window: T): bool = window.inputState.mousePresses.len > 0
  template anyMouseJustReleased*(window: T): bool = window.inputState.mouseReleases.len > 0
  template keyJustPressed*(window: T, key: KeyboardKey): bool = key in window.inputState.keyPresses
  template keyJustReleased*(window: T, key: KeyboardKey): bool = key in window.inputState.keyReleases
  template anyKeyJustPressed*(window: T): bool = window.inputState.keyPresses.len > 0
  template anyKeyJustReleased*(window: T): bool = window.inputState.keyReleases.len > 0

  # template gainedFocus*(window: T): bool = window.inputState.isFocused and not window.previousInputState.isFocused
  # template lostFocus*(window: T): bool = window.previousInputState.isFocused and not window.inputState.isFocused
  # template mouseEntered*(window: T): bool = window.inputState.isHovered and not window.previousInputState.isHovered
  # template mouseExited*(window: T): bool = window.previousInputState.isHovered and not window.inputState.isHovered