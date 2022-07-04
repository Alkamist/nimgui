{.experimental: "overloadableEnums".}

import std/exitprocs
import std/unicode
import std/tables
import std/sequtils
import opengl
import ../glfw
import ./window; export window

proc glfwErrorCallback(errorCode: cint, description: cstring) {.cdecl.} =
  echo "Glfw Error " & $errorCode & ": " & $description

discard glfwSetErrorCallback(glfwErrorCallback)
if glfwInit() == 0:
  raise newException(Exception, "Failed to Initialize GLFW.")

addExitProc(proc() = glfwTerminate())

type
  WindowGlfw* = ref object of Window
    glfwWindow: GLFWwindow

proc toBiTable[K, V](entries: openArray[(K, V)]): (Table[K, V], Table[V, K]) =
  let reverseEntries = entries.mapIt((it[1], it[0]))
  result = (entries.toTable(), reverseEntries.toTable())

const (keyboardKeyToGlfwKey*, glfwKeyToKeyboardKey*) = {
  KeyboardKey.Unknown: GLFW_KEY_UNKNOWN.cint,
  KeyboardKey.Space: GLFW_KEY_SPACE.cint,
  KeyboardKey.Apostrophe: GLFW_KEY_APOSTROPHE.cint,
  KeyboardKey.Comma: GLFW_KEY_COMMA.cint,
  KeyboardKey.Minus: GLFW_KEY_MINUS.cint,
  KeyboardKey.Period: GLFW_KEY_PERIOD.cint,
  KeyboardKey.Slash: GLFW_KEY_SLASH.cint,
  KeyboardKey.Key0: GLFW_KEY_0.cint,
  KeyboardKey.Key1: GLFW_KEY_1.cint,
  KeyboardKey.Key2: GLFW_KEY_2.cint,
  KeyboardKey.Key3: GLFW_KEY_3.cint,
  KeyboardKey.Key4: GLFW_KEY_4.cint,
  KeyboardKey.Key5: GLFW_KEY_5.cint,
  KeyboardKey.Key6: GLFW_KEY_6.cint,
  KeyboardKey.Key7: GLFW_KEY_7.cint,
  KeyboardKey.Key8: GLFW_KEY_8.cint,
  KeyboardKey.Key9: GLFW_KEY_9.cint,
  KeyboardKey.Semicolon: GLFW_KEY_SEMICOLON.cint,
  KeyboardKey.Equal: GLFW_KEY_EQUAL.cint,
  KeyboardKey.A: GLFW_KEY_A.cint,
  KeyboardKey.B: GLFW_KEY_B.cint,
  KeyboardKey.C: GLFW_KEY_C.cint,
  KeyboardKey.D: GLFW_KEY_D.cint,
  KeyboardKey.E: GLFW_KEY_E.cint,
  KeyboardKey.F: GLFW_KEY_F.cint,
  KeyboardKey.G: GLFW_KEY_G.cint,
  KeyboardKey.H: GLFW_KEY_H.cint,
  KeyboardKey.I: GLFW_KEY_I.cint,
  KeyboardKey.J: GLFW_KEY_J.cint,
  KeyboardKey.K: GLFW_KEY_K.cint,
  KeyboardKey.L: GLFW_KEY_L.cint,
  KeyboardKey.M: GLFW_KEY_M.cint,
  KeyboardKey.N: GLFW_KEY_N.cint,
  KeyboardKey.O: GLFW_KEY_O.cint,
  KeyboardKey.P: GLFW_KEY_P.cint,
  KeyboardKey.Q: GLFW_KEY_Q.cint,
  KeyboardKey.R: GLFW_KEY_R.cint,
  KeyboardKey.S: GLFW_KEY_S.cint,
  KeyboardKey.T: GLFW_KEY_T.cint,
  KeyboardKey.U: GLFW_KEY_U.cint,
  KeyboardKey.V: GLFW_KEY_V.cint,
  KeyboardKey.W: GLFW_KEY_W.cint,
  KeyboardKey.X: GLFW_KEY_X.cint,
  KeyboardKey.Y: GLFW_KEY_Y.cint,
  KeyboardKey.Z: GLFW_KEY_Z.cint,
  KeyboardKey.LeftBracket: GLFW_KEY_LEFT_BRACKET.cint,
  KeyboardKey.Backslash: GLFW_KEY_BACKSLASH.cint,
  KeyboardKey.RightBracket: GLFW_KEY_RIGHT_BRACKET.cint,
  KeyboardKey.Backtick: GLFW_KEY_GRAVE_ACCENT.cint,
  KeyboardKey.World1: GLFW_KEY_WORLD_1.cint,
  KeyboardKey.World2: GLFW_KEY_WORLD_2.cint,
  KeyboardKey.Escape: GLFW_KEY_ESCAPE.cint,
  KeyboardKey.Enter: GLFW_KEY_ENTER.cint,
  KeyboardKey.Tab: GLFW_KEY_TAB.cint,
  KeyboardKey.Backspace: GLFW_KEY_BACKSPACE.cint,
  KeyboardKey.Insert: GLFW_KEY_INSERT.cint,
  KeyboardKey.Delete: GLFW_KEY_DELETE.cint,
  KeyboardKey.RightArrow: GLFW_KEY_RIGHT.cint,
  KeyboardKey.LeftArrow: GLFW_KEY_LEFT.cint,
  KeyboardKey.DownArrow: GLFW_KEY_DOWN.cint,
  KeyboardKey.UpArrow: GLFW_KEY_UP.cint,
  KeyboardKey.PageUp: GLFW_KEY_PAGE_UP.cint,
  KeyboardKey.PageDown: GLFW_KEY_PAGE_DOWN.cint,
  KeyboardKey.Home: GLFW_KEY_HOME.cint,
  KeyboardKey.End: GLFW_KEY_END.cint,
  KeyboardKey.CapsLock: GLFW_KEY_CAPS_LOCK.cint,
  KeyboardKey.ScrollLock: GLFW_KEY_SCROLL_LOCK.cint,
  KeyboardKey.NumLock: GLFW_KEY_NUM_LOCK.cint,
  KeyboardKey.PrintScreen: GLFW_KEY_PRINT_SCREEN.cint,
  KeyboardKey.Pause: GLFW_KEY_PAUSE.cint,
  KeyboardKey.F1: GLFW_KEY_F1.cint,
  KeyboardKey.F2: GLFW_KEY_F2.cint,
  KeyboardKey.F3: GLFW_KEY_F3.cint,
  KeyboardKey.F4: GLFW_KEY_F4.cint,
  KeyboardKey.F5: GLFW_KEY_F5.cint,
  KeyboardKey.F6: GLFW_KEY_F6.cint,
  KeyboardKey.F7: GLFW_KEY_F7.cint,
  KeyboardKey.F8: GLFW_KEY_F8.cint,
  KeyboardKey.F9: GLFW_KEY_F9.cint,
  KeyboardKey.F10: GLFW_KEY_F10.cint,
  KeyboardKey.F11: GLFW_KEY_F11.cint,
  KeyboardKey.F12: GLFW_KEY_F12.cint,
  KeyboardKey.F13: GLFW_KEY_F13.cint,
  KeyboardKey.F14: GLFW_KEY_F14.cint,
  KeyboardKey.F15: GLFW_KEY_F15.cint,
  KeyboardKey.F16: GLFW_KEY_F16.cint,
  KeyboardKey.F17: GLFW_KEY_F17.cint,
  KeyboardKey.F18: GLFW_KEY_F18.cint,
  KeyboardKey.F19: GLFW_KEY_F19.cint,
  KeyboardKey.F20: GLFW_KEY_F20.cint,
  KeyboardKey.F21: GLFW_KEY_F21.cint,
  KeyboardKey.F22: GLFW_KEY_F22.cint,
  KeyboardKey.F23: GLFW_KEY_F23.cint,
  KeyboardKey.F24: GLFW_KEY_F24.cint,
  KeyboardKey.F25: GLFW_KEY_F25.cint,
  KeyboardKey.Pad0: GLFW_KEY_KP_0.cint,
  KeyboardKey.Pad1: GLFW_KEY_KP_1.cint,
  KeyboardKey.Pad2: GLFW_KEY_KP_2.cint,
  KeyboardKey.Pad3: GLFW_KEY_KP_3.cint,
  KeyboardKey.Pad4: GLFW_KEY_KP_4.cint,
  KeyboardKey.Pad5: GLFW_KEY_KP_5.cint,
  KeyboardKey.Pad6: GLFW_KEY_KP_6.cint,
  KeyboardKey.Pad7: GLFW_KEY_KP_7.cint,
  KeyboardKey.Pad8: GLFW_KEY_KP_8.cint,
  KeyboardKey.Pad9: GLFW_KEY_KP_9.cint,
  KeyboardKey.PadDecimal: GLFW_KEY_KP_DECIMAL.cint,
  KeyboardKey.PadDivide: GLFW_KEY_KP_DIVIDE.cint,
  KeyboardKey.PadMultiply: GLFW_KEY_KP_MULTIPLY.cint,
  KeyboardKey.PadSubtract: GLFW_KEY_KP_SUBTRACT.cint,
  KeyboardKey.PadAdd: GLFW_KEY_KP_ADD.cint,
  KeyboardKey.PadEnter: GLFW_KEY_KP_ENTER.cint,
  KeyboardKey.PadEqual: GLFW_KEY_KP_EQUAL.cint,
  KeyboardKey.LeftShift: GLFW_KEY_LEFT_SHIFT.cint,
  KeyboardKey.LeftControl: GLFW_KEY_LEFT_CONTROL.cint,
  KeyboardKey.LeftAlt: GLFW_KEY_LEFT_ALT.cint,
  KeyboardKey.LeftSuper: GLFW_KEY_LEFT_SUPER.cint,
  KeyboardKey.RightShift: GLFW_KEY_RIGHT_SHIFT.cint,
  KeyboardKey.RightControl: GLFW_KEY_RIGHT_CONTROL.cint,
  KeyboardKey.RightAlt: GLFW_KEY_RIGHT_ALT.cint,
  KeyboardKey.RightSuper: GLFW_KEY_RIGHT_SUPER.cint,
  KeyboardKey.Menu: GLFW_KEY_MENU.cint,
}.toBiTable()

