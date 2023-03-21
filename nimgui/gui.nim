when defined(windows):
  import ./gui/oswindowwin32; export oswindowwin32

var osWindows*: seq[OsWindow]
var osParentWindow*: pointer
var backgroundColor*: Color

proc update*() =
  var keepWindows: seq[OsWindow]
  for window in osWindows:
    if window.isOpen:
      window.update()
      keepWindows.add window
  osWindows = keepWindows

template parent*(parent: pointer, code: untyped): untyped =
  osParentWindow = parent
  code
  osParentWindow = nil

template window*(code: untyped): untyped =
  let window = newOsWindow(osParentWindow)
  osWindows.add window
  window.backgroundColor = backgroundColor

  window.onFrame = proc(window {.inject.}: OsWindow) =
    code