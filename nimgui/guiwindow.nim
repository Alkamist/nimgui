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
    isRoot*: bool
    childWindows*: seq[GuiWindow]
    inputState*: InputState
    previousInputState*: InputState
    minSize*: Vec2
    maxSize*: Option[Vec2]
    grabState*: GuiWindowGrabState
    dontDraw*: bool
    parentMousePositionWhenGrabbed: Vec2
    positionWhenGrabbed: Vec2
    sizeWhenGrabbed: Vec2
    root {.cursor.}: GuiWindow
    rootHover {.cursor.}: GuiWindow

defineWindowBaseTemplates(GuiWindow)

template `position=`*(window: GuiWindow, value: auto) = window.inputState.position = value
template `x=`*(window: GuiWindow, value: auto) = window.inputState.position.x = value
template `y=`*(window: GuiWindow, value: auto) = window.inputState.position.y = value
template `size=`*(window: GuiWindow, value: auto) = window.inputState.size = value
template `width=`*(window: GuiWindow, value: auto) = window.inputState.size.x = value
template `height=`*(window: GuiWindow, value: auto) = window.inputState.size.y = value

proc newGuiWindow*(): GuiWindow =
  result = GuiWindow()
  result.initInputState()
  result.size = vec2(300, 200)
  result.minSize = vec2(200, headerHeight * 2.0)

proc grabZoneHovered(window: GuiWindow, parentMousePosition: Vec2): bool =
  let m = parentMousePosition
  let w = rect2(window.position, window.size)
  let inTop = m.y >= w.top and m.y < w.top + headerHeight
  let inBottom = m.y < w.bottom and m.y >= w.bottom - resizeHitSize
  let inLeft = m.x >= w.left and m.x < w.left + resizeHitSize
  let inRight = m.x < w.right and m.x >= w.right - resizeHitSize
  inTop or inBottom or inLeft or inRight

proc getHover(window: GuiWindow): GuiWindow =
  for i in countdown(window.childWindows.len - 1, 0, 1):
    let child = window.childWindows[i]
    let childBounds = rect2(child.position, child.size)
    if childBounds.contains(window.mousePosition):
      if child.grabZoneHovered(window.mousePosition):
        return child
      else:
        let hoverOfChild = child.getHover()
        if hoverOfChild != nil:
          return hoverOfChild
        else:
          return child

proc grabBehavior(child: GuiWindow, parentMousePosition: Vec2) =
  if child.mouseJustPressed(Left):
    let m = parentMousePosition
    let w = rect2(child.position, child.size)
    let headerBounds = rect2(child.position, vec2(child.width, headerHeight))

    let inHeader = headerBounds.contains(m)
    let inTop = m.y >= w.top and m.y < w.top + resizeHitSize
    let inBottom = m.y < w.bottom and m.y >= w.bottom - resizeHitSize
    let inLeft = m.x >= w.left and m.x < w.left + resizeHitSize
    let inRight = m.x < w.right and m.x >= w.right - resizeHitSize

    if inTop:
      if inLeft: child.grabState = TopLeft
      elif inRight: child.grabState = TopRight
      else: child.grabState = Top
    elif inBottom:
      if inLeft: child.grabState = BottomLeft
      elif inRight: child.grabState = BottomRight
      else: child.grabState = Bottom
    elif inLeft:
      child.grabState = Left
    elif inRight:
      child.grabState = Right
    elif inHeader:
      child.grabState = Move

    if child.grabState != None:
      child.parentMousePositionWhenGrabbed = parentMousePosition
      child.positionWhenGrabbed = child.position
      child.sizeWhenGrabbed = child.size

  if child.grabState != None:
    let grabDelta = parentMousePosition - child.parentMousePositionWhenGrabbed

    let lastPosition = child.position
    let lastSize = child.size

    case child.grabState:
    of None: discard
    of Move:
      child.position = child.positionWhenGrabbed + grabDelta
    of Left:
      child.x = child.positionWhenGrabbed.x + grabDelta.x
      child.width = child.sizeWhenGrabbed.x - grabDelta.x
    of Right:
      child.width = child.sizeWhenGrabbed.x + grabDelta.x
    of Top:
      child.y = child.positionWhenGrabbed.y + grabDelta.y
      child.height = child.sizeWhenGrabbed.y - grabDelta.y
    of Bottom:
      child.height = child.sizeWhenGrabbed.y + grabDelta.y
    of TopLeft:
      child.x = child.positionWhenGrabbed.x + grabDelta.x
      child.width = child.sizeWhenGrabbed.x - grabDelta.x
      child.y = child.positionWhenGrabbed.y + grabDelta.y
      child.height = child.sizeWhenGrabbed.y - grabDelta.y
    of TopRight:
      child.width = child.sizeWhenGrabbed.x + grabDelta.x
      child.y = child.positionWhenGrabbed.y + grabDelta.y
      child.height = child.sizeWhenGrabbed.y - grabDelta.y
    of BottomLeft:
      child.x = child.positionWhenGrabbed.x + grabDelta.x
      child.width = child.sizeWhenGrabbed.x - grabDelta.x
      child.height = child.sizeWhenGrabbed.y + grabDelta.y
    of BottomRight:
      child.width = child.sizeWhenGrabbed.x + grabDelta.x
      child.height = child.sizeWhenGrabbed.y + grabDelta.y

    if child.width < child.minSize.x or
       child.maxSize.isSome and child.width > child.maxSize.get.x:
      child.x = lastPosition.x
      child.width = lastSize.x

    if child.height < child.minSize.y or
       child.maxSize.isSome and child.height > child.maxSize.get.y:
      child.y = lastPosition.y
      child.height = lastSize.y

    if child.mouseJustReleased(Left):
      child.grabState = None

proc update*(window: GuiWindow, gfx: DrawList) =
  gfx.translate(window.position)

  if not window.dontDraw:
    gfx.drawFrameWithHeader(
      bounds = rect2(vec2(0, 0), window.size),
      borderThickness = 1.0,
      headerHeight = headerHeight,
      cornerRadius = cornerRadius,
      bodyColor = rgb(13, 17, 23),
      headerColor = rgb(22, 27, 34),
      borderColor = rgb(52, 59, 66),
    )

  let bodyBounds = rect2(vec2(0, headerHeight), vec2(window.width, window.height - headerHeight))
  gfx.pushClipRect(bodyBounds)

  if window.isRoot:
    window.root = window
    window.rootHover = window.getHover()

  for child in window.childWindows:
    child.root = window.root
    child.rootHover = window.rootHover
    child.inputState.isHovered = window.rootHover == child
    child.inputState.pixelDensity = window.inputState.pixelDensity
    child.inputState.keyPresses = window.inputState.keyPresses
    child.inputState.keyReleases = window.inputState.keyReleases
    child.inputState.keyIsDown = window.inputState.keyIsDown
    child.inputState.text = window.inputState.text
    child.inputState.mousePosition = window.inputState.mousePosition - child.inputState.position
    child.inputState.mouseReleases = window.inputState.mouseReleases
    if child.inputState.isHovered:
      child.inputState.mouseWheel = child.root.inputState.mouseWheel
      child.inputState.mousePresses = child.root.inputState.mousePresses
      child.inputState.mouseIsDown = child.root.inputState.mouseIsDown

    child.grabBehavior(window.mousePosition)
    child.update(gfx)

  gfx.translate(-window.position)
  gfx.popClipRect()
  window.updateInputState()