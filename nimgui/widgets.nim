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
  gui.updateHoverAndFocus(id, bounds)

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

proc invisibleButton*(gui: Gui, str: string, bounds: Rect2, mb = MouseButton.Left): GuiButton =
  gui.buttonBehavior(gui.getId(str), bounds, gui.mousePressed(mb), gui.mouseReleased(mb))

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
  GuiWindow* = ref object of GuiContainer
    isOpen*: bool
    minSize*: Vec2
    mousePositionWhenGrabbed*: Vec2
    positionWhenGrabbed*: Vec2
    sizeWhenGrabbed*: Vec2

const windowHeaderHeight = 22.0
# const windowResizeHitSize = 5.0
# const windowBorderThickness = 1.0
# const windowCornerRadius = 4.0
# const windowRoundingInset = (1.0 - sin(45.0.degToRad)) * windowCornerRadius

proc updateGrabState(window: GuiWindow, gui: Gui) =
  window.mousePositionWhenGrabbed = gui.mousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: GuiWindow, gui: Gui): Vec2 =
  gui.mousePosition - window.mousePositionWhenGrabbed

proc move(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.position = window.positionWhenGrabbed + grabDelta

# proc resizeLeft(window: GuiWindow, gui: Gui) =
#   let grabDelta = window.calculateGrabDelta(gui)
#   window.x = window.positionWhenGrabbed.x + grabDelta.x
#   window.width = window.sizeWhenGrabbed.x - grabDelta.x
#   if window.width < window.minSize.x:
#     let correction = window.width - window.minSize.x
#     window.x += correction
#     window.width -= correction

# proc resizeRight(window: GuiWindow, gui: Gui) =
#   let grabDelta = window.calculateGrabDelta(gui)
#   window.width = window.sizeWhenGrabbed.x + grabDelta.x
#   if window.width < window.minSize.x:
#     let correction = window.width - window.minSize.x
#     window.width -= correction

# proc resizeTop(window: GuiWindow, gui: Gui) =
#   let grabDelta = window.calculateGrabDelta(gui)
#   window.y = window.positionWhenGrabbed.y + grabDelta.y
#   window.height = window.sizeWhenGrabbed.y - grabDelta.y
#   if window.height < window.minSize.y:
#     let correction = window.height - window.minSize.y
#     window.y += correction
#     window.height -= correction

# proc resizeBottom(window: GuiWindow, gui: Gui) =
#   let grabDelta = window.calculateGrabDelta(gui)
#   window.height = window.sizeWhenGrabbed.y + grabDelta.y
#   if window.height < window.minSize.y:
#     let correction = window.height - window.minSize.y
#     window.height -= correction

# proc addResizeLeftButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("ResizeLeftButton", ResizeLeftRight)

#   button.anchor = anchor(Left, Center)
#   button.position = vec2(0, window.height * 0.5)
#   button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeLeft()

# proc addResizeRightButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("ResizeRightButton", ResizeLeftRight)

#   button.anchor = anchor(Right, Center)
#   button.position = vec2(window.width, window.height * 0.5)
#   button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeRight()

# proc addResizeTopButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeTopButton", ResizeTopBottom)

#   button.anchor = anchor(Center, Top)
#   button.position = vec2(window.width * 0.5, 0)
#   button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeTop()

# proc addResizeBottomButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeBottomButton", ResizeTopBottom)

#   button.anchor = anchor(Center, Bottom)
#   button.position = vec2(window.width * 0.5, window.height)
#   button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeBottom()

# proc addResizeTopLeftButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeTopLeftButton", ResizeTopLeftBottomRight)

#   button.anchor = anchor(Left, Top)
#   button.position = vec2(0, 0)
#   button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeTop()
#     window.resizeLeft()

# proc addResizeTopRightButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeTopRightButton", ResizeTopRightBottomLeft)

#   button.anchor = anchor(Right, Top)
#   button.position = vec2(window.width, 0)
#   button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeTop()
#     window.resizeRight()

# proc addResizeBottomLeftButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeBottomLeftButton", ResizeTopRightBottomLeft)

#   button.anchor = anchor(Left, Bottom)
#   button.position = vec2(0, window.height)
#   button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeBottom()
#     window.resizeLeft()

# proc resizeBottomRightButton(window: GuiWindow) =
#   let button = window.addMoveResizeButton("WindowResizeBottomRightButton", ResizeTopLeftBottomRight)

#   button.anchor = anchor(Right, Bottom)
#   button.position = window.size
#   button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.resizeBottom()
#     window.resizeRight()

proc moveButtonRect(window: GuiWindow, gui: Gui): Rect2 =
  result.position = window.position
  result.size = vec2(window.width, windowHeaderHeight)

proc beginWindow*(gui: Gui, title: string, initialRect: Rect2, color: Color): GuiWindow =
  let id = gui.getId(title)

  let window = gui.getState(id, GuiWindow)
  if window.init:
    window.isOpen = true
    window.bounds = initialRect

  gui.pushContainer(window)

  let vg = gui.vg
  vg.beginPath()
  vg.rect(window.bounds)
  vg.fillColor = color
  vg.fill()

  window

proc endWindow*(gui: Gui) =
  let window = GuiWindow(gui.currentContainer)
  let moveButton = gui.invisibleButton("MoveButton", window.moveButtonRect(gui))
  if moveButton.pressed: window.updateGrabState(gui)
  if moveButton.isDown:
    window.move(gui)

  gui.popContainer()