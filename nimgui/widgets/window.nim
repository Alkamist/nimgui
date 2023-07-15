import std/math
import ../gui
import ./button

type
  Window* = ref object
    gui*: Gui
    backgroundButton*: Button
    moveButton*: Button
    resizeLeftButton*: Button
    resizeRightButton*: Button
    resizeTopButton*: Button
    resizeBottomButton*: Button
    resizeTopLeftButton*: Button
    resizeTopRightButton*: Button
    resizeBottomLeftButton*: Button
    resizeBottomRightButton*: Button
    position*: Vec2
    size*: Vec2
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

proc windowInteraction(gui: Gui): bool =
  gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)

proc drawShadow(window: Window) =
  let gui = window.gui

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

proc drawBackground(window: Window) =
  let gui = window.gui

  let x = 0.0
  let y = 0.0
  let width = window.size.x
  let height = window.size.y

  const bodyColor = rgb(49, 51, 56)
  const bodyBorderColor = rgb(49, 51, 56).lighten(0.1)
  const headerColor = rgb(30, 31, 34)
  const headerBorderColor = rgb(30, 31, 34)

  const headerHeight = windowHeaderHeight
  const borderThickness = windowBorderThickness.clamp(1.0, 0.5 * windowHeaderHeight)
  const borderThicknessHalf = borderThickness * 0.5
  const cornerRadius = windowCornerRadius
  const borderCornerRadius = windowCornerRadius - borderThicknessHalf

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

