import std/times
import oswindow
import ./widget as widgetModule

const densityPixelDpi = 96.0

proc toContentScale(dpi: float): float {.inline.} =
  dpi / densityPixelDpi

proc toDensityPixels(pixels: int, dpi: float): float {.inline.} =
  float(pixels) * dpi / densityPixelDpi

proc toWidgetMouseButton(button: oswindow.MouseButton): widgetModule.MouseButton {.inline.} =
  cast[widgetModule.MouseButton](button)

proc toWidgetKeyboardKey(key: oswindow.KeyboardKey): widgetModule.KeyboardKey {.inline.} =
  cast[widgetModule.KeyboardKey](key)

proc toOsWindowCursorStyle(style: widgetModule.CursorStyle): oswindow.CursorStyle {.inline.} =
  cast[oswindow.CursorStyle](style)

proc attachToOsWindow*(widget: Widget, window: OsWindow) =
  GcRef(widget)
  window.userData = cast[pointer](widget)

  let (width, height) = window.size
  widget.inputResize(float(width), float(height))
  widget.inputContentScale(window.dpi.toContentScale)

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
    let dpi = window.dpi
    widget.inputMouseMove(x.toDensityPixels(dpi), y.toDensityPixels(dpi))

  window.onMousePress = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let widget = cast[Widget](window.userData)
    let dpi = window.dpi
    widget.inputMousePress(button.toWidgetMouseButton, x.toDensityPixels(dpi), y.toDensityPixels(dpi))

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let widget = cast[Widget](window.userData)
    let dpi = window.dpi
    widget.inputMouseRelease(button.toWidgetMouseButton, x.toDensityPixels(dpi), y.toDensityPixels(dpi))

  window.onMouseWheel = proc(window: OsWindow, x, y: float) =
    let widget = cast[Widget](window.userData)
    widget.inputMouseWheel(float(x), float(y))

  window.onKeyPress = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let widget = cast[Widget](window.userData)
    widget.inputKeyPress(key.toWidgetKeyboardKey)

  window.onKeyRelease = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let widget = cast[Widget](window.userData)
    widget.inputKeyRelease(key.toWidgetKeyboardKey)

  window.onTextInput = proc(window: OsWindow, text: string) =
    let widget = cast[Widget](window.userData)
    widget.inputText(text)

  window.onDpiChange = proc(window: OsWindow, dpi: float) =
    let widget = cast[Widget](window.userData)
    widget.inputContentScale(dpi.toContentScale)