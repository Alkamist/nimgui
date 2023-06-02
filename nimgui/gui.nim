{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

import std/times
import std/algorithm
import ./math; export math
import oswindow; export oswindow
import vectorgraphics; export vectorgraphics

type
  Widget* = ref object of RootObj
    gui* {.cursor.}: Gui
    parent* {.cursor.}: Widget
    children*: seq[Widget]
    zIndex*: int
    position*: Vec2
    size*: Vec2
    updateProc*: proc(widget: Widget)
    drawProc*: proc(widget: Widget)
    isAsleep*: bool
    dontDraw*: bool
    clipDrawing*: bool
    clipInput*: bool
    consumeInput*: bool

  Gui* = ref object of Widget
    osWindow*: OsWindow
    onFrameProc*: proc(gui: Gui)
    vg*: VectorGraphics
    hovers*: seq[Widget]
    contentScale*: float
    time*: float
    timePrevious*: float
    mouseCapture*: Widget
    mousePosition*: Vec2
    mousePositionPrevious*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

# =================================================================================
# Widget
# =================================================================================

template x*(widget: Widget): untyped = widget.position.x
template `x=`*(widget: Widget, value: untyped): untyped = widget.position.x = value
template y*(widget: Widget): untyped = widget.position.y
template `y=`*(widget: Widget, value: untyped): untyped = widget.position.y = value
template width*(widget: Widget): untyped = widget.size.x
template `width=`*(widget: Widget, value: untyped): untyped = widget.size.x = value
template height*(widget: Widget): untyped = widget.size.y
template `height=`*(widget: Widget, value: untyped): untyped = widget.size.y = value

proc globalPosition*(widget: Widget): Vec2 =
  if widget.parent == nil:
    widget.position
  else:
    widget.position + widget.parent.globalPosition

proc mousePosition*(widget: Widget): Vec2 =
  widget.gui.mousePosition - widget.globalPosition

proc isHovered*(widget: Widget): bool =
  let parent = widget.parent
  if parent == nil:
    true
  else:
    widget in widget.gui.hovers

proc isHoveredIncludingChildren*(widget: Widget): bool =
  if widget.isHovered:
    return true
  for child in widget.children:
    if child.isHoveredIncludingChildren:
      return true

proc bringToTop*(widget: Widget) =
  let parent = widget.parent
  if parent == nil:
    return

  var highestZIndex = low(int)
  for child in parent.children:
    if child.zIndex >= highestZIndex:
      highestZIndex = child.zIndex

  widget.zIndex = highestZIndex + 1

proc addWidget*(widget: Widget): Widget =
  result = Widget()
  result.gui = widget.gui
  result.parent = widget

  result.dontDraw = false
  result.clipDrawing = false
  result.clipInput = false
  result.consumeInput = false

  result.updateProc = proc(widget: Widget) =
    discard
  result.drawProc = proc(widget: Widget) =
    discard

  widget.children.add(result)

proc addWidget*(widget: Widget, T: typedesc): T =
  result = T()
  result.gui = widget.gui
  result.parent = widget

  result.dontDraw = false
  result.clipDrawing = false
  result.clipInput = false
  result.consumeInput = false

  result.updateProc = proc(widget: Widget) =
    T(widget).update()
  result.drawProc = proc(widget: Widget) =
    T(widget).draw()

  result.init()

  widget.children.add(result)

proc childDrawOrder*(widget: Widget): seq[Widget] =
  if widget.children.len == 0:
    return
  result = widget.children
  result.sort do (x, y: Widget) -> int:
    cmp(x.zIndex, y.zIndex)

proc mouseHits*(widget: Widget): seq[Widget] =
  if widget.isAsleep:
    return

  let widgetHit = rect2(vec2(0, 0), widget.size).contains(widget.mousePosition) or not widget.clipInput
  if not widgetHit:
    return

  for child in widget.childDrawOrder.reversed():
    for hit in child.mouseHits:
      result.add(hit)

  if widgetHit:
    result.add(widget)

proc updateWidget(widget: Widget) =
  if widget.isAsleep:
    return
  if widget.updateProc != nil:
    widget.updateProc(widget)
  for child in widget.children:
    child.updateWidget()

proc drawWidget(widget: Widget) =
  if widget.isAsleep or widget.dontDraw:
    return

  if widget.drawProc != nil:
    widget.drawProc(widget)

  let gui = widget.gui
  let vg = gui.vg
  for child in widget.childDrawOrder:
    vg.saveState()
    vg.translate(gui.pixelAlign(child.position))
    if child.clipDrawing:
      vg.clip(vec2(0, 0), child.size)
    child.drawWidget()
    vg.restoreState()

template updateHook*(w: Widget, code: untyped): untyped =
  let oldUpdateProc = w.updateProc
  w.updateProc = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(w)(widgetBase)
    let gui {.inject.} = self.gui
    if oldUpdateProc != nil:
      oldUpdateProc(widgetBase)
    code

template drawHook*(w: Widget, code: untyped): untyped =
  let oldDrawProc = w.drawProc
  w.drawProc = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(w)(widgetBase)
    let gui {.inject.} = self.gui
    let vg {.inject.} = gui.vg
    if oldDrawProc != nil:
      oldDrawProc(widgetBase)
    code

# =================================================================================
# Gui
# =================================================================================

proc mouseDelta*(gui: Gui): Vec2 = gui.mousePosition - gui.mousePositionPrevious
proc deltaTime*(gui: Gui): float = gui.time - gui.timePrevious
proc mouseDown*(gui: Gui, button: MouseButton): bool = gui.mouseDownStates[button]
proc keyDown*(gui: Gui, key: KeyboardKey): bool = gui.keyDownStates[key]
proc mouseMoved*(gui: Gui): bool = gui.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(gui: Gui): bool = gui.mouseWheel != vec2(0, 0)
proc mousePressed*(gui: Gui, button: MouseButton): bool = button in gui.mousePresses
proc mouseReleased*(gui: Gui, button: MouseButton): bool = button in gui.mouseReleases
proc anyMousePressed*(gui: Gui): bool = gui.mousePresses.len > 0
proc anyMouseReleased*(gui: Gui): bool = gui.mouseReleases.len > 0
proc keyPressed*(gui: Gui, key: KeyboardKey): bool = key in gui.keyPresses
proc keyReleased*(gui: Gui, key: KeyboardKey): bool = key in gui.keyReleases
proc anyKeyPressed*(gui: Gui): bool = gui.keyPresses.len > 0
proc anyKeyReleased*(gui: Gui): bool = gui.keyReleases.len > 0

proc pixelAlign*(gui: Gui, value: float): float =
  let contentScale = gui.contentScale
  (value * contentScale).round / contentScale

proc pixelAlign*(gui: Gui, position: Vec2): Vec2 =
  vec2(gui.pixelAlign(position.x), gui.pixelAlign(position.y))

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()

  result.time = cpuTime()
  result.timePrevious = result.time

  result.gui = result

  result.dontDraw = false
  result.clipDrawing = false
  result.clipInput = false
  result.consumeInput = false

  result.hovers = newSeqOfCap[Widget](16)
  result.mousePresses = newSeqOfCap[MouseButton](16)
  result.mouseReleases = newSeqOfCap[MouseButton](16)
  result.keyPresses = newSeqOfCap[KeyboardKey](16)
  result.keyReleases = newSeqOfCap[KeyboardKey](16)
  result.textInput = newStringOfCap(16)

  result.osWindow = OsWindow.new()
  result.osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
  result.osWindow.setSize(800, 600)
  result.osWindow.show()

  result.vg = VectorGraphics.new()

  result.attachToOsWindow()

proc updateHovers*(gui: Gui) =
  gui.hovers.setLen(0)

  if gui.mouseCapture != nil:
    gui.hovers.add(gui.mouseCapture)
    return

  for hit in gui.mouseHits:
    gui.hovers.add(hit)
    if hit.consumeInput:
      return

proc processFrame*(gui: Gui) =
  gui.time = cpuTime()

  gui.updateHovers()
  gui.updateWidget()

  let (pixelWidth, pixelHeight) = gui.osWindow.size
  gui.vg.beginFrame(pixelWidth, pixelHeight, gui.contentScale)
  gui.drawWidget()
  gui.vg.endFrame()

  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.mousePositionPrevious = gui.mousePosition
  gui.timePrevious = gui.time

proc run*(gui: Gui) =
  gui.osWindow.run()

const densityPixelDpi = 96.0

proc toContentScale(dpi: float): float =
  dpi / densityPixelDpi

proc toDensityPixels(pixels: int, dpi: float): float =
  float(pixels) * dpi / densityPixelDpi

proc attachToOsWindow(gui: Gui) =
  let window = gui.osWindow
  window.userData = cast[pointer](gui)

  let dpi = window.dpi
  gui.contentScale = dpi.toContentScale

  let (width, height) = window.size
  gui.width = width.toDensityPixels(dpi)
  gui.height = height.toDensityPixels(dpi)

  window.onFrame = proc(window: OsWindow) =
    let gui = cast[Gui](window.userData)
    gui.processFrame()
    window.swapBuffers()

  window.onResize = proc(window: OsWindow, width, height: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.width = width.toDensityPixels(dpi)
    gui.height = height.toDensityPixels(dpi)

  window.onMouseMove = proc(window: OsWindow, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mousePosition.x = x.toDensityPixels(dpi)
    gui.mousePosition.y = y.toDensityPixels(dpi)

  window.onMousePress = proc(window: OsWindow, button: MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = true
    gui.mousePresses.add(button)
    gui.mousePosition.x = x.toDensityPixels(dpi)
    gui.mousePosition.y = y.toDensityPixels(dpi)

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = false
    gui.mouseReleases.add(button)
    gui.mousePosition.x = x.toDensityPixels(dpi)
    gui.mousePosition.y = y.toDensityPixels(dpi)

  window.onMouseWheel = proc(window: OsWindow, x, y: float) =
    let gui = cast[Gui](window.userData)
    gui.mouseWheel.x = x
    gui.mouseWheel.y = y

  window.onKeyPress = proc(window: OsWindow, key: KeyboardKey) =
    let gui = cast[Gui](window.userData)
    gui.keyDownStates[key] = true
    gui.keyPresses.add(key)

  window.onKeyRelease = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let gui = cast[Gui](window.userData)
    gui.keyDownStates[key] = false
    gui.keyReleases.add(key)

  window.onTextInput = proc(window: OsWindow, text: string) =
    let gui = cast[Gui](window.userData)
    gui.textInput &= text

  window.onDpiChange = proc(window: OsWindow, dpi: float) =
    let gui = cast[Gui](window.userData)
    gui.contentScale = dpi.toContentScale