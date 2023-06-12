import ./gui
import ./math

proc buttonBehavior*(gui: Gui, id: GuiId, bounds: Rect2, mb = MouseButton.Left): GuiControl =
  result = gui.control(id, bounds.contains(gui.mousePosition), gui.mouseDown(mb))
  # let vg = gui.vg
  # vg.beginPath()
  # vg.rect(bounds)
  # if gui.focus == id:
  #   vg.setStrokeColor(rgb(0, 255, 0))
  # else:
  #   vg.setStrokeColor(rgb(0, 0, 255))
  # vg.stroke()

proc buttonBehavior*(gui: Gui, str: string, bounds: Rect2, mb = MouseButton.Left): GuiControl =
  gui.buttonBehavior(gui.getId(str), bounds, mb)

proc button*(gui: Gui, label: string, mb = MouseButton.Left): GuiControl =
  let bounds = gui.getNextBounds()
  let button = gui.buttonBehavior(label, bounds, mb)

  let vg = gui.vg

  template drawBody(color: Color): untyped =
    vg.beginPath()
    vg.roundedRect(bounds.position, bounds.size, 3.0)
    vg.fillColor(color)
    vg.fill()

  drawBody(rgb(31, 32, 34))
  if button.isDown:
    drawBody(rgba(0, 0, 0, 8))
  elif gui.hover == gui.currentId:
    drawBody(rgba(255, 255, 255, 8))

  button

type
  GuiWindow* = ref object of GuiState
    editBounds*: Rect2
    bounds*: Rect2
    zIndex*: int
    isOpen*: bool
    minSize*: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 4.0
const windowRoundingInset = (1.0 - sin(45.0.degToRad)) * windowCornerRadius

proc updateGrabState(window: GuiWindow, gui: Gui) =
  window.globalMousePositionWhenGrabbed = gui.globalMousePosition
  window.positionWhenGrabbed = window.editBounds.position
  window.sizeWhenGrabbed = window.editBounds.size

proc calculateGrabDelta(window: GuiWindow, gui: Gui): Vec2 =
  gui.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.editBounds.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.editBounds.x = window.positionWhenGrabbed.x + grabDelta.x
  window.editBounds.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.editBounds.width < window.minSize.x:
    let correction = window.editBounds.width - window.minSize.x
    window.editBounds.x += correction
    window.editBounds.width -= correction

