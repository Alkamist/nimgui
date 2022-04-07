import ./types

func isPressed*(client: Client, key: KeyboardKey): bool =
  client.keyStates[key]

func isPressed*(client: Client, button: MouseButton): bool =
  client.mouseButtonStates[button]

func aspectRatio*(client: Client): float =
  client.width / client.height