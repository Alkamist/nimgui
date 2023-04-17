import ./guimod
import oswindow

proc implOsWindow*(gui: Gui, guiWindow: OsWindow) =
  if gui.justCreated:
    let c = gui.backgroundColor
    guiWindow.setBackgroundColor(c.r, c.g, c.b, c.a)

  gui.position = vec2(0, 0)
  gui.size = vec2(guiWindow.widthPixels.float, guiWindow.heightPixels.float) / guiWindow.pixelDensity
  gui.mousePosition = vec2(guiWindow.mouseX, guiWindow.mouseY) - gui.position
  gui.mouseDelta = vec2(guiWindow.mouseDeltaX, guiWindow.mouseDeltaY)
  gui.time = guiWindow.time
  gui.mouseWheel = vec2(guiWindow.mouseWheelX, guiWindow.mouseWheelY)
  gui.mousePresses = cast[seq[guimod.MouseButton]](guiWindow.mousePresses)
  gui.mouseReleases = cast[seq[guimod.MouseButton]](guiWindow.mouseReleases)
  gui.mouseDownStates = cast[array[guimod.MouseButton, bool]](guiWindow.state.mouseDownStates)
  gui.keyPresses = cast[seq[guimod.KeyboardKey]](guiWindow.keyPresses)
  gui.keyReleases = cast[seq[guimod.KeyboardKey]](guiWindow.keyReleases)
  gui.keyDownStates = cast[array[guimod.KeyboardKey, bool]](guiWindow.state.keyDownStates)
  gui.textInput = guiWindow.textInput
  gui.process(guiWindow.widthPixels, guiWindow.heightPixels, guiWindow.pixelDensity)

  if gui.mouseCursorStyleChanged:
    guiWindow.setMouseCursorStyle(cast[oswindow.MouseCursorStyle](gui.mouseCursorStyle))

  if gui.backgroundColorChanged:
    let c = gui.backgroundColor
    guiWindow.setBackgroundColor(c.r, c.g, c.b, c.a)