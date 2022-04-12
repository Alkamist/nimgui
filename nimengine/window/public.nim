import std/times

import ./types
export types

when defined(windows):
  import ./platform/win32
  export win32

func isPressed*(window: Window, key: KeyboardKey): bool =
  window.keyStates[key]

func isPressed*(window: Window, button: MouseButton): bool =
  window.mouseButtonStates[button]

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

proc processFrame*(window: Window) =
  if not window.isClosed:
    if window.previousTime <= 0.0:
      window.previousTime = cpuTime()

    window.time = cpuTime()
    window.delta = window.time - window.previousTime

    window.ctx.image.fill(rgba(0, 0, 0, 0))

    window.gfxCtx.select()
    window.gfxCtx.setViewport(0, 0, window.width.int, window.height.int)
    window.gfxCtx.clearBackground()

    if window.render != nil:
      window.render(window)

    window.quadTexture.uploadData(window.ctx.image)
    window.gfxCtx.drawTriangles(
      window.quadShader,
      window.quadVertexBuffer,
      window.quadIndexBuffer,
      window.quadTexture,
    )
    window.gfxCtx.swapBuffers()
    window.gfxCtx.unselect()

    window.postFrame()
    window.previousTime = window.time