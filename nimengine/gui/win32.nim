{.experimental: "overloadableEnums".}

import opengl
import winim/lean
import ../imgui
import ../math
import ../openglwrappers/openglcontext

{.emit: """/*INCLUDESECTION*/
#include <windows.h>
""".}
{.emit: """
extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
""".}
proc ImGui_ImplWin32_WndProcHandler(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.importc, nodecl.}

type
  Gui* = ref object
    onFrame*: proc()
    isOpen*: bool
    handle*: pointer
    parentHandle*: pointer
    imguiContextPtr*: pointer
    windowClass: WNDCLASSEX
    openGlContext: OpenGlContext

template hwnd(gui): HWND = cast[HWND](gui.handle)
template imguiContext*(gui): ptr ImGuiContext = cast[ptr ImGuiContext](gui.imguiContextPtr)

proc getClientRect(hwnd: HWND): Rect2 =
  var rect: RECT
  GetClientRect(hwnd, rect.addr)
  ClientToScreen(hwnd, cast[ptr POINT](rect.left.addr))
  ClientToScreen(hwnd, cast[ptr POINT](rect.right.addr))
  rect2(
    vec2(rect.left.float, rect.top.float),
    vec2((rect.right - rect.left).float, (rect.bottom - rect.top).float),
  )

proc close*(gui: Gui) =
  gui.isOpen = false

proc windowProc(hwnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if ImGui_ImplWin32_WndProcHandler(hwnd, msg, wParam, lParam) == TRUE:
    return TRUE

  case msg:

  of WM_SIZE:
    if openGlIsInitialized and wParam != SIZE_MINIMIZED:
      glViewport(0.GLint, 0.GLint, LOWORD(lParam).GLsizei, HIWORD(lParam).GLsizei)
      return 0

  of WM_SYSCOMMAND:
    if (wParam and 0xfff0) == SC_KEYMENU: # Disable ALT application menu
      return 0

  of WM_DESTROY:
    PostQuitMessage(0)
    return 0

  else:
    discard

  DefWindowProc(hwnd, msg, wParam, lParam)

proc `=destroy`*(gui: var type Gui()[]) =
  ImGui_ImplOpenGL3_Shutdown()
  ImGui_ImplWin32_Shutdown()
  ImGui_DestroyContext(gui.imguiContext)
  DestroyWindow(gui.hwnd)
  UnregisterClass(gui.windowClass.lpszClassName, gui.windowClass.hInstance)

proc newGui*(parentHandle: pointer = nil): Gui =
  result = Gui()

  result.windowClass = WNDCLASSEX(
    cbSize: WNDCLASSEX.sizeof.UINT,
    style: CS_CLASSDC,
    lpfnWndProc: windowProc,
    cbClsExtra: 0,
    cbWndExtra: 0,
    hInstance: GetModuleHandle(nil),
    hIcon: 0,
    hCursor: 0,
    hbrBackground: 0,
    lpszMenuName: nil,
    lpszClassName: "Gui Window Class",
    hIconSm: 0,
  )
  RegisterClassEx(result.windowClass)

  let isChild = parentHandle != nil
  let windowStyle =
    if isChild:
      WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    else:
      WS_OVERLAPPEDWINDOW or WS_VISIBLE

  let hwnd = CreateWindow(
    lpClassName = result.windowClass.lpszClassName,
    lpWindowName = "Window",
    dwStyle = windowStyle.int32,
    x = 100,
    y = 100,
    nWidth = 1280,
    nHeight = 800,
    hWndParent = cast[HWND](parentHandle),
    hMenu = 0,
    hInstance = result.windowClass.hInstance,
    lpParam = nil,
  )

  ShowWindow(hwnd, SW_SHOWDEFAULT)
  UpdateWindow(hwnd)

  result.handle = cast[pointer](hwnd)
  result.parentHandle = cast[pointer](parentHandle)

  result.openGlContext = newOpenGlContext(result.handle)
  result.openGlContext.select()

  result.imguiContextPtr = cast[pointer](ImGui_CreateContext())

  var io = ImGui_GetIO()
  io.ConfigFlags = (ImGuiConfigFlags_NavEnableKeyboard.cint or
                    ImGuiConfigFlags_DockingEnable.cint or
                    ImGuiConfigFlags_ViewportsEnable.cint).ImGuiConfigFlags

  ImGui_ImplWin32_Init(result.handle)
  ImGui_ImplOpenGL3_Init()

  result.isOpen = true

proc update*(gui: Gui) =
  var msg: MSG
  while PeekMessage(msg.addr, 0, 0, 0, PM_REMOVE):
    TranslateMessage(msg.addr)
    DispatchMessage(msg.addr)
    if msg.message == WM_QUIT:
      gui.isOpen = false

  if gui.isOpen:
    gui.openGlContext.select()
    glClear(GL_COLOR_BUFFER_BIT)

    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplWin32_NewFrame()
    ImGui_NewFrame()

    var showDemoWindow = true
    ImGui_ShowDemoWindow(showDemoWindow.addr)

    if gui.onFrame != nil:
      gui.onFrame()

    ImGui_Render()
    let sizePixels = getClientRect(gui.hwnd).size
    glViewport(0.GLint, 0.GLint, sizePixels.x.GLsizei, sizePixels.y.GLsizei)
    ImGui_ImplOpenGL3_RenderDrawData(ImGui_GetDrawData())

    var io = ImGui_GetIO()
    if (io.ConfigFlags.cint and ImGuiConfigFlags_ViewportsEnable.cint) > 0:
      ImGui_UpdatePlatformWindows()
      ImGui_RenderPlatformWindowsDefault()
      gui.openGlContext.select()

    gui.openGlContext.swapBuffers()

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.openGlContext.select()
  glClearColor(color.r, color.g, color.b, color.a)