const (mouseButtonToGlfwMouseButton*, glfwMouseButtonToMouseButton*) = {
  MouseButton.Left: GLFW_MOUSE_BUTTON_LEFT.cint,
  MouseButton.Right: GLFW_MOUSE_BUTTON_RIGHT.cint,
  MouseButton.Middle: GLFW_MOUSE_BUTTON_MIDDLE.cint,
  MouseButton.Extra1: GLFW_MOUSE_BUTTON_4.cint,
  MouseButton.Extra2: GLFW_MOUSE_BUTTON_5.cint,
  MouseButton.Extra3: GLFW_MOUSE_BUTTON_6.cint,
  MouseButton.Extra4: GLFW_MOUSE_BUTTON_7.cint,
  MouseButton.Extra5: GLFW_MOUSE_BUTTON_8.cint,
}.toBiTable()

template glfwWindow(window: Window): GLFWwindow =
  cast[WindowGlfw](window).glfwWindow

proc pollEvents*() =
  glfwPollEvents()

proc makeContextCurrent*(window: Window) =
  glfwMakeContextCurrent(window.glfwWindow)

proc clipboard*(window: Window): string =
  $glfwGetClipboardString(window.glfwWindow)

proc `clipboard=`*(window: Window, text: string) =
  glfwSetClipboardString(window.glfwWindow, text.cstring)

