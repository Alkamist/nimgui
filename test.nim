{.experimental: "overloadableEnums".}

# Figure out how to purge unused widgets from the table.

import nimgui

const fontData = readFile("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", fontData)
gui.gfx.font = "consola"

gui.onFrame:
  gui.window("Window 1"):
    gui.button("Button 1"):
      if button.justCreated:
        button.position = vec2(50, 50)
      if button.pressed:
        echo "Button 1 Pressed"
      if button.released:
        echo "Button 1 Released"

    gui.button("Button 2"):
      if button.justCreated:
        button.position = vec2(100, 100)
      if button.pressed:
        echo "Button 2 Pressed"
      if button.released:
        echo "Button 2 Released"

  gui.window("Window 2"):
    gui.button("Button 1"):
      if button.justCreated:
        button.position = vec2(50, 50)
      if button.pressed:
        echo "Button 1 Pressed"
      if button.released:
        echo "Button 1 Released"

    gui.button("Button 2"):
      if button.justCreated:
        button.position = vec2(100, 100)
      if button.pressed:
        echo "Button 2 Pressed"
      if button.released:
        echo "Button 2 Released"

  # gui.window("Window 1"):
  #   gui.button("Button 1"):
  #     if button.justCreated:
  #       button.position = vec2(50, 50)
  #     if button.pressed:
  #       echo "Button 1 Pressed"
  #     if button.released:
  #       echo "Button 1 Released"

  #   gui.button("Button 2"):
  #     if button.justCreated:
  #       button.position = vec2(100, 100)
  #     if button.pressed:
  #       echo "Button 2 Pressed"
  #     if button.released:
  #       echo "Button 2 Released"

  # let w = gui.getWidget("Container 1", WidgetContainer(position: vec2(50, 50)))
  # gui.pushContainer w

  # gui.beginWindow("Window 1")
  # gui.beginWindow("Window 2")

  # let b = gui.button("Button 1")
  # b.position = vec2(50, 50)
  # b.size = vec2(100, 48)

  # let gfx = gui.gfx
  # gfx.beginPath()
  # gfx.circle(gui.osWindow.mousePosition, 50.0)
  # gfx.closePath()
  # gfx.strokeColor = rgb(255, 50, 50)
  # gfx.stroke()

  # gui.endWindow()
  # gui.endWindow()

while gui.isOpen:
  gui.update()