import ../gui
import ./button

type
  Slider* = ref object of Widget
    position*: Vec2
    size*: Vec2
    value*: float
    minValue*: float
    maxValue*: float
    handleLength*: float
    handle*: Button
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc init*(slider: Slider) =
  slider.handle = slider.gui.newWidget(Button)
  slider.size = vec2(300, 24)
  slider.minValue = 0.0
  slider.maxValue = 1.0
  slider.handleLength = 16.0

proc update*(slider: Slider, draw = true) =
  let gui = slider.gui

  let position = slider.position
  let size = slider.size
  let handleLength = slider.handleLength
  let minValue = slider.minValue
  let maxValue = slider.maxValue.max(minValue)
  var value = slider.value.clamp(minValue, maxValue)

  let handle = slider.handle
  handle.position = position + vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  handle.size = vec2(handleLength, size.y)

  handle.update(draw = false)

  if handle.pressed or gui.keyPressed(LeftControl) or gui.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = gui.globalMousePosition

  let sensitivity =
    if gui.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = gui.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handleLength)
    slider.value = value.clamp(minValue, maxValue)

  if draw:
    let path = Path.new()
    path.roundedRect(position, size, 3)
    gui.fillPath(path, rgb(31, 32, 34))
    path.clear()

    path.roundedRect(gui.pixelAlign(handle.position), gui.pixelAlign(handle.size), 3)
    gui.fillPath(path, rgb(49, 51, 56).lighten(0.3))
    if handle.isDown:
      gui.fillPath(path, rgba(0, 0, 0, 8))
    elif gui.hover == handle:
      gui.fillPath(path, rgba(255, 255, 255, 8))