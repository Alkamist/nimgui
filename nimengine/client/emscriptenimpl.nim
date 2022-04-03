import ../emscriptenapi
include ./clientbase

{.passL: "-s EXPORTED_RUNTIME_METHODS=ccall".}
{.passL: "-s EXPORTED_FUNCTIONS=_main,_initSize,_onMouseMove,_onMouseDown,_onMouseUp,_onResize".}

var globalClient: Client

func toMouseButton(code: int): MouseButton =
  case code:
  of 0: MouseButton.Left
  of 1: MouseButton.Middle
  of 2: MouseButton.Right
  of 3: MouseButton.Extra1
  of 4: MouseButton.Extra2
  else: MouseButton.Unknown

template startEventLoop*(client: Client, code: untyped): untyped =
  proc mainFn() {.cdecl.} =
    code

  emscripten_set_main_loop(mainFn, 0, true)

proc initSize*(clientWidth, clientHeight: float) {.exportc.} =
  globalClient.width = clientWidth
  globalClient.widthChange = 0.0
  globalClient.widthPrevious = clientWidth
  globalClient.height = clientHeight
  globalClient.heightChange = 0.0
  globalClient.heightPrevious = clientHeight

proc onResize(clientWidth, clientHeight: float) {.exportc.} =
  globalClient.processResized(clientWidth, clientHeight)

emscripten_run_script("""
window.addEventListener("resize", e => {
  let canvas = document.getElementById("canvas");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Module.ccall("onResize", null, ["number", "number"], [window.innerWidth, window.innerHeight]);
});
""")

proc onMouseUp(button: int) {.exportc.} =
  globalClient.processMouseButtonReleased(button.toMouseButton)

emscripten_run_script("""
window.addEventListener("mouseup", e => {
  Module.ccall("onMouseUp", null, ["number"], [e.button]);
});
""")

proc onMouseDown(button: int) {.exportc.} =
  globalClient.processMouseButtonPressed(button.toMouseButton)

emscripten_run_script("""
window.addEventListener("mousedown", e => {
  Module.ccall("onMouseDown", null, ["number"], [e.button]);
});
""")

proc onMouseMove(clientX, clientY: float) {.exportc.} =
  globalClient.processMouseMoved(clientX, clientY)

emscripten_run_script("""
window.addEventListener("mousemove", e => {
  Module.ccall("onMouseMove", null, ["number", "number"], [e.clientX, e.clientY]);
});
""")

proc new*(_: type Client,
          title = "Client",
          x, y = 0,
          width = 1024, height = 768,
          parent = 0): Client =
  globalClient = newDefaultClient(width.float, height.float)
  globalClient.nativeHandle = "#canvas"

  emscripten_run_script("""
  let canvas = document.getElementById("canvas");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Module.ccall("initSize", null, ["number", "number"], [window.innerWidth, window.innerHeight]);
  """)

  globalClient