{.experimental: "overloadableEnums".}

import ./math; export math

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

template boundsPixels*(inputState: InputState): auto = rect2(inputState.bounds.position * inputState.pixelDensity, inputState.bounds.size * inputState.pixelDensity)
template mousePositionPixels*(inputState: InputState): auto = inputState.mousePosition * inputState.pixelDensity

template defineWindowBaseTemplates*(T: typedesc): untyped {.dirty.} =
  import std/times

  template initInputState*(window: T) =
    let inputState = InputState(time: cpuTime(), pixelDensity: 1.0)
    window.inputState = inputState
    window.previousInputState = inputState
    window.inputState.isFocused = true
    window.previousInputState.isFocused = false

  template updateInputState*(window: T) =
    window.previousInputState = window.inputState
    window.inputState.mouseWheel = vec2(0, 0)
    window.inputState.text = ""
    window.inputState.mousePresses.setLen(0)
    window.inputState.mouseReleases.setLen(0)
    window.inputState.keyPresses.setLen(0)
    window.inputState.keyReleases.setLen(0)
    window.inputState.time = cpuTime()

  template time*(window: T): float = window.inputState.time
  template isFocused*(window: T): bool = window.inputState.isFocused
  template isHovered*(window: T): bool = window.inputState.isHovered
  template pixelDensity*(window: T): float = window.inputState.pixelDensity
  template bounds*(window: T): Rect2 = window.inputState.bounds
  template boundsPixels*(window: T): Rect2 = rect2(window.inputState.bounds.position * window.inputState.pixelDensity, window.inputState.bounds.size * window.inputState.pixelDensity)
  template mousePosition*(window: T): Vec2 = window.inputState.mousePosition
  template mousePositionPixels*(window: T): Vec2 = window.inputState.mousePositionPixels
  template mouseWheel*(window: T): Vec2 = window.inputState.mouseWheel
  template mousePresses*(window: T): seq[MouseButton] = window.inputState.mousePresses
  template mouseReleases*(window: T): seq[MouseButton] = window.inputState.mouseReleases
  template mouseDown*(window: T, button: MouseButton): bool = window.inputState.mouseDown[button]
  template keyPresses*(window: T): seq[KeyboardKey] = window.inputState.keyPresses
  template keyReleases*(window: T): seq[KeyboardKey] = window.inputState.keyReleases
  template keyDown*(window: T, key: KeyboardKey): bool = window.inputState.keyDown[key]
  template text*(window: T): string = window.inputState.text

  template deltaTime*(window: T): float = window.inputState.time - window.previousInputState.time
  template mouseDelta*(window: T): Vec2 = window.inputState.mousePosition - window.previousInputState.mousePosition
  template mouseDeltaPixels*(window: T): Vec2 = window.mouseDelta * window.inputState.pixelDensity
  template mouseMoved*(window: T): bool = window.inputState.mousePosition != window.previousInputState.mousePosition
  template mouseWheelMoved*(window: T): bool = window.inputState.mouseWheel.x != 0.0 or window.inputState.mouseWheel.y != 0.0
  template mousePressed*(window: T, button: MouseButton): bool = window.inputState.mouseDown[button] and not window.previousInputState.mouseDown[button]
  template mouseReleased*(window: T, button: MouseButton): bool = window.previousInputState.mouseDown[button] and not window.inputState.mouseDown[button]
  template anyMousePressed*(window: T): bool = window.inputState.mousePresses.len > 0
  template anyMouseReleased*(window: T): bool = window.inputState.mouseReleases.len > 0
  template keyPressed*(window: T, key: KeyboardKey): bool = window.inputState.keyDown[key] and not window.previousInputState.keyDown[key]
  template keyReleased*(window: T, key: KeyboardKey): bool = window.previousInputState.keyDown[key] and not window.inputState.keyDown[key]
  template anyKeyPressed*(window: T): bool = window.inputState.keyPresses.len > 0
  template anyKeyReleased*(window: T): bool = window.inputState.keyReleases.len > 0
  template positionPixels*(window: T): Vec2 = window.inputState.boundsPixels.position
  template xPixels*(window: T): float = window.inputState.boundsPixels.x
  template yPixels*(window: T): float = window.inputState.boundsPixels.y
  template position*(window: T): Vec2 = window.inputState.bounds.position
  template x*(window: T): float = window.inputState.bounds.position.x
  template y*(window: T): float = window.inputState.bounds.position.y
  template sizePixels*(window: T): Vec2 = window.inputState.boundsPixels.size
  template widthPixels*(window: T): float = window.inputState.boundsPixels.size.x
  template heightPixels*(window: T): float = window.inputState.boundsPixels.size.y
  template size*(window: T): Vec2 = window.inputState.bounds.size
  template width*(window: T): float = window.inputState.bounds.size.x
  template height*(window: T): float = window.inputState.bounds.size.y
  template scale*(window: T): float = 1.0 / window.inputState.pixelDensity
  template moved*(window: T): bool = window.inputState.bounds.position != window.previousInputState.bounds.position
  template positionDelta*(window: T): Vec2 = window.inputState.bounds.position - window.previousInputState.bounds.position
  template positionDeltaPixels*(window: T): Vec2 = window.positionDelta * window.inputState.pixelDensity
  template resized*(window: T): bool = window.inputState.bounds.size != window.previousInputState.bounds.size
  template sizeDelta*(window: T): Vec2 = window.inputState.bounds.size - window.previousInputState.bounds.size
  template sizeDeltaPixels*(window: T): Vec2 = window.sizeDelta * window.inputState.pixelDensity
  template pixelDensityChanged*(window: T): bool = window.inputState.pixelDensity != window.previousInputState.pixelDensity
  template aspectRatio*(window: T): float = window.inputState.bounds.size.x / window.inputState.bounds.size.y
  template gainedFocus*(window: T): bool = window.inputState.isFocused and not window.previousInputState.isFocused
  template lostFocus*(window: T): bool = window.previousInputState.isFocused and not window.inputState.isFocused
  template mouseEntered*(window: T): bool = window.inputState.isHovered and not window.previousInputState.isHovered
  template mouseExited*(window: T): bool = window.previousInputState.isHovered and not window.inputState.isHovered