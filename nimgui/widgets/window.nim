{.experimental: "overloadableEnums".}

import ../math
import ../widget
import ./button
import ./text
import ./frame

const resizeHitSize = 5.0
const resizeHitSize2 = resizeHitSize * 2.0
const resizeHitSize4 = resizeHitSize2 * 2.0
const borderThickness = 1.0
const headerHeight = 22.0
const cornerRadius = 4.0
const roundingInset = (1.0 - sin(45.0.degToRad)) * cornerRadius

type
  Window* = ref object of Widget
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
    minSize*: Vec2
    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2
    resizeButtons: Widget

func updateMoveResizeButtonBounds(window: Window) =
  window.moveButton.position = vec2(0, 0)
  window.moveButton.size = vec2(window.width, headerHeight)

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

func moveAndResize(window: Window) =
  template calculateGrabDelta(): Vec2 {.dirty.} =
    window.globalMousePosition - window.globalMousePositionWhenGrabbed

  template moveWindow(grabDelta: Vec2): untyped {.dirty.} =
    window.position = window.positionWhenGrabbed + grabDelta

  template resizeWindowLeft(grabDelta: Vec2): untyped {.dirty.} =
    window.x = window.positionWhenGrabbed.x + grabDelta.x
    window.width = window.sizeWhenGrabbed.x - grabDelta.x
    if window.width < window.minSize.x:
      let correction = window.width - window.minSize.x
      window.x += correction
      window.width -= correction

  template resizeWindowRight(grabDelta: Vec2): untyped {.dirty.} =
    window.width = window.sizeWhenGrabbed.x + grabDelta.x
    if window.width < window.minSize.x:
      let correction = window.width - window.minSize.x
      window.width -= correction

  template resizeWindowTop(grabDelta: Vec2): untyped {.dirty.} =
    window.y = window.positionWhenGrabbed.y + grabDelta.y
    window.height = window.sizeWhenGrabbed.y - grabDelta.y
    if window.height < window.minSize.y:
      let correction = window.height - window.minSize.y
      window.y += correction
      window.height -= correction

  template resizeWindowBottom(grabDelta: Vec2): untyped {.dirty.} =
    window.height = window.sizeWhenGrabbed.y + grabDelta.y
    if window.height < window.minSize.y:
      let correction = window.height - window.minSize.y
      window.height -= correction

  if window.moveButton.pressed or
     window.resizeLeftButton.pressed or window.resizeRightButton.pressed or
     window.resizeTopButton.pressed or window.resizeBottomButton.pressed or
     window.resizeTopLeftButton.pressed or window.resizeTopRightButton.pressed or
     window.resizeBottomLeftButton.pressed or window.resizeBottomRightButton.pressed:
    window.globalMousePositionWhenGrabbed = window.globalMousePosition
    window.positionWhenGrabbed = window.position
    window.sizeWhenGrabbed = window.size

  if window.moveButton.isDown:
    let grabDelta = calculateGrabDelta()
    moveWindow(grabDelta)

  if window.resizeLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowLeft(grabDelta)

  if window.resizeRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowRight(grabDelta)

  if window.resizeTopButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)

  if window.resizeBottomButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)

  if window.resizeTopLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)
    resizeWindowLeft(grabDelta)

  if window.resizeTopRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)
    resizeWindowRight(grabDelta)

  if window.resizeBottomLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)
    resizeWindowLeft(grabDelta)

  if window.resizeBottomRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)
    resizeWindowRight(grabDelta)

proc updateWindow(widget: Widget) =
  let window = Window(widget)

  window.updateMoveResizeButtonBounds()
  window.moveAndResize()

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

  if window.isHoveredIncludingChildren and
    (window.mousePressed(Left) or window.mousePressed(Middle) or window.mousePressed(Right)):
    window.bringToTop()

  window.updateChildren()

proc drawWindow(widget: Widget) =
  let window = Window(widget)
  let vg = window.vg

  vg.drawFrameShadow(vec2(0, 0), window.size, cornerRadius)
  vg.drawFrameWithHeader(
    vec2(0, 0),
    window.size,
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(49, 51, 56),
    bodyBorderColor = rgb(49, 51, 56).lighten(0.1),
    headerColor = rgb(30, 31, 34),
    headerBorderColor = rgb(30, 31, 34),
  )

  window.drawChildren()

func addWindow*(parent: Widget): Window =
  result = parent.addWidget(Window)
  result.consumeInput = true
  result.clipInput = true
  result.clipDrawing = false
  result.update = updateWindow
  result.draw = drawWindow
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)

  result.body = result.addWidget()
  result.body.consumeInput = false
  result.body.clipInput = true
  result.body.clipDrawing = true
  result.moveButton = result.addButton()
  result.moveButton.dontDraw = true
  result.header = result.addWidget()
  result.header.consumeInput = false
  result.header.clipInput = true
  result.header.clipDrawing = true
  result.resizeButtons = result.addWidget()
  result.resizeButtons.dontDraw = true
  result.resizeButtons.consumeInput = false
  result.resizeButtons.clipInput = false
  result.resizeButtons.clipDrawing = false
  result.resizeLeftButton = result.resizeButtons.addButton()
  result.resizeLeftButton.cursorStyle = ResizeLeftRight
  result.resizeRightButton = result.resizeButtons.addButton()
  result.resizeRightButton.cursorStyle = ResizeLeftRight
  result.resizeTopButton = result.resizeButtons.addButton()
  result.resizeTopButton.cursorStyle = ResizeTopBottom
  result.resizeBottomButton = result.resizeButtons.addButton()
  result.resizeBottomButton.cursorStyle = ResizeTopBottom
  result.resizeTopLeftButton = result.resizeButtons.addButton()
  result.resizeTopLeftButton.cursorStyle = ResizeTopLeftBottomRight
  result.resizeTopRightButton = result.resizeButtons.addButton()
  result.resizeTopRightButton.cursorStyle = ResizeTopRightBottomLeft
  result.resizeBottomLeftButton = result.resizeButtons.addButton()
  result.resizeBottomLeftButton.cursorStyle = ResizeTopRightBottomLeft
  result.resizeBottomRightButton = result.resizeButtons.addButton()
  result.resizeBottomRightButton.cursorStyle = ResizeTopLeftBottomRight

func addTitle*(window: Window, title: string): Text {.discardable.} =
  result = window.header.addText()
  result.data = title
  result.alignX = Center
  result.alignY = Center
  result.color = rgb(242, 243, 245)
  result.consumeInput = false
  result.clipInput = false
  result.clipDrawing = false
  result.updateHook:
    self.size = self.parent.size