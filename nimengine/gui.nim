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

proc update*(gui: Gui) =
  if gui.isOpen:
    glfwPollEvents()

    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplGlfw_NewFrame()
    ImGui_NewFrame()

    # var showDemoWindow = true
    # ImGui_ShowDemoWindow(showDemoWindow.addr)

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