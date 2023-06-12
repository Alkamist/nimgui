import ./gui
import ./math

type
  GuiButton* = ref object of GuiState
    isDown*: bool
    pressed*: bool
    released*: bool
    clicked*: bool
    wasDown: bool

proc buttonBehavior*(gui: Gui, id: GuiId, bounds: Rect2, press, release: bool): GuiButton =
  gui.updateControl(id, bounds.contains(gui.mousePosition))

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

proc invisibleButton*(gui: Gui, id: GuiId, bounds: Rect2, mb = MouseButton.Left): GuiButton =
  result = gui.buttonBehavior(id, bounds, gui.mousePressed(mb), gui.mouseReleased(mb))
  let vg = gui.vg
  vg.beginPath()
  vg.rect(bounds)
  vg.strokeColor = rgb(0, 0, 255)
  vg.stroke()

proc invisibleButton*(gui: Gui, str: string, bounds: Rect2, mb = MouseButton.Left): GuiButton =
  gui.invisibleButton(gui.getId(str), bounds, mb)

proc button*(gui: Gui, label: string, mb = MouseButton.Left): GuiButton =
  let bounds = gui.getNextBounds()
  let button = gui.invisibleButton(label, bounds, mb)

  let vg = gui.vg

  template drawBody(color: Color): untyped =
    vg.beginPath()
    vg.roundedRect(bounds.position, bounds.size, 3.0)
    vg.fillColor = color
    vg.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == gui.currentId:
    drawBody(rgba(255, 255, 255, 8))

  button

type
  GuiWindow* = ref object of GuiState
    bounds*: Rect2
    scroll*: Vec2
    zIndex*: int
    isOpen*: bool
    minSize*: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

template position*(window: GuiWindow): untyped = window.bounds.position
template `position=`*(window: GuiWindow, value: untyped): untyped = window.bounds.position = value
template size*(window: GuiWindow): untyped = window.bounds.size
template `size=`*(window: GuiWindow, value: untyped): untyped = window.bounds.size = value
template x*(window: GuiWindow): untyped = window.position.x
template `x=`*(window: GuiWindow, value: untyped): untyped = window.position.x = value
template y*(window: GuiWindow): untyped = window.position.y
template `y=`*(window: GuiWindow, value: untyped): untyped = window.position.y = value
template width*(window: GuiWindow): untyped = window.size.x
template `width=`*(window: GuiWindow, value: untyped): untyped = window.size.x = value
template height*(window: GuiWindow): untyped = window.size.y
template `height=`*(window: GuiWindow, value: untyped): untyped = window.size.y = value

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
# const windowBorderThickness = 1.0
# const windowCornerRadius = 4.0
# const windowRoundingInset = (1.0 - sin(45.0.degToRad)) * windowCornerRadius

proc updateGrabState(window: GuiWindow, gui: Gui) =
  window.globalMousePositionWhenGrabbed = gui.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: GuiWindow, gui: Gui): Vec2 =
  gui.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.x += correction
    window.width -= correction

proc resizeRight(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.width -= correction

proc resizeTop(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.y += correction
    window.height -= correction

proc resizeBottom(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.height -= correction

proc moveButton(window: GuiWindow, gui: Gui) =
  let button = gui.invisibleButton("MoveButton", rect2(
    vec2(windowResizeHitSize, windowResizeHitSize),
    vec2(window.width - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize),
  ))
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.move(gui)

proc resizeLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeLeftButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(0, windowResizeHitSize),
    vec2(windowResizeHitSize, window.height - windowResizeHitSize * 2.0)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeLeftRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeLeft(gui)

proc resizeRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeRightButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(window.width - windowResizeHitSize, windowResizeHitSize),
    vec2(windowResizeHitSize, window.height - windowResizeHitSize * 2.0)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeLeftRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeRight(gui)

proc resizeTopButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(windowResizeHitSize * 2.0, 0),
    vec2(window.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopBottom
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeTop(gui)

proc resizeBottomButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(windowResizeHitSize * 2.0, window.height - windowResizeHitSize),
    vec2(window.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopBottom
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeBottom(gui)

proc resizeTopLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopLeftButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(0, 0),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopLeftBottomRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeLeft(gui)
    window.resizeTop(gui)

proc resizeTopRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopRightButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(window.width - windowResizeHitSize * 2.0, 0),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopRightBottomLeft
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeRight(gui)
    window.resizeTop(gui)

proc resizeBottomLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomLeftButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(0, window.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopRightBottomLeft
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeLeft(gui)
    window.resizeBottom(gui)

proc resizeBottomRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomRightButton")
  let button = gui.invisibleButton(id, rect2(
    vec2(window.width - windowResizeHitSize * 2.0, window.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopLeftBottomRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.resizeRight(gui)
    window.resizeBottom(gui)

proc bringToFront*(gui: Gui, window: GuiWindow) =
  window.zIndex = gui.highestZIndex + 1

proc bodyButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("BodyButton")
  discard gui.invisibleButton(id, rect2(
    vec2(0, 0),
    vec2(window.width, window.height)
  ))

proc beginWindow*(gui: Gui, title: string, initialBounds: Rect2, color: Color): GuiWindow =
  let windowId = gui.getId(title)

  let window = gui.getState(windowId, GuiWindow)
  if window.init:
    window.isOpen = true
    window.minSize = vec2(300, windowHeaderHeight * 2.0)
    window.bounds = initialBounds

  if not window.isOpen:
    return

  gui.beginIdSpace(windowId)
  gui.beginLayer("Window", window.position, vec2(0, 0), window.zIndex)

  if gui.hoverLayer == gui.currentLayer.id and
     gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right):
    gui.bringToFront(window)

  window.bodyButton(gui)

  let vg = gui.vg
  vg.beginPath()
  vg.rect(vec2(0, 0), window.size)
  vg.fillColor = color
  vg.fill()

  gui.beginLayout(rect2(vec2(0, 0), window.size).expand(-10.0), window.scroll)

  window

proc endWindow*(gui: Gui) =
  gui.endLayout()

  let window = gui.getState(gui.currentIdSpace, GuiWindow)
  window.moveButton(gui)
  window.resizeLeftButton(gui)
  window.resizeRightButton(gui)
  window.resizeTopButton(gui)
  window.resizeBottomButton(gui)
  window.resizeTopLeftButton(gui)
  window.resizeTopRightButton(gui)
  window.resizeBottomLeftButton(gui)
  window.resizeBottomRightButton(gui)

  gui.endLayer()
  gui.endIdSpace()