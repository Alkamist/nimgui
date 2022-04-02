when defined(win32):
  import client/win32impl
  export win32impl
elif defined(emscripten):
  import client/emscriptenimpl
  export emscriptenimpl