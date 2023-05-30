import std/unicode
import std/times
import oswindow
import ./widget as widgetModule

proc toWidgetMouseButton(button: oswindow.MouseButton): widgetModule.MouseButton =
  return cast[widgetModule.MouseButton](button)

proc toWidgetKeyboardKey(key: oswindow.KeyboardKey): widgetModule.KeyboardKey =
  return cast[widgetModule.KeyboardKey](key)

proc toOsWindowCursorStyle(style: widgetModule.CursorStyle): oswindow.CursorStyle =
  return cast[oswindow.CursorStyle](style)

proc attachToOsWindow*(widget: Widget, window: OsWindow) =
  GcRef(widget)
  window.userData = cast[pointer](widget)

  let (width, height) = window.size
  widget.inputResize(float(width), float(height))
  widget.inputScale(window.scale)

  window.onFrame = proc(window: OsWindow) =
    let widget = cast[Widget](window.userData)
    widget.processFrame(cpuTime())
    if window.isHovered:
      window.setCursorStyle(widget.activeCursorStyle.toOsWindowCursorStyle)
    window.swapBuffers()

  window.onClose = proc(window: OsWindow) =
    let widget = cast[Widget](window.userData)
    GcUnref(widget)

  window.onResize = proc(window: OsWindow, width, height: int) =
    let widget = cast[Widget](window.userData)
    widget.inputResize(float(width), float(height))

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

  window.onScaleChange = proc(window: OsWindow, scale: float) =
    let widget = cast[Widget](window.userData)
    widget.inputScale(scale)