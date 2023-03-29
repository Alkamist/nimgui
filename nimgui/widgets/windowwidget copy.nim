{.experimental: "overloadableEnums".}

import ../guimod
import ./frame
import ./buttonwidget

const resizeHitSize = 8.0
const resizeHitSize2 = resizeHitSize * 2.0
const cornerRadius = 5.0
const headerHeight = 24.0

type
  WindowWidget* = ref object of WidgetContainer
    title*: string
    resizeStart*: Vec2

proc resizeBehavior(window: WindowWidget, gui: Gui) =
  let w = window.absoluteBounds

  let left = gui.addButton("Left Resize Button")
  let right = gui.addButton("Right Resize Button")
  let top = gui.addButton("Top Resize Button")
  let bottom = gui.addButton("Bottom Resize Button")
  let topLeft = gui.addButton("Top Left Resize Button")
  let topRight = gui.addButton("Top Right Resize Button")
  let bottomLeft = gui.addButton("Bottom Left Resize Button")
  let bottomRight = gui.addButton("Bottom Right Resize Button")

  if left.pressed:
    window.resizeStart = gui.mousePosition
  if left.isDown and gui.mouseMoved:
    window.x += gui.mouseDelta.x
    window.width -= gui.mouseDelta.x

  left.position = vec2(0, resizeHitSize)
  left.size = vec2(resizeHitSize, w.height - resizeHitSize2)
  right.position = vec2(w.width - resizeHitSize, resizeHitSize)
  right.size = vec2(resizeHitSize, w.height - resizeHitSize2)
  top.position = vec2(resizeHitSize, 0)
  top.size = vec2(w.width - resizeHitSize2, resizeHitSize)
  bottom.position = vec2(resizeHitSize, w.height - resizeHitSize)
  bottom.size = vec2(w.width - resizeHitSize2, resizeHitSize)
  topLeft.position = vec2(0, 0)
  topLeft.size = vec2(resizeHitSize, resizeHitSize)
  topRight.position = vec2(w.width - resizeHitSize, 0)
  topRight.size = vec2(resizeHitSize, resizeHitSize)
  bottomLeft.position = vec2(0, w.height - resizeHitSize)
  bottomLeft.size = vec2(resizeHitSize, resizeHitSize)
  bottomRight.position = vec2(w.width - resizeHitSize, w.height - resizeHitSize)
  bottomRight.size = vec2(resizeHitSize, resizeHitSize)

proc beginWindow*(gui: Gui, id: WidgetId): WindowWidget {.discardable.} =
  let window = gui.beginContainer(id, WindowWidget)
  if window.justCreated:
    window.size = vec2(300, 200)

  let gfx = gui.drawList
  let bounds = window.absoluteBounds
  let bodyBounds = rect2(
    bounds.position + vec2(0, headerHeight),
    bounds.size - vec2(0, headerHeight),
  )
  let headerBounds = rect2(
    bounds.position,
    vec2(window.width, headerHeight),
  )

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

  let headerButton = gui.addInvisibleButton("Header Button")
  headerButton.size = headerBounds.size
  if headerButton.isDown and gui.mouseMoved:
    window.position += gui.mouseDelta

  const headerPadding = vec2(3, 3)
  let closeButton = gui.addInvisibleButton("Close Button")
  let closeButtonHeight = headerBounds.height - headerPadding.y * 2.0
  closeButton.size = vec2(closeButtonHeight, closeButtonHeight)
  closeButton.position = vec2(window.width - closeButton.width - headerPadding.x, headerPadding.y)
  gfx.beginPath()
  gfx.roundedRect(closeButton.absoluteBounds, 2.0)
  let closeButtonColor = rgb(16, 120, 16)
  if closeButton.isDown: gfx.fillColor = closeButtonColor.darken(0.3)
  elif gui.hover == closeButton: gfx.fillColor = closeButtonColor.lighten(0.05)
  else: gfx.fillColor = closeButtonColor
  gfx.fill()

  gfx.clip(bodyBounds.expand(-0.5 * cornerRadius))

proc endWindow*(gui: Gui) =
  let window = gui.beginEndContainer(WindowWidget)
  let gfx = gui.drawList
  gfx.resetClip()

  window.resizeBehavior(gui)
  if gui.isHoveredIncludingChildren(window) and
     (gui.mousePressed(Left) or gui.mousePressed(Middle) or gui.mousePressed(Right)):
    window.bringToTop()

  gui.endContainer()