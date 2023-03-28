{.experimental: "overloadableEnums".}

import ../guimod
import ./frame
import ./buttonwidget

const resizeHitSize = 8.0
const resizeHitSize2 = resizeHitSize * 2.0
const cornerRadius = 5.0
const headerHeight = 24.0

type
  WindowWidget* = ref object of Widget
    moveButton*: ButtonWidget
    leftResizeButton*: ButtonWidget
    rightResizeButton*: ButtonWidget
    topResizeButton*: ButtonWidget
    bottomResizeButton*: ButtonWidget
    topLeftResizeButton*: ButtonWidget
    topRightResizeButton*: ButtonWidget
    bottomLeftResizeButton*: ButtonWidget
    bottomRightResizeButton*: ButtonWidget
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2
    mousePositionWhenGrabbed: Vec2

method initialize*(window: WindowWidget) =
  window.size = vec2(300, 200)

  window.moveButton = window.addWidget(ButtonWidget)
  window.moveButton.useMouseButton(Left)

  window.leftResizeButton = window.addWidget(ButtonWidget)
  window.leftResizeButton.useMouseButton(Left)
  window.rightResizeButton = window.addWidget(ButtonWidget)
  window.rightResizeButton.useMouseButton(Left)
  window.topResizeButton = window.addWidget(ButtonWidget)
  window.topResizeButton.useMouseButton(Left)
  window.bottomResizeButton = window.addWidget(ButtonWidget)
  window.bottomResizeButton.useMouseButton(Left)
  window.topLeftResizeButton = window.addWidget(ButtonWidget)
  window.topLeftResizeButton.useMouseButton(Left)
  window.topRightResizeButton = window.addWidget(ButtonWidget)
  window.topRightResizeButton.useMouseButton(Left)
  window.bottomLeftResizeButton = window.addWidget(ButtonWidget)
  window.bottomLeftResizeButton.useMouseButton(Left)
  window.bottomRightResizeButton = window.addWidget(ButtonWidget)
  window.bottomRightResizeButton.useMouseButton(Left)

method update*(window: WindowWidget) =
  let gui = window.gui

  for child in window.children:
    child.update()

  if window.moveButton.pressed or
     window.leftResizeButton.pressed or
     window.rightResizeButton.pressed or
     window.topResizeButton.pressed or
     window.bottomResizeButton.pressed or
     window.topLeftResizeButton.pressed or
     window.topRightResizeButton.pressed or
     window.bottomLeftResizeButton.pressed or
     window.bottomRightResizeButton.pressed:
    window.positionWhenGrabbed = window.position
    window.sizeWhenGrabbed = window.size
    window.mousePositionWhenGrabbed = gui.mousePosition

  if window.moveButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.position = window.positionWhenGrabbed + grabDelta

  if window.leftResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.x = window.positionWhenGrabbed.x + grabDelta.x
    window.width = window.sizeWhenGrabbed.x - grabDelta.x

  if window.rightResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.width = window.sizeWhenGrabbed.x + grabDelta.x

  if window.topResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.y = window.positionWhenGrabbed.y + grabDelta.y
    window.height = window.sizeWhenGrabbed.y - grabDelta.y

  if window.bottomResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.height = window.sizeWhenGrabbed.y + grabDelta.y

  if window.topLeftResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.x = window.positionWhenGrabbed.x + grabDelta.x
    window.width = window.sizeWhenGrabbed.x - grabDelta.x
    window.y = window.positionWhenGrabbed.y + grabDelta.y
    window.height = window.sizeWhenGrabbed.y - grabDelta.y

  if window.topRightResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.width = window.sizeWhenGrabbed.x + grabDelta.x
    window.y = window.positionWhenGrabbed.y + grabDelta.y
    window.height = window.sizeWhenGrabbed.y - grabDelta.y

  if window.bottomLeftResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.x = window.positionWhenGrabbed.x + grabDelta.x
    window.width = window.sizeWhenGrabbed.x - grabDelta.x
    window.height = window.sizeWhenGrabbed.y + grabDelta.y

  if window.bottomRightResizeButton.isDown and gui.mouseMoved:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed
    window.width = window.sizeWhenGrabbed.x + grabDelta.x
    window.height = window.sizeWhenGrabbed.y + grabDelta.y

  window.moveButton.size = vec2(window.width, headerHeight)
  window.leftResizeButton.position = vec2(0, resizeHitSize)
  window.leftResizeButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.rightResizeButton.position = vec2(window.width - resizeHitSize, resizeHitSize)
  window.rightResizeButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.topResizeButton.position = vec2(resizeHitSize, 0)
  window.topResizeButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  window.bottomResizeButton.position = vec2(resizeHitSize, window.height - resizeHitSize)
  window.bottomResizeButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  window.topLeftResizeButton.position = vec2(0, 0)
  window.topLeftResizeButton.size = vec2(resizeHitSize, resizeHitSize)
  window.topRightResizeButton.position = vec2(window.width - resizeHitSize, 0)
  window.topRightResizeButton.size = vec2(resizeHitSize, resizeHitSize)
  window.bottomLeftResizeButton.position = vec2(0, window.height - resizeHitSize)
  window.bottomLeftResizeButton.size = vec2(resizeHitSize, resizeHitSize)
  window.bottomRightResizeButton.position = vec2(window.width - resizeHitSize, window.height - resizeHitSize)
  window.bottomRightResizeButton.size = vec2(resizeHitSize, resizeHitSize)

  if window.isHoveredIncludingChildren() and
     (gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)):
    window.bringToTop()

method draw*(window: WindowWidget) =
  let gfx = window.drawList
  gfx.translate(window.position)

  let bounds = rect2(vec2(0, 0), window.size)
  # let bodyBounds = rect2(
  #   bounds.position + vec2(0, headerHeight),
  #   bounds.size - vec2(0, headerHeight),
  # )
  let headerBounds = rect2(
    bounds.position,
    vec2(window.width, headerHeight),
  )

  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = 1.0,
    headerHeight = headerBounds.height,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  # gfx.clip(bodyBounds.expand(-0.5 * cornerRadius))
  # gfx.resetClip()

  window.moveButton.draw()
  window.leftResizeButton.draw()
  window.rightResizeButton.draw()
  window.topResizeButton.draw()
  window.bottomResizeButton.draw()
  window.topLeftResizeButton.draw()
  window.topRightResizeButton.draw()
  window.bottomLeftResizeButton.draw()
  window.bottomRightResizeButton.draw()

  gfx.translate(-window.position)