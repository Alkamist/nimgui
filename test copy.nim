{.experimental: "overloadableEnums".}

import nimgui

const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(49, 51, 56)
gui.gfx.addFont("consola", consolaData)

let window1 = gui.addWindow()
window1.position = vec2(50, 50)
window1.size = vec2(500, 500)
window1.addTitle("Window 1")

let window2 = window1.body.addWindow()
window2.position = vec2(50, 50)
window2.size = vec2(400, 300)
window2.addTitle("Child Window")

let window3 = gui.addWindow()
window3.position = vec2(600, 50)
window3.size = vec2(500, 500)
window3.addTitle("Window 2")

let window4 = window3.body.addWindow()
window4.position = vec2(50, 50)
window4.size = vec2(400, 300)
window4.addTitle("Child Window")

let testButton = window4.body.addButton()
testButton.position = vec2(10, 10)
testButton.size = vec2(96, 22)
testButton.addLabel("Button")

let txt = window2.body.addText()
txt.data = "abcdefghijklmnopqrstuvwxyz01234567890!@#$%^&*()-=_+"
txt.alignX = Center
txt.alignY = Center
txt.size = vec2(500, 200)
txt.passInput = true

txt.updateHook:
  self.position = self.parent.mousePosition - 0.5 * self.size

txt.drawHook:
  let gfx = self.gui.gfx
  gfx.beginPath()
  gfx.rect(vec2(0, 0), self.size)
  gfx.strokeColor = rgb(0, 255, 0)
  gfx.stroke()

let delta = gui.addText()
delta.alignX = Left
delta.alignY = Baseline
delta.size = vec2(100, 100)
delta.passInput = true

gui.updateHook:
  delta.data = $self.deltaTime

# gui.updateHook:
#   if gui.mouseWheelJustMoved:
#     gui.osWindow.inputState.pixelDensity *= 2.0.pow(gui.mouseWheel.y * 0.2)

while gui.isOpen:
  gui.process()