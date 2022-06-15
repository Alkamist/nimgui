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
  compile: "imgui/backends/imgui_impl_opengl3.cpp".}

const imguiHeader = currentSourceDir() & "/imgui/imgui.h"
const imguiImplOpenGl3Header = currentSourceDir() & "/imgui/backends/imgui_impl_opengl3.h"

const ImGuiMouseButton_Left* = 0.cint
const ImGuiMouseButton_Right* = 1.cint
const ImGuiMouseButton_Middle* = 2.cint
const ImGuiMouseButton_COUNT* = 5.cint

type
  ImGuiContext* {.importc, header: imguiHeader.} = object

  ImGuiConfigFlags* {.size: sizeof(cint).} = enum
    ImGuiConfigFlags_None = 0
    ImGuiConfigFlags_NavEnableKeyboard = 1 shl 0
    ImGuiConfigFlags_NavEnableGamepad = 1 shl 1
    ImGuiConfigFlags_NavEnableSetMousePos = 1 shl 2
    ImGuiConfigFlags_NavNoCaptureKeyboard = 1 shl 3
    ImGuiConfigFlags_NoMouse = 1 shl 4
    ImGuiConfigFlags_NoMouseCursorChange = 1 shl 5
    ImGuiConfigFlags_DockingEnable = 1 shl 6
    ImGuiConfigFlags_ViewportsEnable = 1 shl 10
    ImGuiConfigFlags_DpiEnableScaleViewports = 1 shl 14
    ImGuiConfigFlags_DpiEnableScaleFonts = 1 shl 15
    ImGuiConfigFlags_IsSRGB = 1 shl 20
    ImGuiConfigFlags_IsTouchScreen = 1 shl 21

  ImGuiIO* {.importc, header: imguiHeader.} = object
    ConfigFlags*: ImGuiConfigFlags
    DisplaySize*: ImVec2
    DeltaTime*: cfloat
    Fonts*: ptr ImFontAtlas
    FontGlobalScale*: cfloat
    FontAllowUserScaling*: bool
    DisplayFramebufferScale*: ImVec2
    BackendPlatformName*: cstring
    BackendPlatformUserData*: pointer
    GetClipboardTextFn*: proc(user_data: pointer): cstring {.cdecl.}
    SetClipboardTextFn*: proc(user_data: pointer, text: cstring) {.cdecl.}
    ClipboardUserData*: pointer
    AddKeyEvent*: proc(key: ImGuiKey, down: bool) {.cdecl.}
    AddMousePosEvent*: proc(x, y: cfloat) {.cdecl.}
    AddMouseButtonEvent*: proc(button: cint, down: bool) {.cdecl.}
    AddMouseWheelEvent*: proc(wh_x, wh_y: cfloat) {.cdecl.}
    AddFocusEvent*: proc(focused: bool) {.cdecl.}
    AddInputCharactersUTF8*: proc(str: cstring) {.cdecl.}

  ImFontConfig* {.importc, header: imguiHeader.} = object
    FontData*: pointer
    FontDataSize*: cint
    FontDataOwnedByAtlas*: bool
    FontNo*: cint
    SizePixels*: cfloat
    OversampleH*: cint
    OversampleV*: cint
    PixelSnapH*: bool
    GlyphExtraSpacing*: ImVec2
    GlyphOffset*: ImVec2
    GlyphRanges*: ptr ImWchar
    GlyphMinAdvanceX*: cfloat
    GlyphMaxAdvanceX*: cfloat
    MergeMode*: bool
    FontBuilderFlags*: cuint
    RasterizerMultiply*: cfloat
    EllipsisChar*: ImWchar

  ImWchar* {.importc, header: imguiHeader.} = cushort

  ImFont* {.importc, header: imguiHeader.} = object
  ImFontAtlas* {.importc, header: imguiHeader.} = object
  ImDrawData* {.importc, header: imguiHeader.} = object

  ImVec2* {.importc, header: imguiHeader.} = object
    x*, y*: cfloat

  ImVec4* {.importc, header: imguiHeader.} = object
    x*, y*, z*, w*: cfloat

  ImGuiDir* {.size: sizeof(cint).} = enum
    ImGuiDir_None = -1
    ImGuiDir_Left = 0
    ImGuiDir_Right = 1
    ImGuiDir_Up = 2
    ImGuiDir_Down = 3
    ImGuiDir_COUNT

  ImGuiCol* {.size: sizeof(cint).} = enum
    ImGuiCol_Text
    ImGuiCol_TextDisabled
    ImGuiCol_WindowBg
    ImGuiCol_ChildBg
    ImGuiCol_PopupBg
    ImGuiCol_Border
    ImGuiCol_BorderShadow
    ImGuiCol_FrameBg
    ImGuiCol_FrameBgHovered
    ImGuiCol_FrameBgActive
    ImGuiCol_TitleBg
    ImGuiCol_TitleBgActive
    ImGuiCol_TitleBgCollapsed
    ImGuiCol_MenuBarBg
    ImGuiCol_ScrollbarBg
    ImGuiCol_ScrollbarGrab
    ImGuiCol_ScrollbarGrabHovered
    ImGuiCol_ScrollbarGrabActive
    ImGuiCol_CheckMark
    ImGuiCol_SliderGrab
    ImGuiCol_SliderGrabActive
    ImGuiCol_Button
    ImGuiCol_ButtonHovered
    ImGuiCol_ButtonActive
    ImGuiCol_Header
    ImGuiCol_HeaderHovered
    ImGuiCol_HeaderActive
    ImGuiCol_Separator
    ImGuiCol_SeparatorHovered
    ImGuiCol_SeparatorActive
    ImGuiCol_ResizeGrip
    ImGuiCol_ResizeGripHovered
    ImGuiCol_ResizeGripActive
    ImGuiCol_Tab
    ImGuiCol_TabHovered
    ImGuiCol_TabActive
    ImGuiCol_TabUnfocused
    ImGuiCol_TabUnfocusedActive
    ImGuiCol_PlotLines
    ImGuiCol_PlotLinesHovered
    ImGuiCol_PlotHistogram
    ImGuiCol_PlotHistogramHovered
    ImGuiCol_TableHeaderBg
    ImGuiCol_TableBorderStrong
    ImGuiCol_TableBorderLight
    ImGuiCol_TableRowBg
    ImGuiCol_TableRowBgAlt
    ImGuiCol_TextSelectedBg
    ImGuiCol_DragDropTarget
    ImGuiCol_NavHighlight
    ImGuiCol_NavWindowingHighlight
    ImGuiCol_NavWindowingDimBg
    ImGuiCol_ModalWindowDimBg
    ImGuiCol_COUNT

  ImGuiStyle* {.importc, header: imguiHeader.} = object
    Alpha*: cfloat
    DisabledAlpha*: cfloat
    WindowPadding*: ImVec2
    WindowRounding*: cfloat
    WindowBorderSize*: cfloat
    WindowMinSize*: ImVec2
    WindowTitleAlign*: ImVec2
    WindowMenuButtonPosition*: ImGuiDir
    ChildRounding*: cfloat
    ChildBorderSize*: cfloat
    PopupRounding*: cfloat
    PopupBorderSize*: cfloat
    FramePadding*: ImVec2
    FrameRounding*: cfloat
    FrameBorderSize*: cfloat
    ItemSpacing*: ImVec2
    ItemInnerSpacing*: ImVec2
    CellPadding*: ImVec2
    TouchExtraPadding*: ImVec2
    IndentSpacing*: cfloat
    ColumnsMinSpacing*: cfloat
    ScrollbarSize*: cfloat
    ScrollbarRounding*: cfloat
    GrabMinSize*: cfloat
    GrabRounding*: cfloat
    LogSliderDeadzone*: cfloat
    TabRounding*: cfloat
    TabBorderSize*: cfloat
    TabMinWidthForCloseButton*: cfloat
    ColorButtonPosition*: ImGuiDir
    ButtonTextAlign*: ImVec2
    SelectableTextAlign*: ImVec2
    DisplayWindowPadding*: ImVec2
    DisplaySafeAreaPadding*: ImVec2
    MouseCursorScale*: cfloat
    AntiAliasedLines*: bool
    AntiAliasedLinesUseTex*: bool
    AntiAliasedFill*: bool
    CurveTessellationTol*: cfloat
    CircleTessellationMaxError*: cfloat
    Colors*: array[ImGuiCol_COUNT, ImVec4]

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

  ImGuiWindowFlags* {.size: sizeof(cint).} = enum
    ImGuiWindowFlags_None = 0
    ImGuiWindowFlags_NoTitleBar = 1 shl 0
    ImGuiWindowFlags_NoResize = 1 shl 1
    ImGuiWindowFlags_NoMove = 1 shl 2
    ImGuiWindowFlags_NoScrollbar = 1 shl 3
    ImGuiWindowFlags_NoScrollWithMouse = 1 shl 4
    ImGuiWindowFlags_NoCollapse = 1 shl 5
    ImGuiWindowFlags_AlwaysAutoResize = 1 shl 6
    ImGuiWindowFlags_NoBackground = 1 shl 7
    ImGuiWindowFlags_NoSavedSettings = 1 shl 8
    ImGuiWindowFlags_NoMouseInputs = 1 shl 9
    ImGuiWindowFlags_MenuBar = 1 shl 10
    ImGuiWindowFlags_HorizontalScrollbar = 1 shl 11
    ImGuiWindowFlags_NoFocusOnAppearing = 1 shl 12
    ImGuiWindowFlags_NoBringToFrontOnFocus = 1 shl 13
    ImGuiWindowFlags_AlwaysVerticalScrollbar = 1 shl 14
    ImGuiWindowFlags_AlwaysHorizontalScrollbar = 1 shl 15
    ImGuiWindowFlags_AlwaysUseWindowPadding = 1 shl 16
    ImGuiWindowFlags_NoNavInputs = 1 shl 18
    ImGuiWindowFlags_NoNavFocus = 1 shl 19
    ImGuiWindowFlags_UnsavedDocument = 1 shl 20
    ImGuiWindowFlags_NavFlattened = 1 shl 23

