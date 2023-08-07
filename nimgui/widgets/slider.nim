import ../gui
import ./button

type
  Slider* = ref object of Widget
    position*: Vec2
    size* = vec2(300, 24)
    value*: float
    minValue* = 0.0
    maxValue* = 1.0
    handleLength* = 16.0
    handle*: Button
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc new*(_: typedesc[Slider]): Slider =
  result = Slider()
  result.handle = Button()

proc draw*(slider: Slider) =
  let window = gui.currentWindow

  let path = Path.new()
  path.roundedRect(slider.position, slider.size, 3)
  window.fillPath(path, rgb(31, 32, 34))
  path.clear()

  let handle = slider.handle
  path.roundedRect(window.pixelAlign(handle.position), window.pixelAlign(handle.size), 3)
  window.fillPath(path, rgb(49, 51, 56).lighten(0.3))
  if handle.isDown:
    window.fillPath(path, rgba(0, 0, 0, 8))
  elif window.isHovered(handle):
    window.fillPath(path, rgba(255, 255, 255, 8))

proc update*(slider: Slider) =
  let window = gui.currentWindow

  let position = slider.position
  let size = slider.size
  let handleLength = slider.handleLength
  let minValue = slider.minValue
  let maxValue = slider.maxValue.max(minValue)
  var value = slider.value.clamp(minValue, maxValue)

  let handle = slider.handle
  handle.position = position + vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  handle.size = vec2(handleLength, size.y)

  handle.update()

  if handle.pressed or window.keyPressed(LeftControl) or window.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = window.globalMousePosition

  let sensitivity =
    if window.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = window.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handleLength)
    slider.value = value.clamp(minValue, maxValue)