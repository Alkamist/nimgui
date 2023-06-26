import ../gui
import ./button

type
  GuiSlider* = ref object of GuiState
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc slider*(gui: Gui, id: GuiId, position, size: Vec2, value: var float, minValue = 0.0, maxValue = 1.0): GuiSlider {.discardable.} =
  let slider = gui.getState(id, GuiSlider)
  if not slider.firstAccessThisFrame:
    return slider

  gui.pushId(slider.id)
  gui.pushOffset(position)

  let handleWidth = 16.0
  let handlePosition = vec2((size.x - handleWidth) * (value - minValue) / (maxValue - minValue), 0.0)
  let handleSize = vec2(handleWidth, size.y)
  let handle = gui.invisibleButton("SliderHandle", handlePosition, handleSize)

  if handle.pressed or gui.keyPressed(LeftControl) or gui.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = gui.globalMousePosition

  let sensitivity =
    if gui.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = gui.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (size.x - handleSize.x)

  if value > maxValue: value = maxValue
  if value < minValue: value = minValue

  gui.beginPath()
  gui.pathRoundedRect(vec2(0, 0), size, 3)
  gui.fillColor = rgb(31, 32, 34)
  gui.fill()

  template drawHandle(color: Color): untyped =
    gui.beginPath()
    gui.pathRoundedRect(gui.pixelAlign(handlePosition), handleSize, 3)
    gui.fillColor = color
    gui.fill()

  drawHandle(rgb(49, 51, 56).lighten(0.3))
  if handle.isDown:
    drawHandle(rgba(0, 0, 0, 8))
  elif gui.hover == handle.id:
    drawHandle(rgba(255, 255, 255, 8))

  gui.popOffset()
  gui.popId()

  slider

proc slider*(gui: Gui, id: string, position, size: Vec2, value: var float, minValue = 0.0, maxValue = 1.0): GuiSlider {.discardable.} =
  gui.slider(gui.getId(id), position, size, value, minValue, maxValue)