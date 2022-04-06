when defined(windows):
  import pkg/winim/lean

  type
    PlatformData* = object
      handle*: HWND
      lastCursorPosX*: float
      lastCursorPosY*: float
      restoreCursorPosX*: float
      restoreCursorPosY*: float

elif defined(emscripten):
  type
    PlatformData* = object
      handle*: cstring