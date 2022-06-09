import opengl
import std/unicode
import ./imgui
import ./input

var FLT_MAX {.importc, nodecl.}: cfloat

type
  Font* = ptr ImFont

  Gui* = ref object
    input*: Input
    mouseExitPosition*: Vec2

proc getClipboardText(user_data: pointer): cstring {.cdecl.} =
  var input = cast[Input](user_data)
  input.clipboard.cstring

proc setClipboardText(user_data: pointer, text: cstring) {.cdecl.} =
  var input = cast[Input](user_data)
  input.clipboard = $text

proc setDefaultStyle() =
  var style = ImGui_GetStyle()
  style.Alpha = 1.0
  style.DisabledAlpha = 0.6
  style.WindowPadding = imVec2(8, 8)
  style.WindowRounding = 5.0
  style.WindowBorderSize = 1.0
  style.WindowMinSize = imVec2(32, 32)
  style.WindowTitleAlign = imVec2(0.5, 0.5)
  style.WindowMenuButtonPosition = ImGuiDir_Left
  style.ChildRounding = 5.0
  style.ChildBorderSize = 1.0
  style.PopupRounding = 5.0
  style.PopupBorderSize = 1.0
  style.FramePadding = imVec2(4, 3)
  style.FrameRounding = 2.0
  style.FrameBorderSize = 0.0
  style.ItemSpacing = imVec2(8, 4)
  style.ItemInnerSpacing = imVec2(4, 4)
  style.CellPadding = imVec2(4, 2)
  style.TouchExtraPadding = imVec2(0, 0)
  style.IndentSpacing = 21.0
  style.ColumnsMinSpacing = 6.0
  style.ScrollbarSize = 14.0
  style.ScrollbarRounding = 2.0
  style.GrabMinSize = 10.0
  style.GrabRounding = 2.0
  style.LogSliderDeadzone = 4.0
  style.TabRounding = 4.0
  style.TabBorderSize = 0.0
  style.TabMinWidthForCloseButton = 0.0
  style.ColorButtonPosition = ImGuiDir_Right
  style.ButtonTextAlign = imVec2(0.5, 0.5)
  style.SelectableTextAlign = imVec2(0.0, 0.0)
  style.DisplayWindowPadding = imVec2(19, 19)
  style.DisplaySafeAreaPadding = imVec2(3, 3)
  style.MouseCursorScale = 1.0
  style.AntiAliasedLines = true
  style.AntiAliasedLinesUseTex = true
  style.AntiAliasedFill = true
  style.CurveTessellationTol = 1.25
  style.CircleTessellationMaxError = 0.3

  style.Colors[ImGuiCol_Text] = imVec4(1.0, 1.0, 1.0, 0.87)
  style.Colors[ImGuiCol_TextDisabled] = imVec4(0.55, 0.58, 0.62, 1.0)
  style.Colors[ImGuiCol_WindowBg] = imVec4(0.05, 0.066, 0.09, 1.0)
  style.Colors[ImGuiCol_ChildBg] = imVec4(0.0, 0.0, 0.0, 0.0)
  style.Colors[ImGuiCol_PopupBg] = imVec4(0.05, 0.066, 0.09, 1.0)
  style.Colors[ImGuiCol_Border] = imVec4(0.99, 1.0, 1.0, 0.11)
  style.Colors[ImGuiCol_BorderShadow] = imVec4(0.0, 0.0, 0.0, 0.0)
  style.Colors[ImGuiCol_FrameBg] = imVec4(1.0, 1.0, 1.0, 0.07)
  style.Colors[ImGuiCol_FrameBgHovered] = imVec4(1.0, 1.0, 1.0, 0.09)
  style.Colors[ImGuiCol_FrameBgActive] = imVec4(1.0, 1.0, 1.0, 0.15)
  style.Colors[ImGuiCol_TitleBg] = imVec4(0.1, 0.13, 0.15, 1.0)
  style.Colors[ImGuiCol_TitleBgActive] = imVec4(0.1, 0.13, 0.15, 1.0)
  style.Colors[ImGuiCol_TitleBgCollapsed] = imVec4(0.06, 0.08, 0.09, 1.0)
  style.Colors[ImGuiCol_MenuBarBg] = imVec4(1.0, 1.0, 1.0, 0.02)
  style.Colors[ImGuiCol_ScrollbarBg] = imVec4(0.0, 0.0, 0.0, 0.0)
  style.Colors[ImGuiCol_ScrollbarGrab] = imVec4(1.0, 1.0, 1.0, 0.10)
  style.Colors[ImGuiCol_ScrollbarGrabHovered] = imVec4(1.0, 1.0, 1.0, 0.16)
  style.Colors[ImGuiCol_ScrollbarGrabActive] = imVec4(1.0, 1.0, 1.0, 0.23)
  style.Colors[ImGuiCol_CheckMark] = imVec4(1.0, 1.0, 1.0, 0.74)
  style.Colors[ImGuiCol_SliderGrab] = imVec4(1.0, 1.0, 1.0, 0.2)
  style.Colors[ImGuiCol_SliderGrabActive] = imVec4(1.0, 1.0, 1.0, 0.2)
  style.Colors[ImGuiCol_Button] = imVec4(1.0, 1.0, 1.0, 0.2)
  style.Colors[ImGuiCol_ButtonHovered] = imVec4(1.0, 1.0, 1.0, 0.31)
  style.Colors[ImGuiCol_ButtonActive] = imVec4(1.0, 1.0, 1.0, 0.39)
  style.Colors[ImGuiCol_Header] = imVec4(1.0, 1.0, 1.0, 0.17)
  style.Colors[ImGuiCol_HeaderHovered] = imVec4(1.0, 1.0, 1.0, 0.24)
  style.Colors[ImGuiCol_HeaderActive] = imVec4(1.0, 1.0, 1.0, 0.33)
  style.Colors[ImGuiCol_Separator] = imVec4(1.0, 1.0, 1.0, 0.11)
  style.Colors[ImGuiCol_SeparatorHovered] = imVec4(1.0, 1.0, 1.0, 0.18)
  style.Colors[ImGuiCol_SeparatorActive] = imVec4(1.0, 1.0, 1.0, 0.24)
  style.Colors[ImGuiCol_ResizeGrip] = imVec4(1.0, 1.0, 1.0, 0.11)
  style.Colors[ImGuiCol_ResizeGripHovered] = imVec4(1.0, 1.0, 1.0, 0.18)
  style.Colors[ImGuiCol_ResizeGripActive] = imVec4(0.99, 1.0, 1.0, 0.24)
  style.Colors[ImGuiCol_Tab] = imVec4(1.0, 1.0, 1.0, 0.17)
  style.Colors[ImGuiCol_TabHovered] = imVec4(1.0, 1.0, 1.0, 0.24)
  style.Colors[ImGuiCol_TabActive] = imVec4(1.0, 1.0, 1.0, 0.33)
  style.Colors[ImGuiCol_TabUnfocused] = imVec4(1.0, 1.0, 1.0, 0.07)
  style.Colors[ImGuiCol_TabUnfocusedActive] = imVec4(0.99, 1.0, 1.0, 0.13)
  style.Colors[ImGuiCol_PlotLines] = imVec4(0.9, 0.7, 0.14, 1.0)
  style.Colors[ImGuiCol_PlotLinesHovered] = imVec4(0.94, 0.4, 0.18, 1.0)
  style.Colors[ImGuiCol_PlotHistogram] = imVec4(0.9, 0.7, 0.14, 1.0)
  style.Colors[ImGuiCol_PlotHistogramHovered] = imVec4(0.94, 0.4, 0.18, 1.0)
  style.Colors[ImGuiCol_TableHeaderBg] = imVec4(1.0, 1.0, 1.0, 0.09)
  style.Colors[ImGuiCol_TableBorderStrong] = imVec4(1.0, 1.0, 1.0, 0.11)
  style.Colors[ImGuiCol_TableBorderLight] = imVec4(1.0, 1.0, 1.0, 0.11)
  style.Colors[ImGuiCol_TableRowBg] = imVec4(1.0, 1.0, 1.0, 0.0)
  style.Colors[ImGuiCol_TableRowBgAlt] = imVec4(1.0, 1.0, 1.0, 0.02)
  style.Colors[ImGuiCol_TextSelectedBg] = imVec4(0.47, 0.25, 0.15, 1.0)
  style.Colors[ImGuiCol_DragDropTarget] = imVec4(1.0, 1.0, 0.0, 0.9)
  style.Colors[ImGuiCol_NavHighlight] = imVec4(0.26, 0.59, 0.98, 1.0)
  style.Colors[ImGuiCol_NavWindowingHighlight] = imVec4(1.0, 1.0, 1.0, 0.7)
  style.Colors[ImGuiCol_NavWindowingDimBg] = imVec4(0.8, 0.8, 0.8, 0.2)
  style.Colors[ImGuiCol_ModalWindowDimBg] = imVec4(0.8, 0.8, 0.8, 0.35)

