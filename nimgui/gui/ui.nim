{.experimental: "overloadableEnums".}

import std/times
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

  UiState* = object
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

  Ui* = ref object of RootObj
    state*: UiState
    previousState*: UiState

proc initState*(ui: Ui) =
  let state = UiState(time: cpuTime(), pixelDensity: 1.0)
  ui.state = state
  ui.previousState = state
  ui.state.isFocused = true
  ui.previousState.isFocused = false

proc updateState*(ui: Ui) =
  ui.previousState = ui.state
  ui.state.mouseWheel = vec2(0, 0)
  ui.state.text = ""
  ui.state.mousePresses.setLen(0)
  ui.state.mouseReleases.setLen(0)
  ui.state.keyPresses.setLen(0)
  ui.state.keyReleases.setLen(0)
  ui.state.time = cpuTime()

func time*(ui: Ui): float = ui.state.time
func isFocused*(ui: Ui): bool = ui.state.isFocused
func isHovered*(ui: Ui): bool = ui.state.isHovered
func pixelDensity*(ui: Ui): float = ui.state.pixelDensity
func boundsPixels*(ui: Ui): Rect2 = ui.state.boundsPixels
func mousePositionPixels*(ui: Ui): Vec2 = ui.state.mousePositionPixels
func mouseWheel*(ui: Ui): Vec2 = ui.state.mouseWheel
func mousePresses*(ui: Ui): seq[MouseButton] = ui.state.mousePresses
func mouseReleases*(ui: Ui): seq[MouseButton] = ui.state.mouseReleases
func mouseDown*(ui: Ui, button: MouseButton): bool = ui.state.mouseDown[button]
func keyPresses*(ui: Ui): seq[KeyboardKey] = ui.state.keyPresses
func keyReleases*(ui: Ui): seq[KeyboardKey] = ui.state.keyReleases
func keyDown*(ui: Ui, key: KeyboardKey): bool = ui.state.keyDown[key]
func text*(ui: Ui): string = ui.state.text

func deltaTime*(ui: Ui): float = ui.state.time - ui.previousState.time
func mousePosition*(ui: Ui): Vec2 = ui.state.mousePositionPixels / ui.state.pixelDensity
func mouseDeltaPixels*(ui: Ui): Vec2 = ui.state.mousePositionPixels - ui.previousState.mousePositionPixels
func mouseDelta*(ui: Ui): Vec2 = ui.mouseDeltaPixels / ui.state.pixelDensity
func mouseMoved*(ui: Ui): bool = ui.state.mousePositionPixels != ui.previousState.mousePositionPixels
func mouseWheelMoved*(ui: Ui): bool = ui.state.mouseWheel.x != 0.0 or ui.state.mouseWheel.y != 0.0
func mousePressed*(ui: Ui, button: MouseButton): bool = ui.state.mouseDown[button] and not ui.previousState.mouseDown[button]
func mouseReleased*(ui: Ui, button: MouseButton): bool = ui.previousState.mouseDown[button] and not ui.state.mouseDown[button]
func anyMousePressed*(ui: Ui): bool = ui.state.mousePresses.len > 0
func anyMouseReleased*(ui: Ui): bool = ui.state.mouseReleases.len > 0
func keyPressed*(ui: Ui, key: KeyboardKey): bool = ui.state.keyDown[key] and not ui.previousState.keyDown[key]
func keyReleased*(ui: Ui, key: KeyboardKey): bool = ui.previousState.keyDown[key] and not ui.state.keyDown[key]
func anyKeyPressed*(ui: Ui): bool = ui.state.keyPresses.len > 0
func anyKeyReleased*(ui: Ui): bool = ui.state.keyReleases.len > 0
func bounds*(ui: Ui): Rect2 = rect2(ui.state.boundsPixels.position / ui.state.pixelDensity, ui.state.boundsPixels.size / ui.state.pixelDensity)
func positionPixels*(ui: Ui): Vec2 = ui.state.boundsPixels.position
func position*(ui: Ui): Vec2 = ui.state.boundsPixels.position / ui.state.pixelDensity
func sizePixels*(ui: Ui): Vec2 = ui.state.boundsPixels.size
func size*(ui: Ui): Vec2 = ui.state.boundsPixels.size / ui.state.pixelDensity
func scale*(ui: Ui): float = 1.0 / ui.state.pixelDensity
func moved*(ui: Ui): bool = ui.state.boundsPixels.position != ui.previousState.boundsPixels.position
func positionDeltaPixels*(ui: Ui): Vec2 = ui.state.boundsPixels.position - ui.previousState.boundsPixels.position
func positionDelta*(ui: Ui): Vec2 = ui.positionDeltaPixels / ui.state.pixelDensity
func resized*(ui: Ui): bool = ui.state.boundsPixels.size != ui.previousState.boundsPixels.size
func sizeDeltaPixels*(ui: Ui): Vec2 = ui.state.boundsPixels.size - ui.previousState.boundsPixels.size
func sizeDelta*(ui: Ui): Vec2 = ui.sizeDeltaPixels / ui.state.pixelDensity
func pixelDensityChanged*(ui: Ui): bool = ui.state.pixelDensity != ui.previousState.pixelDensity
func aspectRatio*(ui: Ui): float = ui.state.boundsPixels.size.x / ui.state.boundsPixels.size.y
func gainedFocus*(ui: Ui): bool = ui.state.isFocused and not ui.previousState.isFocused
func lostFocus*(ui: Ui): bool = ui.previousState.isFocused and not ui.state.isFocused
func mouseEntered*(ui: Ui): bool = ui.state.isHovered and not ui.previousState.isHovered
func mouseExited*(ui: Ui): bool = ui.previousState.isHovered and not ui.state.isHovered