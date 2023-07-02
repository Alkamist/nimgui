import std/math
import ../gui
import ./button

type
  GuiWindow* = ref object of GuiElement
    position*: Vec2
    size*: Vec2
    minSize*: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2
    backgroundButton: GuiButton
    moveButton: GuiButton
    resizeLeftButton: GuiButton
    resizeRightButton: GuiButton
    resizeTopButton: GuiButton
    resizeBottomButton: GuiButton
    resizeTopLeftButton: GuiButton
    resizeTopRightButton: GuiButton
    resizeBottomLeftButton: GuiButton
    resizeBottomRightButton: GuiButton

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

proc drawShadow(gui: Gui, window: GuiWindow) =
  let position = vec2(0, 0)
  let size = window.size

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

proc drawBackground(gui: Gui, window: GuiWindow) =
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

proc new*(_: typedesc[GuiWindow]): GuiWindow =
  result = GuiWindow()
  result.size = vec2(400, 300)
  result.minSize = vec2(300, windowHeaderHeight * 2.0)
  result.draw = proc(gui: Gui, element: GuiElement) =
    let window = GuiWindow(element)
    gui.drawShadow(window)
    gui.drawBackground(window)

  result.backgroundButton = GuiButton.new()
  result.moveButton = GuiButton.new()
  result.resizeLeftButton = GuiButton.new()
  result.resizeRightButton = GuiButton.new()
  result.resizeTopButton = GuiButton.new()
  result.resizeBottomButton = GuiButton.new()
  result.resizeTopLeftButton = GuiButton.new()
  result.resizeTopRightButton = GuiButton.new()
  result.resizeBottomLeftButton = GuiButton.new()
  result.resizeBottomRightButton = GuiButton.new()

  result.backgroundButton.draw = nil
  result.moveButton.draw = nil
  result.resizeLeftButton.draw = nil
  result.resizeRightButton.draw = nil
  result.resizeTopButton.draw = nil
  result.resizeBottomButton.draw = nil
  result.resizeTopLeftButton.draw = nil
  result.resizeTopRightButton.draw = nil
  result.resizeBottomLeftButton.draw = nil
  result.resizeBottomRightButton.draw = nil

proc updateGrabState(gui: Gui, window: GuiWindow) =
  window.globalMousePositionWhenGrabbed = gui.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(gui: Gui, window: GuiWindow): Vec2 =
  gui.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.position.x = window.positionWhenGrabbed.x + grabDelta.x
  window.size.x = window.sizeWhenGrabbed.x - grabDelta.x
  if window.size.x < window.minSize.x:
    let correction = window.size.x - window.minSize.x
    window.position.x += correction
    window.size.x -= correction

proc resizeRight(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.size.x = window.sizeWhenGrabbed.x + grabDelta.x
  if window.size.x < window.minSize.x:
    let correction = window.size.x - window.minSize.x
    window.size.x -= correction

proc resizeTop(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.position.y = window.positionWhenGrabbed.y + grabDelta.y
  window.size.y = window.sizeWhenGrabbed.y - grabDelta.y
  if window.size.y < window.minSize.y:
    let correction = window.size.y - window.minSize.y
    window.position.y += correction
    window.size.y -= correction

proc resizeBottom(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.size.y = window.sizeWhenGrabbed.y + grabDelta.y
  if window.size.y < window.minSize.y:
    let correction = window.size.y - window.minSize.y
    window.size.y -= correction

proc updateMoveButton(gui: Gui, window: GuiWindow) =
  let button = window.moveButton
  button.position = vec2(windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

  gui.update(button)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.move(window)

proc updateResizeLeftButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeLeftButton
  button.position = vec2(0, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeLeftRight

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    gui.resizeLeft(window)

proc updateResizeRightButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeRightButton
  button.position = vec2(window.size.x - windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeLeftRight

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    gui.resizeRight(window)

proc updateResizeTopButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeTopButton
  button.position = vec2(windowResizeHitSize * 2.0, 0)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopBottom

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    gui.resizeTop(window)

proc updateResizeBottomButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeBottomButton
  button.position = vec2(windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopBottom

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    gui.resizeBottom(window)

proc updateResizeTopLeftButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeTopLeftButton
  button.position = vec2(0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    gui.resizeLeft(window)
    gui.resizeTop(window)

proc updateResizeTopRightButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeTopRightButton
  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    gui.resizeRight(window)
    gui.resizeTop(window)

proc updateResizeBottomLeftButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeBottomLeftButton
  button.position = vec2(0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    gui.resizeLeft(window)
    gui.resizeBottom(window)

proc updateResizeBottomRightButton(gui: Gui, window: GuiWindow) =
  let button = window.resizeBottomRightButton
  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

  if gui.isHovered(button):
    gui.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    gui.resizeRight(window)
    gui.resizeBottom(window)

proc updateBackgroundButton(gui: Gui, window: GuiWindow) =
  let button = window.backgroundButton
  button.position = vec2(0, 0)
  button.size = window.size
  gui.update(button)

proc update*(gui: Gui, window: GuiWindow) =
  gui.register(window)

  window.size.x = max(window.size.x, window.minSize.x)
  window.size.y = max(window.size.y, window.minSize.y)

  gui.updateBackgroundButton(window)

  gui.updateMoveButton(window)
  gui.updateResizeLeftButton(window)
  gui.updateResizeRightButton(window)
  gui.updateResizeTopButton(window)
  gui.updateResizeBottomButton(window)
  gui.updateResizeTopLeftButton(window)
  gui.updateResizeTopRightButton(window)
  gui.updateResizeBottomLeftButton(window)
  gui.updateResizeBottomRightButton(window)

  # if window.childIsHovered and
  #     (window.mousePressed(Left) or window.mousePressed(Middle) or window.mousePressed(Right)):
  #   window.bringToFront()

# type
#   GuiWindowHeader* = ref object of GuiNode
#     size*: Vec2

# proc header*(window: GuiWindow): GuiWindowHeader =
#   window.getNode("Header", GuiWindowHeader)

# proc update*(header: GuiWindowHeader) =
#   header.register()
#   let window = GuiWindow(header.parent)
#   header.position = vec2(
#     windowBorderThickness + windowRoundingInset,
#     windowBorderThickness + windowRoundingInset,
#   )
#   header.size = vec2(
#     window.size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
#     windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
#   )

# type
#   GuiWindowBody* = ref object of GuiNode
#     size*: Vec2

# proc body*(window: GuiWindow): GuiWindowBody =
#   window.getNode("Body", GuiWindowBody)

# proc update*(body: GuiWindowBody) =
#   body.register()
#   let window = GuiWindow(body.parent)
#   body.position = vec2(
#     windowBorderThickness + windowRoundingInset,
#     windowHeaderHeight + windowRoundingInset,
#   )
#   body.size = vec2(
#     window.size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
#     window.size.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
#   )