when defined(windows):
  import ./oswindow/oswindowwin32; export oswindowwin32

when defined(emscripten):
  import ./oswindow/oswindowemscripten; export oswindowemscripten