import std/unicode
import oswindow
import ./widget

proc toWidgetMouseButton(button: oswindow.MouseButton): widget.MouseButton =
  return cast[widget.MouseButton](button)

proc toWidgetKeyboardKey(key: oswindow.KeyboardKey): widget.KeyboardKey =
  return cast[widget.KeyboardKey](key)

proc attachToOsWindow*(widget: Widget, window: OsWindow, processFrame: proc(window: OsWindow)) =
  GcRef(widget)

  window.userData = cast[pointer](widget)

  let (width, height) = window.size
  widget.inputResize(float(width), float(height))
  widget.inputDpi(window.dpi)

  window.onClose = proc(window: OsWindow) =
    let widget = cast[Widget](window.userData)
    window.makeContextCurrent()
    GcUnref(widget)

  window.onResize = proc(window: OsWindow, width, height: int) =
    let widget = cast[Widget](window.userData)
    widget.inputResize(float(width), float(height))
    processFrame(window)

  window.onMouseMove = proc(window: OsWindow, x, y: int) =
    let widget = cast[Widget](window.userData)
    widget.inputMouseMove(float(x), float(y))

  window.onMousePress = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let widget = cast[Widget](window.userData)
    widget.inputMousePress(button.toWidgetMouseButton, float(x), float(y))

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let widget = cast[Widget](window.userData)
    widget.inputMouseRelease(button.toWidgetMouseButton, float(x), float(y))

  window.onMouseWheel = proc(window: OsWindow, x, y: float) =
    let widget = cast[Widget](window.userData)
    widget.inputMouseWheel(float(x), float(y))

  window.onKeyPress = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let widget = cast[Widget](window.userData)
    widget.inputKeyPress(key.toWidgetKeyboardKey)

  window.onKeyRelease = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let widget = cast[Widget](window.userData)
    widget.inputKeyRelease(key.toWidgetKeyboardKey)

  window.onRune = proc(window: OsWindow, r: Rune) =
    let widget = cast[Widget](window.userData)
    widget.inputText(r.toUTF8)

  window.onDpiChange = proc(window: OsWindow, dpi: float) =
    let widget = cast[Widget](window.userData)
    widget.inputDpi(dpi)