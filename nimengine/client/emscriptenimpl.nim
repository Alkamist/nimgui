import ./emscriptenapi
include ./functions

template startLoop*(client: Client, code: untyped): untyped =
  proc mainFn() {.cdecl.} =
    code

  emscripten_set_main_loop(startLoop, 0, true)

proc new*(_: type Client,
          title = "Client",
          x, y = 0,
          width = 1024, height = 768,
          parent: HWND = 0): Client =
  var c = newDefaultClient(width, height)
  # c.nativeInfo.hwnd = hwnd
  c