import ../gui
import ./button

type
  SliderState* = object
    handle*: ButtonState
    valueWhenHandleGrabbed*: float
    globalMousePositionWhenHandleGrabbed*: Vec2

proc slider*(gui: Gui, id: GuiId,
  value: var float,
  position = vec2(0, 0),
  size = vec2(300, 24),
  minValue = 0.0,
  maxValue = 1.0,
  handleLength = 16.0,
  draw = true,
): SliderState {.discardable.} =
  var slider = gui.getState(id, SliderState())

  gui.pushId(id)

  let minValue = minValue
  let maxValue = maxValue.max(minValue)

  value = value.clamp(minValue, maxValue)

  let handlePosition = position + vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  let handleSize = vec2(handleLength, size.y)

  let handleId = gui.getId("Handle")
  let handle = gui.button(handleId,
    position = handlePosition,
    size = handleSize,
    draw = false,
  )

  if handle.pressed or gui.keyPressed(LeftControl) or gui.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = gui.globalMousePosition

  let sensitivity =
    if gui.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = gui.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handleLength)
    value = value.clamp(minValue, maxValue)

  gui.setState(id, slider)

  if draw:
    let path = Path.new()
    path.roundedRect(position, size, 3)
    gui.fillPath(path, rgb(31, 32, 34))
    path.clear()

    path.roundedRect(handlePosition, handleSize, 3)
    gui.fillPath(path, rgb(49, 51, 56).lighten(0.3))
    if handle.isDown:
      gui.fillPath(path, rgba(0, 0, 0, 8))
    elif gui.isHovered(handleId):
      gui.fillPath(path, rgba(255, 255, 255, 8))

  gui.popId()

  slider

proc slider*(gui: Gui, id: string,
  value: var float,
  position = vec2(0, 0),
  size = vec2(300, 24),
  minValue = 0.0,
  maxValue = 1.0,
  handleLength = 16.0,
  draw = true,
): SliderState {.discardable.} =
  gui.slider(gui.getId(id), value, position, size, minValue, maxValue, handleLength, draw)