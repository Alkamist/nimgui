import ../gui
import ./button

type
  GuiWindow* = ref object of GuiControl
    position*: Vec2
    size*: Vec2
    minSize*: Vec2
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
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

proc newWindow*(gui: Gui): GuiWindow =
  GuiWindow(
    gui: gui,
    size: vec2(400, 300),
    minSize: vec2(300, windowHeaderHeight * 2.0),
    backgroundButton: gui.newButton(),
    moveButton: gui.newButton(),
    resizeLeftButton: gui.newButton(),
    resizeRightButton: gui.newButton(),
    resizeTopButton: gui.newButton(),
    resizeBottomButton: gui.newButton(),
    resizeTopLeftButton: gui.newButton(),
    resizeTopRightButton: gui.newButton(),
    resizeBottomLeftButton: gui.newButton(),
    resizeBottomRightButton: gui.newButton(),
  )

proc updateGrabState(window: GuiWindow) =
  window.globalMousePositionWhenGrabbed = window.gui.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: GuiWindow): Vec2 =
  window.gui.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.position.x = window.positionWhenGrabbed.x + grabDelta.x
  window.size.x = window.sizeWhenGrabbed.x - grabDelta.x
  if window.size.x < window.minSize.x:
    let correction = window.size.x - window.minSize.x
    window.position.x += correction
    window.size.x -= correction

