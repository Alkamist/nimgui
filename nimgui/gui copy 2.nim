{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import std/options
import std/algorithm
import ./math
import ./vectorgraphics; export vectorgraphics
import oswindow; export oswindow

const themeItemSize = vec2(50, 50)
const themeSpacing = 5.0

type
  GuiId* = Hash

  GuiState* = ref object of RootObj
    id*: GuiId
    init*: bool

  GuiPositioning* = enum
    Relative
    Absolute

  FreelyPositionedRect2 = object
    positioning: GuiPositioning
    rect: Rect2

  GuiLayout = object
    body: Rect2
    max: Vec2
    nextPosition: Vec2
    rowSize: Vec2
    widths: seq[float]
    indexInRow: int
    nextRow: float
    indent: float
    freelyPositionedRect: Option[FreelyPositionedRect2]

  GuiContainer* = ref object of GuiState
    vg*: VectorGraphics
    rect*: Rect2
    scroll*: Vec2
    zIndex*: int
    layoutStack: seq[GuiLayout]

template position*(container: GuiContainer): untyped = container.rect.position
template `position=`*(container: GuiContainer, value: untyped): untyped = container.rect.position = value
template size*(container: GuiContainer): untyped = container.rect.size
template `size=`*(container: GuiContainer, value: untyped): untyped = container.rect.size = value

proc currentLayout(container: GuiContainer): ptr GuiLayout =
  addr(container.layoutStack[container.layoutStack.len - 1])

proc newRow(container: GuiContainer, height: float) =
  let layout = container.currentLayout
  layout.nextPosition.x = layout.indent
  layout.nextPosition.y = layout.nextRow
  layout.rowSize.y = height
  layout.indexInRow = 0

proc row(container: GuiContainer, widths: openArray[float], height: float) =
  let layout = container.currentLayout
  layout.widths.setLen(widths.len)
  for i in 0 ..< widths.len:
    layout.widths[i] = widths[i]
  container.newRow(height)

proc getNextRect(container: GuiContainer): Rect2 =
  let layout = container.currentLayout

  if layout.freelyPositionedRect.isSome:
    let freelyPositionedRect = layout.freelyPositionedRect.get
    layout.freelyPositionedRect = none(FreelyPositionedRect2)

    result = freelyPositionedRect.rect

    if freelyPositionedRect.positioning == Relative:
      result.x += layout.body.x
      result.y += layout.body.y

  else:
    if layout.indexInRow == layout.widths.len:
      container.newRow(layout.rowSize.y)

    result.position = layout.nextPosition

    result.width =
      if layout.widths.len > 0:
        layout.widths[layout.indexInRow]
      else:
        layout.rowSize.x

    result.height = layout.rowSize.y

    if result.width == 0:
      result.width = themeItemSize.x

    if result.height == 0:
      result.height = themeItemSize.y

    if result.width < 0:
      result.width += layout.body.width - result.x + 1

    if result.height < 0:
      result.height += layout.body.height - result.y + 1

    layout.indexInRow += 1

    layout.nextPosition.x += result.width + themeSpacing
    layout.nextRow = max(layout.nextRow, result.y + result.height + themeSpacing)

    result.x += layout.body.x
    result.y += layout.body.y

  layout.max.x = max(layout.max.x, result.x + result.width)
  layout.max.y = max(layout.max.y, result.y + result.height)

proc pushLayout(container: GuiContainer, body: Rect2, scroll: Vec2) =
  container.layoutStack.add GuiLayout(
    body: rect2(
      body.x - scroll.x, body.y - scroll.y,
      body.width, body.height,
    ),
    max: vec2(low(float), low(float)),
  )
  container.row([0.0], 0.0)

proc popLayout(container: GuiContainer) =
  discard container.layoutStack.pop()

proc beginColumn(container: GuiContainer) =
  container.pushLayout(container.getNextRect(), vec2(0, 0))

proc endColumn(container: GuiContainer) =
  let b = container.layoutStack.pop()
  let a = container.currentLayout
  a.rowSize.x = max(a.rowSize.x, b.rowSize.x + b.body.x - a.body.x)
  a.nextRow = max(a.nextRow, b.nextRow + b.body.y - a.body.y)
  a.max.x = max(a.max.x, b.max.x)
  a.max.y = max(a.max.y, b.max.y)

proc setNextRect(container: GuiContainer, rect: Rect2, positioning = GuiPositioning.Relative) =
  container.currentLayout.freelyPositionedRect = some(FreelyPositionedRect2(
    positioning: positioning,
    rect: rect,
  ))

type
  Gui* = ref object
    size*: Vec2
    scale*: float
    time*: float
    globalMousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    hover*: GuiId
    focus*: GuiId
    currentId*: GuiId
    currentRect*: Rect2
    lastZIndex*: int

    idStack: seq[GuiId]
    activeContainers: seq[GuiContainer]
    containerStack: seq[GuiContainer]
    retainedState: Table[GuiId, GuiState]
    vgCtx: VectorGraphicsContext

    timePrevious: float
    globalMousePositionPrevious: Vec2

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

proc getId*[T: not GuiId](gui: Gui, x: T): GuiId =
  if gui.idStack.len > 0:
    result = !$(gui.idStack[^1] !& hash(x))
  else:
    result = hash(x)
  gui.currentId = result

proc pushId*(gui: Gui, id: GuiId) =
  gui.idStack.add(id)

proc pushId*(gui: Gui, str: string) =
  gui.pushId(gui.getId(str))

proc popId*(gui: Gui) =
  discard gui.idStack.pop()

proc bringToFront*(gui: Gui, container: GuiContainer) =
  gui.lastZIndex += 1
  container.zIndex = gui.lastZIndex

proc getState*(gui: Gui, id: GuiId, T: typedesc): T =
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true
    result.id = id
    when T is GuiContainer:
      result.vg = VectorGraphics.new()
    gui.retainedState[id] = result

proc getState*(gui: Gui, str: string, T: typedesc): T =
  gui.getState(gui.getId(str), T)

proc currentContainer*(gui: Gui): GuiContainer =
  gui.containerStack[gui.containerStack.len - 1]

proc newRow*(gui: Gui, height: float) =
  gui.currentContainer.newRow(height)

proc row*(gui: Gui, widths: openArray[float], height: float) =
  gui.currentContainer.row(widths, height)

proc getNextRect*(gui: Gui): Rect2 =
  result = gui.currentContainer.getNextRect()
  gui.currentRect = result

proc pushLayout*(gui: Gui, body: Rect2, scroll: Vec2) =
  gui.currentContainer.pushLayout(body, scroll)

proc popLayout*(gui: Gui) =
  gui.currentContainer.popLayout()

proc beginColumn*(gui: Gui) =
  gui.currentContainer.beginColumn()

proc endColumn*(gui: Gui) =
  gui.currentContainer.endColumn()

proc setNextRect*(gui: Gui, rect: Rect2, positioning = GuiPositioning.Relative) =
  gui.currentContainer.setNextRect(rect, positioning)

proc pushContainer*(gui: Gui, container: GuiContainer) =
  gui.containerStack.add(container)
  gui.activeContainers.add(container)
  gui.pushLayout(container.rect, container.scroll)

proc popContainer*(gui: Gui) =
  gui.popLayout()
  discard gui.containerStack.pop()

proc mousePosition*(gui: Gui): Vec2 =
  gui.globalMousePosition - gui.currentContainer.rect.position

proc vg*(gui: Gui): VectorGraphics =
  gui.currentContainer.vg

proc new*(_: typedesc[Gui]): Gui =
  result = Gui()
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(gui: Gui, time: float) =
  gui.vgCtx.beginFrame(gui.size, gui.scale)

  gui.timePrevious = gui.time
  gui.time = time

  let mainId = gui.getId("MainContainer")
  let mainContainer = gui.getState(mainId, GuiContainer)
  mainContainer.rect = rect2(vec2(0, 0), gui.size)
  gui.pushId(mainId)
  gui.pushContainer(mainContainer)

proc endFrame*(gui: Gui) =
  gui.popContainer()
  gui.popId()

  assert(gui.idStack.len == 0)
  assert(gui.containerStack.len == 0)

  gui.activeContainers.sort do (x, y: GuiContainer) -> int:
    cmp(x.zIndex, y.zIndex)

  for container in gui.activeContainers:
    gui.vgCtx.renderVectorGraphics(container.vg)

  gui.activeContainers.setLen(0)

  gui.mousePresses.setLen(0)
  gui.mouseReleases.setLen(0)
  gui.keyPresses.setLen(0)
  gui.keyReleases.setLen(0)
  gui.textInput.setLen(0)
  gui.mouseWheel = vec2(0, 0)
  gui.globalMousePositionPrevious = gui.globalMousePosition

  gui.vgCtx.endFrame()

proc updateHoverAndFocus*(gui: Gui, id: GuiId, rect: Rect2) =
  let mouseOver = rect.contains(gui.globalMousePosition)
  let mouseDown = gui.mouseDown(Left) or gui.mouseDown(Middle) or gui.mouseDown(Right)

  if gui.hover == id and not mouseOver:
    gui.hover = 0

  if mouseDown:
    if gui.hover == id:
      gui.focus = id
  else:
    if mouseOver:
      gui.hover = id
    else:
      gui.focus = 0

type
  GuiButton* = ref object of GuiState
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    wasDown: bool

proc buttonBehavior*(gui: Gui, id: GuiId, rect: Rect2, press, release: bool): GuiButton =
  gui.updateHoverAndFocus(id, rect)

  let button = gui.getState(id, GuiButton)

  button.wasDown = button.isDown
  button.pressed = false
  button.released = false
  button.clicked = false

  if gui.focus == id and not button.isDown and press:
    button.isDown = true
    button.pressed = true

  if button.isDown and release:
    button.isDown = false
    button.released = true
    if gui.hover == id:
      button.clicked = true

  button

proc invisibleButton*(gui: Gui, str: string, rect: Rect2, mb = MouseButton.Left): GuiButton =
  gui.buttonBehavior(gui.getId(str), rect, gui.mousePressed(mb), gui.mouseReleased(mb))

proc button*(gui: Gui, label: string, mb = MouseButton.Left): GuiButton =
  let rect = gui.getNextRect()
  let button = gui.invisibleButton(label, rect, mb)

  let vg = gui.vg

  template drawBody(color: Color): untyped =
    vg.beginPath()
    vg.roundedRect(rect.position, rect.size, 3.0)
    vg.fillColor = color
    vg.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == gui.currentId:
    drawBody(rgba(255, 255, 255, 8))

  button

type
  GuiWindow* = ref object of GuiContainer
    isOpen*: bool
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

proc beginWindow*(gui: Gui, title: string, initialRect: Rect2): GuiWindow =
  let id = gui.getId(title)

  let window = gui.getState(id, GuiWindow)
  if window.init:
    window.isOpen = true
    window.rect = initialRect

  gui.pushId(id)

  let moveButton = gui.invisibleButton("WindowMoveButton", window.rect)

  if moveButton.pressed:
    window.globalMousePositionWhenGrabbed = gui.globalMousePosition
    window.positionWhenGrabbed = window.position
    window.sizeWhenGrabbed = window.size

  if moveButton.isDown:
    let grabDelta = gui.globalMousePosition - window.globalMousePositionWhenGrabbed
    window.position = window.positionWhenGrabbed + grabDelta

  let vg = gui.vg
  vg.beginPath()
  vg.rect(window.rect)
  vg.fillColor = rgb(255, 0, 0)
  vg.fill()

  gui.pushContainer(window)

  window

proc endWindow*(gui: Gui) =
  gui.popContainer()
  gui.popId()