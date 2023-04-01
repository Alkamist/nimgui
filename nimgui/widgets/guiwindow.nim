{.experimental: "overloadableEnums".}

import ../guimod
import ./guibutton
import ./frame

const resizeHitSize = 8.0
const resizeHitSize2 = resizeHitSize * 2.0
const borderThickness = 1.0
const headerHeight = 24.0
const cornerRadius = 5.0

type
  GuiWindow* = ref object of GuiLayer
    minSize*: Vec2
    moveButton*: GuiButton
    resizeLeftButton*: GuiButton
    resizeRightButton*: GuiButton
    resizeTopButton*: GuiButton
    resizeBottomButton*: GuiButton
    resizeTopLeftButton*: GuiButton
    resizeTopRightButton*: GuiButton
    resizeBottomLeftButton*: GuiButton
    resizeBottomRightButton*: GuiButton
    guiMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

func addWindow*(layer: GuiLayer): GuiWindow =
  result = layer.addWidget(GuiWindow)
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)
  result.moveButton = result.addButton()
  result.moveButton.dontDraw = true
  result.resizeLeftButton = result.addButton()
  result.resizeLeftButton.dontDraw = true
  result.resizeRightButton = result.addButton()
  result.resizeRightButton.dontDraw = true
  result.resizeTopButton = result.addButton()
  result.resizeTopButton.dontDraw = true
  result.resizeBottomButton = result.addButton()
  result.resizeBottomButton.dontDraw = true
  result.resizeTopLeftButton = result.addButton()
  result.resizeTopLeftButton.dontDraw = true
  result.resizeTopRightButton = result.addButton()
  result.resizeTopRightButton.dontDraw = true
  result.resizeBottomLeftButton = result.addButton()
  result.resizeBottomLeftButton.dontDraw = true
  result.resizeBottomRightButton = result.addButton()
  result.resizeBottomRightButton.dontDraw = true

func updateButtonBounds(window: GuiWindow) =
  window.moveButton.position = vec2(0, 0)
  window.moveButton.size = vec2(window.width, headerHeight)
  window.resizeLeftButton.position = vec2(0, resizeHitSize)
  window.resizeLeftButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.resizeRightButton.position = vec2(window.width - resizeHitSize, resizeHitSize)
  window.resizeRightButton.size = vec2(resizeHitSize, window.height - resizeHitSize2)
  window.resizeTopButton.position = vec2(resizeHitSize, 0)
  window.resizeTopButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  window.resizeBottomButton.position = vec2(resizeHitSize, window.height - resizeHitSize)
  window.resizeBottomButton.size = vec2(window.width - resizeHitSize2, resizeHitSize)
  window.resizeTopLeftButton.position = vec2(0, 0)
  window.resizeTopLeftButton.size = vec2(resizeHitSize, resizeHitSize)
  window.resizeTopRightButton.position = vec2(window.width - resizeHitSize, 0)
  window.resizeTopRightButton.size = vec2(resizeHitSize, resizeHitSize)
  window.resizeBottomLeftButton.position = vec2(0, window.height - resizeHitSize)
  window.resizeBottomLeftButton.size = vec2(resizeHitSize, resizeHitSize)
  window.resizeBottomRightButton.position = vec2(window.width - resizeHitSize, window.height - resizeHitSize)
  window.resizeBottomRightButton.size = vec2(resizeHitSize, resizeHitSize)

func moveAndResize(window: GuiWindow) =
  let gui = window.gui

  template calculateGrabDelta(): Vec2 =
    gui.mousePosition - window.guiMousePositionWhenGrabbed

  template moveWindow(grabDelta: Vec2): untyped =
    window.position = window.positionWhenGrabbed + grabDelta

  template resizeWindowLeft(grabDelta: Vec2): untyped =
    window.x = window.positionWhenGrabbed.x + grabDelta.x
    window.width = window.sizeWhenGrabbed.x - grabDelta.x
    if window.width < window.minSize.x:
      let correction = window.width - window.minSize.x
      window.x += correction
      window.width -= correction

  template resizeWindowRight(grabDelta: Vec2): untyped =
    window.width = window.sizeWhenGrabbed.x + grabDelta.x
    if window.width < window.minSize.x:
      let correction = window.width - window.minSize.x
      window.width -= correction

  template resizeWindowTop(grabDelta: Vec2): untyped =
    window.y = window.positionWhenGrabbed.y + grabDelta.y
    window.height = window.sizeWhenGrabbed.y - grabDelta.y
    if window.height < window.minSize.y:
      let correction = window.height - window.minSize.y
      window.y += correction
      window.height -= correction

  template resizeWindowBottom(grabDelta: Vec2): untyped =
    window.height = window.sizeWhenGrabbed.y + grabDelta.y
    if window.height < window.minSize.y:
      let correction = window.height - window.minSize.y
      window.height -= correction

  window.updateButtonBounds()

  window.moveButton.update()
  window.resizeLeftButton.update()
  window.resizeRightButton.update()
  window.resizeTopButton.update()
  window.resizeBottomButton.update()
  window.resizeTopLeftButton.update()
  window.resizeTopRightButton.update()
  window.resizeBottomLeftButton.update()
  window.resizeBottomRightButton.update()

  if window.moveButton.justPressed or
     window.resizeLeftButton.justPressed or window.resizeRightButton.justPressed or
     window.resizeTopButton.justPressed or window.resizeBottomButton.justPressed or
     window.resizeTopLeftButton.justPressed or window.resizeTopRightButton.justPressed or
     window.resizeBottomLeftButton.justPressed or window.resizeBottomRightButton.justPressed:
    window.guiMousePositionWhenGrabbed = gui.mousePosition
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

method update*(window: GuiWindow) =
  let gui = window.gui

  window.moveAndResize()

  if window.isHoveredIncludingChildren and
     gui.mouseJustPressed(Left) or gui.mouseJustPressed(Middle) or gui.mouseJustPressed(Right):
    window.bringToTop()

method draw*(window: GuiWindow) =
  let gfx = window.gui.drawList

  gfx.translate(window.position)
  gfx.drawFrameWithHeader(
    bounds = rect2(vec2(0, 0), window.size),
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  window.drawChildren()
  gfx.translate(-window.position)