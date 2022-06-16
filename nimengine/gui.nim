{.experimental: "overloadableEnums".}

import opengl
import glfw
import ./imgui
import ./math

proc glfwErrorCallback(errorCode: cint, description: cstring) {.cdecl.} =
  echo "Glfw Error " & $errorCode & ": " & $description

type
  WindowFlag* = enum
    NoTitleBar = 0
    NoResize = 1
    NoMove = 2
    NoScrollbar = 3
    NoScrollWithMouse = 4
    NoCollapse = 5
    AlwaysAutoResize = 6
    NoBackground = 7
    NoSavedSettings = 8
    NoMouseInputs = 9
    MenuBar = 10
    HorizontalScrollbar = 11
    NoFocusOnAppearing = 12
    NoBringToFrontOnFocus = 13
    AlwaysVerticalScrollbar = 14
    AlwaysHorizontalScrollbar = 15
    AlwaysUseWindowPadding = 16
    NoNavInputs = 18
    NoNavFocus = 19
    UnsavedDocument = 20
    NavFlattened = 23

  Gui* = ref object
    onFrame*: proc()
    glfwWindow*: GLFWwindow
    imguiContextPtr*: pointer

# func toImVec2(v: Vec2): ImVec2 =
#   imVec2(v.x, v.y)

func toImVec4(c: Color): ImVec4 =
  imVec4(c.r, c.g, c.b, c.a)

proc setDefaultSizes() =
  var style = ImGui_GetStyle()
  style.WindowPadding = imVec2(8.0, 8.0)
  style.WindowRounding = 4.0
  style.WindowBorderSize = 1.0
  style.WindowMinSize = imVec2(32.0, 32.0)
  style.ChildRounding = 4.0
  style.ChildBorderSize = 1.0
  style.PopupRounding = 4.0
  style.PopupBorderSize = 1.0
  style.FramePadding = imVec2(4.0, 3.0)
  style.FrameRounding = 2.0
  style.FrameBorderSize = 0.0
  style.ItemSpacing = imVec2(8.0, 4.0)
  style.ItemInnerSpacing = imVec2(4.0, 4.0)
  style.CellPadding = imVec2(4.0, 2.0)
  style.TouchExtraPadding = imVec2(0.0, 0.0)
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
  style.DisplayWindowPadding = imVec2(19.0, 19.0)
  style.DisplaySafeAreaPadding = imVec2(3.0, 3.0)

