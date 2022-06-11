{.experimental: "overloadableEnums".}

import std/times
import ../math; export math

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

  UiFrame* = object
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

  UiHandler* = ref object of RootObj
    frame*: UiFrame
    previousFrame*: UiFrame

proc init*(ui: UiHandler) =
  let frame = UiFrame(time: cpuTime(), pixelDensity: 1.0)
  ui.frame = frame
  ui.previousFrame = frame

proc update*(ui: UiHandler) =
  ui.previousFrame = ui.frame
  ui.frame.mouseWheel = vec2(0, 0)
  ui.frame.text = ""
  ui.frame.mousePresses.setLen(0)
  ui.frame.mouseReleases.setLen(0)
  ui.frame.keyPresses.setLen(0)
  ui.frame.keyReleases.setLen(0)
  ui.frame.time = cpuTime()

func time*(ui: UiHandler): float = ui.frame.time
func isFocused*(ui: UiHandler): bool = ui.frame.isFocused
func isHovered*(ui: UiHandler): bool = ui.frame.isHovered
func pixelDensity*(ui: UiHandler): float = ui.frame.pixelDensity
func boundsPixels*(ui: UiHandler): Rect2 = ui.frame.boundsPixels
func mousePositionPixels*(ui: UiHandler): Vec2 = ui.frame.mousePositionPixels
func mouseWheel*(ui: UiHandler): Vec2 = ui.frame.mouseWheel
func mousePresses*(ui: UiHandler): seq[MouseButton] = ui.frame.mousePresses
func mouseReleases*(ui: UiHandler): seq[MouseButton] = ui.frame.mouseReleases
func mouseDown*(ui: UiHandler, button: MouseButton): bool = ui.frame.mouseDown[button]
func keyPresses*(ui: UiHandler): seq[KeyboardKey] = ui.frame.keyPresses
func keyReleases*(ui: UiHandler): seq[KeyboardKey] = ui.frame.keyReleases
func keyDown*(ui: UiHandler, key: KeyboardKey): bool = ui.frame.keyDown[key]
func text*(ui: UiHandler): string = ui.frame.text

func deltaTime*(ui: UiHandler): float = ui.frame.time - ui.previousFrame.time
func mousePosition*(ui: UiHandler): Vec2 = ui.frame.mousePositionPixels / ui.frame.pixelDensity
func mouseDeltaPixels*(ui: UiHandler): Vec2 = ui.frame.mousePositionPixels - ui.previousFrame.mousePositionPixels
func mouseDelta*(ui: UiHandler): Vec2 = ui.mouseDeltaPixels / ui.frame.pixelDensity
func mouseMoved*(ui: UiHandler): bool = ui.frame.mousePositionPixels != ui.previousFrame.mousePositionPixels
func mouseWheelMoved*(ui: UiHandler): bool = ui.frame.mouseWheel.x != 0.0 or ui.frame.mouseWheel.y != 0.0
func mousePressed*(ui: UiHandler, button: MouseButton): bool = ui.frame.mouseDown[button] and not ui.previousFrame.mouseDown[button]
func mouseReleased*(ui: UiHandler, button: MouseButton): bool = ui.previousFrame.mouseDown[button] and not ui.frame.mouseDown[button]
func anyMousePressed*(ui: UiHandler): bool = ui.frame.mousePresses.len > 0
func anyMouseReleased*(ui: UiHandler): bool = ui.frame.mouseReleases.len > 0
func keyPressed*(ui: UiHandler, key: KeyboardKey): bool = ui.frame.keyDown[key] and not ui.previousFrame.keyDown[key]
func keyReleased*(ui: UiHandler, key: KeyboardKey): bool = ui.previousFrame.keyDown[key] and not ui.frame.keyDown[key]
func anyKeyPressed*(ui: UiHandler): bool = ui.frame.keyPresses.len > 0
func anyKeyReleased*(ui: UiHandler): bool = ui.frame.keyReleases.len > 0
func bounds*(ui: UiHandler): Rect2 = rect2(ui.frame.boundsPixels.position / ui.frame.pixelDensity, ui.frame.boundsPixels.size / ui.frame.pixelDensity)
func positionPixels*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.position
func position*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.position / ui.frame.pixelDensity
func sizePixels*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.size
func size*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.size / ui.frame.pixelDensity
func scale*(ui: UiHandler): float = 1.0 / ui.frame.pixelDensity
func moved*(ui: UiHandler): bool = ui.frame.boundsPixels.position != ui.previousFrame.boundsPixels.position
func positionDeltaPixels*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.position - ui.previousFrame.boundsPixels.position
func positionDelta*(ui: UiHandler): Vec2 = ui.positionDeltaPixels / ui.frame.pixelDensity
func resized*(ui: UiHandler): bool = ui.frame.boundsPixels.size != ui.previousFrame.boundsPixels.size
func sizeDeltaPixels*(ui: UiHandler): Vec2 = ui.frame.boundsPixels.size - ui.previousFrame.boundsPixels.size
func sizeDelta*(ui: UiHandler): Vec2 = ui.sizeDeltaPixels / ui.frame.pixelDensity
func pixelDensityChanged*(ui: UiHandler): bool = ui.frame.pixelDensity != ui.previousFrame.pixelDensity
func aspectRatio*(ui: UiHandler): float = ui.frame.boundsPixels.size.x / ui.frame.boundsPixels.size.y
func gainedFocus*(ui: UiHandler): bool = ui.frame.isFocused and not ui.previousFrame.isFocused
func lostFocus*(ui: UiHandler): bool = ui.previousFrame.isFocused and not ui.frame.isFocused
func mouseEntered*(ui: UiHandler): bool = ui.frame.isHovered and not ui.previousFrame.isHovered
func mouseExited*(ui: UiHandler): bool = ui.previousFrame.isHovered and not ui.frame.isHovered

when defined(windows):
  import winim/lean except INPUT

  var clipboardStorage = ""

  proc `clipboard=`*(ui: UiHandler, text: string) =
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

  proc clipboard*(ui: UiHandler): string =
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

    clipboardStorage = wideStringToUtf8(buffer)

    GlobalUnlock(h)
    CloseClipboard()

    clipboardStorage