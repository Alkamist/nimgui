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
    backgroundColor*: Color

func time*(window: Window): float = window.frameState.time
func exists*(window: Window): bool = window.frameState.exists
func isFocused*(window: Window): bool = window.frameState.isFocused
func isHovered*(window: Window): bool = window.frameState.isHovered
func contentScale*(window: Window): float = window.frameState.contentScale
func bounds*(window: Window): Rect2 = window.frameState.bounds
func frameBufferSize*(window: Window): Vec2 = window.frameState.frameBufferSize
func mousePosition*(window: Window): Vec2 = window.frameState.mousePosition
func mouseWheel*(window: Window): Vec2 = window.frameState.mouseWheel
func mousePresses*(window: Window): seq[MouseButton] = window.frameState.mousePresses
func mouseReleases*(window: Window): seq[MouseButton] = window.frameState.mouseReleases
func mouseDown*(window: Window, button: MouseButton): bool = window.frameState.mouseDown[button]
func keyPresses*(window: Window): seq[KeyboardKey] = window.frameState.keyPresses
func keyReleases*(window: Window): seq[KeyboardKey] = window.frameState.keyReleases
func keyDown*(window: Window, key: KeyboardKey): bool = window.frameState.keyDown[key]
func textInput*(window: Window): string = window.frameState.textInput

func deltaTime*(window: Window): float = window.frameState.time - window.previousFrameState.time
func created*(window: Window): bool = window.frameState.exists and not window.previousFrameState.exists
func destroyed*(window: Window): bool = window.previousFrameState.exists and not window.frameState.exists
func mouseDelta*(window: Window): Vec2 = window.frameState.mousePosition - window.previousFrameState.mousePosition
func mouseMoved*(window: Window): bool = window.frameState.mousePosition != window.previousFrameState.mousePosition
func mouseWheelMoved*(window: Window): bool = window.frameState.mouseWheel.x != 0.0 or window.frameState.mouseWheel.y != 0.0
func mousePressed*(window: Window, button: MouseButton): bool = window.frameState.mouseDown[button] and not window.previousFrameState.mouseDown[button]
func mouseReleased*(window: Window, button: MouseButton): bool = window.previousFrameState.mouseDown[button] and not window.frameState.mouseDown[button]
func anyMousePressed*(window: Window): bool = window.frameState.mousePresses.len > 0
func anyMouseReleased*(window: Window): bool = window.frameState.mouseReleases.len > 0
func keyPressed*(window: Window, key: KeyboardKey): bool = window.frameState.keyDown[key] and not window.previousFrameState.keyDown[key]
func keyReleased*(window: Window, key: KeyboardKey): bool = window.previousFrameState.keyDown[key] and not window.frameState.keyDown[key]
func anyKeyPressed*(window: Window): bool = window.frameState.keyPresses.len > 0
func anyKeyReleased*(window: Window): bool = window.frameState.keyReleases.len > 0
func position*(window: Window): Vec2 = window.frameState.bounds.position
func x*(window: Window): float = window.frameState.bounds.position.x
func y*(window: Window): float = window.frameState.bounds.position.y
func size*(window: Window): Vec2 = window.frameState.bounds.size
func width*(window: Window): float = window.frameState.bounds.size.x
func height*(window: Window): float = window.frameState.bounds.size.y
func moved*(window: Window): bool = window.frameState.bounds.position != window.previousFrameState.bounds.position
func positionDelta*(window: Window): Vec2 = window.frameState.bounds.position - window.previousFrameState.bounds.position
func resized*(window: Window): bool = window.frameState.bounds.size != window.previousFrameState.bounds.size
func sizeDelta*(window: Window): Vec2 = window.frameState.bounds.size - window.previousFrameState.bounds.size
func contentScaleChanged*(window: Window): bool = window.frameState.contentScale != window.previousFrameState.contentScale
func aspectRatio*(window: Window): float = window.frameState.bounds.size.x / window.frameState.bounds.size.y
func gainedFocus*(window: Window): bool = window.frameState.isFocused and not window.previousFrameState.isFocused
func lostFocus*(window: Window): bool = window.previousFrameState.isFocused and not window.frameState.isFocused
func mouseEntered*(window: Window): bool = window.frameState.isHovered and not window.previousFrameState.isHovered
func mouseExited*(window: Window): bool = window.previousFrameState.isHovered and not window.frameState.isHovered

func clearAccumulators*(window: Window) =
  window.frameState.mouseWheel = vec2(0, 0)
  window.frameState.textInput = ""
  window.frameState.mousePresses.setLen(0)
  window.frameState.mouseReleases.setLen(0)
  window.frameState.keyPresses.setLen(0)
  window.frameState.keyReleases.setLen(0)