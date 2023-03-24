{.experimental: "overloadableEnums".}

import std/macros
import ../guimod
import ./buttonwidget

type
  WindowWidget* = ref object of WidgetContainer
    title*: string
    isOpen*: bool
    isResizable*: bool
    moved*: bool
    resized*: bool
    headerHeight*: float
    headerIsHovered*: bool
    headerIsGrabbed*: bool

proc headerBounds(window: WindowWidget): Rect2 =
  rect2(
    window.bounds.position,
    vec2(window.width, window.headerHeight),
  )

proc bodyBounds(window: WindowWidget): Rect2 =
  rect2(
    window.bounds.position + vec2(0, window.headerHeight),
    window.bounds.size - vec2(0, window.headerHeight),
  )

proc windowBehavior*(window: WindowWidget, gui: Gui) =
  window.moved = false

  let isHovered = gui.hover == window

  window.isOpen = true

  window.headerIsHovered =
    not window.headerIsGrabbed and
    isHovered and
    window.headerBounds.contains(gui.mousePosition)

  if window.headerIsHovered and gui.mousePressed(Left):
    window.headerIsGrabbed = true

  if window.headerIsGrabbed and gui.mouseReleased(Left):
    window.headerIsGrabbed = false

  if window.headerIsGrabbed and gui.mouseMoved:
    window.position += gui.mouseDelta
    window.moved = true

proc resizeButtonBehavior*(window: WindowWidget, gui: Gui) =
  if window.isResizable:
    gui.button(resizeButton):
      resizeButton.position = window.size - resizeButton.size
      if resizeButton.isDown and gui.mouseMoved:
        window.size += gui.mouseDelta
        window.resized = true

proc draw*(window: WindowWidget, gui: Gui) =
  let gfx = gui.gfx
  let bounds = window.bounds
  let headerBounds = window.headerBounds
  let cornerRadius = 5.0

  gfx.saveState()

  let shadowFeather = 15.0

  # Drop shadow.
  let shadowPaint = gfx.boxGradient(bounds, cornerRadius * 2, shadowFeather, rgba(0, 0, 0, 64), rgba(0, 0, 0, 0))
  gfx.beginPath()
  gfx.rect(bounds.expand(shadowFeather).translate(vec2(8, 8)))
  gfx.roundedRect(bounds, cornerRadius)
  gfx.pathWinding = Hole
  gfx.fillPaint = shadowPaint
  gfx.fill()

  # Frame.
  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = 1.0,
    headerHeight = headerBounds.height,
    cornerRadius = 5.0,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  # Title text.
  gfx.fontSize = 13
  gfx.fillColor = rgb(201, 209, 217)
  gfx.drawText(
    gfx.newText(window.title),
    headerBounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

  let clipRect = window.bodyBounds.expand(-0.5 * cornerRadius)
  gfx.clip(clipRect)
  window.updateChildren(gui)

  gfx.restoreState()

# template window*(gui: Gui, id: string, code: untyped) =
#   let self = gui.addWidget(id, WindowWidget(
#     title: id,
#     headerHeight: 24,
#     size: vec2(300, 200),
#     isResizable: true,
#   ))

#   self.update = proc(widget: Widget) =
#     let window = cast[WindowWidget](widget)
#     gui.pushContainer window
#     window.windowBehavior(gui)
#     code
#     window.resizeButtonBehavior(gui)
#     window.draw(gui)
#     gui.popContainer()

macro window*(gui: Gui, id, code: untyped): untyped =
  let idString = id.strVal
  quote do:
    let self = `gui`.addWidget(`idString`, WindowWidget(
      headerHeight: 24,
      size: vec2(300, 200),
      isResizable: true,
    ))

    self.update = proc(widget: Widget) =
      let `id` {.inject.} = cast[WindowWidget](widget)
      `gui`.pushContainer `id`
      `id`.windowBehavior(`gui`)
      `code`
      `id`.resizeButtonBehavior(`gui`)
      `id`.draw(`gui`)
      `gui`.popContainer()