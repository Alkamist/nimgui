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
    init*: bool
    isHovered*: bool
    isHoveredIncludingChildren*: bool
    passInput*: bool
    isFreelyPositionable*: bool
    id*: string
    zIndex*: int
    position*: Vec2
    size*: Vec2
    drawProc*: proc(widget: Widget)
    cursorStyle*: CursorStyle
    accessedThisFrame*: bool
    layoutPosition*: Vec2
    childSize*: Vec2
    childSpacing*: Vec2
    lastChildPosition*: Vec2
    lastChildSize*: Vec2
    firstAutoPlacedChild*: bool
    nextChildIsSameRow*: bool
    nextChildIsFreelyPositionable*: bool

  Gui* = ref object of Widget
    osWindow*: OsWindow
    vg*: VectorGraphics
    mouseCapture*: Widget
    contentScale*: float
    time*: float
    timePrevious*: float
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
    activeCursorStyle: CursorStyle


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

proc vg*(widget: Widget): VectorGraphics = widget.gui.vg
proc mouseDelta*(widget: Widget): Vec2 = widget.gui.mouseDelta
proc deltaTime*(widget: Widget): float = widget.gui.deltaTime
proc mouseDown*(widget: Widget, button: MouseButton): bool = widget.gui.mouseDown(button)
proc keyDown*(widget: Widget, key: KeyboardKey): bool = widget.gui.keyDown(key)
proc mouseMoved*(widget: Widget): bool = widget.gui.mouseMoved
proc mouseWheelMoved*(widget: Widget): bool = widget.gui.mouseWheelMoved
proc mousePressed*(widget: Widget, button: MouseButton): bool = widget.gui.mousePressed(button)
proc mouseReleased*(widget: Widget, button: MouseButton): bool = widget.gui.mouseReleased(button)
proc anyMousePressed*(widget: Widget): bool = widget.gui.anyMousePressed
proc anyMouseReleased*(widget: Widget): bool = widget.gui.anyMouseReleased
proc keyPressed*(widget: Widget, key: KeyboardKey): bool = widget.gui.keyPressed(key)
proc keyReleased*(widget: Widget, key: KeyboardKey): bool = widget.gui.keyReleased(key)
proc anyKeyPressed*(widget: Widget): bool = widget.gui.anyKeyPressed
proc anyKeyReleased*(widget: Widget): bool = widget.gui.anyKeyReleased

proc globalMousePosition*(widget: Widget): Vec2 = widget.gui.globalMousePosition

proc globalPosition*(widget: Widget): Vec2 =
  let parent = widget.parent
  if parent == nil:
    widget.position
  else:
    parent.globalPosition + widget.position

proc mousePosition*(widget: Widget): Vec2 = widget.globalMousePosition - widget.globalPosition
proc captureMouse*(widget: Widget) = widget.gui.mouseCapture = widget
proc releaseMouse*(widget: Widget) = widget.gui.mouseCapture = nil

proc mouseIsInside*(widget: Widget): bool =
  rect2(vec2(0, 0), widget.size).contains(widget.mousePosition)

proc sameRow*(widget: Widget) =
  widget.nextChildIsSameRow = true

proc freePosition*(widget: Widget) =
  widget.nextChildIsFreelyPositionable = true

proc nextChildPosition*(widget: Widget): Vec2 =
  if widget.firstAutoPlacedChild:
    return widget.layoutPosition

  if widget.nextChildIsSameRow:
    result.x = widget.lastChildPosition.x + widget.lastChildSize.x + widget.childSpacing.x
    result.y = widget.lastChildPosition.y
  else:
    result.x = widget.layoutPosition.x
    result.y = widget.lastChildPosition.y + widget.lastChildSize.y + widget.childSpacing.y

iterator grid*(widget: Widget, columns, rows: int): int =
  if rows > 0 and columns > 0:
    let gridSize = widget.childSize
    let layoutPositionBeforeGrid = widget.layoutPosition

    widget.layoutPosition = widget.nextChildPosition

    let colsRows = vec2(float(columns), float(rows))
    let spacings = widget.childSpacing * (colsRows - 1.0)

    widget.childSize = (gridSize - spacings) / colsRows

    for row in 0 ..< rows:
      for column in 0 ..< columns:
        yield row * columns + column
        if column < columns - 1:
          widget.sameRow()

    widget.layoutPosition = layoutPositionBeforeGrid
    widget.childSize = gridSize

proc initLayout(widget: Widget) =
  widget.firstAutoPlacedChild = true

proc autoPlaceChild(widget, child: Widget) =
  child.size = widget.childSize
  child.position = widget.nextChildPosition
  widget.lastChildPosition = child.position
  widget.lastChildSize = child.size

  if widget.nextChildIsSameRow:
    widget.nextChildIsSameRow = false

  if widget.firstAutoPlacedChild:
    widget.firstAutoPlacedChild = false