proc imVec2*(x, y: cfloat): ImVec2 {.importc: "ImVec2", header: imguiHeader.}
proc imVec4*(x, y, z, w: cfloat): ImVec4 {.importc: "ImVec4", header: imguiHeader.}

{.push discardable.}

proc ImGui_ShowDemoWindow*(p_open: ptr bool = nil) {.importc: "ImGui::ShowDemoWindow", header: imguiHeader.}

proc ImGui_CreateContext*(shared_font_atlas: ptr ImFontAtlas = nil): ptr ImGuiContext {.importc: "ImGui::CreateContext", header: imguiHeader.}
proc ImGui_DestroyContext*(ctx: ptr ImGuiContext = nil) {.importc: "ImGui::DestroyContext", header: imguiHeader.}
proc ImGui_GetCurrentContext*(): ptr ImGuiContext {.importc: "ImGui::GetCurrentContext", header: imguiHeader.}
proc ImGui_SetCurrentContext*(ctx: ptr ImGuiContext) {.importc: "ImGui::SetCurrentContext", header: imguiHeader.}
proc ImGui_UpdatePlatformWindows*() {.importc: "ImGui::UpdatePlatformWindows", header: imguiHeader.}
proc ImGui_RenderPlatformWindowsDefault*(platform_render_arg: pointer = nil, renderer_render_arg: pointer = nil) {.importc: "ImGui::RenderPlatformWindowsDefault", header: imguiHeader.}
proc ImGui_Text*(fmt: cstring) {.importc: "ImGui::Text", header: imguiHeader, varargs.}
proc ImGui_Render*() {.importc: "ImGui::Render", header: imguiHeader.}
proc ImGui_GetDrawData*(): ptr ImDrawData {.importc: "ImGui::GetDrawData", header: imguiHeader.}
proc ImGui_NewFrame*() {.importc: "ImGui::NewFrame", header: imguiHeader.}
proc ImGui_GetIO*(): ptr ImGuiIO {.importc: "&ImGui::GetIO", header: imguiHeader.}
proc ImGui_GetStyle*(): ptr ImGuiStyle {.importc: "&ImGui::GetStyle", header: imguiHeader.}
proc ImGui_Begin*(name: cstring, p_open: ptr bool = nil, flags = 0.ImGuiWindowFlags): bool {.importc: "ImGui::Begin", header: imguiHeader.}
proc ImGui_End*() {.importc: "ImGui::End", header: imguiHeader.}
proc ImGui_Button*(label: cstring, size = imVec2(0, 0)): bool {.importc: "ImGui::Button", header: imguiHeader.}
proc ImGui_SameLine*(offset_from_start_x: cfloat = 0.0, spacing: cfloat = -1.0) {.importc: "ImGui::SameLine", header: imguiHeader.}

