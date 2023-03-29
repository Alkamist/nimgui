{.experimental: "overloadableEnums".}

import ../guimod
import ./frame

const resizeHitSize = 8.0
const cornerRadius = 5.0
const headerHeight = 24.0

type
  WindowWidgetGrabMode* = enum
    None
    Move
    Left
    Right
    Top
    Bottom
    TopLeft
    TopRight
    BottomLeft
    BottomRight

  WindowWidget* = ref object
    title*: string
    position*: Vec2
    size*: Vec2
    minSize*: Vec2
    maxSize*: Vec2
    grabMode*: WindowWidgetGrabMode
    mousePositionWhenGrabbed*: Vec2
    positionWhenGrabbed*: Vec2
    sizeWhenGrabbed*: Vec2

template x*(widget: WindowWidget): auto = widget.position.x
template `x=`*(widget: WindowWidget, value: float) = widget.position.x = value
template y*(widget: WindowWidget): auto = widget.position.y
template `y=`*(widget: WindowWidget, value: float) = widget.position.y = value
template width*(widget: WindowWidget): auto = widget.size.x
template `width=`*(widget: WindowWidget, value: float) = widget.size.x = value
template height*(widget: WindowWidget): auto = widget.size.y
template `height=`*(widget: WindowWidget, value: float) = widget.size.y = value

template bounds*(window: WindowWidget): Rect2 =
  rect2(window.position, window.size)

template bodyBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position + vec2(0, headerHeight),
    window.size - vec2(0, headerHeight),
  )

template headerBounds*(window: WindowWidget): Rect2 =
  rect2(
    window.position,
    vec2(window.width, headerHeight),
  )

template grabBehavior(window: WindowWidget, gui: Gui): untyped =
  if gui.mousePressed(Left):
    let m = gui.mousePosition
    let w = window.bounds

    let inHeader = window.headerBounds.contains(gui.mousePosition)
    let inTop = m.y >= w.top and m.y < w.top + resizeHitSize
    let inBottom = m.y < w.bottom and m.y >= w.bottom - resizeHitSize
    let inLeft = m.x >= w.left and m.x < w.left + resizeHitSize
    let inRight = m.x < w.right and m.x >= w.right - resizeHitSize

    if inTop:
      if inLeft: window.grabMode = TopLeft
      elif inRight: window.grabMode = TopRight
      else: window.grabMode = Top
    elif inBottom:
      if inLeft: window.grabMode = BottomLeft
      elif inRight: window.grabMode = BottomRight
      else: window.grabMode = Bottom
    elif inLeft:
      window.grabMode = Left
    elif inRight:
      window.grabMode = Right
    elif inHeader:
      window.grabMode = Move

    if window.grabMode != None:
      window.mousePositionWhenGrabbed = gui.mousePosition
      window.positionWhenGrabbed = window.position
      window.sizeWhenGrabbed = window.size

  if window.grabMode != None:
    let grabDelta = gui.mousePosition - window.mousePositionWhenGrabbed

    let lastPosition = window.position
    let lastSize = window.size

    case window.grabMode:
    of None: discard
    of Move:
      window.position = window.positionWhenGrabbed + grabDelta
    of Left:
      window.x = window.positionWhenGrabbed.x + grabDelta.x
      window.width = window.sizeWhenGrabbed.x - grabDelta.x
    of Right:
      window.width = window.sizeWhenGrabbed.x + grabDelta.x
    of Top:
      window.y = window.positionWhenGrabbed.y + grabDelta.y
      window.height = window.sizeWhenGrabbed.y - grabDelta.y
    of Bottom:
      window.height = window.sizeWhenGrabbed.y + grabDelta.y
    of TopLeft:
      window.x = window.positionWhenGrabbed.x + grabDelta.x
      window.width = window.sizeWhenGrabbed.x - grabDelta.x
      window.y = window.positionWhenGrabbed.y + grabDelta.y
      window.height = window.sizeWhenGrabbed.y - grabDelta.y
    of TopRight:
      window.width = window.sizeWhenGrabbed.x + grabDelta.x
      window.y = window.positionWhenGrabbed.y + grabDelta.y
      window.height = window.sizeWhenGrabbed.y - grabDelta.y
    of BottomLeft:
      window.x = window.positionWhenGrabbed.x + grabDelta.x
      window.width = window.sizeWhenGrabbed.x - grabDelta.x
      window.height = window.sizeWhenGrabbed.y + grabDelta.y
    of BottomRight:
      window.width = window.sizeWhenGrabbed.x + grabDelta.x
      window.height = window.sizeWhenGrabbed.y + grabDelta.y

    if window.width < window.minSize.x or
       window.width > window.maxSize.x:
      window.x = lastPosition.x
      window.width = lastSize.x

    if window.height < window.minSize.y or
       window.height > window.maxSize.y:
      window.y = lastPosition.y
      window.height = lastSize.y

    if gui.mouseReleased(Left):
      window.grabMode = None

proc update*(window: WindowWidget, gui: Gui) =
  let gfx = gui.gfx
  let bounds = window.bounds

  window.grabBehavior(gui)

  gfx.drawFrameWithHeader(
    bounds = bounds,
    borderThickness = 1.0,
    headerHeight = headerHeight,
    cornerRadius = cornerRadius,
    bodyColor = rgb(13, 17, 23),
    headerColor = rgb(22, 27, 34),
    borderColor = rgb(52, 59, 66),
  )

  # gfx.clip(bodyBounds.expand(-0.5 * cornerRadius))