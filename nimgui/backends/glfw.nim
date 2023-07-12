import std/unicode
import std/exitprocs
import std/tables
import ../gui
import staticglfw as glfw
import opengl

if glfw.init() == 0:
  raise newException(Exception, "Failed to initialize GLFW.")

addExitProc(proc() = glfw.terminate())

var cursors = {
  Arrow: glfw.createStandardCursor(cint(glfw.ARROW_CURSOR)),
  IBeam: glfw.createStandardCursor(cint(glfw.IBEAM_CURSOR)),
  Crosshair: glfw.createStandardCursor(cint(glfw.CROSSHAIR_CURSOR)),
  PointingHand: glfw.createStandardCursor(cint(glfw.HAND_CURSOR)),
  ResizeLeftRight: glfw.createStandardCursor(cint(glfw.HRESIZE_CURSOR)),
  ResizeTopBottom: glfw.createStandardCursor(cint(glfw.VRESIZE_CURSOR)),

  # GLFW doesn't provide these so they would have to be
  # loaded from each OS manually or created from scratch.
  ResizeTopLeftBottomRight: glfw.createStandardCursor(cint(glfw.CROSSHAIR_CURSOR)),
  ResizeTopRightBottomLeft: glfw.createStandardCursor(cint(glfw.CROSSHAIR_CURSOR)),
}.toTable()

proc toMouseButton*(glfwButton: cint): MouseButton =
  case glfwButton:
  of glfw.MOUSE_BUTTON_1: result = MouseButton.Left
  of glfw.MOUSE_BUTTON_2: result = MouseButton.Right
  of glfw.MOUSE_BUTTON_3: result = MouseButton.Middle
  of glfw.MOUSE_BUTTON_4: result = MouseButton.Extra1
  of glfw.MOUSE_BUTTON_5: result = MouseButton.Extra2
  else: discard

