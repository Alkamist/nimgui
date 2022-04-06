import std/strutils

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.passC: "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1".}
{.passC: "-I" & currentSourceDir() & "/imgui".}

when defined(linux):
  {.passL: "-Xlinker -rpath .".}
elif defined(windows):
  {.passL: "-ldwmapi -lgdi32".}

{.compile: "imgui/imgui.cpp",
  compile: "imgui/imgui_draw.cpp",
  compile: "imgui/imgui_tables.cpp",
  compile: "imgui/imgui_widgets.cpp",
  compile: "imgui/imgui_demo.cpp",
  compile: "imgui/backends/imgui_impl_win32.cpp",
  compile: "imgui/backends/imgui_impl_opengl3.cpp".}

const imguiHeader = currentSourceDir() & "/imgui/imgui.h"
const imguiImplWin32Header = currentSourceDir() & "/imgui/backends/imgui_impl_win32.h"
const imguiImplOpenGl3Header = currentSourceDir() & "/imgui/backends/imgui_impl_opengl3.h"

const ImGuiMouseButton_Left* = 0.cint
const ImGuiMouseButton_Right* = 1.cint
const ImGuiMouseButton_Middle* = 2.cint
const ImGuiMouseButton_COUNT* = 5.cint

type
  ImGuiContext* {.importc, header: imguiHeader.} = object

  ImGuiIO* {.importc, header: imguiHeader.} = object
    DisplaySize*: ImVec2
    DeltaTime*: cfloat
    DisplayFramebufferScale*: ImVec2
    BackendPlatformName*: cstring
    BackendPlatformUserData*: pointer
    AddKeyEvent*: proc(key: ImGuiKey, down: bool) {.cdecl.}
    AddMousePosEvent*: proc(x, y: cfloat) {.cdecl.}
    AddMouseButtonEvent*: proc(button: cint, down: bool) {.cdecl.}
    AddMouseWheelEvent*: proc(wh_x, wh_y: cfloat) {.cdecl.}
    AddFocusEvent*: proc(focused: bool) {.cdecl.}
    AddInputCharactersUTF8*: proc(str: cstring) {.cdecl.}

  ImFontAtlas* {.importc, header: imguiHeader.} = object
  ImDrawData* {.importc, header: imguiHeader.} = object

  ImVec2* {.importc, header: imguiHeader.} = object
    x*, y*: cfloat

  ImGuiKey* {.size: sizeof(cint).} = enum
    ImGuiKey_None = 0,
    ImGuiKey_Tab = 512,
    ImGuiKey_LeftArrow,
    ImGuiKey_RightArrow,
    ImGuiKey_UpArrow,
    ImGuiKey_DownArrow,
    ImGuiKey_PageUp,
    ImGuiKey_PageDown,
    ImGuiKey_Home,
    ImGuiKey_End,
    ImGuiKey_Insert,
    ImGuiKey_Delete,
    ImGuiKey_Backspace,
    ImGuiKey_Space,
    ImGuiKey_Enter,
    ImGuiKey_Escape,
    ImGuiKey_LeftCtrl, ImGuiKey_LeftShift, ImGuiKey_LeftAlt, ImGuiKey_LeftSuper,
    ImGuiKey_RightCtrl, ImGuiKey_RightShift, ImGuiKey_RightAlt, ImGuiKey_RightSuper,
    ImGuiKey_Menu,
    ImGuiKey_0, ImGuiKey_1, ImGuiKey_2, ImGuiKey_3, ImGuiKey_4, ImGuiKey_5, ImGuiKey_6, ImGuiKey_7, ImGuiKey_8, ImGuiKey_9,
    ImGuiKey_A, ImGuiKey_B, ImGuiKey_C, ImGuiKey_D, ImGuiKey_E, ImGuiKey_F, ImGuiKey_G, ImGuiKey_H, ImGuiKey_I, ImGuiKey_J,
    ImGuiKey_K, ImGuiKey_L, ImGuiKey_M, ImGuiKey_N, ImGuiKey_O, ImGuiKey_P, ImGuiKey_Q, ImGuiKey_R, ImGuiKey_S, ImGuiKey_T,
    ImGuiKey_U, ImGuiKey_V, ImGuiKey_W, ImGuiKey_X, ImGuiKey_Y, ImGuiKey_Z,
    ImGuiKey_F1, ImGuiKey_F2, ImGuiKey_F3, ImGuiKey_F4, ImGuiKey_F5, ImGuiKey_F6,
    ImGuiKey_F7, ImGuiKey_F8, ImGuiKey_F9, ImGuiKey_F10, ImGuiKey_F11, ImGuiKey_F12,
    ImGuiKey_Apostrophe,
    ImGuiKey_Comma,
    ImGuiKey_Minus,
    ImGuiKey_Period,
    ImGuiKey_Slash,
    ImGuiKey_Semicolon,
    ImGuiKey_Equal,
    ImGuiKey_LeftBracket,
    ImGuiKey_Backslash,
    ImGuiKey_RightBracket,
    ImGuiKey_GraveAccent,
    ImGuiKey_CapsLock,
    ImGuiKey_ScrollLock,
    ImGuiKey_NumLock,
    ImGuiKey_PrintScreen,
    ImGuiKey_Pause,
    ImGuiKey_Keypad0, ImGuiKey_Keypad1, ImGuiKey_Keypad2, ImGuiKey_Keypad3, ImGuiKey_Keypad4,
    ImGuiKey_Keypad5, ImGuiKey_Keypad6, ImGuiKey_Keypad7, ImGuiKey_Keypad8, ImGuiKey_Keypad9,
    ImGuiKey_KeypadDecimal,
    ImGuiKey_KeypadDivide,
    ImGuiKey_KeypadMultiply,
    ImGuiKey_KeypadSubtract,
    ImGuiKey_KeypadAdd,
    ImGuiKey_KeypadEnter,
    ImGuiKey_KeypadEqual,
    ImGuiKey_GamepadStart,
    ImGuiKey_GamepadBack,
    ImGuiKey_GamepadFaceUp,
    ImGuiKey_GamepadFaceDown,
    ImGuiKey_GamepadFaceLeft,
    ImGuiKey_GamepadFaceRight,
    ImGuiKey_GamepadDpadUp,
    ImGuiKey_GamepadDpadDown,
    ImGuiKey_GamepadDpadLeft,
    ImGuiKey_GamepadDpadRight,
    ImGuiKey_GamepadL1,
    ImGuiKey_GamepadR1,
    ImGuiKey_GamepadL2,
    ImGuiKey_GamepadR2,
    ImGuiKey_GamepadL3,
    ImGuiKey_GamepadR3,
    ImGuiKey_GamepadLStickUp,
    ImGuiKey_GamepadLStickDown,
    ImGuiKey_GamepadLStickLeft,
    ImGuiKey_GamepadLStickRight,
    ImGuiKey_GamepadRStickUp,
    ImGuiKey_GamepadRStickDown,
    ImGuiKey_GamepadRStickLeft,
    ImGuiKey_GamepadRStickRight,
    ImGuiKey_ModCtrl, ImGuiKey_ModShift, ImGuiKey_ModAlt, ImGuiKey_ModSuper,
    ImGuiKey_COUNT,

