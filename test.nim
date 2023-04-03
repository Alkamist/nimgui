{.experimental: "overloadableEnums".}

import nimgui

const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", consolaData)

let window1 = gui.addWindow()
let window2 = window1.body.addWindow()

let headerButton = window2.header.addButton()
headerButton.updateHook:
  self.position = vec2(5, 5)
  self.size = vec2(16, 16)

let txt = window2.addText()
txt.data = "abcdefghijklmnopqrstuvwxyz01234567890!@#$%^&*()-=_+"
txt.size = vec2(500, 200)
txt.passInput = true

txt.updateHook:
  self.position = self.parent.mousePosition

txt.drawHook:
  let gfx = self.gui.gfx
  gfx.beginPath()
  gfx.rect(vec2(0, 0), self.size)
  gfx.strokeColor = rgb(0, 255, 0)
  gfx.stroke()

while gui.isOpen:
  gui.process()