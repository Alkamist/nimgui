{.experimental: "overloadableEnums".}

import ../guimod
import ./guibutton
import ./frame

const resizeHitSize = 8.0
const resizeHitSize2 = resizeHitSize * 2.0
const borderThickness = 1.0
const headerHeight = 24.0
const cornerRadius = 0.0

type
  GuiWindow* = ref object of GuiWidget
    header*: GuiWidget
    body*: GuiWidget
    moveButton*: GuiButton
    resizeLeftButton*: GuiButton
    resizeRightButton*: GuiButton
    resizeTopButton*: GuiButton
    resizeBottomButton*: GuiButton
    resizeTopLeftButton*: GuiButton
    resizeTopRightButton*: GuiButton
    resizeBottomLeftButton*: GuiButton
    resizeBottomRightButton*: GuiButton
    minSize*: Vec2
    guiMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2
    resizeButtons: GuiWidget

func updateMoveResizeButtonBounds(window: GuiWindow) =
  window.resizeButtons.size = window.size
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

proc updateWindow(widget: GuiWidget) =
  let window = GuiWindow(widget)
  let gui = window.gui

  window.updateMoveResizeButtonBounds()
  window.moveAndResize()

  window.header.position = vec2(borderThickness, borderThickness)
  window.header.size = vec2(
    window.width - 2.0 * borderThickness,
    headerHeight - borderThickness,
  )
  window.body.position = vec2(borderThickness, headerHeight)
  window.body.size = vec2(
    window.width - 2.0 * borderThickness,
    window.height - headerHeight - borderThickness,
  )

  if window.isHoveredIncludingChildren and
     (gui.mouseJustPressed(Left) or gui.mouseJustPressed(Middle) or gui.mouseJustPressed(Right)):
    window.bringToTop()

  window.updateChildren()

proc drawWindow(widget: GuiWidget) =
  let window = GuiWindow(widget)
  let gfx = window.gui.drawList

  gfx.drawFrameWithHeader(
    bounds = window.bounds,
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  window.drawChildren()

func addWindow*(parent: GuiWidget): GuiWindow =
  result = parent.addWidget(GuiWindow)
  result.update = updateWindow
  result.draw = drawWindow
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)

  result.body = result.addWidget()
  result.moveButton = result.addButton()
  result.header = result.addWidget()
  result.header.passInput = true
  result.resizeButtons = result.addWidget()
  result.resizeButtons.dontDraw = true
  result.resizeButtons.passInput = true
  result.resizeLeftButton = result.resizeButtons.addButton()
  result.resizeRightButton = result.resizeButtons.addButton()
  result.resizeTopButton = result.resizeButtons.addButton()
  result.resizeBottomButton = result.resizeButtons.addButton()
  result.resizeTopLeftButton = result.resizeButtons.addButton()
  result.resizeTopRightButton = result.resizeButtons.addButton()
  result.resizeBottomLeftButton = result.resizeButtons.addButton()
  result.resizeBottomRightButton = result.resizeButtons.addButton()