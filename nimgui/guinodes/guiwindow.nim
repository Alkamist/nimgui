{.experimental: "overloadableEnums".}

import ../gui
import ./guibutton
import ./frame

type
  GuiWindow* = ref object of GuiNode
    headerHeight*: float
    resizeHitSize*: float
    minSize*: Vec2

    globalMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

proc updateGrabState(window: GuiWindow) =
  window.globalMousePositionWhenGrabbed = window.root.globalMousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

proc calculateGrabDelta(window: GuiWindow): Vec2 =
  window.root.globalMousePosition - window.globalMousePositionWhenGrabbed

proc move(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.position = window.positionWhenGrabbed + grabDelta

proc resizeLeft(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.x += correction
    window.width -= correction

proc resizeRight(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.width = window.sizeWhenGrabbed.x + grabDelta.x
  if window.width < window.minSize.x:
    let correction = window.width - window.minSize.x
    window.width -= correction

proc resizeTop(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.y += correction
    window.height -= correction

proc resizeBottom(window: GuiWindow) =
  let grabDelta = window.calculateGrabDelta()
  window.height = window.sizeWhenGrabbed.y + grabDelta.y
  if window.height < window.minSize.y:
    let correction = window.height - window.minSize.y
    window.height -= correction

proc addMoveResizeButton(window: GuiWindow, id: string, style: CursorStyle): GuiButton =
  let button = window.addButton(id)
  button.cursorStyle = style
  button.zIndex = 1
  button.drawProc = nil
  button.press = button.mousePressed(Left)
  button.release = button.mouseReleased(Left)
  button

proc addMoveButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("MoveButton", Arrow)

  button.anchor = anchor(Left, Top)
  button.position = vec2(0, 0)
  button.size = vec2(window.width, window.headerHeight)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.move()

proc addResizeLeftButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("ResizeLeftButton", ResizeLeftRight)

  button.anchor = anchor(Left, Center)
  button.position = vec2(0, window.height * 0.5)
  button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeLeft()

proc addResizeRightButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("ResizeRightButton", ResizeLeftRight)

  button.anchor = anchor(Right, Center)
  button.position = vec2(window.width, window.height * 0.5)
  button.size = vec2(window.resizeHitSize, window.height - window.resizeHitSize * 2.0)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeRight()

proc addResizeTopButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeTopButton", ResizeTopBottom)

  button.anchor = anchor(Center, Top)
  button.position = vec2(window.width * 0.5, 0)
  button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()

proc addResizeBottomButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeBottomButton", ResizeTopBottom)

  button.anchor = anchor(Center, Bottom)
  button.position = vec2(window.width * 0.5, window.height)
  button.size = vec2(window.width - window.resizeHitSize * 4.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()

proc addResizeTopLeftButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeTopLeftButton", ResizeTopLeftBottomRight)

  button.anchor = anchor(Left, Top)
  button.position = vec2(0, 0)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()
    window.resizeLeft()

proc addResizeTopRightButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeTopRightButton", ResizeTopRightBottomLeft)

  button.anchor = anchor(Right, Top)
  button.position = vec2(window.width, 0)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeTop()
    window.resizeRight()

proc addResizeBottomLeftButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeBottomLeftButton", ResizeTopRightBottomLeft)

  button.anchor = anchor(Left, Bottom)
  button.position = vec2(0, window.height)
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()
    window.resizeLeft()

proc addResizeBottomRightButton(window: GuiWindow) =
  let button = window.addMoveResizeButton("WindowResizeBottomRightButton", ResizeTopLeftBottomRight)

  button.anchor = anchor(Right, Bottom)
  button.position = window.size
  button.size = vec2(window.resizeHitSize * 2.0, window.resizeHitSize)

  if button.pressed:
    window.updateGrabState()

  if button.isDown:
    window.resizeBottom()
    window.resizeRight()

proc update*(window: GuiWindow) =
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

proc defaultDraw*(window: GuiWindow) =
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

proc addWindow*(node: GuiNode, id: string): GuiWindow {.discardable.} =
  let window = node.addNode(id, GuiWindow)
  window.update()

  window.draw:
    window.defaultDraw()

  if window.init:
    window.resizeHitSize = 5.0
    window.headerHeight = 22.0
    window.size = vec2(300, 200)
    window.minSize = vec2(200, window.headerHeight * 2.0)

  window

proc header*(window: GuiWindow): GuiNode =
  let header = window.addNode("WindowHeader")

  if header.init:
    header.passInput = true
    header.clipChildren = true

  if header.firstAccessThisFrame:
    header.anchor = anchor(Center, Top)
    header.position = vec2(window.width * 0.5, borderThickness)
    header.size = vec2(
      window.width - 2.0 * borderThickness,
      window.headerHeight - borderThickness,
    )

  header

proc body*(window: GuiWindow): GuiNode =
  let body = window.addNode("WindowBody")

  if body.init:
    body.passInput = true
    body.clipChildren = true

  if body.firstAccessThisFrame:
    body.anchor = anchor(Center, Bottom)
    body.position = vec2(window.width * 0.5, window.height - borderThickness - roundingInset)
    body.size = vec2(
      window.width - 2.0 * (borderThickness + roundingInset),
      window.height - window.headerHeight - roundingInset - 2.0 * borderThickness,
    )

  body