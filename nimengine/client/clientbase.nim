include ./types

proc processMouseMoved(client: Client, x, y: float) =
  client.mouse.xPrevious = client.mouse.x
  client.mouse.yPrevious = client.mouse.y
  client.mouse.x = x
  client.mouse.y = y
  client.mouse.xChange = client.mouse.x - client.mouse.xPrevious
  client.mouse.yChange = client.mouse.y - client.mouse.yPrevious
  for listener in client.mouseMovedListeners:
    listener()

proc processMouseEntered(client: Client) =
  client.mouseIsOver = true
  for listener in client.mouseEnteredListeners:
    listener()

proc processMouseExited(client: Client) =
  client.mouseIsOver = false
  for listener in client.mouseExitedListeners:
    listener()

proc processMouseWheelScrolled(client: Client, x, y: float) =
  client.mouse.wheelX = x
  client.mouse.wheelY = y
  for listener in client.mouseWheelScrolledListeners:
    listener()

proc processMouseButtonPressed(client: Client, button: MouseButton) =
  client.mouse.press = button
  for listener in client.mouseButtonPressedListeners:
    listener()

proc processMouseButtonReleased(client: Client, button: MouseButton) =
  client.mouse.release = button
  for listener in client.mouseButtonReleasedListeners:
    listener()

proc processKeyboardKeyPressed(client: Client, key: KeyboardKey) =
  client.keyboard.press = key
  for listener in client.keyboardKeyPressedListeners:
    listener()

proc processKeyboardKeyReleased*(client: Client, key: KeyboardKey) =
  client.keyboard.release = key
  for listener in client.keyboardKeyReleasedListeners:
    listener()

proc processKeyboardCharacterInput(client: Client, character: string) =
  client.keyboard.character = character
  for listener in client.keyboardCharacterInputListeners:
    listener()

proc processClosed(client: Client) =
  for listener in client.closedListeners:
    listener()

proc processFocused(client: Client) =
  for listener in client.focusedListeners:
    listener()

proc processLostFocus(client: Client) =
  for listener in client.lostFocusListeners:
    listener()

proc processResized(client: Client, width, height: float) =
  client.widthPrevious = client.width
  client.heightPrevious = client.height
  client.width = width
  client.height = height
  client.widthChange = client.width - client.widthPrevious
  client.heightChange = client.height - client.heightPrevious
  for listener in client.resizedListeners:
    listener()

template delListener(listeners: seq[untyped], listenerToDelete: proc()): untyped =
  for listenerId in 0 ..< listeners.len:
    if listeners[listenerId] == listenerToDelete:
      listeners.del listenerId
      break

func addListener*(client: Client, kind: MouseEventKind, listener: proc()) =
  case kind:
  of MouseEventKind.Moved: client.mouseMovedListeners.add listener
  of MouseEventKind.EnteredClient: client.mouseEnteredListeners.add listener
  of MouseEventKind.ExitedClient: client.mouseExitedListeners.add listener
  of MouseEventKind.ButtonPressed: client.mouseButtonPressedListeners.add listener
  of MouseEventKind.ButtonReleased: client.mouseButtonReleasedListeners.add listener
  of MouseEventKind.WheelScrolled: client.mouseWheelScrolledListeners.add listener

func removeListener*(client: Client, kind: MouseEventKind, listener: proc()) =
  case kind:
  of MouseEventKind.Moved: client.mouseMovedListeners.delListener listener
  of MouseEventKind.EnteredClient: client.mouseEnteredListeners.delListener listener
  of MouseEventKind.ExitedClient: client.mouseExitedListeners.delListener listener
  of MouseEventKind.ButtonPressed: client.mouseButtonPressedListeners.delListener listener
  of MouseEventKind.ButtonReleased: client.mouseButtonReleasedListeners.delListener listener
  of MouseEventKind.WheelScrolled: client.mouseWheelScrolledListeners.delListener listener

func addListener*(client: Client, kind: KeyboardEventKind, listener: proc()) =
  case kind:
  of KeyboardEventKind.KeyPressed: client.keyboardKeyPressedListeners.add listener
  of KeyboardEventKind.KeyReleased: client.keyboardKeyReleasedListeners.add listener
  of KeyboardEventKind.CharacterInput: client.keyboardCharacterInputListeners.add listener

func removeListener*(client: Client, kind: KeyboardEventKind, listener: proc()) =
  case kind:
  of KeyboardEventKind.KeyPressed: client.keyboardKeyPressedListeners.delListener listener
  of KeyboardEventKind.KeyReleased: client.keyboardKeyReleasedListeners.delListener listener
  of KeyboardEventKind.CharacterInput: client.keyboardCharacterInputListeners.delListener listener

func addListener*(client: Client, kind: ClientEventKind, listener: proc()) =
  case kind:
  of ClientEventKind.Closed: client.closedListeners.add listener
  of ClientEventKind.Focused: client.focusedListeners.add listener
  of ClientEventKind.LostFocus: client.lostFocusListeners.add listener
  of ClientEventKind.Resized: client.resizedListeners.add listener

func removeListener*(client: Client, kind: ClientEventKind, listener: proc()) =
  case kind:
  of ClientEventKind.Closed: client.closedListeners.delListener listener
  of ClientEventKind.Focused: client.focusedListeners.delListener listener
  of ClientEventKind.LostFocus: client.lostFocusListeners.delListener listener
  of ClientEventKind.Resized: client.resizedListeners.delListener listener

func aspectRatio*(client: Client): float =
  client.width / client.height

func newDefaultClient(width, height: float): Client =
  Client(
    mouse: MouseState(),
    keyboard: KeyboardState(),
    width: width,
    height: height,
    widthPrevious: width,
    heightPrevious: height,
  )