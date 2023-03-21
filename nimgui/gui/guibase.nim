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

template defineGuiProcs*(): untyped {.dirty.} =
  template initState(gui: Gui) =
    let inputState = InputState(time: cpuTime(), pixelDensity: 1.0)
    gui.inputState = inputState
    gui.previousInputState = inputState
    gui.isOpen = true
    gui.inputState.isFocused = true
    gui.previousInputState.isFocused = false

  template processFrame(gui: Gui) =
    if gui.isOpen:
      gui.openGlContext.select()
      glClear(GL_COLOR_BUFFER_BIT)

      if gui.onFrame != nil:
        gui.gfx.beginFrame(gui.sizePixels, gui.pixelDensity)
        gui.onFrame()
        gui.gfx.endFrame()

      gui.openGlContext.swapBuffers()

      gui.previousInputState = gui.inputState
      gui.inputState.mouseWheel = vec2(0, 0)
      gui.inputState.text = ""
      gui.inputState.mousePresses.setLen(0)
      gui.inputState.mouseReleases.setLen(0)
      gui.inputState.keyPresses.setLen(0)
      gui.inputState.keyReleases.setLen(0)
      gui.inputState.time = cpuTime()

  proc `backgroundColor=`*(gui: Gui, color: Color) =
    gui.openGlContext.select()
    glClearColor(color.r, color.g, color.b, color.a)

  func time*(gui: Gui): float = gui.inputState.time
  func isFocused*(gui: Gui): bool = gui.inputState.isFocused
  func isHovered*(gui: Gui): bool = gui.inputState.isHovered
  func pixelDensity*(gui: Gui): float = gui.inputState.pixelDensity
  func boundsPixels*(gui: Gui): Rect2 = gui.inputState.boundsPixels
  func mousePositionPixels*(gui: Gui): Vec2 = gui.inputState.mousePositionPixels
  func mouseWheel*(gui: Gui): Vec2 = gui.inputState.mouseWheel
  func mousePresses*(gui: Gui): seq[MouseButton] = gui.inputState.mousePresses
  func mouseReleases*(gui: Gui): seq[MouseButton] = gui.inputState.mouseReleases
  func mouseDown*(gui: Gui, button: MouseButton): bool = gui.inputState.mouseDown[button]
  func keyPresses*(gui: Gui): seq[KeyboardKey] = gui.inputState.keyPresses
  func keyReleases*(gui: Gui): seq[KeyboardKey] = gui.inputState.keyReleases
  func keyDown*(gui: Gui, key: KeyboardKey): bool = gui.inputState.keyDown[key]
  func text*(gui: Gui): string = gui.inputState.text

  func deltaTime*(gui: Gui): float = gui.inputState.time - gui.previousInputState.time
  func mousePosition*(gui: Gui): Vec2 = gui.inputState.mousePositionPixels / gui.inputState.pixelDensity
  func mouseDeltaPixels*(gui: Gui): Vec2 = gui.inputState.mousePositionPixels - gui.previousInputState.mousePositionPixels
  func mouseDelta*(gui: Gui): Vec2 = gui.mouseDeltaPixels / gui.inputState.pixelDensity
  func mouseMoved*(gui: Gui): bool = gui.inputState.mousePositionPixels != gui.previousInputState.mousePositionPixels
  func mouseWheelMoved*(gui: Gui): bool = gui.inputState.mouseWheel.x != 0.0 or gui.inputState.mouseWheel.y != 0.0
  func mousePressed*(gui: Gui, button: MouseButton): bool = gui.inputState.mouseDown[button] and not gui.previousInputState.mouseDown[button]
  func mouseReleased*(gui: Gui, button: MouseButton): bool = gui.previousInputState.mouseDown[button] and not gui.inputState.mouseDown[button]
  func anyMousePressed*(gui: Gui): bool = gui.inputState.mousePresses.len > 0
  func anyMouseReleased*(gui: Gui): bool = gui.inputState.mouseReleases.len > 0
  func keyPressed*(gui: Gui, key: KeyboardKey): bool = gui.inputState.keyDown[key] and not gui.previousInputState.keyDown[key]
  func keyReleased*(gui: Gui, key: KeyboardKey): bool = gui.previousInputState.keyDown[key] and not gui.inputState.keyDown[key]
  func anyKeyPressed*(gui: Gui): bool = gui.inputState.keyPresses.len > 0
  func anyKeyReleased*(gui: Gui): bool = gui.inputState.keyReleases.len > 0
  func bounds*(gui: Gui): Rect2 = rect2(gui.inputState.boundsPixels.position / gui.inputState.pixelDensity, gui.inputState.boundsPixels.size / gui.inputState.pixelDensity)
  func positionPixels*(gui: Gui): Vec2 = gui.inputState.boundsPixels.position
  func position*(gui: Gui): Vec2 = gui.inputState.boundsPixels.position / gui.inputState.pixelDensity
  func sizePixels*(gui: Gui): Vec2 = gui.inputState.boundsPixels.size
  func size*(gui: Gui): Vec2 = gui.inputState.boundsPixels.size / gui.inputState.pixelDensity
  func scale*(gui: Gui): float = 1.0 / gui.inputState.pixelDensity
  func moved*(gui: Gui): bool = gui.inputState.boundsPixels.position != gui.previousInputState.boundsPixels.position
  func positionDeltaPixels*(gui: Gui): Vec2 = gui.inputState.boundsPixels.position - gui.previousInputState.boundsPixels.position
  func positionDelta*(gui: Gui): Vec2 = gui.positionDeltaPixels / gui.inputState.pixelDensity
  func resized*(gui: Gui): bool = gui.inputState.boundsPixels.size != gui.previousInputState.boundsPixels.size
  func sizeDeltaPixels*(gui: Gui): Vec2 = gui.inputState.boundsPixels.size - gui.previousInputState.boundsPixels.size
  func sizeDelta*(gui: Gui): Vec2 = gui.sizeDeltaPixels / gui.inputState.pixelDensity
  func pixelDensityChanged*(gui: Gui): bool = gui.inputState.pixelDensity != gui.previousInputState.pixelDensity
  func aspectRatio*(gui: Gui): float = gui.inputState.boundsPixels.size.x / gui.inputState.boundsPixels.size.y
  func gainedFocus*(gui: Gui): bool = gui.inputState.isFocused and not gui.previousInputState.isFocused
  func lostFocus*(gui: Gui): bool = gui.previousInputState.isFocused and not gui.inputState.isFocused
  func mouseEntered*(gui: Gui): bool = gui.inputState.isHovered and not gui.previousInputState.isHovered
  func mouseExited*(gui: Gui): bool = gui.previousInputState.isHovered and not gui.inputState.isHovered

