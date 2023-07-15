import ../gui
import ./button

type
  Slider* = ref object
    position*: Vec2
    size*: Vec2
    value*: float
    minValue*: float
    maxValue*: float
    handleLength*: float
    handle*: Button
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc new*(_: typedesc[Slider]): Slider =
  result = Slider()
  result.handle = Button.new()
  result.size = vec2(300, 24)
  result.minValue = 0.0
  result.maxValue = 1.0
  result.handleLength = 16.0

proc draw*(slider: Slider, gui: Gui) =
  let path = Path.new()
  path.roundedRect(slider.position, slider.size, 3)
  gui.fillPath(path, rgb(31, 32, 34))
  path.clear()

  let handle = slider.handle
  path.roundedRect(gui.pixelAlign(handle.position), gui.pixelAlign(handle.size), 3)
  gui.fillPath(path, rgb(49, 51, 56).lighten(0.3))
  if handle.isDown:
    gui.fillPath(path, rgba(0, 0, 0, 8))
  elif handle.isHovered(gui):
    gui.fillPath(path, rgba(255, 255, 255, 8))

proc update*(slider: Slider, gui: Gui) =
  let position = slider.position
  let size = slider.size
  let handleLength = slider.handleLength
  let minValue = slider.minValue
  let maxValue = slider.maxValue.max(minValue)
  var value = slider.value.clamp(minValue, maxValue)

  let handle = slider.handle
  handle.position = position + vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  handle.size = vec2(handleLength, size.y)

  handle.update(gui)

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