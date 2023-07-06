import std/math
import ../gui
import ./button

type
  Window* = ref object of GuiNode
    currentMinSize: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

proc bringToFront*(window: Window) =
  window.zIndex = window.parent.highestChildZIndex + 1
  if window.parent of Window:
    Window(window.parent).bringToFront()

proc minSize*(window: Window): Vec2 =
  window.currentMinSize

proc `minSize=`*(window: Window, value: Vec2) =
  window.currentMinSize = value
  if window.size.x < window.currentMinSize.x:
    window.size.x = window.currentMinSize.x
  if window.size.y < window.currentMinSize.y:
    window.size.y = window.currentMinSize.y

proc updateGrabState(window: Window) =
  window.globalMousePositionWhenGrabbed = window.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: Window): Vec2 =
  window.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.position.x = window.positionWhenGrabbed.x + grabDelta.x
  window.size.x = window.sizeWhenGrabbed.x - grabDelta.x
  if window.size.x < window.currentMinSize.x:
    let correction = window.size.x - window.currentMinSize.x
    window.position.x += correction
    window.size.x -= correction

proc resizeRight(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.size.x = window.sizeWhenGrabbed.x + grabDelta.x
  if window.size.x < window.currentMinSize.x:
    let correction = window.size.x - window.currentMinSize.x
    window.size.x -= correction

proc resizeTop(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.position.y = window.positionWhenGrabbed.y + grabDelta.y
  window.size.y = window.sizeWhenGrabbed.y - grabDelta.y
  if window.size.y < window.currentMinSize.y:
    let correction = window.size.y - window.currentMinSize.y
    window.position.y += correction
    window.size.y -= correction

proc resizeBottom(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.size.y = window.sizeWhenGrabbed.y + grabDelta.y
  if window.size.y < window.currentMinSize.y:
    let correction = window.size.y - window.currentMinSize.y
    window.size.y -= correction

proc updateMoveButton(window: Window) =
  let button = window.getNode("MoveButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

  button.update(draw = false)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.move()

proc updateResizeLeftButton(window: Window) =
  let button = window.getNode("ResizeLeftButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(0, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeLeftRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeLeftRight
    window.resizeLeft()

proc updateResizeRightButton(window: Window) =
  let button = window.getNode("ResizeRightButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(window.size.x - windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeLeftRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeLeftRight
    window.resizeRight()

proc updateResizeTopButton(window: Window) =
  let button = window.getNode("ResizeTopButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(windowResizeHitSize * 2.0, 0)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopBottom

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopBottom
    window.resizeTop()

proc updateResizeBottomButton(window: Window) =
  let button = window.getNode("ResizeBottomButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopBottom

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopBottom
    window.resizeBottom()

proc updateResizeTopLeftButton(window: Window) =
  let button = window.getNode("ResizeTopLeftButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopLeftBottomRight
    window.resizeLeft()
    window.resizeTop()

proc updateResizeTopRightButton(window: Window) =
  let button = window.getNode("ResizeTopRightButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopRightBottomLeft
    window.resizeRight()
    window.resizeTop()

proc updateResizeBottomLeftButton(window: Window) =
  let button = window.getNode("ResizeBottomLeftButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopRightBottomLeft
    window.resizeLeft()
    window.resizeBottom()

proc updateResizeBottomRightButton(window: Window) =
  let button = window.getNode("ResizeBottomRightButton", Button)
  if button.init:
    button.zIndex = 1

  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(draw = false)

  if button.isHovered:
    window.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.cursorStyle = ResizeTopLeftBottomRight
    window.resizeRight()
    window.resizeBottom()

proc updateBackgroundButton(window: Window) =
  let button = window.getNode("BackgroundButton", Button)
  button.position = vec2(0, 0)
  button.size = window.size
  button.update(draw = false)

proc drawShadow(window: Window) =
  let position = vec2(0, 0)
  let size = window.size

  const feather = 10.0
  const feather2 = feather * 2.0

  let path = Path.new()
  path.rect(position - vec2(feather, feather), size + feather2)
  path.roundedRect(position, size, windowCornerRadius, Negative)
  window.fillPath(path, boxGradient(
    vec2(position.x, position.y + 2),
    size,
    windowCornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  ))

proc drawBackground(window: Window) =
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
  let width = window.size.x
  let height = window.size.y

  let path = Path.new()

  # Header fill:
  path.roundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  window.fillPath(path, headerColor)
  path.clear()

  # Body fill:
  path.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  window.fillPath(path, bodyColor)
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
  window.strokePath(path, bodyBorderColor, borderThickness)
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
  window.strokePath(path, headerBorderColor, borderThickness)
  path.clear()

proc header*(window: Window): GuiNode =
  window.getNode("Header")

proc body*(window: Window): GuiNode =
  window.getNode("Body")

proc setDefault*(window: Window) =
  window.zIndex = 1
  window.size = vec2(400, 300)
  window.minSize = vec2(300, windowHeaderHeight * 2.0)
  window.header.clipChildren = true
  window.body.clipChildren = true

proc getWindow*(node: GuiNode, name: string): Window =
  result = node.getNode(name, Window)
  if result.init:
    result.setDefault()

proc update*(window: Window, draw = true) =
  GuiNode(window).update()

  window.size.x = max(window.size.x, window.currentMinSize.x)
  window.size.y = max(window.size.y, window.currentMinSize.y)

  if window.childIsHovered and
    (window.mousePressed(Left) or window.mousePressed(Middle) or window.mousePressed(Right)):
    window.bringToFront()

  window.updateBackgroundButton()
  window.updateMoveButton()
  window.updateResizeLeftButton()
  window.updateResizeRightButton()
  window.updateResizeTopButton()
  window.updateResizeBottomButton()
  window.updateResizeTopLeftButton()
  window.updateResizeTopRightButton()
  window.updateResizeBottomLeftButton()
  window.updateResizeBottomRightButton()

  let body = window.body
  body.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  )
  body.size = vec2(
    window.size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    window.size.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  body.update()

  let header = window.header
  header.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowBorderThickness + windowRoundingInset,
  )
  header.size = vec2(
    window.size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  header.update()

  if not draw:
    return

  window.drawShadow()
  window.drawBackground()