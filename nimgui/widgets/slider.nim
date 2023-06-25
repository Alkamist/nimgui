import ../gui
import ./button

type
  GuiSlider* = ref object of GuiControl
    valueWhenHandleGrabbed: float
    globalMousePositionWhenHandleGrabbed: Vec2

proc slider*(gui: Gui, id: GuiId, position, size: Vec2, value: var float, minValue = 0.0, maxValue = 1.0) =
  let slider = gui.getState(id, GuiSlider)
  slider.position = position
  slider.size = size

  gui.pushId(slider.id)
  gui.pushOffset(slider.position)

  let handle = gui.getState("SliderHandle", GuiButton)
  handle.size = vec2(16, slider.size.y)
  gui.update(handle)

  if handle.pressed or gui.keyPressed(LeftControl) or gui.keyReleased(LeftControl):
    slider.valueWhenHandleGrabbed = value
    slider.globalMousePositionWhenHandleGrabbed = gui.globalMousePosition

  let sensitivity =
    if gui.keyDown(LeftControl): 0.15
    else: 1.0

  if handle.isDown:
    let grabDelta = gui.globalMousePosition.x - slider.globalMousePositionWhenHandleGrabbed.x
    value = slider.valueWhenHandleGrabbed + sensitivity * grabDelta * (maxValue - minValue) / (slider.size.x - handle.size.x)

  if value > maxValue: value = maxValue
  if value < minValue: value = minValue

  handle.position.x = (slider.size.x - handle.size.x) * (value - minValue) / (maxValue - minValue)

  gui.beginPath()
  gui.pathRoundedRect(vec2(0, 0), slider.size, 3)
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
  elif gui.hover == handle.id:
    drawHandle(rgba(255, 255, 255, 8))

  gui.popOffset()
  gui.popId()

proc slider*(gui: Gui, id: string, position, size: Vec2, value: var float, minValue = 0.0, maxValue = 1.0) =
  gui.slider(gui.getId(id), position, size, value, minValue, maxValue)