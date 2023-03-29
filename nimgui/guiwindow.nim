{.experimental: "overloadableEnums".}

import std/options; export options
import ./math; export math
import ./windowbase; export windowbase
import ./drawlist; export drawlist
import ./frame; export frame

const resizeHitSize = 8.0
const cornerRadius = 5.0
const headerHeight = 24.0

type
  GuiWindowGrabState* = enum
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

  GuiWindow* = ref object
    inputState*: InputState
    previousInputState*: InputState
    drawList*: DrawList
    minSize*: Vec2
    maxSize*: Option[Vec2]
    grabState*: GuiWindowGrabState
    mousePositionWhenGrabbed*: Vec2
    positionWhenGrabbed*: Vec2
    sizeWhenGrabbed*: Vec2

defineWindowBaseTemplates(GuiWindow)

template `bounds=`*(window: GuiWindow, value: auto) = window.inputState.bounds = value
template `position=`*(window: GuiWindow, value: auto) = window.inputState.bounds.position = value
template `x=`*(window: GuiWindow, value: auto) = window.inputState.bounds.position.x = value
template `y=`*(window: GuiWindow, value: auto) = window.inputState.bounds.position.y = value
template `size=`*(window: GuiWindow, value: auto) = window.inputState.bounds.size = value
template `width=`*(window: GuiWindow, value: auto) = window.inputState.bounds.size.x = value
template `height=`*(window: GuiWindow, value: auto) = window.inputState.bounds.size.y = value

template bodyBounds*(window: GuiWindow): Rect2 =
  rect2(
    window.position + vec2(0, headerHeight),
    window.size - vec2(0, headerHeight),
  )

template headerBounds*(window: GuiWindow): Rect2 =
  rect2(
    window.position,
    vec2(window.width, headerHeight),
  )

proc newGuiWindow*(): GuiWindow =
  result = GuiWindow()
  result.initInputState()
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)
  result.drawList = newDrawList()

template grabBehavior(window: GuiWindow): untyped =
  if window.mousePressed(Left):
    let m = window.mousePosition
    let w = window.bounds

    let inHeader = window.headerBounds.contains(window.mousePosition)
    let inTop = m.y >= w.top and m.y < w.top + resizeHitSize
    let inBottom = m.y < w.bottom and m.y >= w.bottom - resizeHitSize
    let inLeft = m.x >= w.left and m.x < w.left + resizeHitSize
    let inRight = m.x < w.right and m.x >= w.right - resizeHitSize

    if inTop:
      if inLeft: window.grabState = TopLeft
      elif inRight: window.grabState = TopRight
      else: window.grabState = Top
    elif inBottom:
      if inLeft: window.grabState = BottomLeft
      elif inRight: window.grabState = BottomRight
      else: window.grabState = Bottom
    elif inLeft:
      window.grabState = Left
    elif inRight:
      window.grabState = Right
    elif inHeader:
      window.grabState = Move

    if window.grabState != None:
      window.mousePositionWhenGrabbed = window.mousePosition
      window.positionWhenGrabbed = window.position
      window.sizeWhenGrabbed = window.size

  if window.grabState != None:
    let grabDelta = window.mousePosition - window.mousePositionWhenGrabbed

    let lastPosition = window.position
    let lastSize = window.size

    case window.grabState:
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
       window.maxSize.isSome and window.width > window.maxSize.get.x:
      window.x = lastPosition.x
      window.width = lastSize.x

    if window.height < window.minSize.y or
       window.maxSize.isSome and window.height > window.maxSize.get.y:
      window.y = lastPosition.y
      window.height = lastSize.y

    if window.mouseReleased(Left):
      window.grabState = None

proc beginFrame*(window: GuiWindow) =
  let gfx = window.drawList
  let bounds = window.bounds

  window.grabBehavior()

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

proc endFrame*(window: GuiWindow) =
  window.updateInputState()
  window.drawList.clearCommands()