proc `position=`*(window: Window, position: Vec2) =
  glfwSetWindowPos(window.glfwWindow, position.x.round.cint, position.y.round.cint)

proc updateFrameState(window: Window) =
  window.frameState.time = glfwGetTime()

  var xScale, yScale: cfloat
  glfwGetWindowContentScale(window.glfwWindow, xScale.addr, yScale.addr)
  window.frameState.contentScale = xScale.float

  var mouseX, mouseY: cdouble
  glfwGetCursorPos(window.glfwWindow, mouseX.addr, mouseY.addr)
  window.frameState.mousePosition = vec2(mouseX.float, mouseY.float)

  var frameWidth, frameHeight: cint
  glfwGetFramebufferSize(window.glfwWindow, frameWidth.addr, frameHeight.addr)
  window.frameState.frameBufferSize = vec2(frameWidth.float, frameHeight.float)

  var x, y: cint
  glfwGetWindowPos(window.glfwWindow, x.addr, y.addr)
  window.frameState.bounds.x = x.float
  window.frameState.bounds.y = y.float

  var width, height: cint
  glfwGetWindowSize(window.glfwWindow, width.addr, height.addr)
  window.frameState.bounds.width = width.float
  window.frameState.bounds.height = height.float

  for button in MouseButton:
    if button != Unknown:
      window.frameState.mouseDown[button] = glfwGetMouseButton(window.glfwWindow, mouseButtonToGlfwMouseButton[button]) == GLFW_TRUE

  for key in KeyboardKey:
    if key != Unknown:
      window.frameState.keyDown[key] = glfwGetKey(window.glfwWindow, keyboardKeyToGlfwKey[key]) == GLFW_TRUE

