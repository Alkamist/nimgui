import ../gui
import ./button

const handleLength = 16.0

type
  GuiSlider* = ref object of GuiControl
    position*: Vec2
    size*: Vec2
    handle*: GuiButton
    currentMinValue: float
    currentMaxValue: float
    currentValue: float
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc newSlider*(gui: Gui): GuiSlider =
  GuiSlider(
    gui: gui,
    handle: gui.newButton(),
  )

proc value*(slider: GuiSlider): float =
  slider.currentValue

proc `value=`*(slider: GuiSlider, value: float) =
  slider.currentValue = value.clamp(slider.currentMinValue, slider.currentMaxValue)

proc minValue*(slider: GuiSlider): float =
  slider.currentMinValue

proc `minValue=`*(slider: GuiSlider, minValue: float) =
  slider.currentMinValue = minValue
  if slider.currentMaxValue < minValue: slider.currentMaxValue = minValue
  if slider.currentValue < minValue: slider.currentValue = minValue

proc maxValue*(slider: GuiSlider): float =
  slider.currentMaxValue

proc `maxValue=`*(slider: GuiSlider, maxValue: float) =
  slider.currentMaxValue = maxValue
  if slider.currentMinValue > maxValue: slider.currentMinValue = maxValue
  if slider.currentValue > maxValue: slider.currentValue = maxValue

proc update*(slider: GuiSlider, invisible = false) =
  let gui = slider.gui
  let position = slider.position
  let size = slider.size
  let value = slider.value
  let minValue = slider.minValue
  let maxValue = slider.maxValue

  let handle = slider.handle
  handle.position = position + vec2((size.x - handleLength) * (value - minValue) / (maxValue - minValue), 0.0)
  handle.size = vec2(handleLength, size.y)
  handle.update()

  if handle.pressed or gui.keyPressed(LeftControl) or gui.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = gui.globalMousePosition

  let sensitivity =
    if gui.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = gui.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    slider.value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handle.size.x)

  if not invisible:
    gui.beginPath()
    gui.pathRoundedRect(position, size, 3)
    gui.fillColor = rgb(31, 32, 34)
    gui.fill()

    template drawHandle(color: Color): untyped =
      gui.beginPath()
      gui.pathRoundedRect(gui.pixelAlign(handle.position), handle.size, 3)
      gui.fillColor = color
      gui.fill()

    drawHandle(rgb(49, 51, 56).lighten(0.3))
    if handle.isDown:
      drawHandle(rgba(0, 0, 0, 8))
    elif gui.hover == handle:
      drawHandle(rgba(255, 255, 255, 8))