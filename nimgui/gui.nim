{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

import std/tables
import std/times
import std/algorithm
import ./math; export math
import oswindow; export oswindow
import vectorgraphics; export vectorgraphics

type
  Widget* = ref object of RootObj
    gui* {.cursor.}: Gui
    parent* {.cursor.}: Widget
    children*: Table[string, Widget]
    childDrawOrder*: seq[Widget]
    hovers*: seq[Widget]
    init*: bool
    isHovered*: bool
    passInput*: bool
    id*: string
    zIndex*: int
    position*: Vec2
    size*: Vec2
    drawProc*: proc(widget: Widget)

  Gui* = ref object of Widget
    osWindow*: OsWindow
    vg*: VectorGraphics
    widgetStack*: seq[Widget]
    contentScale*: float
    time*: float
    timePrevious*: float
    mouseCapture*: pointer
    globalMousePosition*: Vec2
    globalMousePositionPrevious*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string
    onFrameProc*: proc(gui: Gui)


# =================================================================================
# Widget
# =================================================================================


proc vg*(widget: Widget): VectorGraphics = widget.gui.vg

template x*(widget: Widget): untyped = widget.position.x
template `x=`*(widget: Widget, value: untyped): untyped = widget.position.x = value
template y*(widget: Widget): untyped = widget.position.y
template `y=`*(widget: Widget, value: untyped): untyped = widget.position.y = value
template width*(widget: Widget): untyped = widget.size.x
template `width=`*(widget: Widget, value: untyped): untyped = widget.size.x = value
template height*(widget: Widget): untyped = widget.size.y
template `height=`*(widget: Widget, value: untyped): untyped = widget.size.y = value

proc globalPosition*(widget: Widget): Vec2 =
  let parent = widget.parent
  if parent == nil:
    widget.position
  else:
    parent.globalPosition + widget.position

template draw*(w: Widget, code: untyped): untyped =
  w.drawProc = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(w)(widgetBase)
    let gui {.inject.} = self.gui
    let gfx {.inject.} = self.vg
    code


# =================================================================================
# Gui
# =================================================================================


proc mouseDelta*(gui: Gui): Vec2 = gui.globalMousePosition - gui.globalMousePositionPrevious
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

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()

  result.time = cpuTime()
  result.timePrevious = result.time

  result.id = "gui"
  result.gui = result
  result.isHovered = true

  result.widgetStack = newSeqOfCap[Widget](1024)
  result.widgetStack.add(Widget(result))

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

proc processFrame*(gui: Gui) =
  gui.time = cpuTime()

  if gui.onFrameProc != nil:
    gui.onFrameProc(gui)

  let (pixelWidth, pixelHeight) = gui.osWindow.size
  gui.vg.beginFrame(pixelWidth, pixelHeight, gui.contentScale)
  gui.drawWidget()
  gui.vg.endFrame()

  gui.childDrawOrder.setLen(0)
  gui.widgetStack.setLen(1)
  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.globalMousePositionPrevious = gui.globalMousePosition
  gui.timePrevious = gui.time

template run*(g: Gui, code: untyped): untyped =
  g.onFrameProc = proc(argGui: Gui) =
    {.hint[XDeclaredButNotUsed]: off.}
    let gui {.inject.} = argGui
    code

  g.osWindow.run()

proc beginWidget*(gui: Gui, id: string, T: typedesc): T =
  let parent = gui.widgetStack[gui.widgetStack.len - 1]
  if parent.children.hasKey(id):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(parent.children[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.gui = gui
    result.id = id
    parent.children[id] = result

  result.parent = parent
  result.childDrawOrder.setLen(0)

  gui.widgetStack.add(result)
  parent.childDrawOrder.add(result)

proc endWidget*(gui: Gui, T: typedesc): T {.discardable.} =
  {.hint[ConvFromXtoItselfNotNeeded]: off.}
  result = T(gui.widgetStack[gui.widgetStack.len - 1])
  if gui.widgetStack.len <= 1:
    echo "Error: gui.endWidget was called more times than gui.beginWidget"
  gui.widgetStack.setLen(gui.widgetStack.len - 1)

template newWidget*(gui: Gui, id: string, T: typedesc, updateCode: untyped): untyped =
  block:
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = gui.beginWidget(id, T)
    updateCode
    gui.endWidget(T)

proc bringToTop*(widget: Widget) =
  let parent = widget.parent
  if parent == nil:
    return

  var topZIndex = low(int)
  for id, child in parent.children:
    if child.zIndex >= topZIndex:
      topZIndex = child.zIndex

  widget.zIndex = topZIndex + 1

proc drawWidget(widget: Widget) =
  let vg = widget.vg

  vg.saveState()
  vg.translate(widget.globalPosition)
  if widget.drawProc != nil:
    widget.drawProc(widget)
  vg.restoreState()

  widget.childDrawOrder.sort do (x, y: Widget) -> int:
    cmp(x.zIndex, y.zIndex)

  let gui = widget.gui
  var inputConsumed = false
  for child in widget.childDrawOrder.reversed():
    child.isHovered =
      not inputConsumed and
      widget.isHovered and
      rect2(child.globalPosition, child.size).contains(gui.globalMousePosition)
    if child.isHovered and not child.passInput:
      inputConsumed = true

  for child in widget.childDrawOrder:
    child.drawWidget()


# =================================================================================
# OsWindow Binding
# =================================================================================


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
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMousePress = proc(window: OsWindow, button: MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = true
    gui.mousePresses.add(button)
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let gui = cast[Gui](window.userData)
    let dpi = window.dpi
    gui.mouseDownStates[button] = false
    gui.mouseReleases.add(button)
    gui.globalMousePosition.x = x.toDensityPixels(dpi)
    gui.globalMousePosition.y = y.toDensityPixels(dpi)

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