proc setDefaultStyle() =
  var style = ImGui_GetStyle()
  style.Alpha = 1.0
  style.DisabledAlpha = 0.6
  style.WindowTitleAlign = imVec2(0.5, 0.5)
  style.WindowMenuButtonPosition = ImGuiDir_Left
  style.ColorButtonPosition = ImGuiDir_Right
  style.ButtonTextAlign = imVec2(0.5, 0.5)
  style.SelectableTextAlign = imVec2(0.0, 0.0)
  style.MouseCursorScale = 1.0
  style.AntiAliasedLines = true
  style.AntiAliasedLinesUseTex = true
  style.AntiAliasedFill = true
  style.CurveTessellationTol = 1.25
  style.CircleTessellationMaxError = 0.3

  setDefaultSizes()

  let text = rgb(236, 236, 236)
  style.Colors[ImGuiCol_Text] = text.toImVec4
  style.Colors[ImGuiCol_TextDisabled] = text.darken(0.4).toImVec4

  let bg = rgb(16, 16, 16)
  style.Colors[ImGuiCol_WindowBg] = bg.toImVec4
  style.Colors[ImGuiCol_ChildBg] = bg.toImVec4
  style.Colors[ImGuiCol_PopupBg] = bg.toImVec4

  let border = rgba(255, 255, 255, 43)
  style.Colors[ImGuiCol_Border] = border.toImVec4
  style.Colors[ImGuiCol_BorderShadow] = rgba(0, 0, 0, 0).toImVec4

  let frame = rgb(36, 36, 36)
  style.Colors[ImGuiCol_FrameBg] = frame.toImVec4
  style.Colors[ImGuiCol_FrameBgHovered] = frame.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_FrameBgActive] = frame.lighten(0.2).toImVec4

  let title = rgb(39, 39, 39)
  style.Colors[ImGuiCol_TitleBg] = title.toImVec4
  style.Colors[ImGuiCol_TitleBgActive] = title.toImVec4
  style.Colors[ImGuiCol_TitleBgCollapsed] = title.toImVec4

  let menu = rgb(21, 21, 21)
  style.Colors[ImGuiCol_MenuBarBg] = menu.toImVec4

  let scrollBar = rgb(54, 54, 54)
  style.Colors[ImGuiCol_ScrollbarBg] = rgba(0, 0, 0, 0).toImVec4
  style.Colors[ImGuiCol_ScrollbarGrab] = scrollBar.toImVec4
  style.Colors[ImGuiCol_ScrollbarGrabHovered] = scrollBar.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_ScrollbarGrabActive] = scrollBar.lighten(0.2).toImVec4

  let checkMark = rgb(218, 218, 218)
  style.Colors[ImGuiCol_CheckMark] = checkMark.toImVec4

  let slider = rgb(81, 81, 81)
  style.Colors[ImGuiCol_SliderGrab] = slider.toImVec4
  style.Colors[ImGuiCol_SliderGrabActive] = slider.lighten(0.3).toImVec4

  let button = rgb(57, 57, 57)
  style.Colors[ImGuiCol_Button] = button.toImVec4
  style.Colors[ImGuiCol_ButtonHovered] = button.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_ButtonActive] = button.lighten(0.2).toImVec4

  let header = rgb(57, 57, 57)
  style.Colors[ImGuiCol_Header] = header.toImVec4
  style.Colors[ImGuiCol_HeaderHovered] = header.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_HeaderActive] = header.lighten(0.2).toImVec4

  let separator = rgb(67, 67, 67)
  style.Colors[ImGuiCol_Separator] = separator.toImVec4
  style.Colors[ImGuiCol_SeparatorHovered] = separator.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_SeparatorActive] = separator.lighten(0.2).toImVec4

  let resizeGrip = rgb(42, 42, 42)
  style.Colors[ImGuiCol_ResizeGrip] = resizeGrip.toImVec4
  style.Colors[ImGuiCol_ResizeGripHovered] = resizeGrip.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_ResizeGripActive] = resizeGrip.lighten(0.2).toImVec4

  let tab = rgb(51, 51, 51)
  style.Colors[ImGuiCol_Tab] = tab.toImVec4
  style.Colors[ImGuiCol_TabHovered] = tab.lighten(0.1).toImVec4
  style.Colors[ImGuiCol_TabActive] = tab.lighten(0.2).toImVec4
  style.Colors[ImGuiCol_TabUnfocused] = tab.darken(0.03).toImVec4
  style.Colors[ImGuiCol_TabUnfocusedActive] = tab.darken(0.03).lighten(0.1).toImVec4

  style.Colors[ImGuiCol_DockingPreview] = rgb(23, 198, 126).toImVec4
  style.Colors[ImGuiCol_DockingEmptyBg] = rgb(23, 198, 126).darken(0.4).toImVec4

  let plot = rgb(23, 198, 126)
  let plotHover = rgb(120, 220, 179)
  style.Colors[ImGuiCol_PlotLines] = plot.toImVec4
  style.Colors[ImGuiCol_PlotLinesHovered] = plotHover.toImVec4
  style.Colors[ImGuiCol_PlotHistogram] = plot.toImVec4
  style.Colors[ImGuiCol_PlotHistogramHovered] = plotHover.toImVec4

  style.Colors[ImGuiCol_TableHeaderBg] = rgb(36, 36, 36).toImVec4
  style.Colors[ImGuiCol_TableBorderStrong] = separator.toImVec4
  style.Colors[ImGuiCol_TableBorderLight] = separator.toImVec4
  style.Colors[ImGuiCol_TableRowBg] = rgba(0, 0, 0, 0).toImVec4
  style.Colors[ImGuiCol_TableRowBgAlt] = rgba(255, 255, 255, 10).toImVec4

  style.Colors[ImGuiCol_TextSelectedBg] = rgba(23, 198, 126, 89).toImVec4

  style.Colors[ImGuiCol_DragDropTarget] = plot.toImVec4

  style.Colors[ImGuiCol_NavHighlight] = plot.toImVec4

  # style.Colors[ImGuiCol_NavWindowingHighlight] = imVec4(1.0, 1.0, 1.0, 0.7)
  # style.Colors[ImGuiCol_NavWindowingDimBg] = imVec4(0.8, 0.8, 0.8, 0.2)
  # style.Colors[ImGuiCol_ModalWindowDimBg] = imVec4(0.8, 0.8, 0.8, 0.35)

