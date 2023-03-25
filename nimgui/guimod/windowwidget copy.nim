{.experimental: "overloadableEnums".}

import ../guimod
# import ./layerwidget
import ./buttonwidget

type
  WindowWidget* = ref object of WidgetContainer
    title*: string
    headerHeight*: float

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

  # let cornerRadius = 5.0
  # let shadowFeather = 15.0

  # # Drop shadow.
  # let shadowPaint = gfx.boxGradient(bounds, cornerRadius * 2, shadowFeather, rgba(0, 0, 0, 64), rgba(0, 0, 0, 0))
  # gfx.beginPath()
  # gfx.rect(bounds.expand(shadowFeather).translate(vec2(8, 8)))
  # gfx.roundedRect(bounds, cornerRadius)
  # gfx.pathWinding = Hole
  # gfx.fillPaint = shadowPaint
  # gfx.fill()

  # # Frame.
  # gfx.drawFrameWithHeader(
  #   bounds = bounds,
  #   borderThickness = 1.0,
  #   headerHeight = headerBounds.height,
  #   cornerRadius = 5.0,
  #   bodyColor = rgb(13, 17, 23),
  #   headerColor = rgb(22, 27, 34),
  #   borderColor = rgb(52, 59, 66),
  # )

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

  # gui.button(headerButton)
  # headerButton.size = headerBounds.size
  # if headerButton.isDown and gui.mouseMoved:
  #   window.position += gui.mouseDelta

  # gfx.clip(bodyBounds.expand(-0.5 * cornerRadius))
  # window.updateChildren(gui)
  # gfx.resetClip()

implementContainerWidget(window, WindowWidget(
  headerHeight: 24,
  size: vec2(300, 200),
))