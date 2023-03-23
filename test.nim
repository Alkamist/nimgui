{.experimental: "overloadableEnums".}

# Drawing should all be done inside a method. If you need graphics make an empty widget.

import nimgui

const fontData = readFile("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", fontData)
gui.gfx.font = "consola"

gui.onFrame:
  # let w = gui.getWidget("Container 1", WidgetContainer(position: vec2(50, 50)))
  # gui.pushContainer w

  gui.beginWindow("Window 1")
  gui.beginWindow("Window 2")

  gui.button("Button 1")
  let button = gui.currentWidget(ButtonWidget)
  button.position = vec2(5, 30)
  button.size = vec2(100, 48)

  # let gfx = gui.gfx
  # gfx.beginPath()
  # gfx.circle(gui.osWindow.mousePosition, 50.0)
  # gfx.closePath()
  # gfx.strokeColor = rgb(255, 50, 50)
  # gfx.stroke()

  gui.endWindow()
  gui.endWindow()



while gui.isOpen:
  gui.update()