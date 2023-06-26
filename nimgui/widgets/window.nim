import ../gui
import ./button

type
  GuiWindow* = ref object of GuiState
    position*: Vec2
    size*: Vec2
    visualPosition*: Vec2
    visualSize*: Vec2
    zIndex*: int
    minSize*: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

proc bringToFront*(gui: Gui, window: GuiWindow) =
  window.zIndex = gui.highestZIndex + 1

proc windowInteraction(gui: Gui): bool =
  gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

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

proc moveButton(gui: Gui, window: GuiWindow) =
  let position = vec2(windowResizeHitSize, windowResizeHitSize)
  let size = vec2(window.visualSize.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)
  let button = gui.invisibleButton("MoveButton", position, size)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.move(window)

proc resizeLeftButton(gui: Gui, window: GuiWindow) =
  let position = vec2(0, windowResizeHitSize)
  let size = vec2(windowResizeHitSize, window.visualSize.y - windowResizeHitSize * 2.0)
  let button = gui.invisibleButton("ResizeLeftButton", position, size)

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
  let position = vec2(window.visualSize.x - windowResizeHitSize, windowResizeHitSize)
  let size = vec2(windowResizeHitSize, window.visualSize.y - windowResizeHitSize * 2.0)
  let button = gui.invisibleButton("ResizeRightButton", position, size)

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
  let position = vec2(windowResizeHitSize * 2.0, 0)
  let size = vec2(window.visualSize.x - windowResizeHitSize * 4.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeTopButton", position, size)

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
  let position = vec2(windowResizeHitSize * 2.0, window.visualSize.y - windowResizeHitSize)
  let size = vec2(window.visualSize.x - windowResizeHitSize * 4.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeBottomButton", position, size)

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
  let position = vec2(0, 0)
  let size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeTopLeftButton", position, size)

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
  let position = vec2(window.visualSize.x - windowResizeHitSize * 2.0, 0)
  let size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeTopRightButton", position, size)

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
  let position = vec2(0, window.visualSize.y - windowResizeHitSize)
  let size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeBottomLeftButton", position, size)

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
  let position = vec2(window.visualSize.x - windowResizeHitSize * 2.0, window.visualSize.y - windowResizeHitSize)
  let size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)
  let button = gui.invisibleButton("ResizeBottomRightButton", position, size)

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
  let position = vec2(0, 0)
  let size = window.size
  let button = gui.invisibleButton("BackgroundButton", position, size)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

proc drawShadow(gui: Gui, window: GuiWindow) =
  const feather = 10.0
  const feather2 = feather * 2.0

  let position = vec2(0, 0)
  let size = window.visualSize

  gui.beginPath()
  gui.pathRect(-vec2(feather, feather), size + feather2)
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
  let width = window.visualSize.x
  let height = window.visualSize.y

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

proc beginWindow*(gui: Gui, id: GuiId, position, size: Vec2, minSize = vec2(300, windowHeaderHeight * 2.0), zIndex = 0): GuiWindow {.discardable.} =
  let window = gui.getState(id, GuiWindow)
  if window.init:
    window.position = position
    window.size = size
    window.minSize = minSize
    window.zIndex = zIndex

  window.size.x = max(window.size.x, window.minSize.x)
  window.size.y = max(window.size.y, window.minSize.y)
  window.visualPosition = window.position
  window.visualSize = window.size

  gui.pushId(window.id)
  gui.pushZIndex(window.zIndex)
  gui.pushOffset(window.position)
  gui.drawShadow(window)
  gui.drawBackground(window)
  gui.backgroundButton(window)

  window

proc beginWindow*(gui: Gui, id: string, position, size: Vec2, minSize = vec2(300, windowHeaderHeight * 2.0), zIndex = 0): GuiWindow {.discardable.} =
  gui.beginWindow(gui.getId(id), position, size, minSize, zIndex)

proc endWindow*(gui: Gui) =
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

  gui.popOffset()
  gui.popZIndex()
  gui.popId()

proc beginHeader*(gui: Gui, window: GuiWindow): tuple[position, size: Vec2] {.discardable.} =
  result.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowBorderThickness + windowRoundingInset,
  )
  result.size = vec2(
    window.visualSize.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  gui.pushOffset(result.position)
  gui.pushClip(vec2(0, 0), result.size)

proc endHeader*(gui: Gui) =
  gui.popClip()
  gui.popOffset()

proc beginBody*(gui: Gui, window: GuiWindow): tuple[position, size: Vec2] {.discardable.} =
  result.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  )
  result.size = vec2(
    window.visualSize.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    window.visualSize.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  gui.pushOffset(result.position)
  gui.pushClip(vec2(0, 0), result.size)

proc endBody*(gui: Gui) =
  gui.popClip()
  gui.popOffset()