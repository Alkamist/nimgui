import opengl
import std/unicode
import ./imgui
import ./input

var FLT_MAX {.importc, nodecl.}: cfloat

type
  Gui* = ref object
    input*: Input
    mouseExitPosition*: Vec2

proc `=destroy`*(gui: var type Gui()[]) =
  ImGui_ImplOpenGL3_Shutdown()
  ImGui_DestroyContext()

func newGui*(input: Input): Gui =
  ImGui_CreateContext()
  ImGui_ImplOpenGL3_Init("#version 100")
  Gui(input: input)

func toImVec2(v: Vec2): ImVec2 =
  imVec2(v.x, v.y)

func toImGuiMouseButton(button: MouseButton): cint =
  case button:
  of MouseButton.Left: ImGuiMouseButton_Left
  of MouseButton.Right: ImGuiMouseButton_Right
  of MouseButton.Middle: ImGuiMouseButton_Middle
  of MouseButton.Extra1: 3
  of MouseButton.Extra2: 4
  else: ImGuiMouseButton_COUNT

func toImGuiKey(key: KeyboardKey): ImGuiKey =
  case key:
  of KeyboardKey.Tab: ImGuiKey_Tab
  of KeyboardKey.LeftArrow: ImGuiKey_LeftArrow
  of KeyboardKey.RightArrow: ImGuiKey_RightArrow
  of KeyboardKey.UpArrow: ImGuiKey_UpArrow
  of KeyboardKey.DownArrow: ImGuiKey_DownArrow
  of KeyboardKey.PageUp: ImGuiKey_PageUp
  of KeyboardKey.PageDown: ImGuiKey_PageDown
  of KeyboardKey.Home: ImGuiKey_Home
  of KeyboardKey.End: ImGuiKey_End
  of KeyboardKey.Insert: ImGuiKey_Insert
  of KeyboardKey.Delete: ImGuiKey_Delete
  of KeyboardKey.Backspace: ImGuiKey_Backspace
  of KeyboardKey.Space: ImGuiKey_Space
  of KeyboardKey.Enter: ImGuiKey_Enter
  of KeyboardKey.Escape: ImGuiKey_Escape
  of KeyboardKey.Quote: ImGuiKey_Apostrophe
  of KeyboardKey.Comma: ImGuiKey_Comma
  of KeyboardKey.Minus: ImGuiKey_Minus
  of KeyboardKey.Period: ImGuiKey_Period
  of KeyboardKey.Slash: ImGuiKey_Slash
  of KeyboardKey.Semicolon: ImGuiKey_Semicolon
  of KeyboardKey.Equal: ImGuiKey_Equal
  of KeyboardKey.LeftBracket: ImGuiKey_LeftBracket
  of KeyboardKey.Backslash: ImGuiKey_Backslash
  of KeyboardKey.RightBracket: ImGuiKey_RightBracket
  of KeyboardKey.Backtick: ImGuiKey_GraveAccent
  of KeyboardKey.CapsLock: ImGuiKey_CapsLock
  of KeyboardKey.ScrollLock: ImGuiKey_ScrollLock
  of KeyboardKey.NumLock: ImGuiKey_NumLock
  of KeyboardKey.Pause: ImGuiKey_Pause
  of KeyboardKey.Pad0: ImGuiKey_Keypad0
  of KeyboardKey.Pad1: ImGuiKey_Keypad1
  of KeyboardKey.Pad2: ImGuiKey_Keypad2
  of KeyboardKey.Pad3: ImGuiKey_Keypad3
  of KeyboardKey.Pad4: ImGuiKey_Keypad4
  of KeyboardKey.Pad5: ImGuiKey_Keypad5
  of KeyboardKey.Pad6: ImGuiKey_Keypad6
  of KeyboardKey.Pad7: ImGuiKey_Keypad7
  of KeyboardKey.Pad8: ImGuiKey_Keypad8
  of KeyboardKey.Pad9: ImGuiKey_Keypad9
  of KeyboardKey.PadPeriod: ImGuiKey_KeypadDecimal
  of KeyboardKey.PadDivide: ImGuiKey_KeypadDivide
  of KeyboardKey.PadMultiply: ImGuiKey_KeypadMultiply
  of KeyboardKey.PadSubtract: ImGuiKey_KeypadSubtract
  of KeyboardKey.PadAdd: ImGuiKey_KeypadAdd
  of KeyboardKey.PadEnter: ImGuiKey_KeypadEnter
  of KeyboardKey.LeftShift: ImGuiKey_LeftShift
  of KeyboardKey.LeftControl: ImGuiKey_LeftCtrl
  of KeyboardKey.LeftAlt: ImGuiKey_LeftAlt
  of KeyboardKey.LeftMeta: ImGuiKey_LeftSuper
  of KeyboardKey.RightShift: ImGuiKey_RightShift
  of KeyboardKey.RightControl: ImGuiKey_RightCtrl
  of KeyboardKey.RightAlt: ImGuiKey_RightAlt
  of KeyboardKey.RightMeta: ImGuiKey_RightSuper
  of KeyboardKey.Key0: ImGuiKey_0
  of KeyboardKey.Key1: ImGuiKey_1
  of KeyboardKey.Key2: ImGuiKey_2
  of KeyboardKey.Key3: ImGuiKey_3
  of KeyboardKey.Key4: ImGuiKey_4
  of KeyboardKey.Key5: ImGuiKey_5
  of KeyboardKey.Key6: ImGuiKey_6
  of KeyboardKey.Key7: ImGuiKey_7
  of KeyboardKey.Key8: ImGuiKey_8
  of KeyboardKey.Key9: ImGuiKey_9
  of KeyboardKey.A: ImGuiKey_A
  of KeyboardKey.B: ImGuiKey_B
  of KeyboardKey.C: ImGuiKey_C
  of KeyboardKey.D: ImGuiKey_D
  of KeyboardKey.E: ImGuiKey_E
  of KeyboardKey.F: ImGuiKey_F
  of KeyboardKey.G: ImGuiKey_G
  of KeyboardKey.H: ImGuiKey_H
  of KeyboardKey.I: ImGuiKey_I
  of KeyboardKey.J: ImGuiKey_J
  of KeyboardKey.K: ImGuiKey_K
  of KeyboardKey.L: ImGuiKey_L
  of KeyboardKey.M: ImGuiKey_M
  of KeyboardKey.N: ImGuiKey_N
  of KeyboardKey.O: ImGuiKey_O
  of KeyboardKey.P: ImGuiKey_P
  of KeyboardKey.Q: ImGuiKey_Q
  of KeyboardKey.R: ImGuiKey_R
  of KeyboardKey.S: ImGuiKey_S
  of KeyboardKey.T: ImGuiKey_T
  of KeyboardKey.U: ImGuiKey_U
  of KeyboardKey.V: ImGuiKey_V
  of KeyboardKey.W: ImGuiKey_W
  of KeyboardKey.X: ImGuiKey_X
  of KeyboardKey.Y: ImGuiKey_Y
  of KeyboardKey.Z: ImGuiKey_Z
  of KeyboardKey.F1: ImGuiKey_F1
  of KeyboardKey.F2: ImGuiKey_F2
  of KeyboardKey.F3: ImGuiKey_F3
  of KeyboardKey.F4: ImGuiKey_F4
  of KeyboardKey.F5: ImGuiKey_F5
  of KeyboardKey.F6: ImGuiKey_F6
  of KeyboardKey.F7: ImGuiKey_F7
  of KeyboardKey.F8: ImGuiKey_F8
  of KeyboardKey.F9: ImGuiKey_F9
  of KeyboardKey.F10: ImGuiKey_F10
  of KeyboardKey.F11: ImGuiKey_F11
  of KeyboardKey.F12: ImGuiKey_F12
  else: ImGuiKey_None

