{.experimental: "overloadableEnums".}

import nimgui

let mainWindow = newOsWindow()
mainWindow.backgroundColor = rgb(13, 17, 23)

let renderer = newDrawListRenderer()
let drawList = newDrawList()

let rootWindow = newGuiWindow()
rootWindow.dontDraw = true

let childWindow = newGuiWindow()
childWindow.position = vec2(50, 50)
childWindow.size = vec2(500, 400)
let childChildWindow = newGuiWindow()
childChildWindow.position = vec2(50, 50)

rootWindow.childWindows.add childWindow
childWindow.childWindows.add childChildWindow

let childWindow2 = newGuiWindow()
childWindow2.position = vec2(600, 50)
childWindow2.size = vec2(500, 400)
let childChildWindow2 = newGuiWindow()
childChildWindow2.position = vec2(50, 50)

rootWindow.childWindows.add childWindow2
childWindow2.childWindows.add childChildWindow2





# Fix mouse presses








proc update(osWindow: OsWindow, rootWindow: GuiWindow) =
  # guiWindow.isFocused
  # guiWindow.isHovered
  rootWindow.inputState.pixelDensity = osWindow.inputState.pixelDensity
  rootWindow.inputState.bounds.position = vec2(0, 0)
  rootWindow.inputState.bounds.size = osWindow.inputState.bounds.size
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
  mainWindow.update(rootWindow)
  renderer.beginFrame(mainWindow.sizePixels, mainWindow.pixelDensity)
  drawList.clearCommands()

  rootWindow.update(drawList)

  renderer.render(drawList)
  renderer.endFrame(mainWindow.sizePixels)

while mainWindow.isOpen:
  mainWindow.update()