proc addWidget*(widget: Widget, id: string, T: typedesc): T {.discardable.} =
  if widget.children.hasKey(id):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(widget.children[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.gui = widget.gui
    result.id = id
    widget.children[id] = result

  result.parent = widget

  if not result.accessedThisFrame:
    widget.childDrawOrder.add(result)
    result.accessedThisFrame = true
    result.initLayout()

  result.isFreelyPositionable = widget.nextChildIsFreelyPositionable

  if not widget.nextChildIsFreelyPositionable:
    widget.autoPlaceChild(result)

  widget.nextChildIsFreelyPositionable = false

proc bringToTop*(widget: Widget) =
  let parent = widget.parent
  if parent == nil:
    return

  var topZIndex = low(int)
  for id, child in parent.children:
    if child.zIndex >= topZIndex:
      topZIndex = child.zIndex

  widget.zIndex = topZIndex + 1

proc sortDrawOrderByZIndex(widget: Widget) =
  widget.childDrawOrder.sort do (x, y: Widget) -> int:
    cmp(x.zIndex, y.zIndex)

proc updateMouseCaptureHovers(capture: Widget) =
  capture.isHoveredIncludingChildren = true
  if capture.parent != nil:
    capture.parent.updateMouseCaptureHovers()

proc updateHovers(widget: Widget) =
  let gui = widget.gui
  if gui.mouseCapture != nil:
    for child in widget.childDrawOrder:
      child.isHovered = false
      child.isHoveredIncludingChildren = false

    gui.mouseCapture.isHovered = true
    gui.mouseCapture.updateMouseCaptureHovers()

  else:
    var inputConsumed = false
    for child in widget.childDrawOrder.reversed():
      child.isHoveredIncludingChildren =
        (not inputConsumed) and
        widget.isHoveredIncludingChildren and
        child.mouseIsInside

      child.isHovered = child.isHoveredIncludingChildren

      if child.isHoveredIncludingChildren and not child.passInput:
        inputConsumed = true
        widget.isHovered = false

      child.updateHovers()

proc pixelAlign(value, contentScale: float): float =
  round(value * contentScale) / contentScale

proc pixelAlign(position: Vec2, contentScale: float): Vec2 =
  vec2(
    position.x.pixelAlign(contentScale),
    position.y.pixelAlign(contentScale),
  )

proc drawWidget(widget: Widget) =
  let vg = widget.vg

  if widget.isHovered and not widget.passInput:
    widget.gui.activeCursorStyle = widget.cursorStyle

  let scale = widget.gui.contentScale

  # Pixel align the widget's size for the draw call so it is crisp.
  let size = widget.size
  widget.size = size.pixelAlign(scale)

  vg.saveState()
  vg.translate(widget.globalPosition.pixelAlign(scale))
  if widget.drawProc != nil:
    widget.drawProc(widget)
  vg.restoreState()

  for child in widget.childDrawOrder:
    child.drawWidget()

  # Set the size back to normal.
  widget.size = size

  widget.drawProc = nil
  widget.childDrawOrder.setLen(0)
  widget.accessedThisFrame = false

template draw*(widget: Widget, code: untyped): untyped =
  if true:
    widget.drawProc = proc(widgetBase: Widget) =
      {.hint[XDeclaredButNotUsed]: off.}
      {.hint[ConvFromXtoItselfNotNeeded]: off.}
      let `widget` {.inject.} = typeof(widget)(widgetBase)
      code

template drawHook*(widget: Widget, code: untyped): untyped =
  if true:
    let previousDrawProc = widget.drawProc
    widget.drawProc = proc(widgetBase: Widget) =
      {.hint[XDeclaredButNotUsed]: off.}
      {.hint[ConvFromXtoItselfNotNeeded]: off.}
      let `widget` {.inject.} = typeof(widget)(widgetBase)
      if previousDrawProc != nil:
        previousDrawProc(widgetBase)
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
  gui.isHoveredIncludingChildren = gui.osWindow.isHovered
  gui.isHovered = gui.isHoveredIncludingChildren
  gui.initLayout()

  let (pixelWidth, pixelHeight) = gui.osWindow.size
  gui.vg.beginFrame(pixelWidth, pixelHeight, gui.contentScale)

  if gui.onFrameProc != nil:
    gui.onFrameProc(gui)

  gui.sortDrawOrderByZIndex()
  gui.updateHovers()
  gui.drawWidget()

  gui.vg.endFrame()

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
    if window.isHovered:
      window.setCursorStyle(gui.activeCursorStyle)
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
    window.setCursorStyle(gui.activeCursorStyle)

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