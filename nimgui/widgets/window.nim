import std/math
import ../gui
import ./button

type
  WindowState = ref object of RootRef
    position: Vec2
    size: Vec2
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

proc windowInteraction(gui: Gui): bool =
  gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

proc windowStateId(gui: Gui): GuiId =
  gui.getId("_State")

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

proc windowMoveAndResizeBehavior(gui: Gui) =
  let state = gui.getState(gui.windowStateId, WindowState)
  var position = state.position
  var size = state.size

  template grabDelta(): Vec2 =
    gui.globalMousePosition - state.globalMousePositionWhenGrabbed

  template resizeLeft() =
    let grabDelta = grabDelta()
    position.x = state.positionWhenGrabbed.x + grabDelta.x
    size.x = state.sizeWhenGrabbed.x - grabDelta.x
    if size.x < state.minSize.x:
      let correction = size.x - state.minSize.x
      position.x += correction
      size.x -= correction

  template resizeRight() =
    let grabDelta = grabDelta()
    size.x = state.sizeWhenGrabbed.x + grabDelta.x
    if size.x < state.minSize.x:
      let correction = size.x - state.minSize.x
      size.x -= correction

  template resizeTop() =
    let grabDelta = grabDelta()
    position.y = state.positionWhenGrabbed.y + grabDelta.y
    size.y = state.sizeWhenGrabbed.y - grabDelta.y
    if size.y < state.minSize.y:
      let correction = size.y - state.minSize.y
      position.y += correction
      size.y -= correction

  template resizeBottom() =
    let grabDelta = grabDelta()
    size.y = state.sizeWhenGrabbed.y + grabDelta.y
    if size.y < state.minSize.y:
      let correction = size.y - state.minSize.y
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
    state.globalMousePositionWhenGrabbed = gui.globalMousePosition
    state.positionWhenGrabbed = position
    state.sizeWhenGrabbed = size

  if moveButton.isDown:
    position = state.positionWhenGrabbed + grabDelta()

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

  state.position = position
  state.size = size

proc bringWindowToFront*(gui: Gui, id: GuiId) =
  gui.pushIdSpace(id)
  let state = gui.getState(gui.windowStateId, WindowState)
  gui.popIdSpace()
  let zIndex = gui.highestWindowZIndex + 1
  state.zIndex = zIndex
  gui.highestWindowZIndex = zIndex

proc beginWindow*(gui: Gui, id: GuiId,
  initialPosition: Vec2,
  initialSize = vec2(400, 300),
  minSize = vec2(300, windowHeaderHeight * 2.0),
  draw = true,
) =
  gui.pushIdSpace(id)

  let state = gui.getState(gui.windowStateId, WindowState(
    position: initialPosition,
    size: initialSize,
  ))
  var position = state.position
  var size = state.size

  gui.pushZIndex(state.zIndex, global = true)

  size.x = max(size.x, minSize.x)
  size.y = max(size.y, minSize.y)

  if draw:
    gui.drawWindowShadow(position, size)
    gui.drawWindowBackground(position, size)

  state.minSize = minSize
  state.position = position
  state.size = size

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
) =
  gui.beginWindow(gui.getId(id), initialPosition, initialSize, minSize, draw)

proc endWindow*(gui: Gui) =
  gui.windowMoveAndResizeBehavior()

  if gui.windowInteraction:
    let tracker = gui.popInteractionTracker()
    if tracker.detectedHover:
      gui.bringWindowToFront(gui.idSpace)

  gui.popOffset()
  gui.popZIndex()
  gui.popIdSpace()

proc beginWindowBody*(gui: Gui) =
  let state = gui.getState(gui.windowStateId, WindowState)
  let size = state.size
  gui.pushOffset vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  )
  gui.pushClipRect(
    vec2(0, 0),
    vec2(
      size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
      size.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
    )
  )

proc endWindowBody*(gui: Gui) =
  gui.popClipRect()
  gui.popOffset()

proc beginWindowHeader*(gui: Gui) =
  let state = gui.getState(gui.windowStateId, WindowState)
  let size = state.size
  gui.pushOffset vec2(
    windowBorderThickness + windowRoundingInset,
    windowBorderThickness + windowRoundingInset,
  )
  gui.pushClipRect(
    vec2(0, 0),
    vec2(
      size.x - (windowBorderThickness + windowRoundingInset) * 2.0,
      windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
    )
  )

proc endWindowHeader*(gui: Gui) =
  gui.popClipRect()
  gui.popOffset()