template imguiContext*(gui): ptr ImGuiContext =
  cast[ptr ImGuiContext](gui.imguiContextPtr)

proc isOpen*(gui: Gui): bool =
  glfwWindowShouldClose(gui.glfwWindow) == 0

proc close*(gui: Gui) =
  glfwSetWindowShouldClose(gui.glfwWindow, 1)

proc `=destroy`*(gui: var type Gui()[]) =
  ImGui_ImplOpenGL3_Shutdown()
  ImGui_ImplGlfw_Shutdown()
  ImGui_DestroyContext(gui.imguiContext)
  glfwDestroyWindow(gui.glfwWindow)
  glfwTerminate()

proc newGui*(): Gui =
  result = Gui()

  discard glfwSetErrorCallback(glfwErrorCallback)
  if glfwInit() == 0:
    raise newException(Exception, "Failed to Initialize GLFW.")

  when defined(IMGUI_IMPL_OPENGL_ES2):
    # GL ES 2.0 + GLSL 100
    var glslVersion = cstring"#version 100"
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
  elif defined(macosx):
    # GL 3.2 + GLSL 150:
    var glslVersion = cstring"#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE) # 3.2+ only
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE) # Required on Mac
  else:
    # GL 3.0 + GLSL 130
    var glslVersion = cstring"#version 130"
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  result.glfwWindow = glfwCreateWindow(1280, 720, "Window", nil, nil)
  if result.glfwWindow == nil:
    raise newException(Exception, "Failed to create main GLFW window.")

  glfwMakeContextCurrent(result.glfwWindow)
  glfwSwapInterval(1) # Enable vsync

  opengl.loadExtensions()

  result.imguiContextPtr = cast[pointer](ImGui_CreateContext())

  var io = ImGui_GetIO()
  io.ConfigFlags = (ImGuiConfigFlags_NavEnableKeyboard.cint or
                    ImGuiConfigFlags_DockingEnable.cint or
                    ImGuiConfigFlags_ViewportsEnable.cint).ImGuiConfigFlags

  ImGui_ImplGlfw_InitForOpenGL(result.glfwWindow, true)
  ImGui_ImplOpenGL3_Init(glslVersion)

  setDefaultStyle()

proc update*(gui: Gui) =
  if gui.isOpen:
    glfwPollEvents()

    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplGlfw_NewFrame()
    ImGui_NewFrame()

    var showDemoWindow = true
    ImGui_ShowDemoWindow(showDemoWindow.addr)

    if gui.onFrame != nil:
      gui.onFrame()

    ImGui_Render()
    var displayW, displayH: cint
    glfwGetFramebufferSize(gui.glfwWindow, displayW.addr, displayH.addr)
    glViewport(0.GLint, 0.GLint, displayW.GLsizei, displayH.GLsizei)
    glClear(GL_COLOR_BUFFER_BIT)
    ImGui_ImplOpenGL3_RenderDrawData(ImGui_GetDrawData())

    var io = ImGui_GetIO()
    if (io.ConfigFlags.cint and ImGuiConfigFlags_ViewportsEnable.cint) > 0:
      ImGui_UpdatePlatformWindows()
      ImGui_RenderPlatformWindowsDefault()
      glfwMakeContextCurrent(gui.glfwWindow)

    glfwSwapBuffers(gui.glfwWindow)

proc `backgroundColor=`*(gui: Gui, color: Color) =
  glfwMakeContextCurrent(gui.glfwWindow)
  glClearColor(color.r, color.g, color.b, color.a)

proc beginWindow*(gui: Gui, name: string, isOpen: var bool, flags: set[WindowFlag] = {}): bool =
  ImGui_Begin(name.cstring, isOpen.addr, cast[ImGuiWindowFlags](flags))

proc beginWindow*(gui: Gui, name: string, flags: set[WindowFlag] = {}): bool =
  ImGui_Begin(name.cstring, nil, cast[ImGuiWindowFlags](flags))

proc endWindow*(gui: Gui) =
  ImGui_End()

template window*(gui: Gui, name: string, code: untyped) =
  if gui.beginWindow(name, {}):
    code
  gui.endWindow()

template window*(gui: Gui, name: string, flags: set[WindowFlag] = {}, code: untyped) =
  if gui.beginWindow(name, flags):
    code
  gui.endWindow()

proc button*(gui: Gui, label: string): bool =
  ImGui_Button(label.cstring)

proc sameRow*(gui: Gui) =
  ImGui_SameLine()