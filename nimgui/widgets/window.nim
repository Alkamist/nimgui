import ../gui
import ../math
import ./button

type
  GuiWindow* = ref object of GuiState
    editBounds*: Rect2
    bounds*: Rect2
    zIndex*: int
    isOpen*: bool
    minSize*: Vec2
    mousePositionWhenGrabbed*: Vec2
    positionWhenGrabbed*: Vec2
    sizeWhenGrabbed*: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 4.0
const windowRoundingInset = (1.0 - sin(45.0.degToRad)) * windowCornerRadius

proc bringToFront*(gui: Gui, window: GuiWindow) =
  window.zIndex = gui.highestZIndex + 1

proc windowInteraction(gui: Gui): bool =
  gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

proc updateGrabState(gui: Gui, window: GuiWindow) =
  window.mousePositionWhenGrabbed = gui.mousePosition
  window.positionWhenGrabbed = window.editBounds.position
  window.sizeWhenGrabbed = window.editBounds.size

proc calculateGrabDelta(gui: Gui, window: GuiWindow): Vec2 =
  gui.mousePosition - window.mousePositionWhenGrabbed

proc move(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.editBounds.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.editBounds.x = window.positionWhenGrabbed.x + grabDelta.x
  window.editBounds.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.editBounds.width < window.minSize.x:
    let correction = window.editBounds.width - window.minSize.x
    window.editBounds.x += correction
    window.editBounds.width -= correction

proc resizeRight(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.editBounds.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.editBounds.width < window.minSize.x:
    let correction = window.editBounds.width - window.minSize.x
    window.editBounds.width -= correction

proc resizeTop(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.editBounds.y = window.positionWhenGrabbed.y + grabDelta.y
  window.editBounds.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.editBounds.height < window.minSize.y:
    let correction = window.editBounds.height - window.minSize.y
    window.editBounds.y += correction
    window.editBounds.height -= correction

proc resizeBottom(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.editBounds.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.editBounds.height < window.minSize.y:
    let correction = window.editBounds.height - window.minSize.y
    window.editBounds.height -= correction

proc moveButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("MoveButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(windowResizeHitSize, windowResizeHitSize),
    vec2(window.bounds.width - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize),
  )

  gui.button(button, bounds)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.move(window)

proc resizeLeftButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeLeftButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(0, windowResizeHitSize),
    vec2(windowResizeHitSize, window.bounds.height - windowResizeHitSize * 2.0)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeLeftRight
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    gui.resizeLeft(window)

proc resizeRightButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeRightButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(window.bounds.width - windowResizeHitSize, windowResizeHitSize),
    vec2(windowResizeHitSize, window.bounds.height - windowResizeHitSize * 2.0)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeLeftRight
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeLeftRight
    gui.resizeRight(window)

proc resizeTopButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeTopButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(windowResizeHitSize * 2.0, 0),
    vec2(window.bounds.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopBottom
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    gui.resizeTop(window)

proc resizeBottomButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeBottomButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(windowResizeHitSize * 2.0, window.bounds.height - windowResizeHitSize),
    vec2(window.bounds.width - windowResizeHitSize * 4.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopBottom
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopBottom
    gui.resizeBottom(window)

proc resizeTopLeftButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeTopLeftButton", GuiButton)
  let bounds = rect2(
    window.bounds.position,
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopLeftBottomRight
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    gui.resizeLeft(window)
    gui.resizeTop(window)

proc resizeTopRightButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeTopRightButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(window.bounds.width - windowResizeHitSize * 2.0, 0),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopRightBottomLeft
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    gui.resizeRight(window)
    gui.resizeTop(window)

proc resizeBottomLeftButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeBottomLeftButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(0, window.bounds.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopRightBottomLeft
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    gui.resizeLeft(window)
    gui.resizeBottom(window)

proc resizeBottomRightButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeBottomRightButton", GuiButton)
  let bounds = rect2(
    window.bounds.position + vec2(window.bounds.width - windowResizeHitSize * 2.0, window.bounds.height - windowResizeHitSize),
    vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  )

  gui.button(button, bounds)

  if gui.hover == button.id:
    gui.cursorStyle = ResizeTopLeftBottomRight
    if gui.windowInteraction:
      gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    gui.resizeRight(window)
    gui.resizeBottom(window)

proc backgroundButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("BackgroundButton", GuiButton)
  let bounds = window.bounds

  gui.button(button, bounds)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

# proc drawShadow(gui: Gui, window: GuiWindow) =
#   const feather = 10.0
#   const feather2 = feather * 2.0

#   let position = window.bounds.position
#   let size = window.bounds.size

#   let vg = gui.vg
#   vg.beginPath()
#   vg.rect(-vec2(feather), size + feather2)
#   vg.roundedRect(position, size, cornerRadius)
#   vg.pathWinding = Hole
#   vg.fillPaint = vg.boxGradient(
#     vec2(position.x, position.y + 2),
#     size,
#     cornerRadius * 2.0,
#     feather,
#     rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
#   )
#   vg.fill()

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

  let x = window.bounds.position.x
  let y = window.bounds.position.y
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
  vg.fillColor = headerColor
  vg.fill()

  # Body fill:
  vg.beginPath()
  vg.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  vg.fillColor = bodyColor
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
  vg.strokeWidth = borderThickness
  vg.strokeColor = bodyBorderColor
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
  vg.strokeWidth = borderThickness
  vg.strokeColor = headerBorderColor
  vg.stroke()

proc bodyBounds*(window: GuiWindow): Rect2 =
  rect2(
    window.bounds.position + vec2(
      windowBorderThickness + windowRoundingInset,
      windowHeaderHeight + windowRoundingInset,
    ),
    vec2(
      window.bounds.width - 2.0 * (windowBorderThickness + windowRoundingInset),
      window.bounds.height - windowHeaderHeight - windowRoundingInset - 2.0 * windowBorderThickness,
    ),
  )

proc beginWindow*(gui: Gui, window: GuiWindow): GuiWindow =
  if not window.isOpen:
    return window

  window.editBounds.size.x = max(window.editBounds.size.x, window.minSize.x)
  window.editBounds.size.y = max(window.editBounds.size.y, window.minSize.y)
  window.bounds = window.editBounds

  gui.pushId(window.id)
  gui.pushZIndex(window.zIndex)
  gui.pushLayout(window.bounds)

  gui.drawBackground(window)
  gui.backgroundButton(window)

  gui.pushLayout(window.bodyBounds)

  window

proc beginWindow*(gui: Gui, id: auto, initialBounds: Rect2): GuiWindow =
  let window = gui.getState(id, GuiWindow)

  if window.init:
    window.isOpen = true
    window.minSize = vec2(300, windowHeaderHeight * 2.0)
    window.editBounds = initialBounds

  gui.beginWindow(window)

proc endWindow*(gui: Gui) =
  gui.popLayout()

  let window = gui.getState(gui.stackId, GuiWindow)
  gui.moveButton(window)
  gui.resizeLeftButton(window)
  gui.resizeRightButton(window)
  gui.resizeTopButton(window)
  gui.resizeBottomButton(window)
  gui.resizeTopLeftButton(window)
  gui.resizeTopRightButton(window)
  gui.resizeBottomLeftButton(window)
  gui.resizeBottomRightButton(window)

  gui.popLayout()
  gui.popZIndex()
  gui.popId()