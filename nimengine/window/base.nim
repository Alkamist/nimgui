import ./types

proc processMouseMove*(window: Window, x, y: float) =
  let input = window.input
  if input.mouseX == x and input.mouseY == y:
    return
  input.mouseX = x
  input.mouseY = y
  if window.onMouseMove != nil:
    window.onMouseMove()

proc processMouseEnter*(window: Window) =
  window.cursorIsOver = true
  if window.onMouseEnter != nil:
    window.onMouseEnter()

proc processMouseExit*(window: Window) =
  window.cursorIsOver = false
  if window.onMouseExit != nil:
    window.onMouseExit()

proc processMouseWheel*(window: Window, x, y: float) =
  let input = window.input
  input.mouseWheelX = x
  input.mouseWheelY = y
  if window.onMouseWheel != nil:
    window.onMouseWheel()

proc processMousePress*(window: Window, button: MouseButton) =
  let input = window.input
  input.lastMousePress = button
  input.mouseButtonStates[button] = true
  if window.onMousePress != nil:
    window.onMousePress()

proc processMouseRelease*(window: Window, button: MouseButton) =
  let input = window.input
  input.lastMouseRelease = button
  input.mouseButtonStates[button] = false
  if window.onMouseRelease != nil:
    window.onMouseRelease()

proc processKeyPress*(window: Window, key: KeyboardKey) =
  let input = window.input
  input.lastKeyPress = key
  input.keyStates[key] = true
  if window.onKeyPress != nil:
    window.onKeyPress()

proc processKeyRelease*(window: Window, key: KeyboardKey) =
  let input = window.input
  input.lastKeyRelease = key
  input.keyStates[key] = false
  if window.onKeyRelease != nil:
    window.onKeyRelease()

proc processCharacter*(window: Window, character: string) =
  let input = window.input
  input.text &= character
  if window.onCharacter != nil:
    window.onCharacter()

proc processClose*(window: Window) =
  if window.onClose != nil:
    window.onClose()

proc processFocus*(window: Window) =
  if window.onFocus != nil:
    window.onFocus()

proc processLoseFocus*(window: Window) =
  if window.onLoseFocus != nil:
    window.onLoseFocus()

proc processMove*(window: Window, x, y: float) =
  window.previousX = window.x
  window.previousY = window.y
  window.x = x
  window.y = y
  window.xChange = window.x - window.previousX
  window.yChange = window.y - window.previousY
  if window.onMove != nil:
    window.onMove()

proc processResize*(window: Window, width, height: float) =
  window.previousWidth = window.width
  window.previousHeight = window.height
  window.width = width
  window.height = height
  window.widthChange = window.width - window.previousWidth
  window.heightChange = window.height - window.previousHeight
  window.input.windowHeight = window.height

  if window.onResize != nil:
    window.onResize()

  if window.renderer != nil:
    window.renderer.render(window.width.int, window.height.int)