# when defined(windows):
#   import winim/lean except INPUT

#   var clipboardStorage = ""

#   proc `clipboard=`*(gui: Gui, text: string) =
#     let characterCount = MultiByteToWideChar(CP_UTF8, 0, text, -1, NULL, 0)
#     if characterCount == 0:
#       return

#     let h = GlobalAlloc(GMEM_MOVEABLE, characterCount * sizeof(WCHAR))
#     if h == 0:
#       echo "Win32: Failed to allocate global handle for clipboard."
#       return

#     var buffer = cast[ptr WCHAR](GlobalLock(h))
#     if buffer == nil:
#       echo "Win32: Failed to lock global handle."
#       GlobalFree(h)

#     MultiByteToWideChar(CP_UTF8, 0, text, -1, buffer, characterCount)
#     GlobalUnlock(h)

#     if OpenClipboard(0) == 0:
#       echo "Win32: Failed to open clipboard."
#       GlobalFree(h)
#       return

#     EmptyClipboard()
#     SetClipboardData(CF_UNICODETEXT, h)
#     CloseClipboard()

#   proc wideStringToUtf8(source: ptr WCHAR): string =
#     let size = WideCharToMultiByte(CP_UTF8, 0, source, -1, NULL, 0, NULL, NULL)
#     if size == 0:
#       echo "Win32: Failed to convert string to UTF-8."
#       return ""

#     result = newString(size)

#     if WideCharToMultiByte(CP_UTF8, 0, source, -1, result, size, NULL, NULL) == 0:
#       echo "Win32: Failed to convert string to UTF-8."
#       return ""

#   proc clipboard*(gui: Gui): string =
#     if OpenClipboard(0) == 0:
#       echo "Win32: Failed to open clipboard"
#       return ""

#     let h = GetClipboardData(CF_UNICODETEXT)
#     if h == 0:
#       echo "Win32: Failed to convert clipboard to string."
#       CloseClipboard()
#       return ""

#     let buffer = cast[ptr WCHAR](GlobalLock(h))
#     if buffer == nil:
#       echo "Win32: Failed to lock global handle."
#       CloseClipboard()
#       return ""

#     clipboardStorage = wideStringToUtf8(buffer)

#     GlobalUnlock(h)
#     CloseClipboard()

#     clipboardStorage