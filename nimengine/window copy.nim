{.experimental: "overloadableEnums".}

import std/exitprocs
import std/unicode
import std/tables
import std/sequtils
import opengl
import ./glfw
import ./math; export math
import ./gfx; export gfx

proc glfwErrorCallback(errorCode: cint, description: cstring) {.cdecl.} =
  echo "Glfw Error " & $errorCode & ": " & $description

discard glfwSetErrorCallback(glfwErrorCallback)
if glfwInit() == 0:
  raise newException(Exception, "Failed to Initialize GLFW.")

addExitProc(proc() = glfwTerminate())

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
    isFocused*: bool
    isHovered*: bool
    contentScale*: Vec2
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

  Window* = ref object
    isOpen*: bool
    frameState*: FrameState
    previousFrameState*: FrameState
    gfx*: Gfx
    glfwWindow*: GLFWwindow

func time*(window: Window): float = window.frameState.time
func isFocused*(window: Window): bool = window.frameState.isFocused
func isHovered*(window: Window): bool = window.frameState.isHovered
func contentScale*(window: Window): Vec2 = window.frameState.contentScale
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
func size*(window: Window): Vec2 = window.frameState.bounds.size
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

proc clipboard*(window: Window): string =
  $glfwGetClipboardString(window.glfwWindow)

proc `clipboard=`*(window: Window, text: string) =
  glfwSetClipboardString(window.glfwWindow, text.cstring)

proc toBiTable[K, V](entries: openArray[(K, V)]): (Table[K, V], Table[V, K]) =
  let reverseEntries = entries.mapIt((it[1], it[0]))
  result = (entries.toTable(), reverseEntries.toTable())

