{.experimental: "overloadableEnums".}

import nimgui

let mainWindow = newOsWindow()
mainWindow.backgroundColor = rgb(13, 17, 23)

let renderer = newDrawListRenderer()
let drawList = newDrawList()

let rootWindow = newGuiWindow()
rootWindow.isRoot = true
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

mainWindow.onFrame = proc() =
  rootWindow.inputState.isHovered = mainWindow.inputState.isHovered
  rootWindow.inputState.pixelDensity = mainWindow.inputState.pixelDensity
  rootWindow.inputState.position = vec2(0, 0)
  rootWindow.inputState.size = mainWindow.inputState.size
  rootWindow.inputState.mousePosition = mainWindow.inputState.mousePosition
  rootWindow.inputState.mouseWheel = mainWindow.inputState.mouseWheel
  rootWindow.inputState.mousePresses = mainWindow.inputState.mousePresses
  rootWindow.inputState.mouseReleases = mainWindow.inputState.mouseReleases
  rootWindow.inputState.mouseIsDown = mainWindow.inputState.mouseIsDown
  rootWindow.inputState.keyPresses = mainWindow.inputState.keyPresses
  rootWindow.inputState.keyReleases = mainWindow.inputState.keyReleases
  rootWindow.inputState.keyIsDown = mainWindow.inputState.keyIsDown
  rootWindow.inputState.text = mainWindow.inputState.text

  renderer.beginFrame(mainWindow.sizePixels, mainWindow.pixelDensity)
  drawList.clearCommands()
  rootWindow.update(drawList)
  renderer.render(drawList)
  renderer.endFrame(mainWindow.sizePixels)

while mainWindow.isOpen:
  mainWindow.update()