when defined(windows):
  import client/platform/win32
  export win32
elif defined(emscripten):
  import client/platform/emscripten
  export emscripten