const (keyboardKeyToGlfwKey*, glfwKeyToKeyboardKey*) = {
  KeyboardKey.Unknown: GLFW_KEY_UNKNOWN,
  KeyboardKey.Space: GLFW_KEY_SPACE,
  KeyboardKey.Apostrophe: GLFW_KEY_APOSTROPHE,
  KeyboardKey.Comma: GLFW_KEY_COMMA,
  KeyboardKey.Minus: GLFW_KEY_MINUS,
  KeyboardKey.Period: GLFW_KEY_PERIOD,
  KeyboardKey.Slash: GLFW_KEY_SLASH,
  KeyboardKey.Key0: GLFW_KEY_0,
  KeyboardKey.Key1: GLFW_KEY_1,
  KeyboardKey.Key2: GLFW_KEY_2,
  KeyboardKey.Key3: GLFW_KEY_3,
  KeyboardKey.Key4: GLFW_KEY_4,
  KeyboardKey.Key5: GLFW_KEY_5,
  KeyboardKey.Key6: GLFW_KEY_6,
  KeyboardKey.Key7: GLFW_KEY_7,
  KeyboardKey.Key8: GLFW_KEY_8,
  KeyboardKey.Key9: GLFW_KEY_9,
  KeyboardKey.Semicolon: GLFW_KEY_SEMICOLON,
  KeyboardKey.Equal: GLFW_KEY_EQUAL,
  KeyboardKey.A: GLFW_KEY_A,
  KeyboardKey.B: GLFW_KEY_B,
  KeyboardKey.C: GLFW_KEY_C,
  KeyboardKey.D: GLFW_KEY_D,
  KeyboardKey.E: GLFW_KEY_E,
  KeyboardKey.F: GLFW_KEY_F,
  KeyboardKey.G: GLFW_KEY_G,
  KeyboardKey.H: GLFW_KEY_H,
  KeyboardKey.I: GLFW_KEY_I,
  KeyboardKey.J: GLFW_KEY_J,
  KeyboardKey.K: GLFW_KEY_K,
  KeyboardKey.L: GLFW_KEY_L,
  KeyboardKey.M: GLFW_KEY_M,
  KeyboardKey.N: GLFW_KEY_N,
  KeyboardKey.O: GLFW_KEY_O,
  KeyboardKey.P: GLFW_KEY_P,
  KeyboardKey.Q: GLFW_KEY_Q,
  KeyboardKey.R: GLFW_KEY_R,
  KeyboardKey.S: GLFW_KEY_S,
  KeyboardKey.T: GLFW_KEY_T,
  KeyboardKey.U: GLFW_KEY_U,
  KeyboardKey.V: GLFW_KEY_V,
  KeyboardKey.W: GLFW_KEY_W,
  KeyboardKey.X: GLFW_KEY_X,
  KeyboardKey.Y: GLFW_KEY_Y,
  KeyboardKey.Z: GLFW_KEY_Z,
  KeyboardKey.LeftBracket: GLFW_KEY_LEFT_BRACKET,
  KeyboardKey.Backslash: GLFW_KEY_BACKSLASH,
  KeyboardKey.RightBracket: GLFW_KEY_RIGHT_BRACKET,
  KeyboardKey.Backtick: GLFW_KEY_GRAVE_ACCENT,
  KeyboardKey.World1: GLFW_KEY_WORLD_1,
  KeyboardKey.World2: GLFW_KEY_WORLD_2,
  KeyboardKey.Escape: GLFW_KEY_ESCAPE,
  KeyboardKey.Enter: GLFW_KEY_ENTER,
  KeyboardKey.Tab: GLFW_KEY_TAB,
  KeyboardKey.Backspace: GLFW_KEY_BACKSPACE,
  KeyboardKey.Insert: GLFW_KEY_INSERT,
  KeyboardKey.Delete: GLFW_KEY_DELETE,
  KeyboardKey.RightArrow: GLFW_KEY_RIGHT,
  KeyboardKey.LeftArrow: GLFW_KEY_LEFT,
  KeyboardKey.DownArrow: GLFW_KEY_DOWN,
  KeyboardKey.UpArrow: GLFW_KEY_UP,
  KeyboardKey.PageUp: GLFW_KEY_PAGE_UP,
  KeyboardKey.PageDown: GLFW_KEY_PAGE_DOWN,
  KeyboardKey.Home: GLFW_KEY_HOME,
  KeyboardKey.End: GLFW_KEY_END,
  KeyboardKey.CapsLock: GLFW_KEY_CAPS_LOCK,
  KeyboardKey.ScrollLock: GLFW_KEY_SCROLL_LOCK,
  KeyboardKey.NumLock: GLFW_KEY_NUM_LOCK,
  KeyboardKey.PrintScreen: GLFW_KEY_PRINT_SCREEN,
  KeyboardKey.Pause: GLFW_KEY_PAUSE,
  KeyboardKey.F1: GLFW_KEY_F1,
  KeyboardKey.F2: GLFW_KEY_F2,
  KeyboardKey.F3: GLFW_KEY_F3,
  KeyboardKey.F4: GLFW_KEY_F4,
  KeyboardKey.F5: GLFW_KEY_F5,
  KeyboardKey.F6: GLFW_KEY_F6,
  KeyboardKey.F7: GLFW_KEY_F7,
  KeyboardKey.F8: GLFW_KEY_F8,
  KeyboardKey.F9: GLFW_KEY_F9,
  KeyboardKey.F10: GLFW_KEY_F10,
  KeyboardKey.F11: GLFW_KEY_F11,
  KeyboardKey.F12: GLFW_KEY_F12,
  KeyboardKey.F13: GLFW_KEY_F13,
  KeyboardKey.F14: GLFW_KEY_F14,
  KeyboardKey.F15: GLFW_KEY_F15,
  KeyboardKey.F16: GLFW_KEY_F16,
  KeyboardKey.F17: GLFW_KEY_F17,
  KeyboardKey.F18: GLFW_KEY_F18,
  KeyboardKey.F19: GLFW_KEY_F19,
  KeyboardKey.F20: GLFW_KEY_F20,
  KeyboardKey.F21: GLFW_KEY_F21,
  KeyboardKey.F22: GLFW_KEY_F22,
  KeyboardKey.F23: GLFW_KEY_F23,
  KeyboardKey.F24: GLFW_KEY_F24,
  KeyboardKey.F25: GLFW_KEY_F25,
  KeyboardKey.Pad0: GLFW_KEY_KP_0,
  KeyboardKey.Pad1: GLFW_KEY_KP_1,
  KeyboardKey.Pad2: GLFW_KEY_KP_2,
  KeyboardKey.Pad3: GLFW_KEY_KP_3,
  KeyboardKey.Pad4: GLFW_KEY_KP_4,
  KeyboardKey.Pad5: GLFW_KEY_KP_5,
  KeyboardKey.Pad6: GLFW_KEY_KP_6,
  KeyboardKey.Pad7: GLFW_KEY_KP_7,
  KeyboardKey.Pad8: GLFW_KEY_KP_8,
  KeyboardKey.Pad9: GLFW_KEY_KP_9,
  KeyboardKey.PadDecimal: GLFW_KEY_KP_DECIMAL,
  KeyboardKey.PadDivide: GLFW_KEY_KP_DIVIDE,
  KeyboardKey.PadMultiply: GLFW_KEY_KP_MULTIPLY,
  KeyboardKey.PadSubtract: GLFW_KEY_KP_SUBTRACT,
  KeyboardKey.PadAdd: GLFW_KEY_KP_ADD,
  KeyboardKey.PadEnter: GLFW_KEY_KP_ENTER,
  KeyboardKey.PadEqual: GLFW_KEY_KP_EQUAL,
  KeyboardKey.LeftShift: GLFW_KEY_LEFT_SHIFT,
  KeyboardKey.LeftControl: GLFW_KEY_LEFT_CONTROL,
  KeyboardKey.LeftAlt: GLFW_KEY_LEFT_ALT,
  KeyboardKey.LeftSuper: GLFW_KEY_LEFT_SUPER,
  KeyboardKey.RightShift: GLFW_KEY_RIGHT_SHIFT,
  KeyboardKey.RightControl: GLFW_KEY_RIGHT_CONTROL,
  KeyboardKey.RightAlt: GLFW_KEY_RIGHT_ALT,
  KeyboardKey.RightSuper: GLFW_KEY_RIGHT_SUPER,
  KeyboardKey.Menu: GLFW_KEY_MENU,
}.toBiTable()

