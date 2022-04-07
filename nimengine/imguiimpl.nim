import std/times
import ./imgui
import ./client

var FLT_MAX {.importc, nodecl.}: cfloat

type
  BackendData = ref object
    time: float
    installedCallbacks: bool
    client: Client
    mouseClient: Client
    lastValidMouseX: float
    lastValidMouseY: float
    previousOnFocus: proc(client: Client)
    previousOnLoseFocus: proc(client: Client)
    previousOnMouseMove: proc(client: Client)
    previousOnMouseEnter: proc(client: Client)
    previousOnMouseExit: proc(client: Client)
    previousOnMousePress: proc(client: Client)
    previousOnMouseRelease: proc(client: Client)
    previousOnMouseWheel: proc(client: Client)
    previousOnKeyPress: proc(client: Client)
    previousOnKeyRelease: proc(client: Client)
    previousOnCharacter: proc(client: Client)

var bd = BackendData()

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

proc ImGui_OnMousePress(client: Client) =
  if bd.previousOnMousePress != nil and client == bd.client:
    bd.previousOnMousePress(client)

  let button = client.mousePress.toImGuiMouseButton
  if button >= 0 and button < ImGuiMouseButton_COUNT:
    var io = ImGui_GetIO()
    io.AddMouseButtonEvent(button, true)

proc ImGui_OnMouseRelease(client: Client) =
  if bd.previousOnMouseRelease != nil and client == bd.client:
    bd.previousOnMouseRelease(client)

  let button = client.mousePress.toImGuiMouseButton
  if button >= 0 and button < ImGuiMouseButton_COUNT:
    var io = ImGui_GetIO()
    io.AddMouseButtonEvent(button, false)

proc ImGui_OnMouseWheel(client: Client) =
  if bd.previousOnMouseWheel != nil and client == bd.client:
    bd.previousOnMouseWheel(client)

  var io = ImGui_GetIO()
  io.AddMouseWheelEvent(client.mouseWheelX.cfloat, client.mouseWheelY.cfloat)

proc ImGui_OnKeyPress(client: Client) =
  if bd.previousOnKeyPress != nil and client == bd.client:
    bd.previousOnKeyPress(client)

  var io = ImGui_GetIO()
  var imguiKey = client.keyPress.toImguiKey
  io.AddKeyEvent(imguiKey, true)

proc ImGui_OnKeyRelease(client: Client) =
  if bd.previousOnKeyRelease != nil and client == bd.client:
    bd.previousOnKeyRelease(client)

  var io = ImGui_GetIO()
  var imguiKey = client.keyRelease.toImguiKey
  io.AddKeyEvent(imguiKey, false)

proc ImGui_OnFocus(client: Client) =
  if bd.previousOnFocus != nil and client == bd.client:
    bd.previousOnFocus(client)

  var io = ImGui_GetIO()
  io.AddFocusEvent(true)

proc ImGui_OnLoseFocus(client: Client) =
  if bd.previousOnLoseFocus != nil and client == bd.client:
    bd.previousOnLoseFocus(client)

  var io = ImGui_GetIO()
  io.AddFocusEvent(false)

proc ImGui_OnMouseMove(client: Client) =
  if bd.previousOnMouseMove != nil and client == bd.client:
    bd.previousOnMouseMove(client)

  var io = ImGui_GetIO()
  io.AddMousePosEvent(client.mouseX.cfloat, client.mouseY.cfloat)

  bd.lastValidMouseX = client.mouseX
  bd.lastValidMouseY = client.mouseY

proc ImGui_OnMouseEnter(client: Client) =
  if bd.previousOnMouseEnter != nil and client == bd.client:
    bd.previousOnMouseEnter(client)

  bd.mouseClient = client

  var io = ImGui_GetIO()
  io.AddMousePosEvent(bd.lastValidMouseX.cfloat, bd.lastValidMouseY.cfloat)

proc ImGui_OnMouseExit(client: Client) =
  if bd.previousOnMouseExit != nil and client == bd.client:
    bd.previousOnMouseExit(client)

  if client == bd.mouseClient:
    bd.mouseClient = nil
    bd.lastValidMouseX = client.mouseX
    bd.lastValidMouseY = client.mouseY
    var io = ImGui_GetIO()
    io.AddMousePosEvent(-FLT_MAX, -FLT_MAX)

proc ImGui_OnCharacter(client: Client) =
  if bd.previousOnCharacter != nil and client == bd.client:
    bd.previousOnCharacter(client)

  var io = ImGui_GetIO()
  io.AddInputCharactersUTF8(client.character.cstring)

