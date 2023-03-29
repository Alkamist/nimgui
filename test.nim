{.experimental: "overloadableEnums".}

import nimgui

let mainWindow = newOsWindow()
mainWindow.backgroundColor = rgb(13, 17, 23)

let renderer = newDrawListRenderer()

let rootWindow = newGuiWindow()

proc updateRootWindow(osWindow: OsWindow, rootWindow: GuiWindow) =
  # guiWindow.isFocused
  # guiWindow.isHovered
  rootWindow.inputState.pixelDensity = osWindow.inputState.pixelDensity
  # rootWindow.inputState.bounds.position = vec2(0, 0)
  # rootWindow.inputState.bounds.size = osWindow.inputState.bounds.size
  rootWindow.inputState.mousePosition = osWindow.inputState.mousePosition
  rootWindow.inputState.mouseWheel = osWindow.inputState.mouseWheel
  rootWindow.inputState.mousePresses = osWindow.inputState.mousePresses
  rootWindow.inputState.mouseReleases = osWindow.inputState.mouseReleases
  rootWindow.inputState.mouseDown = osWindow.inputState.mouseDown
  rootWindow.inputState.keyPresses = osWindow.inputState.keyPresses
  rootWindow.inputState.keyReleases = osWindow.inputState.keyReleases
  rootWindow.inputState.keyDown = osWindow.inputState.keyDown
  rootWindow.inputState.text = osWindow.inputState.text

mainWindow.onFrame = proc() =
  mainWindow.updateRootWindow(rootWindow)
  renderer.beginFrame(mainWindow.sizePixels, mainWindow.pixelDensity)
  rootWindow.beginFrame()
  renderer.render(rootWindow.drawList)
  rootWindow.endFrame()
  renderer.endFrame(mainWindow.sizePixels)

while mainWindow.isOpen:
  mainWindow.update()