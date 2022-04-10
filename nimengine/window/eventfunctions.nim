import ./types

proc processMouseMove*(window: Window, x, y: float) =
  if window.mouseX == x and window.mouseY == y:
    return

  window.previousMouseX = window.mouseX
  window.previousMouseY = window.mouseY
  window.mouseX = x
  window.mouseY = y
  window.mouseXChange = window.mouseX - window.previousMouseX
  window.mouseYChange = window.mouseY - window.previousMouseY

  if window.onMouseMove != nil:
    window.onMouseMove(window)

proc processMouseEnter*(window: Window) =
  window.cursorIsOver = true
  if window.onMouseEnter != nil:
    window.onMouseEnter(window)

proc processMouseExit*(window: Window) =
  window.cursorIsOver = false
  if window.onMouseExit != nil:
    window.onMouseExit(window)

proc processMouseWheel*(window: Window, x, y: float) =
  window.mouseWheelX = x
  window.mouseWheelY = y
  if window.onMouseWheel != nil:
    window.onMouseWheel(window)

proc processMousePress*(window: Window, button: MouseButton) =
  window.mousePress = button
  window.mouseButtonStates[button] = true
  if window.onMousePress != nil:
    window.onMousePress(window)

proc processMouseRelease*(window: Window, button: MouseButton) =
  window.mouseRelease = button
  window.mouseButtonStates[button] = false
  if window.onMouseRelease != nil:
    window.onMouseRelease(window)

proc processKeyPress*(window: Window, key: KeyboardKey) =
  window.keyPress = key
  window.keyStates[key] = true
  if window.onKeyPress != nil:
    window.onKeyPress(window)

proc processKeyRelease*(window: Window, key: KeyboardKey) =
  window.keyRelease = key
  window.keyStates[key] = false
  if window.onKeyRelease != nil:
    window.onKeyRelease(window)

proc processCharacter*(window: Window, character: string) =
  window.character = character
  if window.onCharacter != nil:
    window.onCharacter(window)

proc processPaint*(window: Window) =
  if window.onPaint != nil:
    window.onPaint(window)

proc processClose*(window: Window) =
  if window.onClose != nil:
    window.onClose(window)

proc processFocus*(window: Window) =
  if window.onFocus != nil:
    window.onFocus(window)

proc processLoseFocus*(window: Window) =
  if window.onLoseFocus != nil:
    window.onLoseFocus(window)

proc processMove*(window: Window, x, y: float) =
  window.previousX = window.x
  window.previousY = window.y
  window.x = x
  window.y = y
  window.xChange = window.x - window.previousX
  window.yChange = window.y - window.previousY
  if window.onMove != nil:
    window.onMove(window)

proc processResize*(window: Window, width, height: float) =
  window.previousWidth = window.width
  window.previousHeight = window.height
  window.width = width
  window.height = height
  window.widthChange = window.width - window.previousWidth
  window.heightChange = window.height - window.previousHeight
  if window.onResize != nil:
    window.onResize(window)