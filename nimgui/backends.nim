when defined(emscripten):
  import ./backends/emscripten; export emscripten
elif defined(windows):
  import ./backends/win32; export win32
else:
  import ./backends/glfw; export glfw