proc beginFrame*(gui: Gui) =
  let input = gui.input
  var io = ImGui_GetIO()

  io.DisplaySize = input.size.toImVec2

  if input.size.x > 0 and input.size.y > 0:
    let pixelDensity = input.pixelDensity
    io.DisplayFramebufferScale = imVec2(pixelDensity, pixelDensity)

  if input.deltaTime > 0:
    io.DeltaTime = input.deltaTime
  else:
    io.DeltaTime = 1.0 / 60.0

  if input.gainedFocus:
    io.AddFocusEvent(true)
  elif input.lostFocus:
    io.AddFocusEvent(false)

  if input.mouseMoved:
    io.AddMousePosEvent(input.mousePosition.x, input.mousePosition.y)

  if input.mouseEntered:
    io.AddMousePosEvent(gui.mouseExitPosition.x, gui.mouseExitPosition.y)

  if input.mouseExited:
    gui.mouseExitPosition = input.mousePosition
    io.AddMousePosEvent(-FLT_MAX, -FLT_MAX)

  for button in input.mousePresses:
    let imguiButton = button.toImGuiMouseButton
    if imguiButton >= 0 and imguiButton < ImGuiMouseButton_COUNT:
      io.AddMouseButtonEvent(imguiButton, true)

  for button in input.mouseReleases:
    let imguiButton = button.toImGuiMouseButton
    if imguiButton >= 0 and imguiButton < ImGuiMouseButton_COUNT:
      io.AddMouseButtonEvent(imguiButton, false)

  if input.mouseWheelMoved:
    io.AddMouseWheelEvent(input.mouseWheel.x, input.mouseWheel.y)

  for key in input.keyPresses:
    io.AddKeyEvent(key.toImGuiKey, true)

  for key in input.keyReleases:
    io.AddKeyEvent(key.toImGuiKey, false)

  if input.text != "":
    for rune in input.text.runes:
      io.AddInputCharactersUTF8(rune.toUTF8.cstring)

  ImGui_ImplOpenGL3_NewFrame()
  ImGui_NewFrame()

  var showDemoWindow = true
  ImGui_ShowDemoWindow(showDemoWindow.addr)

proc endFrame*(gui: Gui) =
  let input = gui.input
  let sizePixels = input.size * input.pixelDensity
  glViewport(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
  ImGui_Render()
  ImGui_ImplOpenGL3_RenderDrawData(ImGui_GetDrawData())