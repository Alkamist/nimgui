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

proc behavior*(window: Window) =
  let gui = window.gui

  let headerHeight = window.headerHeight
  let resizeHitSize = window.resizeHitSize
  let resizeHitSize2 = resizeHitSize * 2.0
  let resizeHitSize4 = resizeHitSize2 * 2.0

  gui.invisibleButton("WindowMoveButton"):
    self.position = vec2(0, 0)
    self.size = vec2(window.width, headerHeight)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.move()

  gui.invisibleButton("WindowResizeLeftButton"):
    self.cursorStyle = ResizeLeftRight
    self.position = vec2(0, resizeHitSize)
    self.size = vec2(resizeHitSize, window.height - resizeHitSize2)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeLeft()

  gui.invisibleButton("WindowResizeRightButton"):
    self.cursorStyle = ResizeLeftRight
    self.position = vec2(window.width - resizeHitSize, resizeHitSize)
    self.size = vec2(resizeHitSize, window.height - resizeHitSize2)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeRight()

  gui.invisibleButton("WindowResizeTopButton"):
    self.cursorStyle = ResizeTopBottom
    self.position = vec2(resizeHitSize2, 0)
    self.size = vec2(window.width - resizeHitSize4, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeTop()

  gui.invisibleButton("WindowResizeBottomButton"):
    self.cursorStyle = ResizeTopBottom
    self.position = vec2(resizeHitSize2, window.height - resizeHitSize)
    self.size = vec2(window.width - resizeHitSize4, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeBottom()

  gui.invisibleButton("WindowResizeTopLeftButton"):
    self.cursorStyle = ResizeTopLeftBottomRight
    self.position = vec2(0, 0)
    self.size = vec2(resizeHitSize2, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeTop()
      window.resizeLeft()

  gui.invisibleButton("WindowResizeTopRightButton"):
    self.cursorStyle = ResizeTopRightBottomLeft
    self.position = vec2(window.width - resizeHitSize2, 0)
    self.size = vec2(resizeHitSize2, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeTop()
      window.resizeRight()

  gui.invisibleButton("WindowResizeBottomLeftButton"):
    self.cursorStyle = ResizeTopRightBottomLeft
    self.position = vec2(0, window.height - resizeHitSize)
    self.size = vec2(resizeHitSize2, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeBottom()
      window.resizeLeft()

  gui.invisibleButton("WindowResizeBottomRightButton"):
    self.cursorStyle = ResizeTopLeftBottomRight
    self.position = vec2(window.width - resizeHitSize2, window.height - resizeHitSize)
    self.size = vec2(resizeHitSize2, resizeHitSize)

    if self.pressed:
      window.updateGrabState()

    if self.isDown:
      window.resizeBottom()
      window.resizeRight()

  if gui.mousePressed(Left) and window.isHoveredIncludingChildren:
    window.bringToTop()

proc defaultDraw*(window: Window) =
  let gfx = window.vg
  gfx.drawFrameShadow(vec2(0, 0), window.size, 5.0)
  gfx.drawFrameWithHeader(
    vec2(0, 0),
    window.size,
    borderThickness = 1.0,
    headerHeight = window.headerHeight,
    cornerRadius = 4.0,
    bodyColor = rgb(49, 51, 56),
    bodyBorderColor = rgb(49, 51, 56).lighten(0.1),
    headerColor = rgb(30, 31, 34),
    headerBorderColor = rgb(30, 31, 34),
  )

template window*(gui: Gui, id: string, code: untyped): untyped =
  gui.newWidget(id, Window):
    if self.init:
      self.resizeHitSize = 5.0
      self.headerHeight = 22.0
      self.size = vec2(300, 200)
      self.minSize = vec2(200, self.headerHeight * 2.0)

    self.behavior()
    code

    self.draw:
      self.defaultDraw()