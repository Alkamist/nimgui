{.experimental: "overloadableEnums".}

import ./buttonwidget
import ../guimod
import ../frame

const resizeHitSize = 8.0
const borderThickness = 1.0
const headerHeight = 24.0
const cornerRadius = 5.0

type
  WindowWidget* = ref object of GuiWidget
    mousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2

template grab(): untyped =
  window.mousePositionWhenGrabbed = view.mousePosition
  window.positionWhenGrabbed = window.position
  window.sizeWhenGrabbed = window.size

func beginWindow*(gui: Gui, id: GuiId): WindowWidget =
  let gfx = gui.gfx

  let window = gui.addWidget(id, WindowWidget)
  if window.justCreated:
    window.size = vec2(300, 200)

  let bounds = window.bounds

  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = borderThickness,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  let windowView = gui.beginView(id & "View")
  windowView.position = vec2(window.x, window.y + headerHeight)
  windowView.size = vec2(window.width, window.height - headerHeight)

  window

func endWindow*(gui: Gui) =
  gui.endView()

  let moveButton = gui.addButton("MoveButton")
  moveButton.size = vec2(300, headerHeight)
  if moveButton.justPressed:
    grab()
  if moveButton.isDown:
    let grabDelta = view.mousePosition - window.mousePositionWhenGrabbed
    window.position = window.positionWhenGrabbed + grabDelta

  moveButton.position = window.position