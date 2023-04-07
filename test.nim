{.experimental: "overloadableEnums".}

import nimgui

const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(49, 51, 56)
# gui.backgroundColor = rgb(255, 255, 255)
gui.gfx.addFont("consola", consolaData)

let window1 = gui.addWindow()
window1.position = vec2(50, 50)
window1.size = vec2(500, 500)
let window2 = window1.body.addWindow()
window2.position = vec2(50, 50)
window2.size = vec2(400, 300)

let window3 = gui.addWindow()
window3.position = vec2(600, 50)
window3.size = vec2(500, 500)
let window4 = window3.body.addWindow()
window4.position = vec2(50, 50)
window4.size = vec2(400, 300)

let testButton = window4.body.addButton()
testButton.position = vec2(10, 10)
testButton.size = vec2(96, 24)

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

while gui.isOpen:
  gui.process()