proc resizeRight(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.editBounds.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.editBounds.width < window.minSize.x:
    let correction = window.editBounds.width - window.minSize.x
    window.editBounds.width -= correction

proc resizeTop(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.editBounds.y = window.positionWhenGrabbed.y + grabDelta.y
  window.editBounds.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.editBounds.height < window.minSize.y:
    let correction = window.editBounds.height - window.minSize.y
    window.editBounds.y += correction
    window.editBounds.height -= correction

proc resizeBottom(window: GuiWindow, gui: Gui) =
  let grabDelta = window.calculateGrabDelta(gui)
  window.editBounds.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.editBounds.height < window.minSize.y:
    let correction = window.editBounds.height - window.minSize.y
    window.editBounds.height -= correction

proc moveButton(window: GuiWindow, gui: Gui) =
  let button = gui.buttonBehavior("MoveButton", rect2(
    vec2(windowResizeHitSize, windowResizeHitSize),
    vec2(window.bounds.width - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize),
  ))
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    window.move(gui)

proc resizeLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeLeftButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(0, windowResizeHitSize),
    vec2(windowResizeHitSize, window.bounds.height - windowResizeHitSize * 2.0)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeLeftRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    window.resizeLeft(gui)

proc resizeRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeRightButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(window.bounds.width - windowResizeHitSize, windowResizeHitSize),
    vec2(windowResizeHitSize, window.bounds.height - windowResizeHitSize * 2.0)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeLeftRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    window.resizeRight(gui)

proc resizeTopButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(windowResizeHitSize * 2.0, 0),
    vec2(window.bounds.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopBottom
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    window.resizeTop(gui)

proc resizeBottomButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(windowResizeHitSize * 2.0, window.bounds.height - windowResizeHitSize),
    vec2(window.bounds.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopBottom
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    window.resizeBottom(gui)

proc resizeTopLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopLeftButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(0, 0),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopLeftBottomRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    window.resizeLeft(gui)
    window.resizeTop(gui)

proc resizeTopRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeTopRightButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(window.bounds.width - windowResizeHitSize * 2.0, 0),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopRightBottomLeft
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    window.resizeRight(gui)
    window.resizeTop(gui)

proc resizeBottomLeftButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomLeftButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(0, window.bounds.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopRightBottomLeft
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    window.resizeLeft(gui)
    window.resizeBottom(gui)

proc resizeBottomRightButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("ResizeBottomRightButton")
  let button = gui.buttonBehavior(id, rect2(
    vec2(window.bounds.width - windowResizeHitSize * 2.0, window.bounds.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  ))
  if gui.hover == id: gui.cursorStyle = ResizeTopLeftBottomRight
  if button.pressed: window.updateGrabState(gui)
  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    window.resizeRight(gui)
    window.resizeBottom(gui)

proc bringToFront*(gui: Gui, window: GuiWindow) =
  window.zIndex = gui.highestZIndex + 1

proc drawBackground(window: GuiWindow, gui: Gui) =
  const bodyColor = rgb(49, 51, 56)
  const bodyBorderColor = rgb(49, 51, 56).lighten(0.1)
  const headerColor = rgb(30, 31, 34)
  const headerBorderColor = rgb(30, 31, 34)

  const headerHeight = windowHeaderHeight
  const borderThickness = windowBorderThickness.clamp(1.0, 0.5 * windowHeaderHeight)
  const borderThicknessHalf = borderThickness * 0.5
  const cornerRadius = windowCornerRadius
  const borderCornerRadius = windowCornerRadius - borderThicknessHalf

  let x = 0.0
  let y = 0.0
  let width = window.bounds.size.x
  let height = window.bounds.size.y

  let vg = gui.vg

  # Header fill:
  vg.beginPath()
  vg.roundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  vg.fillColor(headerColor)
  vg.fill()

  # Body fill:
  vg.beginPath()
  vg.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  vg.fillColor(bodyColor)
  vg.fill()

  # Body border:
  vg.beginPath()
  vg.moveTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  vg.lineTo(vec2(x + width - borderThicknessHalf, y + height - cornerRadius))
  vg.arcTo(
    vec2(x + width - borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + width - cornerRadius, y + height - borderThicknessHalf),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + cornerRadius, y + height - borderThicknessHalf))
  vg.arcTo(
    vec2(x + borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + borderThicknessHalf, y + height - cornerRadius),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + borderThicknessHalf, y + headerHeight))
  vg.strokeWidth(borderThickness)
  vg.strokeColor(bodyBorderColor)
  vg.stroke()

  # Header border:
  vg.beginPath()
  vg.moveTo(vec2(x + borderThicknessHalf, y + headerHeight))
  vg.lineTo(vec2(x + borderThicknessHalf, y + cornerRadius))
  vg.arcTo(
    vec2(x + borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + cornerRadius, y + borderThicknessHalf),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + width - cornerRadius, y + borderThicknessHalf))
  vg.arcTo(
    vec2(x + width - borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + width - borderThicknessHalf, y + cornerRadius),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  vg.strokeWidth(borderThickness)
  vg.strokeColor(headerBorderColor)
  vg.stroke()

proc backgroundButton(window: GuiWindow, gui: Gui) =
  let id = gui.getId("BackgroundButton")
  discard gui.buttonBehavior(id, rect2(
    vec2(0, 0),
    vec2(window.bounds.width, window.bounds.height)
  ))

proc beginWindow*(gui: Gui, title: string): GuiWindow =
  let windowId = gui.getId(title)
  let initialBounds = gui.getNextBounds()

  let window = gui.getState(windowId, GuiWindow)
  if window.init:
    window.isOpen = true
    window.minSize = vec2(300, windowHeaderHeight * 2.0)
    window.editBounds = initialBounds

  window.editBounds.size.x = max(window.editBounds.size.x, window.minSize.x)
  window.editBounds.size.y = max(window.editBounds.size.y, window.minSize.y)
  window.bounds = window.editBounds

  if not window.isOpen:
    return

  gui.beginIdSpace(windowId)
  gui.beginLayer("Window", window.bounds.position, window.zIndex)

  if gui.hoverLayer == gui.currentLayer.id and
     gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right):
    gui.bringToFront(window)

  window.drawBackground(gui)
  window.backgroundButton(gui)

  gui.beginLayout(rect2(vec2(0, 0), window.bounds.size))

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