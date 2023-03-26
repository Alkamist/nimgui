{.experimental: "overloadableEnums".}

import ../guimod
import ./buttonwidget

type
  WindowWidget* = ref object of WidgetContainer
    title*: string
    headerHeight*: float

proc new*(T: type WindowWidget, gui: Gui): T =
  result = T()
  result.headerHeight = 24
  result.size = vec2(300, 200)

proc update*(window: WindowWidget, gui: Gui) =
  let gfx = gui.drawList
  let bounds = window.bounds
  let bodyBounds = rect2(
    window.bounds.position + vec2(0, window.headerHeight),
    window.bounds.size - vec2(0, window.headerHeight),
  )
  let headerBounds = rect2(
    window.bounds.position,
    vec2(window.width, window.headerHeight),
  )

  let cornerRadius = 5.0
  # let shadowFeather = 15.0

  # # Drop shadow.
  # let shadowPaint = gfx.boxGradient(bounds, cornerRadius * 2, shadowFeather, rgba(0, 0, 0, 64), rgba(0, 0, 0, 0))
  # gfx.beginPath()
  # gfx.rect(bounds.expand(shadowFeather).translate(vec2(8, 8)))
  # gfx.roundedRect(bounds, cornerRadius)
  # gfx.pathWinding = Hole
  # gfx.fillPaint = shadowPaint
  # gfx.fill()

  # Frame.
  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = 1.0,
    headerHeight = headerBounds.height,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  # # Title text.
  # gfx.fontSize = 13
  # gfx.fillColor = rgb(201, 209, 217)
  # gfx.drawText(
  #   gfx.newText(window.title),
  #   headerBounds,
  #   alignX = Center,
  #   alignY = Center,
  #   wordWrap = false,
  #   clip = true,
  # )

  gui.invisibleButton(headerButton)
  headerButton.size = headerBounds.size
  if headerButton.isDown and gui.mouseMoved:
    window.position += gui.mouseDelta

  const headerPadding = vec2(3, 3)
  gui.invisibleButton(closeButton)
  let closeButtonHeight = headerBounds.height - headerPadding.y * 2.0
  closeButton.size = vec2(closeButtonHeight, closeButtonHeight)
  closeButton.position = vec2(window.width - closeButton.width - headerPadding.x, headerPadding.y)
  gfx.beginPath()
  gfx.roundedRect(closeButton.bounds, 2.0)
  let closeButtonColor = rgb(16, 120, 16)
  if closeButton.isDown: gfx.fillColor = closeButtonColor.darken(0.3)
  elif gui.hover == closeButton: gfx.fillColor = closeButtonColor.lighten(0.05)
  else: gfx.fillColor = closeButtonColor
  gfx.fill()


  # gfx.clip(bodyBounds.expand(-0.5 * cornerRadius))

  if gui.isHoveredIncludingChildren(window) and
     (gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)):
    gui.bringContainerToTopOfParentContainer(window)

implementWidget(window, WindowWidget)