proc `=destroy`*(gui: var type Gui()[]) =
  ImGui_ImplOpenGL3_Shutdown()
  ImGui_DestroyContext()

proc newGui*(input: Input): Gui =
  result = Gui(input: input)
  ImGui_CreateContext()
  ImGui_ImplOpenGL3_Init("#version 100")
  setDefaultStyle()
  var io = ImGui_GetIO()
  io.GetClipboardTextFn = getClipboardText
  io.SetClipboardTextFn = setClipboardText
  io.ClipboardUserData = cast[pointer](result.input)

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

  io.AddKeyEvent(ImGuiKey_ModCtrl, input.keyDown(LeftControl) or input.keyDown(RightControl))
  io.AddKeyEvent(ImGuiKey_ModShift, input.keyDown(LeftShift) or input.keyDown(RightShift))
  io.AddKeyEvent(ImGuiKey_ModAlt, input.keyDown(LeftAlt) or input.keyDown(RightAlt))
  io.AddKeyEvent(ImGuiKey_ModSuper, input.keyDown(LeftMeta) or input.keyDown(RightMeta))

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

proc addFont*(gui: Gui, data: string, size: float): Font =
  var io = ImGui_GetIO()
  io.Fonts.AddFontFromMemoryTTF(data[0].unsafeAddr, data.len.cint + 1, size)