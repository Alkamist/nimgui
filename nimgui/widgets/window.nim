import std/math
import ../gui
import ./button

type
  Window* = ref object of RootRef
    currentPosition: Vec2
    currentSize: Vec2
    pendingPosition: Vec2
    pendingSize: Vec2
    minSize: Vec2
    zIndex: int
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

const windowHeaderHeight = 22.0
const windowResizeHitSize = 5.0
const windowBorderThickness = 1.0
const windowCornerRadius = 3.0
const windowRoundingInset = ceil((1.0 - sin(45.0.degToRad)) * windowCornerRadius)

proc position*(window: Window): Vec2 =
  window.currentPosition

proc `position=`*(window: Window, value: Vec2) =
  window.pendingPosition = value

proc size*(window: Window): Vec2 =
  window.currentSize

proc `size=`*(window: Window, value: Vec2) =
  window.pendingSize = value

proc windowInteraction(gui: Gui): bool =
  gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

proc windowId(gui: Gui): GuiId =
  gui.getId("_Window")

proc highestWindowZIndexStateId(gui: Gui): GuiId =
  gui.getId("HIGHEST_WINDOW_Z_INDEX", global = true)

proc highestWindowZIndex(gui: Gui): int =
  gui.getState(gui.highestWindowZIndexStateId, 0)

proc `highestWindowZIndex=`(gui: Gui, value: int) =
  gui.setState(gui.highestWindowZIndexStateId, value)

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

