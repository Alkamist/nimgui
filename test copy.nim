{.experimental: "overloadableEnums".}

import nimgui

const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", consolaData)

# let window1 = gui.addWindow()
# let window2 = window1.body.addWindow()

# let headerButton = window2.header.addButton()
# headerButton.updateHook:
#   self.position = vec2(5, 5)
#   self.size = vec2(16, 16)

var txt = "abcdefghijklmnopqrstuvwxyz01234567890!@#$%^&*()-=_+"

gui.drawHook:
  let gfx = self.gui.gfx
  gfx.fontSize = 32
  # gfx.beginPath()
  # gfx.rect(self.mousePosition, vec2(50, 50))
  # gfx.fillColor = rgb(100, 200, 0)
  # gfx.fill()

  # let lineHeight = gfx.textMetrics.lineHeight
  # var nextX = self.mousePosition.x
  # var yOffset = 0.0
  # for i in 0 ..< 2000:
  #   nextX = gfx.drawText(vec2(nextX, self.mousePosition.y + yOffset), "WWWWWWWWWW")
  #   if nextX > self.width:
  #     nextX = 0.0
  #     yOffset += lineHeight
  #     if yOffset > self.height:
  #       break

  let metrics = gfx.textMetrics

  gfx.strokeColor = rgb(200, 100, 0)
  gfx.drawText(self.mousePosition, txt)

  let glyphs = gfx.glyphs(self.mousePosition, txt)
  for glyph in glyphs:
    gfx.beginPath()
    let position = vec2(glyph.minX, self.mousePosition.y - metrics.ascender)
    let size = vec2(glyph.width, metrics.lineHeight)
    gfx.rect(position - vec2(0.5, 0.5), size)
    gfx.strokeColor = rgb(0, 100, 0)
    gfx.stroke()

while gui.isOpen:
  gui.process()