import ../gui
import ../math
import ./button

type
  GuiWindow* = ref object of GuiControl
    visualPosition*: Vec2
    visualSize*: Vec2
    zIndex*: int
    minSize*: Vec2
    globalMousePositionWhenGrabbed*: Vec2
    positionWhenGrabbed*: Vec2
    sizeWhenGrabbed*: Vec2

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
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.x += correction
    window.width -= correction

proc resizeRight(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.width -= correction

proc resizeTop(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.y += correction
    window.height -= correction

proc resizeBottom(gui: Gui, window: GuiWindow) =
  let grabDelta = gui.calculateGrabDelta(window)
  window.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.height -= correction

proc moveButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("MoveButton", GuiButton)

  button.position = vec2(windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(window.visualSize.x - windowResizeHitSize * 2.0, windowHeaderHeight - windowResizeHitSize)

  gui.update(button)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

  if button.pressed:
    gui.updateGrabState(window)

  if button.isDown:
    gui.move(window)

proc resizeLeftButton(gui: Gui, window: GuiWindow) =
  let button = gui.getState("ResizeLeftButton", GuiButton)

  button.position = vec2(0, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.visualSize.y - windowResizeHitSize * 2.0)

  gui.update(button)

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

  button.position = vec2(window.visualSize.x - windowResizeHitSize, windowResizeHitSize)
  button.size = vec2(windowResizeHitSize, window.visualSize.y - windowResizeHitSize * 2.0)

  gui.update(button)

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

  button.position = vec2(windowResizeHitSize * 2.0, 0)
  button.size = vec2(window.visualSize.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(windowResizeHitSize * 2.0, window.visualSize.y - windowResizeHitSize)
  button.size = vec2(window.visualSize.x - windowResizeHitSize * 4.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(window.visualSize.x - windowResizeHitSize * 2.0, 0)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(0, window.visualSize.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(window.visualSize.x - windowResizeHitSize * 2.0, window.visualSize.y - windowResizeHitSize)
  button.size = vec2(windowResizeHitSize * 2.0, windowResizeHitSize)

  gui.update(button)

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

  button.position = vec2(0, 0)
  button.size = window.size

  gui.update(button)

  if gui.hover == button.id and gui.windowInteraction:
    gui.bringToFront(window)

# proc drawShadow(gui: Gui, window: GuiWindow) =
#   const feather = 10.0
#   const feather2 = feather * 2.0

#   let position = window.visualPosition
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

  let x = 0.0
  let y = 0.0
  let width = window.visualSize.x
  let height = window.visualSize.y

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

proc draw*(gui: Gui, window: GuiWindow) =
  gui.drawBackground(window)

proc beginUpdate*(gui: Gui, window: GuiWindow) =
  window.size.x = max(window.size.x, window.minSize.x)
  window.size.y = max(window.size.y, window.minSize.y)
  window.visualPosition = window.position
  window.visualSize = window.size

  gui.pushId(window.id)
  gui.pushZIndex(window.zIndex)
  gui.pushOffset(window.position)

  gui.backgroundButton(window)

proc endUpdate*(gui: Gui) =
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

template update*(gui: Gui, window: GuiWindow, code: untyped): untyped =
  gui.beginUpdate(window)
  if true:
    code
  gui.endUpdate()

proc beginHeader*(gui: Gui, window: GuiWindow) =
  gui.pushOffset(vec2(
    windowBorderThickness + windowRoundingInset,
    windowBorderThickness + windowRoundingInset,
  ))
  gui.pushClip(vec2(0, 0), vec2(
    window.visualSize.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  ))

proc endHeader*(gui: Gui) =
  gui.popClip()
  gui.popOffset()

template header*(gui: Gui, window: GuiWindow, code: untyped): untyped =
  gui.beginHeader(window)
  if true:
    code
  gui.endHeader()

proc beginBody*(gui: Gui, window: GuiWindow) =
  gui.pushOffset(vec2(
    windowBorderThickness + windowRoundingInset,
    windowHeaderHeight + windowRoundingInset,
  ))
  gui.pushClip(vec2(0, 0), vec2(
    window.visualSize.x - (windowBorderThickness + windowRoundingInset) * 2.0,
    window.visualSize.y - windowHeaderHeight - windowBorderThickness - windowRoundingInset * 2.0,
  ))

proc endBody*(gui: Gui) =
  gui.popClip()
  gui.popOffset()

template body*(gui: Gui, window: GuiWindow, code: untyped): untyped =
  gui.beginBody(window)
  if true:
    code
  gui.endBody()