proc onClose(window: GLFWwindow) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.isOpen = false
  glfwDestroyWindow(window)

proc onMove(window: GLFWwindow, x: cint, y: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.bounds.x = x.float
  w.frameState.bounds.y = y.float

proc onResize(window: GLFWwindow, width: cint, height: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.bounds.width = width.float
  w.frameState.bounds.height = height.float

proc onFrameBufferResize(window: GLFWwindow, width: cint, height: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.frameBufferSize.x = width.float
  w.frameState.frameBufferSize.y = height.float

proc onFocus(window: GLFWwindow, focused: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  if focused == GLFW_TRUE:
    w.frameState.isFocused = true
  else:
    w.frameState.isFocused = false

proc onMouseButton(window: GLFWwindow, button: cint, action: cint, modifiers: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  if button >= 0 and button <= GLFW_MOUSE_BUTTON_LAST:
    let mouseButton = case button:
      of GLFW_MOUSE_BUTTON_LEFT: MouseButton.Left
      of GLFW_MOUSE_BUTTON_RIGHT: MouseButton.Right
      of GLFW_MOUSE_BUTTON_MIDDLE: MouseButton.Middle
      of GLFW_MOUSE_BUTTON_4: MouseButton.Extra1
      of GLFW_MOUSE_BUTTON_5: MouseButton.Extra2
      of GLFW_MOUSE_BUTTON_6: MouseButton.Extra3
      of GLFW_MOUSE_BUTTON_7: MouseButton.Extra4
      of GLFW_MOUSE_BUTTON_8: MouseButton.Extra5
      else: MouseButton.Unknown

    if action == GLFW_PRESS:
      w.frameState.mousePresses.add mouseButton
      w.frameState.mouseDown[mouseButton] = true

    elif action == GLFW_RELEASE:
      w.frameState.mouseReleases.add mouseButton
      w.frameState.mouseDown[mouseButton] = false

proc onCursorMove(window: GLFWwindow, x: cdouble, y: cdouble) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.mousePosition.x = x.float
  w.frameState.mousePosition.y = y.float

proc onCursorEnter(window: GLFWwindow, entered: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  if entered == GLFW_TRUE:
    w.frameState.isHovered = true
  else:
    w.frameState.isHovered = false

proc onScroll(window: GLFWwindow, xoffset: cdouble, yoffset: cdouble) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.mouseWheel.x += xoffset.float
  w.frameState.mouseWheel.y += yoffset.float

proc onKey(window: GLFWwindow, key: cint, scancode: cint, action: cint, modifiers: cint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  let keyboardKey = glfwKeyToKeyboardKey[key]

  if action == GLFW_PRESS:
    w.frameState.keyPresses.add keyboardKey
    w.frameState.keyDown[keyboardKey] = true

  elif action == GLFW_RELEASE:
    w.frameState.keyReleases.add keyboardKey
    w.frameState.keyDown[keyboardKey] = false

proc onChar(window: GLFWwindow, character: cuint) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.textInput &= cast[Rune](character).toUTF8

proc onDrop(window: GLFWwindow, count: cint, paths: cstringArray) {.cdecl.} =
  discard

proc newWindow*(): Window =
  result = Window()

  when defined(emscripten):
    # GL ES 2.0 + GLSL 100
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
  elif defined(macosx):
    # GL 3.2 + GLSL 150:
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE) # 3.2+ only
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE) # Required on Mac
  else:
    # GL 3.0 + GLSL 130
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  result.glfwWindow = glfwCreateWindow(1280, 720, "Window", nil, nil)
  if result.glfwWindow == nil:
    raise newException(Exception, "Failed to create window.")

  glfwMakeContextCurrent(result.glfwWindow)
  glfwSwapInterval(1)
  opengl.loadExtensions()

  var initialFrameState = FrameState()
  initialFrameState.time = glfwGetTime()
  initialFrameState.isFocused = true

  var xScale, yScale: cfloat
  glfwGetWindowContentScale(result.glfwWindow, xScale.addr, yScale.addr)
  initialFrameState.contentScale = vec2(xScale.float, yScale.float)

  var mouseX, mouseY: cdouble
  glfwGetCursorPos(result.glfwWindow, mouseX.addr, mouseY.addr)
  initialFrameState.mousePosition = vec2(mouseX.float, mouseY.float)

  var frameWidth, frameHeight: cint
  glfwGetFramebufferSize(result.glfwWindow, frameWidth.addr, frameHeight.addr)
  initialFrameState.frameBufferSize = vec2(frameWidth.float, frameHeight.float)

  var x, y: cint
  glfwGetWindowPos(result.glfwWindow, x.addr, y.addr)
  initialFrameState.bounds.x = x.float
  initialFrameState.bounds.y = y.float

  var width, height: cint
  glfwGetWindowSize(result.glfwWindow, width.addr, height.addr)
  initialFrameState.bounds.width = width.float
  initialFrameState.bounds.height = height.float

  result.frameState = initialFrameState
  result.previousFrameState = initialFrameState

  glfwSetWindowUserPointer(result.glfwWindow, result[].addr)
  glfwSetWindowCloseCallback(result.glfwWindow, onClose)
  glfwSetWindowPosCallback(result.glfwWindow, onMove)
  glfwSetWindowSizeCallback(result.glfwWindow, onResize)
  glfwSetFramebufferSizeCallback(result.glfwWindow, onFrameBufferResize)
  glfwSetWindowFocusCallback(result.glfwWindow, onFocus)
  glfwSetMouseButtonCallback(result.glfwWindow, onMouseButton)
  glfwSetCursorPosCallback(result.glfwWindow, onCursorMove)
  glfwSetCursorEnterCallback(result.glfwWindow, onCursorEnter)
  glfwSetScrollCallback(result.glfwWindow, onScroll)
  glfwSetKeyCallback(result.glfwWindow, onKey)
  glfwSetCharCallback(result.glfwWindow, onChar)
  glfwSetDropCallback(result.glfwWindow, onDrop)

  result.gfx = newGfx()
  result.isOpen = true

proc pollEvents*() =
  glfwPollEvents()

proc beginFrame*(window: Window) =
  if window.isOpen:
    glfwMakeContextCurrent(window.glfwWindow)

    let frameBufferSize = window.frameBufferSize
    glViewport(0.GLint, 0.GLint, frameBufferSize.x.GLsizei, frameBufferSize.y.GLsizei)
    glClear(GL_COLOR_BUFFER_BIT)

    window.gfx.beginFrame(window.frameBufferSize, window.contentScale.x)

proc endFrame*(window: Window) =
  if window.isOpen:
    window.gfx.endFrame()
    glfwSwapBuffers(window.glfwWindow)

    window.previousFrameState = window.frameState
    window.frameState.mouseWheel = vec2(0, 0)
    window.frameState.textInput = ""
    window.frameState.mousePresses.setLen(0)
    window.frameState.mouseReleases.setLen(0)
    window.frameState.keyPresses.setLen(0)
    window.frameState.keyReleases.setLen(0)
    window.frameState.time = glfwGetTime()

template processFrame*(window: Window, onFrame) =
  window.beginFrame()
  if window.isOpen:
    onFrame
  window.endFrame()

proc `backgroundColor=`*(window: Window, color: Color) =
  glfwMakeContextCurrent(window.glfwWindow)
  glClearColor(color.r, color.g, color.b, color.a)