proc toKeyboardKey*(glfwKey: cint): KeyboardKey =
  case glfwKey:
  of glfw.KEY_SPACE: KeyboardKey.Space
  of glfw.KEY_APOSTROPHE: KeyboardKey.Quote
  of glfw.KEY_COMMA: KeyboardKey.Comma
  of glfw.KEY_MINUS: KeyboardKey.Minus
  of glfw.KEY_PERIOD: KeyboardKey.Period
  of glfw.KEY_SLASH: KeyboardKey.Slash
  of glfw.KEY_0: KeyboardKey.Key0
  of glfw.KEY_1: KeyboardKey.Key1
  of glfw.KEY_2: KeyboardKey.Key2
  of glfw.KEY_3: KeyboardKey.Key3
  of glfw.KEY_4: KeyboardKey.Key4
  of glfw.KEY_5: KeyboardKey.Key5
  of glfw.KEY_6: KeyboardKey.Key6
  of glfw.KEY_7: KeyboardKey.Key7
  of glfw.KEY_8: KeyboardKey.Key8
  of glfw.KEY_9: KeyboardKey.Key9
  of glfw.KEY_SEMICOLON: KeyboardKey.Semicolon
  of glfw.KEY_EQUAL: KeyboardKey.Equal
  of glfw.KEY_A: KeyboardKey.A
  of glfw.KEY_B: KeyboardKey.B
  of glfw.KEY_C: KeyboardKey.C
  of glfw.KEY_D: KeyboardKey.D
  of glfw.KEY_E: KeyboardKey.E
  of glfw.KEY_F: KeyboardKey.F
  of glfw.KEY_G: KeyboardKey.G
  of glfw.KEY_H: KeyboardKey.H
  of glfw.KEY_I: KeyboardKey.I
  of glfw.KEY_J: KeyboardKey.J
  of glfw.KEY_K: KeyboardKey.K
  of glfw.KEY_L: KeyboardKey.L
  of glfw.KEY_M: KeyboardKey.M
  of glfw.KEY_N: KeyboardKey.N
  of glfw.KEY_O: KeyboardKey.O
  of glfw.KEY_P: KeyboardKey.P
  of glfw.KEY_Q: KeyboardKey.Q
  of glfw.KEY_R: KeyboardKey.R
  of glfw.KEY_S: KeyboardKey.S
  of glfw.KEY_T: KeyboardKey.T
  of glfw.KEY_U: KeyboardKey.U
  of glfw.KEY_V: KeyboardKey.V
  of glfw.KEY_W: KeyboardKey.W
  of glfw.KEY_X: KeyboardKey.X
  of glfw.KEY_Y: KeyboardKey.Y
  of glfw.KEY_Z: KeyboardKey.Z
  of glfw.KEY_LEFT_BRACKET: KeyboardKey.LeftBracket
  of glfw.KEY_BACKSLASH: KeyboardKey.Backslash
  of glfw.KEY_RIGHT_BRACKET: KeyboardKey.RightBracket
  of glfw.KEY_GRAVE_ACCENT: KeyboardKey.Backtick
  # of glfw.KEY_WORLD_1: KeyboardKey.World1
  # of glfw.KEY_WORLD_2: KeyboardKey.World2
  of glfw.KEY_ESCAPE: KeyboardKey.Escape
  of glfw.KEY_ENTER: KeyboardKey.Enter
  of glfw.KEY_TAB: KeyboardKey.Tab
  of glfw.KEY_BACKSPACE: KeyboardKey.Backspace
  of glfw.KEY_INSERT: KeyboardKey.Insert
  of glfw.KEY_DELETE: KeyboardKey.Delete
  of glfw.KEY_RIGHT: KeyboardKey.RightArrow
  of glfw.KEY_LEFT: KeyboardKey.LeftArrow
  of glfw.KEY_DOWN: KeyboardKey.DownArrow
  of glfw.KEY_UP: KeyboardKey.UpArrow
  of glfw.KEY_PAGE_UP: KeyboardKey.PageUp
  of glfw.KEY_PAGE_DOWN: KeyboardKey.PageDown
  of glfw.KEY_HOME: KeyboardKey.Home
  of glfw.KEY_END: KeyboardKey.End
  of glfw.KEY_CAPS_LOCK: KeyboardKey.CapsLock
  of glfw.KEY_SCROLL_LOCK: KeyboardKey.ScrollLock
  of glfw.KEY_NUM_LOCK: KeyboardKey.NumLock
  of glfw.KEY_PRINT_SCREEN: KeyboardKey.PrintScreen
  of glfw.KEY_PAUSE: KeyboardKey.Pause
  of glfw.KEY_F1: KeyboardKey.F1
  of glfw.KEY_F2: KeyboardKey.F2
  of glfw.KEY_F3: KeyboardKey.F3
  of glfw.KEY_F4: KeyboardKey.F4
  of glfw.KEY_F5: KeyboardKey.F5
  of glfw.KEY_F6: KeyboardKey.F6
  of glfw.KEY_F7: KeyboardKey.F7
  of glfw.KEY_F8: KeyboardKey.F8
  of glfw.KEY_F9: KeyboardKey.F9
  of glfw.KEY_F10: KeyboardKey.F10
  of glfw.KEY_F11: KeyboardKey.F11
  of glfw.KEY_F12: KeyboardKey.F12
  # of glfw.KEY_F13: KeyboardKey.F13
  # of glfw.KEY_F14: KeyboardKey.F14
  # of glfw.KEY_F15: KeyboardKey.F15
  # of glfw.KEY_F16: KeyboardKey.F16
  # of glfw.KEY_F17: KeyboardKey.F17
  # of glfw.KEY_F18: KeyboardKey.F18
  # of glfw.KEY_F19: KeyboardKey.F19
  # of glfw.KEY_F20: KeyboardKey.F20
  # of glfw.KEY_F21: KeyboardKey.F21
  # of glfw.KEY_F22: KeyboardKey.F22
  # of glfw.KEY_F23: KeyboardKey.F23
  # of glfw.KEY_F24: KeyboardKey.F24
  # of glfw.KEY_F25: KeyboardKey.F25
  of glfw.KEY_KP_0: KeyboardKey.Pad0
  of glfw.KEY_KP_1: KeyboardKey.Pad1
  of glfw.KEY_KP_2: KeyboardKey.Pad2
  of glfw.KEY_KP_3: KeyboardKey.Pad3
  of glfw.KEY_KP_4: KeyboardKey.Pad4
  of glfw.KEY_KP_5: KeyboardKey.Pad5
  of glfw.KEY_KP_6: KeyboardKey.Pad6
  of glfw.KEY_KP_7: KeyboardKey.Pad7
  of glfw.KEY_KP_8: KeyboardKey.Pad8
  of glfw.KEY_KP_9: KeyboardKey.Pad9
  of glfw.KEY_KP_DECIMAL: KeyboardKey.PadPeriod
  of glfw.KEY_KP_DIVIDE: KeyboardKey.PadDivide
  of glfw.KEY_KP_MULTIPLY: KeyboardKey.PadMultiply
  of glfw.KEY_KP_SUBTRACT: KeyboardKey.PadSubtract
  of glfw.KEY_KP_ADD: KeyboardKey.PadAdd
  of glfw.KEY_KP_ENTER: KeyboardKey.PadEnter
  # of glfw.KEY_KP_EQUAL: KeyboardKey.PadEqual
  of glfw.KEY_LEFT_SHIFT: KeyboardKey.LeftShift
  of glfw.KEY_LEFT_CONTROL: KeyboardKey.LeftControl
  of glfw.KEY_LEFT_ALT: KeyboardKey.LeftAlt
  of glfw.KEY_LEFT_SUPER: KeyboardKey.LeftMeta
  of glfw.KEY_RIGHT_SHIFT: KeyboardKey.RightShift
  of glfw.KEY_RIGHT_CONTROL: KeyboardKey.RightControl
  of glfw.KEY_RIGHT_ALT: KeyboardKey.RightAlt
  of glfw.KEY_RIGHT_SUPER: KeyboardKey.RightMeta
  # of glfw.KEY_MENU: KeyboardKey.Menu
  else: KeyboardKey.Unknown