proc init*(_: type ImVec2, x, y: cfloat): ImVec2 {.importc: "ImVec2", header: imguiHeader.}

{.push discardable.}

proc ImGui_CreateContext*(shared_font_atlas: ptr ImFontAtlas = nil): ptr ImGuiContext {.importc: "ImGui::CreateContext", header: imguiHeader.}
proc ImGui_DestroyContext*(ctx: ptr ImGuiContext = nil) {.importc: "ImGui::DestroyContext", header: imguiHeader.}
proc ImGui_GetCurrentContext*(): ptr ImGuiContext {.importc: "ImGui::GetCurrentContext", header: imguiHeader.}
proc ImGui_Text*(fmt: cstring) {.importc: "ImGui::Text", header: imguiHeader, varargs.}
proc ImGui_Render*() {.importc: "ImGui::Render", header: imguiHeader.}
proc ImGui_GetDrawData*(): ptr ImDrawData {.importc: "ImGui::GetDrawData", header: imguiHeader.}
proc ImGui_NewFrame*() {.importc: "ImGui::NewFrame", header: imguiHeader.}
proc ImGui_GetIO*(): ptr ImGuiIO {.importc: "&ImGui::GetIO", header: imguiHeader.}
proc ImGui_Button*(label: cstring, size = ImVec2.init(0, 0)): bool {.importc: "ImGui::Button", header: imguiHeader.}

proc ImGui_ImplWin32_Init*(hwnd: pointer): bool {.importc, header: imguiImplWin32Header.}
proc ImGui_ImplWin32_Shutdown*() {.importc, header: imguiImplWin32Header.}
proc ImGui_ImplWin32_NewFrame*() {.importc, header: imguiImplWin32Header.}

proc ImGui_ImplOpenGL3_Init*(glsl_version: cstring = nil): bool {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_Shutdown*() {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_NewFrame*() {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_RenderDrawData*(draw_data: ptr ImDrawData) {.importc, header: imguiImplOpenGl3Header.}

{.pop.}