proc ImGui_StyleColorsDark*(dst: ptr ImGuiStyle = nil) {.importc: "ImGui::StyleColorsDark", header: imguiHeader.}
proc ImGui_StyleColorsLight*(dst: ptr ImGuiStyle = nil) {.importc: "ImGui::StyleColorsLight", header: imguiHeader.}
proc ImGui_StyleColorsClassic*(dst: ptr ImGuiStyle = nil) {.importc: "ImGui::StyleColorsClassic", header: imguiHeader.}

proc ScaleAllSizes*(style: ptr ImGuiStyle, scale_factor: cfloat) {.importcpp, header: imguiHeader.}
proc AddFontFromMemoryTTF*(atlas: ptr ImFontAtlas, font_data: pointer, font_size: cint, size_pixels: cfloat, font_cfg: ptr ImFontConfig = nil, glyph_ranges: ptr ImWchar = nil): ptr ImFont {.importcpp, header: imguiHeader.}

proc ImGui_ImplOpenGL3_Init*(glsl_version: cstring = nil): bool {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_Shutdown*() {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_NewFrame*() {.importc, header: imguiImplOpenGl3Header.}
proc ImGui_ImplOpenGL3_RenderDrawData*(draw_data: ptr ImDrawData) {.importc, header: imguiImplOpenGl3Header.}

when defined(windows):
  {.compile: "imgui/backends/imgui_impl_win32.cpp".}
  const imguiImplWin32Header = currentSourceDir() & "/imgui/backends/imgui_impl_win32.h"

  proc ImGui_ImplWin32_Init*(hwnd: pointer): bool {.importc, header: imguiImplWin32Header.}
  proc ImGui_ImplWin32_Shutdown*() {.importc, header: imguiImplWin32Header.}
  proc ImGui_ImplWin32_NewFrame*() {.importc, header: imguiImplWin32Header.}

{.pop.}