{.experimental: "overloadableEnums".}

import ../gui
import ./button
import ./frame

type
  Window* = ref object of Widget
    headerHeight*: float
    resizeHitSize*: float
    borderThickness*: float
    cornerRadius*: float
    minSize*: Vec2

    header*: Widget
    body*: Widget

    moveButton*: Button
    resizeLeftButton*: Button
    resizeRightButton*: Button
    resizeTopButton*: Button
    resizeBottomButton*: Button
    resizeTopLeftButton*: Button
    resizeTopRightButton*: Button
    resizeBottomLeftButton*: Button
    resizeBottomRightButton*: Button

    guiMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

proc updateGrabState(window: Window) =
  window.guiMousePositionWhenGrabbed = window.gui.mousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc newMoveResizeButton(window: Window): Button =
  let gui = window.gui
  result = window.addWidget(Button)
  result.press:
    gui.mousePressed(Left)
  result.release:
    gui.mouseReleased(Left)
  result.onPress:
    window.updateGrabState()
  result.drawProc = nil

proc init*(window: Window) =
  let gui = window.gui

  window.dontDraw = false
  window.consumeInput = false
  window.clipInput = false
  window.clipDrawing = false

  window.resizeHitSize = 5.0
  window.borderThickness = 1.0
  window.headerHeight = 22.0
  window.cornerRadius = 4.0
  window.size = vec2(300, 200)
  window.minSize = vec2(200, window.headerHeight * 2.0)

  window.header = window.addWidget()
  window.header.dontDraw = false
  window.header.consumeInput = false
  window.header.clipInput = true
  window.header.clipDrawing = true

  window.body = window.addWidget()
  window.body.dontDraw = false
  window.body.consumeInput = true
  window.body.clipInput = true
  window.body.clipDrawing = true

  window.moveButton = window.newMoveResizeButton()
  window.resizeLeftButton = window.newMoveResizeButton()
  window.resizeRightButton = window.newMoveResizeButton()
  window.resizeTopButton = window.newMoveResizeButton()
  window.resizeBottomButton = window.newMoveResizeButton()
  window.resizeTopLeftButton = window.newMoveResizeButton()
  window.resizeTopRightButton = window.newMoveResizeButton()
  window.resizeBottomLeftButton = window.newMoveResizeButton()
  window.resizeBottomRightButton = window.newMoveResizeButton()

proc updateMoveAndResizeButtonBounds(window: Window) =
  let resizeHitSize = window.resizeHitSize
  let resizeHitSize2 = resizeHitSize * 2.0
  let resizeHitSize4 = resizeHitSize2 * 2.0

  window.moveButton.position = vec2(0, 0)
  window.moveButton.size = vec2(window.width, window.headerHeight)

  window.resizeLeftButton.position = vec2(0, resizeHitSize)
  window.resizeLeftButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.resizeRightButton.position = vec2(window.width - resizeHitSize, resizeHitSize)
  window.resizeRightButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.resizeTopButton.position = vec2(resizeHitSize2, 0)
  window.resizeTopButton.size = vec2(window.width - resizeHitSize4, resizeHitSize)
  window.resizeBottomButton.position = vec2(resizeHitSize2, window.height - resizeHitSize)
  window.resizeBottomButton.size = vec2(window.width - resizeHitSize4, resizeHitSize)

  window.resizeTopLeftButton.position = vec2(0, 0)
  window.resizeTopLeftButton.size = vec2(resizeHitSize2, resizeHitSize)
  window.resizeTopRightButton.position = vec2(window.width - resizeHitSize2, 0)
  window.resizeTopRightButton.size = vec2(resizeHitSize2, resizeHitSize)
  window.resizeBottomLeftButton.position = vec2(0, window.height - resizeHitSize)
  window.resizeBottomLeftButton.size = vec2(resizeHitSize2, resizeHitSize)
  window.resizeBottomRightButton.position = vec2(window.width - resizeHitSize2, window.height - resizeHitSize)
  window.resizeBottomRightButton.size = vec2(resizeHitSize2, resizeHitSize)

proc calculateGrabDelta(window: Window): Vec2 =
  window.gui.mousePosition - window.guiMousePositionWhenGrabbed

proc move(window: Window, grabDelta: Vec2) =
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: Window, grabDelta: Vec2) =
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.x += correction
    window.width -= correction

proc resizeRight(window: Window, grabDelta: Vec2) =
  window.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.width -= correction

proc resizeTop(window: Window, grabDelta: Vec2) =
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.y += correction
    window.height -= correction

proc resizeBottom(window: Window, grabDelta: Vec2) =
  window.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.height -= correction

proc moveAndResize(window: Window) =
  if window.moveButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.move(grabDelta)

  if window.resizeLeftButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeLeft(grabDelta)

  if window.resizeRightButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeRight(grabDelta)

  if window.resizeTopButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeTop(grabDelta)

  if window.resizeBottomButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeBottom(grabDelta)

  if window.resizeTopLeftButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeTop(grabDelta)
    window.resizeLeft(grabDelta)

  if window.resizeTopRightButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeTop(grabDelta)
    window.resizeRight(grabDelta)

  if window.resizeBottomLeftButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeBottom(grabDelta)
    window.resizeLeft(grabDelta)

  if window.resizeBottomRightButton.isDown:
    let grabDelta = window.calculateGrabDelta()
    window.resizeBottom(grabDelta)
    window.resizeRight(grabDelta)

proc shouldBringToTop(window: Window): bool =
  let gui = window.gui

  if not (gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)):
    return false

  for child in window.children:
    if child.isHoveredIncludingChildren:
      return true

proc update*(window: Window) =
  let gui = window.gui

  window.updateMoveAndResizeButtonBounds()
  window.moveAndResize()

  let headerHeight = window.headerHeight
  let borderThickness = window.borderThickness
  let roundingInset = (1.0 - sin(45.0.degToRad)) * window.cornerRadius

  window.header.position = vec2(borderThickness, borderThickness)
  window.header.size = vec2(
    window.width - 2.0 * borderThickness,
    headerHeight - borderThickness,
  )
  window.body.position = vec2(borderThickness + roundingInset, headerHeight + borderThickness)
  window.body.size = vec2(
    window.width - 2.0 * (borderThickness + roundingInset),
    window.height - headerHeight - roundingInset - 2.0 * borderThickness,
  )

  if window.shouldBringToTop:
    window.bringToTop()

proc draw*(window: Window) =
  let vg = window.gui.vg
  vg.drawFrameShadow(vec2(0, 0), window.size, 5.0)
  vg.drawFrameWithHeader(
    vec2(0, 0),
    window.size,
    borderThickness = window.borderThickness,
    headerHeight = window.headerHeight,
    cornerRadius = window.cornerRadius,
    bodyColor = rgb(49, 51, 56),
    bodyBorderColor = rgb(49, 51, 56).lighten(0.1),
    headerColor = rgb(30, 31, 34),
    headerBorderColor = rgb(30, 31, 34),
  )