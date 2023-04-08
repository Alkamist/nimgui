{.experimental: "overloadableEnums".}

import ../guimod
import ./guibutton
import ./guitext
import ./frame

const resizeHitSize = 5.0
const resizeHitSize2 = resizeHitSize * 2.0
const resizeHitSize4 = resizeHitSize2 * 2.0
const borderThickness = 1.0
const headerHeight = 22.0
const cornerRadius = 4.0
const roundingInset = (1.0 - sin(45.0.degToRad)) * cornerRadius

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
  window.body.position = vec2(borderThickness + roundingInset, headerHeight + borderThickness)
  window.body.size = vec2(
    window.width - 2.0 * (borderThickness + roundingInset),
    window.height - headerHeight - roundingInset - 2.0 * borderThickness,
  )

  if window.resizeLeftButton.mouseEntered or window.resizeRightButton.mouseEntered:
    gui.mouseCursorImage = ResizeLeftRight
  elif window.resizeTopButton.mouseEntered or window.resizeBottomButton.mouseEntered:
    gui.mouseCursorImage = ResizeTopBottom
  elif window.resizeTopLeftButton.mouseEntered or window.resizeBottomRightButton.mouseEntered:
    gui.mouseCursorImage = ResizeTopLeftBottomRight
  elif window.resizeTopRightButton.mouseEntered or window.resizeBottomLeftButton.mouseEntered:
    gui.mouseCursorImage = ResizeTopRightBottomLeft
  elif window.resizeLeftButton.mouseExited or window.resizeRightButton.mouseExited or
       window.resizeTopButton.mouseExited or window.resizeBottomButton.mouseExited or
       window.resizeTopLeftButton.mouseExited or window.resizeBottomRightButton.mouseExited or
       window.resizeTopRightButton.mouseExited or window.resizeBottomLeftButton.mouseExited:
    gui.mouseCursorImage = Arrow

  if window.isHoveredIncludingChildren and
     (gui.mouseJustPressed(Left) or gui.mouseJustPressed(Middle) or gui.mouseJustPressed(Right)):
    window.bringToTop()

  window.updateChildren()

proc drawWindow(widget: GuiWidget) =
  let window = GuiWindow(widget)
  let gfx = window.gui.gfx

  gfx.drawFrameShadow(0, 0, window.width, window.height, cornerRadius)
  gfx.drawFrameWithHeader(
    0, 0,
    window.width, window.height,
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(49, 51, 56),
    bodyBorderColor = rgb(49, 51, 56).lighten(0.1),
    headerColor = rgb(30, 31, 34),
    headerBorderColor = rgb(30, 31, 34),
  )

  window.drawChildren()

func addWindow*(parent: GuiWidget): GuiWindow =
  result = parent.addWidget(GuiWindow)
  result.dontClip = true
  result.passInput = true
  result.update = updateWindow
  result.draw = drawWindow
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)

  result.body = result.addWidget()
  result.moveButton = result.addButton()
  result.moveButton.dontDraw = true
  result.header = result.addWidget()
  result.header.passInput = true
  result.resizeButtons = result.addWidget()
  result.resizeButtons.dontDraw = true
  result.resizeButtons.dontClip = true
  result.resizeButtons.passInput = true
  result.resizeLeftButton = result.resizeButtons.addButton()
  result.resizeRightButton = result.resizeButtons.addButton()
  result.resizeTopButton = result.resizeButtons.addButton()
  result.resizeBottomButton = result.resizeButtons.addButton()
  result.resizeTopLeftButton = result.resizeButtons.addButton()
  result.resizeTopRightButton = result.resizeButtons.addButton()
  result.resizeBottomLeftButton = result.resizeButtons.addButton()
  result.resizeBottomRightButton = result.resizeButtons.addButton()

func addTitle*(window: GuiWindow, title: string): GuiText {.discardable.} =
  result = window.header.addText()
  result.data = title
  result.alignX = Center
  result.alignY = Center
  result.color = rgb(242, 243, 245)
  result.passInput = true
  result.updateHook:
    self.size = self.parent.size