proc windowMoveAndResizeBehavior(gui: Gui, window: Window) =
  var position = window.position
  var size = window.size

  template grabDelta(): Vec2 =
    gui.globalMousePosition - window.globalMousePositionWhenGrabbed

  template resizeLeft() =
    let grabDelta = grabDelta()
    position.x = window.positionWhenGrabbed.x + grabDelta.x
    size.x = window.sizeWhenGrabbed.x - grabDelta.x
    if size.x < window.minSize.x:
      let correction = size.x - window.minSize.x
      position.x += correction
      size.x -= correction

  template resizeRight() =
    let grabDelta = grabDelta()
    size.x = window.sizeWhenGrabbed.x + grabDelta.x
    if size.x < window.minSize.x:
      let correction = size.x - window.minSize.x
      size.x -= correction

  template resizeTop() =
    let grabDelta = grabDelta()
    position.y = window.positionWhenGrabbed.y + grabDelta.y
    size.y = window.sizeWhenGrabbed.y - grabDelta.y
    if size.y < window.minSize.y:
      let correction = size.y - window.minSize.y
      position.y += correction
      size.y -= correction

  template resizeBottom() =
    let grabDelta = grabDelta()
    size.y = window.sizeWhenGrabbed.y + grabDelta.y
    if size.y < window.minSize.y:
      let correction = size.y - window.minSize.y
      size.y -= correction

  let moveButton = gui.button("_MoveButton",
    position = vec2(windowResizeHitSize, windowResizeHitSize),
    size = vec2(size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize),
    draw = false,
  )

  let resizeLeftButtonId = gui.getId("_ResizeLeftButton")
  let resizeLeftButton = gui.button(resizeLeftButtonId,
    position = vec2(0, windowResizeHitSize),
    size = vec2(windowResizeHitSize, size.y - windowResizeHitSize * 2.0),
    draw = false,
  )
  if gui.isHovered(resizeLeftButtonId):
    gui.cursorStyle = ResizeLeftRight

  let resizeRightButtonId = gui.getId("_ResizeRightButton")
  let resizeRightButton = gui.button(resizeRightButtonId,
    position = vec2(size.x - windowResizeHitSize, windowResizeHitSize),
    size = vec2(windowResizeHitSize, size.y - windowResizeHitSize * 2.0),
    draw = false,
  )
  if gui.isHovered(resizeRightButtonId):
    gui.cursorStyle = ResizeLeftRight

  let resizeTopButtonId = gui.getId("_ResizeTopButton")
  let resizeTopButton = gui.button(resizeTopButtonId,
    position = vec2(windowResizeHitSize * 2.0, 0),
    size = vec2(size.x - windowResizeHitSize * 4.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeTopButtonId):
    gui.cursorStyle = ResizeTopBottom

  let resizeBottomButtonId = gui.getId("_ResizeBottomButton")
  let resizeBottomButton = gui.button(resizeBottomButtonId,
    position = vec2(windowResizeHitSize * 2.0, size.y - windowResizeHitSize),
    size = vec2(size.x - windowResizeHitSize * 4.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeBottomButtonId):
    gui.cursorStyle = ResizeTopBottom

  let resizeTopLeftButtonId = gui.getId("_ResizeTopLeftButton")
  let resizeTopLeftButton = gui.button(resizeTopLeftButtonId,
    position = vec2(0, 0),
    size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeTopLeftButtonId):
    gui.cursorStyle = ResizeTopLeftBottomRight

  let resizeTopRightButtonId = gui.getId("_ResizeTopRightButton")
  let resizeTopRightButton = gui.button(resizeTopRightButtonId,
    position = vec2(size.x - windowResizeHitSize * 2.0, 0),
    size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeTopRightButtonId):
    gui.cursorStyle = ResizeTopRightBottomLeft

  let resizeBottomLeftButtonId = gui.getId("_ResizeBottomLeftButton")
  let resizeBottomLeftButton = gui.button(resizeBottomLeftButtonId,
    position = vec2(0, size.y - windowResizeHitSize),
    size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeBottomLeftButtonId):
    gui.cursorStyle = ResizeTopRightBottomLeft

  let resizeBottomRightButtonId = gui.getId("_ResizeBottomRightButton")
  let resizeBottomRightButton = gui.button(resizeBottomRightButtonId,
    position = vec2(size.x - windowResizeHitSize * 2.0, size.y - windowResizeHitSize),
    size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize),
    draw = false,
  )
  if gui.isHovered(resizeBottomRightButtonId):
    gui.cursorStyle = ResizeTopLeftBottomRight

  if moveButton.pressed or
     resizeLeftButton.pressed or resizeRightButton.pressed or
     resizeTopButton.pressed or resizeBottomButton.pressed or
     resizeTopLeftButton.pressed or resizeTopRightButton.pressed or
     resizeBottomLeftButton.pressed or resizeBottomRightButton.pressed:
    window.globalMousePositionWhenGrabbed = gui.globalMousePosition
    window.positionWhenGrabbed = position
    window.sizeWhenGrabbed = size

  if moveButton.isDown:
    position = window.positionWhenGrabbed + grabDelta()

  if resizeLeftButton.isDown:
    gui.cursorStyle = ResizeLeftRight
    resizeLeft()

  if resizeRightButton.isDown:
    gui.cursorStyle = ResizeLeftRight
    resizeRight()

  if resizeTopButton.isDown:
    gui.cursorStyle = ResizeTopBottom
    resizeTop()

  if resizeBottomButton.isDown:
    gui.cursorStyle = ResizeTopBottom
    resizeBottom()

  if resizeTopLeftButton.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    resizeLeft()
    resizeTop()

  if resizeTopRightButton.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    resizeRight()
    resizeTop()

  if resizeBottomLeftButton.isDown:
    gui.cursorStyle = ResizeTopRightBottomLeft
    resizeLeft()
    resizeBottom()

  if resizeBottomRightButton.isDown:
    gui.cursorStyle = ResizeTopLeftBottomRight
    resizeRight()
    resizeBottom()

  window.position = position
  window.size = size

proc bringWindowToFront*(gui: Gui, id: GuiId) =
  gui.pushIdSpace(id)
  let window = gui.getState(gui.windowId, Window)
  gui.popIdSpace()
  let zIndex = gui.highestWindowZIndex + 1
  window.zIndex = zIndex
  gui.highestWindowZIndex = zIndex

proc beginWindow*(gui: Gui, id: GuiId,
  initialPosition: Vec2,
  initialSize = vec2(400, 300),
  minSize = vec2(300, windowHeaderHeight * 2.0),
  draw = true,
) {.discardable.} =
  gui.pushIdSpace(id)

  let window = gui.getState(gui.windowId, Window(
    currentPosition: initialPosition,
    currentSize: initialSize,
    pendingPosition: initialPosition,
    pendingSize: initialSize,
  ))
  var position = window.position
  var size = window.size

  gui.pushZIndex(window.zIndex, global = true)

  size.x = max(size.x, minSize.x)
  size.y = max(size.y, minSize.y)

  if draw:
    gui.drawWindowShadow(position, size)
    gui.drawWindowBackground(position, size)

  window.minSize = minSize
  window.position = position
  window.size = size

  gui.pushOffset(position, global = true)
  if gui.windowInteraction:
    gui.pushInteractionTracker()

  # Blocks mouse input from going through the window.
  gui.button("_BackgroundButton",
    position = vec2(0, 0),
    size = size,
    draw = false,
  )

proc beginWindow*(gui: Gui, id: string,
  initialPosition: Vec2,
  initialSize = vec2(400, 300),
  minSize = vec2(300, windowHeaderHeight * 2.0),
  draw = true,
): Window {.discardable.} =
  gui.beginWindow(gui.getId(id), initialPosition, initialSize, minSize, draw)

proc endWindow*(gui: Gui) =
  let window = gui.getState(gui.windowId, Window)

  gui.windowMoveAndResizeBehavior(window)

  if gui.windowInteraction:
    let tracker = gui.popInteractionTracker()
    if tracker.detectedHover:
      gui.bringWindowToFront(gui.idSpace)

  window.currentPosition = window.pendingPosition
  window.currentSize = window.pendingSize

  gui.popOffset()
  gui.popZIndex()
  gui.popIdSpace()

proc beginWindowBody*(gui: Gui): tuple[position, size: Vec2] {.discardable.} =
  let window = gui.getState(gui.windowId, Window)
  let size = window.size
  result.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  )
  result.size = vec2(
    size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    size.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  gui.pushOffset(result.position)
  gui.pushClipRect(vec2(0, 0), result.size)

proc endWindowBody*(gui: Gui) =
  gui.popClipRect()
  gui.popOffset()

proc beginWindowHeader*(gui: Gui): tuple[position, size: Vec2] {.discardable.} =
  let window = gui.getState(gui.windowId, Window)
  let size = window.size
  result.position = vec2(
    windowBorderThickness + windowRoundingInset,
    windowBorderThickness + windowRoundingInset,
  )
  result.size = vec2(
    size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  )
  gui.pushOffset(result.position)
  gui.pushClipRect(vec2(0, 0), result.size)

proc endWindowHeader*(gui: Gui) =
  gui.popClipRect()
  gui.popOffset()