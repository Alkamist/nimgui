{.experimental: "overloadableEnums".}

import ../math; export math
import ../gfx; export gfx

const defaultDpi* = 96.0

type
  MouseButton* = enum
    Unknown,
    Left, Middle, Right,
    Extra1, Extra2, Extra3,
    Extra4, Extra5,

  KeyboardKey* = enum
    Unknown,
    Space, Apostrophe, Comma,
    Minus, Period, Slash,
    Key0, Key1, Key2, Key3, Key4,
    Key5, Key6, Key7, Key8, Key9,
    Semicolon, Equal,
    A, B, C, D, E, F, G, H, I,
    J, K, L, M, N, O, P, Q, R,
    S, T, U, V, W, X, Y, Z,
    LeftBracket, Backslash,
    RightBracket, Backtick,
    World1, World2, Escape, Enter,
    Tab, Backspace, Insert, Delete,
    RightArrow, LeftArrow,
    DownArrow, UpArrow,
    PageUp, PageDown, Home,
    End, CapsLock,
    ScrollLock, NumLock,
    PrintScreen, Pause,
    F1, F2, F3, F4, F5, F6, F7, F8, F9,
    F10, F11, F12, F13, F14, F15, F16,
    F17, F18, F19, F20, F21, F22,
    F23, F24, F25,
    Pad0, Pad1, Pad2, Pad3, Pad4,
    Pad5, Pad6, Pad7, Pad8, Pad9,
    PadDecimal, PadDivide, PadMultiply,
    PadSubtract, PadAdd, PadEnter, PadEqual,
    LeftShift, LeftControl,
    LeftAlt, LeftSuper,
    RightShift, RightControl,
    RightAlt, RightSuper,
    Menu,

  FrameState* = object
    time*: float
    exists*: bool
    isChild*: bool
    isFocused*: bool
    isHovered*: bool
    contentScale*: float
    bounds*: Rect2
    frameBufferSize*: Vec2
    mousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDown*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDown*: array[KeyboardKey, bool]
    textInput*: string

  Window* = ref object of RootObj
    onFrame*: proc()
    gfx*: Gfx
    frameState*: FrameState
    previousFrameState*: FrameState
    closeRequested*: bool

template time*(window: Window): float = window.frameState.time
template exists*(window: Window): bool = window.frameState.exists
template isFocused*(window: Window): bool = window.frameState.isFocused
template isHovered*(window: Window): bool = window.frameState.isHovered
template contentScale*(window: Window): float = window.frameState.contentScale
template bounds*(window: Window): Rect2 = window.frameState.bounds
template frameBufferSize*(window: Window): Vec2 = window.frameState.frameBufferSize
template mousePosition*(window: Window): Vec2 = window.frameState.mousePosition
template mouseWheel*(window: Window): Vec2 = window.frameState.mouseWheel
template mousePresses*(window: Window): seq[MouseButton] = window.frameState.mousePresses
template mouseReleases*(window: Window): seq[MouseButton] = window.frameState.mouseReleases
template mouseDown*(window: Window, button: MouseButton): bool = window.frameState.mouseDown[button]
template keyPresses*(window: Window): seq[KeyboardKey] = window.frameState.keyPresses
template keyReleases*(window: Window): seq[KeyboardKey] = window.frameState.keyReleases
template keyDown*(window: Window, key: KeyboardKey): bool = window.frameState.keyDown[key]
template textInput*(window: Window): string = window.frameState.textInput

template deltaTime*(window: Window): float = window.frameState.time - window.previousFrameState.time
template created*(window: Window): bool = window.frameState.exists and not window.previousFrameState.exists
template destroyed*(window: Window): bool = window.previousFrameState.exists and not window.frameState.exists
template mouseDelta*(window: Window): Vec2 = window.frameState.mousePosition - window.previousFrameState.mousePosition
template mouseMoved*(window: Window): bool = window.frameState.mousePosition != window.previousFrameState.mousePosition
template mouseWheelMoved*(window: Window): bool = window.frameState.mouseWheel.x != 0.0 or window.frameState.mouseWheel.y != 0.0
template mousePressed*(window: Window, button: MouseButton): bool = window.frameState.mouseDown[button] and not window.previousFrameState.mouseDown[button]
template mouseReleased*(window: Window, button: MouseButton): bool = window.previousFrameState.mouseDown[button] and not window.frameState.mouseDown[button]
template anyMousePressed*(window: Window): bool = window.frameState.mousePresses.len > 0
template anyMouseReleased*(window: Window): bool = window.frameState.mouseReleases.len > 0
template keyPressed*(window: Window, key: KeyboardKey): bool = window.frameState.keyDown[key] and not window.previousFrameState.keyDown[key]
template keyReleased*(window: Window, key: KeyboardKey): bool = window.previousFrameState.keyDown[key] and not window.frameState.keyDown[key]
template anyKeyPressed*(window: Window): bool = window.frameState.keyPresses.len > 0
template anyKeyReleased*(window: Window): bool = window.frameState.keyReleases.len > 0
template position*(window: Window): Vec2 = window.frameState.bounds.position
template x*(window: Window): float = window.frameState.bounds.position.x
template y*(window: Window): float = window.frameState.bounds.position.y
template size*(window: Window): Vec2 = window.frameState.bounds.size
template width*(window: Window): float = window.frameState.bounds.size.x
template height*(window: Window): float = window.frameState.bounds.size.y
template moved*(window: Window): bool = window.frameState.bounds.position != window.previousFrameState.bounds.position
template positionDelta*(window: Window): Vec2 = window.frameState.bounds.position - window.previousFrameState.bounds.position
template resized*(window: Window): bool = window.frameState.bounds.size != window.previousFrameState.bounds.size
template sizeDelta*(window: Window): Vec2 = window.frameState.bounds.size - window.previousFrameState.bounds.size
template contentScaleChanged*(window: Window): bool = window.frameState.contentScale != window.previousFrameState.contentScale
template aspectRatio*(window: Window): float = window.frameState.bounds.size.x / window.frameState.bounds.size.y
template gainedFocus*(window: Window): bool = window.frameState.isFocused and not window.previousFrameState.isFocused
template lostFocus*(window: Window): bool = window.previousFrameState.isFocused and not window.frameState.isFocused
template mouseEntered*(window: Window): bool = window.frameState.isHovered and not window.previousFrameState.isHovered
template mouseExited*(window: Window): bool = window.previousFrameState.isHovered and not window.frameState.isHovered

proc newWindowBase*(time: float): Window =
  Window(
    frameState: FrameState(
      time: time,
      exists: true,
      isFocused: true,
      contentScale: 1.0,
    ),
    previousFrameState: FrameState(
      time: time,
      exists: true,
      isFocused: true,
      contentScale: 1.0,
    ),
  )

proc updateFrameState*(window: Window, time: float) =
  window.previousFrameState = window.frameState
  window.frameState.mouseWheel = vec2(0, 0)
  window.frameState.textInput = ""
  window.frameState.mousePresses.setLen(0)
  window.frameState.mouseReleases.setLen(0)
  window.frameState.keyPresses.setLen(0)
  window.frameState.keyReleases.setLen(0)
  window.frameState.time = time