proc resizeRight(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.size.x = window.sizeWhenGrabbed.x + grabDelta.x
  if window.size.x < window.minSize.x:
    let correction = window.size.x - window.minSize.x
    window.size.x -= correction

proc resizeTop(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.position.y = window.positionWhenGrabbed.y + grabDelta.y
  window.size.y = window.sizeWhenGrabbed.y - grabDelta.y
  if window.size.y < window.minSize.y:
    let correction = window.size.y - window.minSize.y
    window.position.y += correction
    window.size.y -= correction

proc resizeBottom(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.size.y = window.sizeWhenGrabbed.y + grabDelta.y
  if window.size.y < window.minSize.y:
    let correction = window.size.y - window.minSize.y
    window.size.y -= correction

proc updateMoveButton(window: GuiWindow) =
  let button = window.moveButton
  button.position = vec2(windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

  button.update(invisible = true)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.move()

proc updateResizeLeftButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeLeftButton
  button.position = vec2(0, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeLeftRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    window.resizeLeft()

proc updateResizeRightButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeRightButton
  button.position = vec2(window.size.x - windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.size.y - windowResizeHitSize * 2.0)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeLeftRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    window.resizeRight()

proc updateResizeTopButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeTopButton
  button.position = vec2(windowResizeHitSize * 2.0, 0)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopBottom

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    window.resizeTop()

proc updateResizeBottomButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeBottomButton
  button.position = vec2(windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(window.size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopBottom

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    window.resizeBottom()

proc updateResizeTopLeftButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeTopLeftButton
  button.position = vec2(0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    window.resizeLeft()
    window.resizeTop()

proc updateResizeTopRightButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeTopRightButton
  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    window.resizeRight()
    window.resizeTop()

proc updateResizeBottomLeftButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeBottomLeftButton

  button.position = vec2(0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopRightBottomLeft

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    window.resizeLeft()
    window.resizeBottom()

proc updateResizeBottomRightButton(window: GuiWindow) =
  let gui = window.gui

  let button = window.resizeBottomRightButton
  button.position = vec2(window.size.x - windowResizeHitSize * 2.0, window.size.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  button.update(invisible = true)

  if gui.hover == button:
    gui.cursorStyle = ResizeTopLeftBottomRight

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    window.resizeRight()
    window.resizeBottom()

proc updateBackgroundButton(window: GuiWindow) =
  let button = window.backgroundButton
  button.position = vec2(0, 0)
  button.size = window.size
  button.update(invisible = true)

proc drawShadow(window: GuiWindow) =
  let gui = window.gui
  let position = vec2(0, 0)
  let size = window.size

  const feather = 10.0
  const feather2 = feather * 2.0

  gui.beginPath()
  gui.pathRect(position - vec2(feather, feather), size + feather2)
  gui.pathRoundedRect(position, size, windowCornerRadius)
  gui.pathWinding = Hole
  gui.fillPaint = boxGradient(
    vec2(position.x, position.y + 2),
    size,
    windowCornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  )
  gui.fill()

proc drawBackground(window: GuiWindow) =
  let gui = window.gui

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

  # Header fill:
  gui.beginPath()
  gui.pathRoundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  gui.fillColor = headerColor
  gui.fill()

  # Body fill:
  gui.beginPath()
  gui.pathRoundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  gui.fillColor = bodyColor
  gui.fill()

  # Body border:
  gui.beginPath()
  gui.pathMoveTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  gui.pathLineTo(vec2(x + width - borderThicknessHalf, y + height - cornerRadius))
  gui.pathArcTo(
    vec2(x + width - borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + width - cornerRadius, y + height - borderThicknessHalf),
    borderCornerRadius,
  )
  gui.pathLineTo(vec2(x + cornerRadius, y + height - borderThicknessHalf))
  gui.pathArcTo(
    vec2(x + borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + borderThicknessHalf, y + height - cornerRadius),
    borderCornerRadius,
  )
  gui.pathLineTo(vec2(x + borderThicknessHalf, y + headerHeight))
  gui.strokeWidth = borderThickness
  gui.strokeColor = bodyBorderColor
  gui.stroke()

  # Header border:
  gui.beginPath()
  gui.pathMoveTo(vec2(x + borderThicknessHalf, y + headerHeight))
  gui.pathLineTo(vec2(x + borderThicknessHalf, y + cornerRadius))
  gui.pathArcTo(
    vec2(x + borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + cornerRadius, y + borderThicknessHalf),
    borderCornerRadius,
  )
  gui.pathLineTo(vec2(x + width - cornerRadius, y + borderThicknessHalf))
  gui.pathArcTo(
    vec2(x + width - borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + width - borderThicknessHalf, y + cornerRadius),
    borderCornerRadius,
  )
  gui.pathLineTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  gui.strokeWidth = borderThickness
  gui.strokeColor = headerBorderColor
  gui.stroke()

proc beginUpdate*(window: GuiWindow) =
  let gui = window.gui
  let position = window.position
  let size = window.size
  let minSize = window.minSize

  window.size.x = max(size.x, minSize.x)
  window.size.y = max(size.y, minSize.y)

  # gui.pushId(window.id)
  # gui.pushZIndex(window.zIndex)
  gui.pushOffset(position)

  window.updateBackgroundButton()
  window.drawShadow()
  window.drawBackground()

proc endUpdate*(window: GuiWindow) =
  let gui = window.gui

  window.updateMoveButton()
  window.updateResizeLeftButton()
  window.updateResizeRightButton()
  window.updateResizeTopButton()
  window.updateResizeBottomButton()
  window.updateResizeTopLeftButton()
  window.updateResizeTopRightButton()
  window.updateResizeBottomLeftButton()
  window.updateResizeBottomRightButton()

  # for id in gui.childIds:
  #   if gui.hover == id and gui.windowInteraction:
  #     gui.bringToFront(window)
  #     break

  gui.popOffset()

# proc headerPosition*(window: GuiWindow): Vec2 =
#   vec2(
#     windowBorderThickness + windowRoundingInset,
#     windowBorderThickness + windowRoundingInset,
#   )

# proc headerSize*(window: GuiWindow): Vec2 =
#   vec2(
#     size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
#     windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
#   )

# proc beginHeader*(gui: Gui, window: GuiWindow): tuple[position, size: Vec2] {.discardable.} =
#   result.position = vec2(
#     windowBorderThickness + windowRoundingInset,
#     windowBorderThickness + windowRoundingInset,
#   )
#   result.size = vec2(
#     size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
#     windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
#   )
#   gui.pushOffset(result.position)
#   # gui.pushClip(vec2(0, 0), result.size)

# proc endHeader*(gui: Gui) =
#   # gui.popClip()
#   gui.popOffset()

proc beginBody*(window: GuiWindow) =
  let gui = window.gui
  let position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  )
  # let size = vec2(
  #   window.size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
  #   window.size.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  # )
  gui.pushOffset(position)
  # gui.pushClip(vec2(0, 0), result.size)

proc endBody*(gui: Gui) =
  # gui.popClip()
  gui.popOffset()