proc installCallbacks(client: Client) =
  assert(bd.installedCallbacks == false, "Callbacks are already installed.")
  assert(client == bd.client)

  bd.previousOnFocus = client.onFocus
  bd.previousOnLoseFocus = client.onLoseFocus
  bd.previousOnMouseMove = client.onMouseMove
  bd.previousOnMouseEnter = client.onMouseEnter
  bd.previousOnMouseExit = client.onMouseExit
  bd.previousOnMousePress = client.onMousePress
  bd.previousOnMouseRelease = client.onMouseRelease
  bd.previousOnMouseWheel = client.onMouseWheel
  bd.previousOnKeyPress = client.onKeyPress
  bd.previousOnKeyRelease = client.onKeyRelease
  bd.previousOnCharacter = client.onCharacter

  client.onFocus = ImGui_OnFocus
  client.onLoseFocus = ImGui_OnLoseFocus
  client.onMouseMove = ImGui_OnMouseMove
  client.onMouseEnter = ImGui_OnMouseEnter
  client.onMouseExit = ImGui_OnMouseExit
  client.onMousePress = ImGui_OnMousePress
  client.onMouseRelease = ImGui_OnMouseRelease
  client.onMouseWheel = ImGui_OnMouseWheel
  client.onKeyPress = ImGui_OnKeyPress
  client.onKeyRelease = ImGui_OnKeyRelease
  client.onCharacter = ImGui_OnCharacter

  bd.installedCallbacks = true

proc restoreCallbacks(client: Client) =
  assert(bd.installedCallbacks == true, "Callbacks are not installed.")
  assert(client == bd.client)

  client.onFocus = bd.previousOnFocus
  client.onLoseFocus = bd.previousOnLoseFocus
  client.onMouseMove = bd.previousOnMouseMove
  client.onMouseEnter = bd.previousOnMouseEnter
  client.onMouseExit = bd.previousOnMouseExit
  client.onMousePress = bd.previousOnMousePress
  client.onMouseRelease = bd.previousOnMouseRelease
  client.onMouseWheel = bd.previousOnMouseWheel
  client.onKeyPress = bd.previousOnKeyPress
  client.onKeyRelease = bd.previousOnKeyRelease
  client.onCharacter = bd.previousOnCharacter

  bd.previousOnFocus = nil
  bd.previousOnLoseFocus = nil
  bd.previousOnMouseMove = nil
  bd.previousOnMouseEnter = nil
  bd.previousOnMouseExit = nil
  bd.previousOnMousePress = nil
  bd.previousOnMouseRelease = nil
  bd.previousOnMouseWheel = nil
  bd.previousOnKeyPress = nil
  bd.previousOnKeyRelease = nil
  bd.previousOnCharacter = nil

  bd.installedCallbacks = false

proc ImGui_ImplClient_Init*(client: Client) =
  var io = ImGui_GetIO()
  assert(io.BackendPlatformUserData == nil, "A platform backend is already initialized.")

  io.BackendPlatformUserData = bd.addr
  io.BackendPlatformName = "nim_client_backend"

  bd.client = client
  bd.time = 0.0

  client.installCallbacks()

proc ImGui_ImplClient_Shutdown*() =
  assert(bd != nil, "No platform backend to shutdown, or already shutdown?")
  var io = ImGui_GetIO()

  if bd.installedCallbacks:
    bd.client.restoreCallbacks()

  io.BackendPlatformName = nil
  io.BackendPlatformUserData = nil

proc ImGui_ImplClient_NewFrame*() =
  var io = ImGui_GetIO()
  assert(bd != nil, "ImGui has not been initialized for Client.")

  # Setup display size every frame to accommodate for window resizing.
  let w = bd.client.width
  let h = bd.client.height
  # let displayW = bd.client.widthPixels
  # let displayH = bd.client.heightPixels
  let displayW = bd.client.width
  let displayH = bd.client.height
  io.DisplaySize = ImVec2.init(w.cfloat, h.cfloat)
  if w > 0 and h > 0:
    io.DisplayFramebufferScale = ImVec2.init(displayW.cfloat / w.cfloat, displayH.cfloat / h.cfloat)

  # Setup time step.
  let currentTime = cpuTime()

  if currentTime > bd.time:
    io.DeltaTime = (currentTime - bd.time).cfloat
  else:
    io.DeltaTime = (1.0 / 60.0).cfloat

  bd.time = currentTime