proc move(window: Window) =
  let gui = window.gui

  let moveButton = window.moveButton
  moveButton.position = vec2(windowResizeHitSize, windowResizeHitSize)
  moveButton.size = vec2(window.size.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

  moveButton.update()

  if moveButton.pressed:
    window.globalMousePositionWhenGrabbed = gui.globalMousePosition
    window.positionWhenGrabbed = window.position
    window.sizeWhenGrabbed = window.size

  if moveButton.isDown:
    let grabDelta = gui.globalMousePosition - window.globalMousePositionWhenGrabbed
    window.position = window.positionWhenGrabbed + grabDelta

proc resize(window: Window) =
  let gui = window.gui

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

  let resizeLeftButton = window.resizeLeftButton
  resizeLeftButton.position = vec2(0, windowResizeHitSize)
  resizeLeftButton.size = vec2(windowResizeHitSize, size.y - windowResizeHitSize * 2.0)

  let resizeRightButton = window.resizeRightButton
  resizeRightButton.position = vec2(size.x - windowResizeHitSize, windowResizeHitSize)
  resizeRightButton.size = vec2(windowResizeHitSize, size.y - windowResizeHitSize * 2.0)

  let resizeTopButton = window.resizeTopButton
  resizeTopButton.position = vec2(windowResizeHitSize * 2.0, 0)
  resizeTopButton.size = vec2(size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  let resizeBottomButton = window.resizeBottomButton
  resizeBottomButton.position = vec2(windowResizeHitSize * 2.0, size.y - windowResizeHitSize)
  resizeBottomButton.size = vec2(size.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  let resizeTopLeftButton = window.resizeTopLeftButton
  resizeTopLeftButton.position = vec2(0, 0)
  resizeTopLeftButton.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  let resizeTopRightButton = window.resizeTopRightButton
  resizeTopRightButton.position = vec2(size.x - windowResizeHitSize * 2.0, 0)
  resizeTopRightButton.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  let resizeBottomLeftButton = window.resizeBottomLeftButton
  resizeBottomLeftButton.position = vec2(0, size.y - windowResizeHitSize)
  resizeBottomLeftButton.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  let resizeBottomRightButton = window.resizeBottomRightButton
  resizeBottomRightButton.position = vec2(size.x - windowResizeHitSize * 2.0, size.y - windowResizeHitSize)
  resizeBottomRightButton.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  resizeLeftButton.update()
  resizeRightButton.update()
  resizeTopButton.update()
  resizeBottomButton.update()
  resizeTopLeftButton.update()
  resizeTopRightButton.update()
  resizeBottomLeftButton.update()
  resizeBottomRightButton.update()

  if gui.isHovered(resizeLeftButton):
    gui.cursorStyle = ResizeLeftRight

  if gui.isHovered(resizeRightButton):
    gui.cursorStyle = ResizeLeftRight

  if gui.isHovered(resizeTopButton):
    gui.cursorStyle = ResizeTopBottom

  if gui.isHovered(resizeBottomButton):
    gui.cursorStyle = ResizeTopBottom

  if gui.isHovered(resizeTopLeftButton):
    gui.cursorStyle = ResizeTopLeftBottomRight

  if gui.isHovered(resizeTopRightButton):
    gui.cursorStyle = ResizeTopRightBottomLeft

  if gui.isHovered(resizeBottomLeftButton):
    gui.cursorStyle = ResizeTopRightBottomLeft

  if gui.isHovered(resizeBottomRightButton):
    gui.cursorStyle = ResizeTopLeftBottomRight

  if resizeLeftButton.pressed or resizeRightButton.pressed or
     resizeTopButton.pressed or resizeBottomButton.pressed or
     resizeTopLeftButton.pressed or resizeTopRightButton.pressed or
     resizeBottomLeftButton.pressed or resizeBottomRightButton.pressed:
    window.globalMousePositionWhenGrabbed = gui.globalMousePosition
    window.positionWhenGrabbed = position
    window.sizeWhenGrabbed = size

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

proc draw*(window: Window) =
  window.drawShadow()
  window.drawBackground()

proc bringToFront*(window: Window) =
  window.zIndex = window.gui.highestZIndex + 1

proc new*( _: typedesc[Window], gui: Gui): Window =
  result = Window()
  result.gui = gui
  result.backgroundButton = Button.new(gui)
  result.moveButton = Button.new(gui)
  result.resizeLeftButton = Button.new(gui)
  result.resizeRightButton = Button.new(gui)
  result.resizeTopButton = Button.new(gui)
  result.resizeBottomButton = Button.new(gui)
  result.resizeTopLeftButton = Button.new(gui)
  result.resizeTopRightButton = Button.new(gui)
  result.resizeBottomLeftButton = Button.new(gui)
  result.resizeBottomRightButton = Button.new(gui)
  result.size = vec2(400, 300)
  result.minSize = vec2(300, windowHeaderHeight * 2.0)

proc beginUpdate*(window: Window) =
  let gui = window.gui

  gui.beginZIndex(window.zIndex, global = true)

  window.size.x = max(window.size.x, window.minSize.x)
  window.size.y = max(window.size.y, window.minSize.y)

  gui.beginOffset(window.position, global = true)

  if gui.windowInteraction:
    gui.beginInteractionTracker()

  # Blocks mouse input from going through the window.
  window.backgroundButton.size = window.size
  window.backgroundButton.update()

  window.move()

proc endUpdate*(window: Window) =
  let gui = window.gui

  window.resize()

  if gui.windowInteraction:
    let tracker = gui.endInteractionTracker()
    if tracker.detectedHover:
      window.bringToFront()

  gui.endOffset()
  gui.endZIndex()

proc beginBody*(window: Window, padding = vec2(0, 0)): tuple[position, size: Vec2] {.discardable.} =
  let gui = window.gui
  let size = window.size
  let padding = vec2(
    max(padding.x, windowBorderThickness + windowRoundingInset),
    max(padding.y, windowBorderThickness + windowRoundingInset),
  )
  result = gui.beginPadding(
    vec2(0, windowHeaderHeight),
    vec2(size.x, size.y - windowHeaderHeight),
    padding,
  )
  gui.beginClipRect(vec2(0, 0), result.size)

proc endBody*(window: Window) =
  let gui = window.gui
  gui.endClipRect()
  gui.endPadding()

proc beginHeader*(window: Window, padding = vec2(0, 0)): tuple[position, size: Vec2] {.discardable.} =
  let gui = window.gui
  let size = window.size
  let padding = vec2(
    max(padding.x, windowBorderThickness + windowRoundingInset),
    max(padding.y, windowBorderThickness + windowRoundingInset),
  )
  result = gui.beginPadding(
    vec2(0, 0),
    vec2(size.x, windowHeaderHeight),
    padding,
  )
  gui.beginClipRect(vec2(0, 0), result.size)

proc endHeader*(window: Window) =
  let gui = window.gui
  gui.endClipRect()
  gui.endPadding()