proc glfwWindow(gui: Gui): glfw.Window =
  cast[glfw.Window](gui.backendData)

proc updateCursorStyle(gui: Gui) =
  glfw.setCursor(gui.glfwWindow, cursors[gui.cursorStyle])

proc closeRequested*(gui: Gui): bool =
  glfw.windowShouldClose(gui.glfwWindow) == glfw.TRUE

proc makeContextCurrent*(gui: Gui) =
  glfw.makeContextCurrent(gui.glfwWindow)

proc pollEvents*(gui: Gui) =
  glfw.pollEvents()

proc swapBuffers*(gui: Gui) =
  glfw.swapBuffers(gui.glfwWindow)

proc show*(gui: Gui) =
  glfw.showWindow(gui.glfwWindow)

proc hide*(gui: Gui) =
  glfw.hideWindow(gui.glfwWindow)

proc close*(gui: Gui) =
  glfw.setWindowShouldClose(gui.glfwWindow, 1)

proc processFrame*(gui: Gui) =
  gui.inputTime(glfw.getTime())

  var scaleX, scaleY: cfloat
  glfw.getWindowContentScale(gui.glfwWindow, addr(scaleX), addr(scaleY))
  gui.inputContentScale(scaleX)

  if not gui.closeRequested:
    gui.clear()

  if gui.onFrame != nil:
    gui.onFrame(gui)
  if gui.isHovered:
    gui.updateCursorStyle()

proc run*(gui: Gui) =
  while true:
    gui.pollEvents()
    if gui.closeRequested:
      return
    gui.makeContextCurrent()
    gui.processFrame()
    gui.swapBuffers()

proc setupBackend*(gui: Gui) =
  glfw.windowHint(glfw.VISIBLE, glfw.FALSE)

  let window = glfw.createWindow(800, 600, "", nil, nil)
  gui.backendData = cast[pointer](window)
  glfw.setWindowUserPointer(window, cast[pointer](gui))

  var scaleX, scaleY: cfloat
  glfw.getWindowContentScale(window, addr(scaleX), addr(scaleY))
  gui.inputContentScale(scaleX)

  var width, height: cint
  glfw.getWindowSize(window, addr(width), addr(height))
  gui.inputSize(float(width), float(height))

  gui.makeContextCurrent()
  opengl.loadExtensions()

  gui.setupVectorGraphics()

  discard glfw.setWindowCloseCallback(window, proc(window: glfw.Window) {.cdecl.} =
    glfw.destroyWindow(window)
  )

  discard glfw.setWindowSizeCallback(window, proc(window: glfw.Window, width, height: cint) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    gui.inputSize(float(width), float(height))
  )

  discard glfw.setCursorPosCallback(window, proc(window: glfw.Window, x, y: cdouble) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    gui.inputMouseMove(x, y)
    gui.updateCursorStyle()
  )

  discard glfw.setCursorEnterCallback(window, proc(window: glfw.Window, entered: cint) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    if entered == glfw.TRUE:
      gui.inputMouseEnter()
    else:
      gui.inputMouseExit()
  )

  discard glfw.setMouseButtonCallback(window, proc(window: glfw.Window, button, action, modifiers: cint) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    let button = button.toMouseButton
    if action == glfw.PRESS:
      gui.inputMousePress(button)
    if action == glfw.RELEASE:
      gui.inputMouseRelease(button)
  )

  discard glfw.setScrollCallback(window, proc (window: glfw.Window, xoffset, yoffset: cdouble) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    gui.inputMouseWheel(xoffset, yoffset)
  )

  discard glfw.setKeyCallback(window, proc(window: glfw.Window, key, scancode, action, modifiers: cint) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    let key = key.toKeyboardKey
    if action == glfw.PRESS:
      gui.inputKeyPress(key)
    if action == glfw.RELEASE:
      gui.inputKeyRelease(key)
  )

  discard glfw.setCharCallback(window, proc (window: Window, character: cuint) {.cdecl.} =
    let gui = cast[Gui](glfw.getWindowUserPointer(window))
    gui.inputText(Rune(character).toUTF8)
  )