# proc handleDragAndResize(window: Window) =
#   if window.mousePressed(Left):
#     window.grabPosition = window.mousePosition
#     window.grabbed = true

#   if window.grabbed:
#     let delta = window.mousePosition - window.grabPosition
#     if delta != vec2(0, 0):
#       window.position = window.position + delta

#   if window.mouseReleased(Left):
#     window.grabbed = false

proc update*(window: Window) =
  let window = cast[WindowGlfw](window)
  if window.exists:
    # window.handleDragAndResize()

    window.makeContextCurrent()

    let frameBufferSize = window.frameBufferSize
    glViewport(0.GLint, 0.GLint, frameBufferSize.x.GLsizei, frameBufferSize.y.GLsizei)

    let bg = window.backgroundColor
    glClearColor(bg.r, bg.g, bg.b, bg.a)
    glClear(GL_COLOR_BUFFER_BIT)

    window.gfx.beginFrame(window.frameBufferSize, window.contentScale)

    if window.onFrame != nil:
      window.onFrame()

    window.gfx.endFrame()

    glfwSwapBuffers(window.glfwWindow)

    window.previousFrameState = window.frameState
    window.clearAccumulators()

proc onClose(window: GLFWwindow) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.frameState.exists = false
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
  if glfwMouseButtonToMouseButton.contains(button):
    let mouseButton = glfwMouseButtonToMouseButton[button]
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
  if glfwKeyToKeyboardKey.contains(key):
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

proc onRefresh(window: GLFWwindow) {.cdecl.} =
  let w = cast[Window](glfwGetWindowUserPointer(window))
  w.update()

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

  # glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE)
  # glfwWindowHint(GLFW_DECORATED, GLFW_FALSE)

  cast[WindowGlfw](result).glfwWindow = glfwCreateWindow(1280, 720, "Window", nil, nil)
  if result.glfwWindow == nil:
    raise newException(Exception, "Failed to create window.")

  glfwMakeContextCurrent(result.glfwWindow)
  glfwSwapInterval(1)
  opengl.loadExtensions()

  result.updateFrameState()
  result.previousFrameState = result.frameState
  result.frameState.exists = true

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
  glfwSetWindowRefreshCallback(result.glfwWindow, onRefresh)

  result.gfx = newGfx()