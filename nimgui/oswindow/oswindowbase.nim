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
    time*: float
    isFocused*: bool
    isHovered*: bool
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

template defineBaseTemplates*(): untyped {.dirty.} =
  import std/times

  template initInputState*(window: OsWindow) =
    let inputState = InputState(time: cpuTime(), pixelDensity: 1.0)
    window.inputState = inputState
    window.previousInputState = inputState
    window.inputState.isFocused = true
    window.previousInputState.isFocused = false

  template updateInputState*(window: OsWindow) =
    window.previousInputState = window.inputState
    window.inputState.mouseWheel = vec2(0, 0)
    window.inputState.text = ""
    window.inputState.mousePresses.setLen(0)
    window.inputState.mouseReleases.setLen(0)
    window.inputState.keyPresses.setLen(0)
    window.inputState.keyReleases.setLen(0)
    window.inputState.time = cpuTime()

  template time*(window: OsWindow): float = window.inputState.time
  template isFocused*(window: OsWindow): bool = window.inputState.isFocused
  template isHovered*(window: OsWindow): bool = window.inputState.isHovered
  template pixelDensity*(window: OsWindow): float = window.inputState.pixelDensity
  template boundsPixels*(window: OsWindow): Rect2 = window.inputState.boundsPixels
  template mousePositionPixels*(window: OsWindow): Vec2 = window.inputState.mousePositionPixels
  template mouseWheel*(window: OsWindow): Vec2 = window.inputState.mouseWheel
  template mousePresses*(window: OsWindow): seq[MouseButton] = window.inputState.mousePresses
  template mouseReleases*(window: OsWindow): seq[MouseButton] = window.inputState.mouseReleases
  template mouseDown*(window: OsWindow, button: MouseButton): bool = window.inputState.mouseDown[button]
  template keyPresses*(window: OsWindow): seq[KeyboardKey] = window.inputState.keyPresses
  template keyReleases*(window: OsWindow): seq[KeyboardKey] = window.inputState.keyReleases
  template keyDown*(window: OsWindow, key: KeyboardKey): bool = window.inputState.keyDown[key]
  template text*(window: OsWindow): string = window.inputState.text

  template deltaTime*(window: OsWindow): float = window.inputState.time - window.previousInputState.time
  template mousePosition*(window: OsWindow): Vec2 = window.inputState.mousePositionPixels / window.inputState.pixelDensity
  template mouseDeltaPixels*(window: OsWindow): Vec2 = window.inputState.mousePositionPixels - window.previousInputState.mousePositionPixels
  template mouseDelta*(window: OsWindow): Vec2 = window.mouseDeltaPixels / window.inputState.pixelDensity
  template mouseMoved*(window: OsWindow): bool = window.inputState.mousePositionPixels != window.previousInputState.mousePositionPixels
  template mouseWheelMoved*(window: OsWindow): bool = window.inputState.mouseWheel.x != 0.0 or window.inputState.mouseWheel.y != 0.0
  template mousePressed*(window: OsWindow, button: MouseButton): bool = window.inputState.mouseDown[button] and not window.previousInputState.mouseDown[button]
  template mouseReleased*(window: OsWindow, button: MouseButton): bool = window.previousInputState.mouseDown[button] and not window.inputState.mouseDown[button]
  template anyMousePressed*(window: OsWindow): bool = window.inputState.mousePresses.len > 0
  template anyMouseReleased*(window: OsWindow): bool = window.inputState.mouseReleases.len > 0
  template keyPressed*(window: OsWindow, key: KeyboardKey): bool = window.inputState.keyDown[key] and not window.previousInputState.keyDown[key]
  template keyReleased*(window: OsWindow, key: KeyboardKey): bool = window.previousInputState.keyDown[key] and not window.inputState.keyDown[key]
  template anyKeyPressed*(window: OsWindow): bool = window.inputState.keyPresses.len > 0
  template anyKeyReleased*(window: OsWindow): bool = window.inputState.keyReleases.len > 0
  template bounds*(window: OsWindow): Rect2 = rect2(window.inputState.boundsPixels.position / window.inputState.pixelDensity, window.inputState.boundsPixels.size / window.inputState.pixelDensity)
  template positionPixels*(window: OsWindow): Vec2 = window.inputState.boundsPixels.position
  template position*(window: OsWindow): Vec2 = window.inputState.boundsPixels.position / window.inputState.pixelDensity
  template sizePixels*(window: OsWindow): Vec2 = window.inputState.boundsPixels.size
  template size*(window: OsWindow): Vec2 = window.inputState.boundsPixels.size / window.inputState.pixelDensity
  template scale*(window: OsWindow): float = 1.0 / window.inputState.pixelDensity
  template moved*(window: OsWindow): bool = window.inputState.boundsPixels.position != window.previousInputState.boundsPixels.position
  template positionDeltaPixels*(window: OsWindow): Vec2 = window.inputState.boundsPixels.position - window.previousInputState.boundsPixels.position
  template positionDelta*(window: OsWindow): Vec2 = window.positionDeltaPixels / window.inputState.pixelDensity
  template resized*(window: OsWindow): bool = window.inputState.boundsPixels.size != window.previousInputState.boundsPixels.size
  template sizeDeltaPixels*(window: OsWindow): Vec2 = window.inputState.boundsPixels.size - window.previousInputState.boundsPixels.size
  template sizeDelta*(window: OsWindow): Vec2 = window.sizeDeltaPixels / window.inputState.pixelDensity
  template pixelDensityChanged*(window: OsWindow): bool = window.inputState.pixelDensity != window.previousInputState.pixelDensity
  template aspectRatio*(window: OsWindow): float = window.inputState.boundsPixels.size.x / window.inputState.boundsPixels.size.y
  template gainedFocus*(window: OsWindow): bool = window.inputState.isFocused and not window.previousInputState.isFocused
  template lostFocus*(window: OsWindow): bool = window.previousInputState.isFocused and not window.inputState.isFocused
  template mouseEntered*(window: OsWindow): bool = window.inputState.isHovered and not window.previousInputState.isHovered
  template mouseExited*(window: OsWindow): bool = window.previousInputState.isHovered and not window.inputState.isHovered