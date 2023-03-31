{.experimental: "overloadableEnums".}

import ../guimod
import ./buttonwidget
import ./frame

const resizeHitSize = 8.0
const resizeHitSize2 = resizeHitSize * 2.0
const borderThickness = 1.0
const headerHeight = 24.0
const cornerRadius = 5.0

type
  WindowWidget* = ref object of GuiLayer
    guiMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

template calculateGrabDelta(): Vec2 =
  gui.mousePosition - window.guiMousePositionWhenGrabbed

template grabWindow(): untyped =
  window.guiMousePositionWhenGrabbed = gui.mousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

template moveWindow(grabDelta: Vec2): untyped =
  window.position = window.positionWhenGrabbed + grabDelta

template resizeWindowLeft(grabDelta: Vec2): untyped =
  window.x = window.positionWhenGrabbed.x + grabDelta.x
  window.width = window.sizeWhenGrabbed.x - grabDelta.x

template resizeWindowRight(grabDelta: Vec2): untyped =
  window.width = window.sizeWhenGrabbed.x + grabDelta.x

template resizeWindowTop(grabDelta: Vec2): untyped =
  window.y = window.positionWhenGrabbed.y + grabDelta.y
  window.height = window.sizeWhenGrabbed.y - grabDelta.y

template resizeWindowBottom(grabDelta: Vec2): untyped =
  window.height = window.sizeWhenGrabbed.y + grabDelta.y

func update*(window: WindowWidget, gui: Gui) =
  gui.button(resizeLeftButton):
    resizeLeftButton.position = vec2(0, resizeHitSize)
    resizeLeftButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  if resizeLeftButton.justPressed: grabWindow()
  if resizeLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowLeft(grabDelta)

  gui.button(moveButton):
    moveButton.position = vec2(0, 0)
    moveButton.size = vec2(window.width, headerHeight)
  if moveButton.justPressed: grabWindow()
  if moveButton.isDown:
    let grabDelta = calculateGrabDelta()
    moveWindow(grabDelta)

  gui.button(resizeBottomLeftButton):
    resizeBottomLeftButton.position = vec2(0, window.height - resizeHitSize)
    resizeBottomLeftButton.size = vec2(resizeHitSize, resizeHitSize)
  if resizeBottomLeftButton.justPressed: grabWindow()
  if resizeBottomLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)
    resizeWindowLeft(grabDelta)

  gui.button(resizeTopLeftButton):
    resizeTopLeftButton.position = vec2(0, 0)
    resizeTopLeftButton.size = vec2(resizeHitSize, resizeHitSize)
  if resizeTopLeftButton.justPressed: grabWindow()
  if resizeTopLeftButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)
    resizeWindowLeft(grabDelta)

  gui.button(resizeRightButton):
    resizeRightButton.position = vec2(window.width - resizeHitSize, resizeHitSize)
    resizeRightButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  if resizeRightButton.justPressed: grabWindow()
  if resizeRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowRight(grabDelta)

  gui.button(resizeTopButton):
    resizeTopButton.position = vec2(resizeHitSize, 0)
    resizeTopButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  if resizeTopButton.justPressed: grabWindow()
  if resizeTopButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)

  gui.button(resizeBottomButton):
    resizeBottomButton.position = vec2(resizeHitSize, window.height - resizeHitSize)
    resizeBottomButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  if resizeBottomButton.justPressed: grabWindow()
  if resizeBottomButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)

  gui.button(resizeTopRightButton):
    resizeTopRightButton.position = vec2(window.width - resizeHitSize, 0)
    resizeTopRightButton.size = vec2(resizeHitSize, resizeHitSize)
  if resizeTopRightButton.justPressed: grabWindow()
  if resizeTopRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowTop(grabDelta)
    resizeWindowRight(grabDelta)

  gui.button(resizeBottomRightButton):
    resizeBottomRightButton.position = vec2(window.width - resizeHitSize, window.height - resizeHitSize)
    resizeBottomRightButton.size = vec2(resizeHitSize, resizeHitSize)
  if resizeBottomRightButton.justPressed: grabWindow()
  if resizeBottomRightButton.isDown:
    let grabDelta = calculateGrabDelta()
    resizeWindowBottom(grabDelta)
    resizeWindowRight(grabDelta)

  if window.isHoveredIncludingChildren and
     gui.mouseJustPressed(Left) or gui.mouseJustPressed(Middle) or gui.mouseJustPressed(Right):
    window.bringToTop()

  let gfx = gui.drawList
  gfx.drawFrameWithHeader(
    bounds = rect2(vec2(0, 0), window.size),
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgba(13, 17, 23, 0),
    headerColor = rgba(22, 27, 34, 0),
    borderColor = rgb(52, 59, 66),
  )

template window*(gui: Gui, name, code: untyped): untyped =
  let `name` {.inject.} = gui.beginLayer(makeGuiId(name), WindowWidget)
  code
  name.update(gui)
  gui.endLayer()