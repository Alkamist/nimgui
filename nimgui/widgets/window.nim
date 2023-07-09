import std/math
import ../gui
import ./button

type
  WindowState = object
    positionPtr: ptr Vec2
    sizePtr: ptr Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

# proc bringToFront*(window: Window) =
#   window.zIndex = window.parent.highestChildZIndex + 1
#   if window.parent of Window:
#     Window(window.parent).bringToFront()

# proc updateWindowState(gui: Gui, window: Window) =
#   window.globalMousePositionWhenGrabbed = window.globalMousePosition
#   window.positionWhenGrabbed = window.position
#   window.sizeWhenGrabbed = window.size

# proc calculateGrabDelta(window: Window): Vec2 =
#   window.globalMousePosition - window.globalMousePositionWhenGrabbed

# proc move(window: Window) =
#   let grabDelta = window.calculateGrabDelta()
#   window.position = window.positionWhenGrabbed + grabDelta

# proc resizeLeft(window: Window) =
#   let grabDelta = window.calculateGrabDelta()
#   window.position.x = window.positionWhenGrabbed.x + grabDelta.x
#   window.size.x = window.sizeWhenGrabbed.x - grabDelta.x
#   if window.size.x < window.currentMinSize.x:
#     let correction = window.size.x - window.currentMinSize.x
#     window.position.x += correction
#     window.size.x -= correction

# proc resizeRight(window: Window) =
#   let grabDelta = window.calculateGrabDelta()
#   window.size.x = window.sizeWhenGrabbed.x + grabDelta.x
#   if window.size.x < window.currentMinSize.x:
#     let correction = window.size.x - window.currentMinSize.x
#     window.size.x -= correction

# proc resizeTop(window: Window) =
#   let grabDelta = window.calculateGrabDelta()
#   window.position.y = window.positionWhenGrabbed.y + grabDelta.y
#   window.size.y = window.sizeWhenGrabbed.y - grabDelta.y
#   if window.size.y < window.currentMinSize.y:
#     let correction = window.size.y - window.currentMinSize.y
#     window.position.y += correction
#     window.size.y -= correction

# proc resizeBottom(window: Window) =
#   let grabDelta = window.calculateGrabDelta()
#   window.size.y = window.sizeWhenGrabbed.y + grabDelta.y
#   if window.size.y < window.currentMinSize.y:
#     let correction = window.size.y - window.currentMinSize.y
#     window.size.y -= correction

# proc updateMoveButton(window: Window) =
#   let button = window.getNode("MoveButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(windowResizeHitSize, windowResizeHitSize)
#   button.size = vec2(window.size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

#   button.update(draw = false)

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.move()

# proc updateResizeLeftButton(window: Window) =
#   let button = window.getNode("ResizeLeftButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(0, windowResizeHitSize)
#   button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeLeftRight

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeLeftRight
#     window.resizeLeft()

# proc updateResizeRightButton(window: Window) =
#   let button = window.getNode("ResizeRightButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(window.size.x - windowResizeHitSize, windowResizeHitSize)
#   button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeLeftRight

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeLeftRight
#     window.resizeRight()

# proc updateResizeTopButton(window: Window) =
#   let button = window.getNode("ResizeTopButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(windowResizeHitSize * 2.0, 0)
#   button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopBottom

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopBottom
#     window.resizeTop()

# proc updateResizeBottomButton(window: Window) =
#   let button = window.getNode("ResizeBottomButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
#   button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopBottom

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopBottom
#     window.resizeBottom()

# proc updateResizeTopLeftButton(window: Window) =
#   let button = window.getNode("ResizeTopLeftButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(0, 0)
#   button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopLeftBottomRight

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopLeftBottomRight
#     window.resizeLeft()
#     window.resizeTop()

# proc updateResizeTopRightButton(window: Window) =
#   let button = window.getNode("ResizeTopRightButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(window.size.x - windowResizeHitSize * 2.0, 0)
#   button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopRightBottomLeft

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopRightBottomLeft
#     window.resizeRight()
#     window.resizeTop()

# proc updateResizeBottomLeftButton(window: Window) =
#   let button = window.getNode("ResizeBottomLeftButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(0, window.size.y - windowResizeHitSize)
#   button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopRightBottomLeft

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopRightBottomLeft
#     window.resizeLeft()
#     window.resizeBottom()

# proc updateResizeBottomRightButton(window: Window) =
#   let button = window.getNode("ResizeBottomRightButton", Button)
#   if button.init:
#     button.zIndex = 1

#   button.position = vec2(window.size.x - windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
#   button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

#   button.update(draw = false)

#   if button.isHovered:
#     window.cursorStyle = ResizeTopLeftBottomRight

#   if button.pressed:
#     window.updateGrabState()

