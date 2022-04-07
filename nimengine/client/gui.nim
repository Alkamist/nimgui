import std/times
import ../imgui
import ./imguiimpl
import ./types

export times
export imgui
export imguiimpl

template eventLoopInit*(client: Client) =
  client.previousTime = cpuTime()
  ImGui_CreateContext()
  ImGui_ImplClient_Init(client)
  ImGui_ImplOpenGL3_Init()

template eventLoopNewFrame*(client: Client) =
  client.time = cpuTime()
  client.delta = client.time - client.previousTime
  client.previousTime = client.time
  ImGui_ImplOpenGL3_NewFrame()
  ImGui_ImplClient_NewFrame()
  ImGui_NewFrame()

template eventLoopShutdown*(client: Client) =
  ImGui_ImplOpenGL3_Shutdown()
  ImGui_ImplClient_Shutdown()
  ImGui_DestroyContext()

template render*() =
  ImGui_Render()
  ImGui_ImplOpenGL3_RenderDrawData(ImGui_GetDrawData())

template text*(fmt: cstring, args: varargs[untyped]): untyped =
  ImGui_Text(fmt, args)

template button*(label: cstring, size = ImVec2.init(0, 0)): bool =
  ImGui_Button(label, size)