{.experimental: "overloadableEnums".}

import ../gui
import ./button
import ./frame

type
  Window* = ref object of Widget
    headerHeight*: float
    resizeHitSize*: float
    minSize*: Vec2

    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

proc updateGrabState(window: Window) =
  window.globalMousePositionWhenGrabbed = window.gui.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: Window): Vec2 =
  window.gui.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.x += correction
    window.width -= correction

proc resizeRight(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.width -= correction

proc resizeTop(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.y += correction
    window.height -= correction

proc resizeBottom(window: Window) =
  let grabDelta = window.calculateGrabDelta()
  window.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.height -= correction

proc addMoveResizeButton(window: Window, id: string, style: CursorStyle): Button =
  let button = window.addWidget(id, Button)

  if button.init:
    button.cursorStyle = style

  button.drawProc = nil
  button.press = button.mousePressed(Left)
  button.release = button.mouseReleased(Left)

  button

proc addMoveButton(window: Window) =
  let button = window.addMoveResizeButton("MoveButton", Arrow)

  button.position = vec2(0, 0)
  button.size = vec2(window.width, window.headerHeight)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.move()

proc addResizeLeftButton(window: Window) =
  let button = window.addMoveResizeButton("ResizeLeftButton", ResizeLeftRight)

  button.position = vec2(0, window.resizeHitSize)
  button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeLeft()

proc addResizeRightButton(window: Window) =
  let button = window.addMoveResizeButton("ResizeRightButton", ResizeLeftRight)

  button.position = vec2(window.width - window.resizeHitSize, window.resizeHitSize)
  button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeRight()

proc addResizeTopButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeTopButton", ResizeTopBottom)

  button.position = vec2(window.resizeHitSize * 2.0, 0)
  button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()

proc addResizeBottomButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeBottomButton", ResizeTopBottom)

  button.position = vec2(window.resizeHitSize * 2.0, window.height - window.resizeHitSize)
  button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()

proc addResizeTopLeftButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeTopLeftButton", ResizeTopLeftBottomRight)

  button.position = vec2(0, 0)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()
    window.resizeLeft()

proc addResizeTopRightButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeTopRightButton", ResizeTopRightBottomLeft)

  button.position = vec2(window.width - window.resizeHitSize * 2.0, 0)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()
    window.resizeRight()

proc addResizeBottomLeftButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeBottomLeftButton", ResizeTopRightBottomLeft)

  button.position = vec2(0, window.height - window.resizeHitSize)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()
    window.resizeLeft()

proc addResizeBottomRightButton(window: Window) =
  let button = window.addMoveResizeButton("WindowResizeBottomRightButton", ResizeTopLeftBottomRight)

  button.position = vec2(window.width - window.resizeHitSize * 2.0, window.height - window.resizeHitSize)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  button.update()

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()
    window.resizeRight()

proc update*(window: Window) =
  if window.isFreelyPositionable:
    window.addMoveButton()
    window.addResizeLeftButton()
    window.addResizeRightButton()
    window.addResizeTopButton()
    window.addResizeBottomButton()
    window.addResizeTopLeftButton()
    window.addResizeTopRightButton()
    window.addResizeBottomLeftButton()
    window.addResizeBottomRightButton()

    if (window.mousePressed(Left) or
        window.mousePressed(Middle) or
        window.mousePressed(Right)) and
        window.isHoveredIncludingChildren:
      window.bringToTop()

# Const for now but should probably be in a theme.
const borderThickness = 1.0
const cornerRadius = 4.0
const roundingInset = (1.0 - sin(45.0.degToRad)) * cornerRadius

proc defaultDraw*(window: Window) =
  let gfx = window.vg
  gfx.drawFrameShadow(vec2(0, 0), window.size, 5.0)
  gfx.drawFrameWithHeader(
    vec2(0, 0),
    window.size,
    borderThickness = borderThickness,
    headerHeight = window.headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(49, 51, 56),
    bodyBorderColor = rgb(49, 51, 56).lighten(0.1),
    headerColor = rgb(30, 31, 34),
    headerBorderColor = rgb(30, 31, 34),
  )

proc addWindow*(widget: Widget, id: string): Window =
  let window = widget.addWidget(id, Window)

  if window.init:
    window.resizeHitSize = 5.0
    window.headerHeight = 22.0
    window.size = vec2(300, 200)
    window.minSize = vec2(200, window.headerHeight * 2.0)

  window.draw:
    window.defaultDraw()

  window.update()

  window

proc addHeader*(window: Window): Widget =
  let header = window.addWidget("Header", Widget)
  if header.init:
    header.passInput = true

  header.position = vec2(borderThickness, borderThickness)
  header.size = vec2(
    window.width - 2.0 * borderThickness,
    window.headerHeight - borderThickness,
  )

  header

proc addBody*(window: Window): Widget =
  let body = window.addWidget("Body", Widget)
  if body.init:
    body.passInput = true

  body.position = vec2(
    borderThickness + roundingInset,
    window.headerHeight + borderThickness,
  )
  body.size = vec2(
    window.width - 2.0 * (borderThickness + roundingInset),
    window.height - window.headerHeight - roundingInset - 2.0 * borderThickness,
  )

  body