#   if button.isDown:
#     window.cursorStyle = ResizeTopLeftBottomRight
#     window.resizeRight()
#     window.resizeBottom()

# proc updateBackgroundButton(window: Window) =
#   let button = window.getNode("BackgroundButton", Button)
#   button.position = vec2(0, 0)
#   button.size = window.size
#   button.update(draw = false)

proc drawWindowShadow(gui: Gui, position, size: Vec2) =
  const feather = 10.0
  const feather2 = feather * 2.0

  let path = Path.new()
  path.rect(position - vec2(feather, feather), size + feather2)
  path.roundedRect(position, size, windowCornerRadius, Negative)
  gui.fillPath(path, boxGradient(
    vec2(position.x, position.y + 2),
    size,
    windowCornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  ))

proc drawWindowBackground(gui: Gui, position, size: Vec2) =
  const bodyColor = rgb(49, 51, 56)
  const bodyBorderColor = rgb(49, 51, 56).lighten(0.1)
  const headerColor = rgb(30, 31, 34)
  const headerBorderColor = rgb(30, 31, 34)

  const headerHeight = windowHeaderHeight
  const borderThickness = windowBorderThickness.clamp(1.0, 0.5 * windowHeaderHeight)
  const borderThicknessHalf = borderThickness * 0.5
  const cornerRadius = windowCornerRadius
  const borderCornerRadius = windowCornerRadius - borderThicknessHalf

  let x = position.x
  let y = position.y
  let width = size.x
  let height = size.y

  let path = Path.new()

  # Header fill:
  path.roundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  gui.fillPath(path, headerColor)
  path.clear()

  # Body fill:
  path.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  gui.fillPath(path, bodyColor)
  path.clear()

  # Body border:
  path.moveTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  path.lineTo(vec2(x + width - borderThicknessHalf, y + height - cornerRadius))
  path.arcTo(
    vec2(x + width - borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + width - cornerRadius, y + height - borderThicknessHalf),
    borderCornerRadius,
  )
  path.lineTo(vec2(x + cornerRadius, y + height - borderThicknessHalf))
  path.arcTo(
    vec2(x + borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + borderThicknessHalf, y + height - cornerRadius),
    borderCornerRadius,
  )
  path.lineTo(vec2(x + borderThicknessHalf, y + headerHeight))
  gui.strokePath(path, bodyBorderColor, borderThickness)
  path.clear()

  # Header border:
  path.moveTo(vec2(x + borderThicknessHalf, y + headerHeight))
  path.lineTo(vec2(x + borderThicknessHalf, y + cornerRadius))
  path.arcTo(
    vec2(x + borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + cornerRadius, y + borderThicknessHalf),
    borderCornerRadius,
  )
  path.lineTo(vec2(x + width - cornerRadius, y + borderThicknessHalf))
  path.arcTo(
    vec2(x + width - borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + width - borderThicknessHalf, y + cornerRadius),
    borderCornerRadius,
  )
  path.lineTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  gui.strokePath(path, headerBorderColor, borderThickness)
  path.clear()

proc beginWindow*(gui: Gui, id: GuiId,
  position, size: var Vec2,
  minSize = vec2(300, windowHeaderHeight * 2.0),
  draw = true,
) =
  size.x = max(size.x, minSize.x)
  size.y = max(size.y, minSize.y)

  if draw:
    gui.drawWindowShadow(position, size)
    gui.drawWindowBackground(position, size)

  var state = gui.getState(id, WindowState)
  state.positionPtr = addr(position)
  state.sizePtr = addr(size)
  gui.setState(id, state)

  gui.pushId(id)
  gui.pushOffset(position)

proc endWindow*(gui: Gui) =
  let id = gui.popId()
  var state = gui.getState(id, WindowState)

  var position =
    if state.positionPtr != nil: state.positionPtr[]
    else: vec2(0, 0)

  var size =
    if state.sizePtr != nil: state.sizePtr[]
    else: vec2(0, 0)

  gui.pushId(id)

  let moveButton = gui.button("MoveButton",
    position = vec2(windowResizeHitSize, windowResizeHitSize),
    size = vec2(size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize),
  )

  if moveButton.pressed:
    state.globalMousePositionWhenGrabbed = gui.globalMousePosition
    state.positionWhenGrabbed = position
    state.sizeWhenGrabbed = size

  template grabDelta(): Vec2 =
    gui.globalMousePosition - state.globalMousePositionWhenGrabbed

  if moveButton.isDown:
    position = state.positionWhenGrabbed + grabDelta()

  gui.popId()
  gui.popOffset()

  if state.positionPtr != nil:
    state.positionPtr[] = position

  if state.sizePtr != nil:
    state.sizePtr[] = size

  gui.setState(id, state)