import ./types

func newDefaultClient*(width, height: float): Client =
  Client(
    width: width,
    height: height,
    widthPrevious: width,
    heightPrevious: height,
  )

proc processMouseMove*(client: Client, x, y: float) =
  if client.mouseX == x and client.mouseY == y:
    return

  client.previousMouseX = client.mouseX
  client.previousMouseY = client.mouseY
  client.mouseX = x
  client.mouseY = y
  client.mouseXChange = client.mouseX - client.previousMouseX
  client.mouseYChange = client.mouseY - client.previousMouseY

  if client.onMouseMove != nil:
    client.onMouseMove(client)

proc processMouseEnter*(client: Client) =
  client.mouseIsOver = true
  if client.onMouseEnter != nil:
    client.onMouseEnter(client)

proc processMouseExit*(client: Client) =
  client.mouseIsOver = false
  if client.onMouseExit != nil:
    client.onMouseExit(client)

proc processMouseWheel*(client: Client, x, y: float) =
  client.mouseWheelX = x
  client.mouseWheelY = y
  if client.onMouseWheel != nil:
    client.onMouseWheel(client)

proc processMousePress*(client: Client, button: MouseButton) =
  client.mousePress = button
  client.mouseButtonStates[button] = true
  if client.onMousePress != nil:
    client.onMousePress(client)

proc processMouseRelease*(client: Client, button: MouseButton) =
  client.mouseRelease = button
  client.mouseButtonStates[button] = false
  if client.onMouseRelease != nil:
    client.onMouseRelease(client)

proc processKeyPress*(client: Client, key: KeyboardKey) =
  client.keyPress = key
  client.keyStates[key] = true
  if client.onKeyPress != nil:
    client.onKeyPress(client)

proc processKeyRelease*(client: Client, key: KeyboardKey) =
  client.keyRelease = key
  client.keyStates[key] = false
  if client.onKeyRelease != nil:
    client.onKeyRelease(client)

proc processCharacter*(client: Client, character: string) =
  client.character = character
  if client.onCharacter != nil:
    client.onCharacter(client)

proc processClose*(client: Client) =
  if client.onClose != nil:
    client.onClose(client)

proc processFocus*(client: Client) =
  if client.onFocus != nil:
    client.onFocus(client)

proc processLoseFocus*(client: Client) =
  if client.onLoseFocus != nil:
    client.onLoseFocus(client)

proc processResize*(client: Client, width, height: float) =
  client.widthPrevious = client.width
  client.heightPrevious = client.height
  client.width = width
  client.height = height
  client.widthChange = client.width - client.widthPrevious
  client.heightChange = client.height - client.heightPrevious
  if client.onResize != nil:
    client.onResize(client)