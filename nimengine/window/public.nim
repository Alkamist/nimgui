import std/times

import ../renderer
export renderer

import ./types
export types

when defined(windows):
  import ./platform/win32
  export win32

func isPressed*(self: Window, key: KeyboardKey): bool =
  self.keyStates[key]

func isPressed*(self: Window, button: MouseButton): bool =
  self.mouseButtonStates[button]

func aspectRatio*(self: Window): float =
  self.width / self.height

proc disableCursor*(self: Window) =
  self.hideCursor()
  self.pinCursorToCenter()
  self.confineCursor()

proc enableCursor*(self: Window) =
  self.unconfineCursor()
  self.unpinCursorFromCenter()
  self.showCursor()

proc update*(self: Window) =
  if not self.isClosed:
    if self.previousTime <= 0.0:
      self.previousTime = cpuTime()

    self.time = cpuTime()
    self.delta = self.time - self.previousTime

    if self.onUpdate != nil:
      self.onUpdate()

    if self.renderer != nil:
      self.renderer.render(self.width.int, self.height.int)

    self.postUpdate()
    self.previousTime = self.time

proc enableRenderer*(self: Window) =
  self.renderer = newRenderer(cast[pointer](self.platform.handle))

proc disableRenderer*(self: Window) =
  self.renderer = nil