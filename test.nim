{.experimental: "overloadableEnums".}

import nimgui

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

# proc testWindow(id: GuiId, position: Vec2) =
#   let layer = gui.beginLayer(id)
#   layer.position = position
#   layer.size = vec2(500, 500)

#   var gfx1 = layer.drawList
#   gfx1.beginPath()
#   gfx1.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
#   gfx1.fillColor = rgb(100, 0, 0)
#   gfx1.fill()

#   if layer.isHoveredIncludingChildren and gui.mouseJustPressed(Left):
#     layer.bringToTop()

#   discard gui.addButton("Button")

#   let layerChild = gui.beginLayer("LayerChild")
#   layerChild.position = vec2(50, 50)
#   layerChild.size = vec2(500, 500)

#   var gfx2 = layerChild.drawList
#   gfx2.beginPath()
#   gfx2.rect(rect2(vec2(0, 0), vec2(8000, 8000)))
#   gfx2.fillColor = rgb(0, 100, 0)
#   gfx2.fill()

#   discard gui.addButton("Button")

#   gui.endLayer()
#   gui.endLayer()

gui.onFrame:
  # testWindow("Test1", vec2(50, 50))
  # testWindow("Test2", vec2(500, 100))

  gui.window(window1):
    if window1.justCreated:
      window1.size = vec2(300, 200)
    # gui.window(window2):
    #   if window2.justCreated:
    #     window2.size = vec2(300, 200)

  gui.window(window3):
    if window3.justCreated:
      window3.position = vec2(0, 200)
      window3.size = vec2(300, 200)

while gui.isOpen:
  gui.update()