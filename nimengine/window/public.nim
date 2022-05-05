import std/times

import ./types
export types

when defined(windows):
  import ./platform/win32
  export win32

func aspectRatio*(window: Window): float =
  window.width / window.height

proc disableCursor*(window: Window) =
  window.hideCursor()
  window.pinCursorToCenter()
  window.confineCursor()

proc enableCursor*(window: Window) =
  window.unconfineCursor()
  window.unpinCursorFromCenter()
  window.showCursor()

proc pollEvents*(window: Window) =
  if not window.isClosed:
    if window.previousTime <= 0.0:
      window.previousTime = cpuTime()

    window.input.update()
    window.previousTime = window.time
    window.time = cpuTime()
    window.delta = window.time - window.previousTime

    window.pollEventsPlatform()