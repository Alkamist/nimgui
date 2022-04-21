import ./types

proc processMouseMove*(self: Window, x, y: float) =
  if self.mouseX == x and self.mouseY == y:
    return

  self.previousMouseX = self.mouseX
  self.previousMouseY = self.mouseY
  self.mouseX = x
  self.mouseY = y
  self.mouseXChange = self.mouseX - self.previousMouseX
  self.mouseYChange = self.mouseY - self.previousMouseY

  if self.onMouseMove != nil:
    self.onMouseMove()

proc processMouseEnter*(self: Window) =
  self.cursorIsOver = true
  if self.onMouseEnter != nil:
    self.onMouseEnter()

proc processMouseExit*(self: Window) =
  self.cursorIsOver = false
  if self.onMouseExit != nil:
    self.onMouseExit()

proc processMouseWheel*(self: Window, x, y: float) =
  self.mouseWheelX = x
  self.mouseWheelY = y
  if self.onMouseWheel != nil:
    self.onMouseWheel()

proc processMousePress*(self: Window, button: MouseButton) =
  self.mousePress = button
  self.mouseButtonStates[button] = true
  if self.onMousePress != nil:
    self.onMousePress()

proc processMouseRelease*(self: Window, button: MouseButton) =
  self.mouseRelease = button
  self.mouseButtonStates[button] = false
  if self.onMouseRelease != nil:
    self.onMouseRelease()

proc processKeyPress*(self: Window, key: KeyboardKey) =
  self.keyPress = key
  self.keyStates[key] = true
  if self.onKeyPress != nil:
    self.onKeyPress()

proc processKeyRelease*(self: Window, key: KeyboardKey) =
  self.keyRelease = key
  self.keyStates[key] = false
  if self.onKeyRelease != nil:
    self.onKeyRelease()

proc processCharacter*(self: Window, character: string) =
  self.character = character
  if self.onCharacter != nil:
    self.onCharacter()

proc processClose*(self: Window) =
  if self.onClose != nil:
    self.onClose()

proc processFocus*(self: Window) =
  if self.onFocus != nil:
    self.onFocus()

proc processLoseFocus*(self: Window) =
  if self.onLoseFocus != nil:
    self.onLoseFocus()

proc processMove*(self: Window, x, y: float) =
  self.previousX = self.x
  self.previousY = self.y
  self.x = x
  self.y = y
  self.xChange = self.x - self.previousX
  self.yChange = self.y - self.previousY
  if self.onMove != nil:
    self.onMove()

proc processResize*(self: Window, width, height: float) =
  self.previousWidth = self.width
  self.previousHeight = self.height
  self.width = width
  self.height = height
  self.widthChange = self.width - self.previousWidth
  self.heightChange = self.height - self.previousHeight

  if self.onResize != nil:
    self.onResize()

  if self.renderer != nil:
    self.renderer.render(self.width.int, self.height.int)