import std/times

import ../renderer
export renderer

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

proc update*(window: Window) =
  if not window.isClosed:
    if window.previousTime <= 0.0:
      window.previousTime = cpuTime()

    window.time = cpuTime()
    window.delta = window.time - window.previousTime

    window.input.update()
    window.preUpdate()

    if window.onUpdate != nil:
      window.onUpdate()

    if window.renderer != nil:
      window.renderer.render(window.width.int, window.height.int)

    window.postUpdate()
    window.previousTime = window.time

proc enableRenderer*(window: Window) =
  window.renderer = newRenderer(cast[pointer](window.platform.handle))

proc disableRenderer*(window: Window) =
  window.renderer = nil