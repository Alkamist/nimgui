{.define: nimPreviewHashRef.}

import std/tables; export tables

import ./gfxmod; export gfxmod
when defined(windows):
  import ./guimod/oswindowwin32; export oswindowwin32

type
  Gui* = ref object
    windowGfx*: Table[OsWindow, Gfx]
    osWindows*: seq[OsWindow]
    osParentWindow*: pointer
    backgroundColor*: Color

let gui* = Gui()

proc isRunning*(gui: Gui): bool =
  gui.osWindows.len > 0

proc update*(gui: Gui) =
  var keepWindows: seq[OsWindow]

  for window in gui.osWindows:
    if window.isOpen:
      window.update()
      keepWindows.add window

  gui.osWindows = keepWindows

template parent*(gui: Gui, parent: pointer, code: untyped): untyped =
  gui.osParentWindow = parent
  code
  gui.osParentWindow = nil

template window*(gui: Gui, code: untyped): untyped =
  let window = newOsWindow(gui.osParentWindow)
  gui.osWindows.add window
  gui.windowGfx[window] = newGfx()
  window.backgroundColor = gui.backgroundColor

  window.onFrame = proc(window {.inject.}: OsWindow) =
    let gfx {.inject.} = gui.windowGfx[window]
    gfx.beginFrame(window.sizePixels, window.pixelDensity)
    code
    gfx.endFrame()