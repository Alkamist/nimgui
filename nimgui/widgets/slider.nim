import ../gui
import ./button

const handleLength = 16.0

type
  Slider* = ref object of GuiNode
    currentMinValue: float
    currentMaxValue: float
    currentValue: float
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc handle*(slider: Slider): Button =
  slider.getNode("Handle", Button)

proc value*(slider: Slider): float =
  slider.currentValue

proc `value=`*(slider: Slider, value: float) =
  slider.currentValue = value.clamp(slider.currentMinValue, slider.currentMaxValue)

proc minValue*(slider: Slider): float =
  slider.currentMinValue

proc `minValue=`*(slider: Slider, minValue: float) =
  slider.currentMinValue = minValue
  if slider.currentMaxValue < minValue: slider.currentMaxValue = minValue
  if slider.currentValue < minValue: slider.currentValue = minValue

proc maxValue*(slider: Slider): float =
  slider.currentMaxValue

proc `maxValue=`*(slider: Slider, maxValue: float) =
  slider.currentMaxValue = maxValue
  if slider.currentMinValue > maxValue: slider.currentMinValue = maxValue
  if slider.currentValue > maxValue: slider.currentValue = maxValue

proc setDefault*(slider: Slider) =
  slider.size = vec2(300, 24)
  slider.minValue = 0.0
  slider.maxValue = 1.0

proc getSlider*(node: GuiNode, name: string): Slider =
  result = node.getNode(name, Slider)
  if result.init:
    result.setDefault()

proc update*(slider: Slider, draw = true) =
  GuiNode(slider).update()

  let size = slider.size
  let value = slider.value
  let minValue = slider.minValue
  let maxValue = slider.maxValue

  let handle = slider.handle
  handle.position = vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  handle.size = vec2(handleLength, size.y)
  handle.update(draw = false)

  if handle.pressed or slider.keyPressed(LeftControl) or slider.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = slider.globalMousePosition

  let sensitivity =
    if slider.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = slider.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    slider.value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handle.size.x)

  if not draw:
    return

  let path = Path.new()
  path.roundedRect(vec2(0, 0), slider.size, 3)
  slider.fillPath(path, rgb(31, 32, 34))
  path.clear()

  path.roundedRect(vec2(0, 0), handle.size, 3)
  handle.fillPath(path, rgb(49, 51, 56).lighten(0.3))
  if handle.isDown:
    handle.fillPath(path, rgba(0, 0, 0, 8))
  elif handle.isHovered:
    handle.fillPath(path, rgba(255, 255, 255, 8))